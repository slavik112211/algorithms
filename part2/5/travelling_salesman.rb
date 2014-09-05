# require 'memory_profiler'
# require 'byebug'
# require 'gc_tracer'
require 'debugger'
=begin
  What is the difference between Travelling Salesman and finding Shortest Path?
  the TSP is to find a path that contains a permutation of every node in the graph, 
  while in the shortest path problem, any given shortest path may, and often does, 
  contain a proper subset of the nodes in the graph.

  Other differences include:

    The TSP solution requires its answer to be a cycle.
    The TSP solution will necessarily repeat a node in its path, while a shortest 
      path will not (unless one is looking for shortest path from a node to itself).
    TSP is an NP-complete problem and shortest path is known polynomial-time.

  The TSP requires one to find the simple cycle covering every node in the graph 
  with the smallest weight (alternatively, the Hamilton cycle with the least weight). 
  The Shortest Path problem requires one to find the path between two given nodes 
  with the smallest weight. Shortest paths need not be Hamiltonian, nor do they need to be cycles.

  What complicates the problem immensely is having to find a path that visits all nodes, 
  rather than having to return to the starting node (e.g. see 'Hamilton path', which is 
  also NP-complete, but doesn't require finding a cycle).

  gnuplot: plot "tsp.txt"
  /media/ntfs/jruby-1.7.15/bin/jruby -J-Xmx1900m -J-verbose:gc travelling_salesman.rb

  http://en.wikipedia.org/wiki/User:LIU_CS_MUN/draft_of_the_page_for_Held-Karp_algorithm
=end

class TravellingSalesman
  attr_reader :distances, :points_subsets, :points_amount, :solution, :optimal_path
  # The first line indicates the number of cities. Each city is a point in the plane, and 
  # each subsequent line indicates the x- and y-coordinates of a single city.
  # The distance between two cities is defined as the Euclidean distance. 
  # That is, two cities at locations (x,y) and (z,w) have distance sqrt( (x−z)^2+(y−w)^2 ) between them. 
  def initialize file_name
    File.open(file_name, 'r').each_line.with_index { |line, index|
      line = line.split(" ")
      if index == 0
        @points_amount = line[1].to_i
        @distances = Hash.new{|h, k| h[k] = []}
        @points    = Hash.new{|h, k| h[k] = []} # x,y point coordinates
        next
      end
      @points[index-1][0] = line[0].to_f
      @points[index-1][1] = line[1].to_f
    }

    (0..@points.length-1).each do |i|
      (0..i).each do |j|
        @distances[i][j] = Math.sqrt((@points[i][0] - @points[j][0])**2 + (@points[i][1] - @points[j][1])**2)
        @distances[j][i] = @distances[i][j]
      end
    end
  end

  def distances_to_csv
    File.open('distances.csv','w'){ |f| f << @distances.map{ |row| row.join(',') }.join("\n") }
  end

  # http://en.wikipedia.org/wiki/User:LIU_CS_MUN/draft_of_the_page_for_Held-Karp_algorithm
  def held_karp_algorithm
    puts "Calculating optimal path by Held-Karp algorithm"
    # 2-dim arrays indexed by points-subset S and destination point j
    @subsolutions_path_lengths = Hash.new{|h, k| h[k] = Hash.new }
    @subsolutions_path_points  = Hash.new{|h, k| h[k] = Hash.new }
    @subsolutions_path_lengths[1][1] = 0

    (2..@points_amount).each do |subset_size|
      subsets = @points_subsets[subset_size]
      puts "Subset size: " + subset_size.to_s + "; Subsets total: " + subsets.size.to_s
      i = 1
      subsets.each do |subset|
        if i%10000 == 0 then p i; time_elapsed end; i += 1 # debug info
        points_of_subset = points_of_subset_fast(subset, {omit_first: true})
        points_of_subset.each do |j| # j - destination point
          subset_without_j = TravellingSalesman.find_subset_minus_point_fast(subset, j)
          optimal_path = find_optimal_path_from_subset_to_destination_point(subset_without_j, j)

          @subsolutions_path_lengths[subset][j] = optimal_path[:path_length]
          @subsolutions_path_points [subset][j] = optimal_path[:prev_point]
          optimal_path = nil
        end
      end
      remove_subsolutions_of_size(subset_size-1)
      GC.start
    end
    #Last hop of the path - after visiting all points, calculating the shortest return path to point 1.
    #Subset = a complete set of all points, for ex. "11111", destination point - 1st.
    @complete_points_set = @points_subsets[@points_subsets.keys.last].first
    @solution = find_optimal_path_from_subset_to_destination_point(@complete_points_set, 1)
  end

  def find_optimal_path_from_subset_to_destination_point subset_without_j, j
    optimal_path_length = Float::INFINITY
    optimal_path = Hash.new
    @subsolutions_path_lengths[subset_without_j].keys.each do |k| # k - destination point in subset "subset_without_j"
      path_length = @subsolutions_path_lengths[subset_without_j][k] + @distances[k-1][j-1] # @distances is a 2-dim array, indexes start from 0
      if path_length < optimal_path_length
        optimal_path_length = path_length
        optimal_path[:prev_point]  = k
        optimal_path[:path_length] = optimal_path_length
      end
    end
    optimal_path
  end

  def reconstruct_optimal_path
    puts "Reconstructing optimal path"
    @optimal_path = [1]
    subset = @complete_points_set
    point = @solution[:prev_point]

    begin
      @optimal_path << point
      smaller_subset = TravellingSalesman.find_subset_minus_point_fast(subset, point)
      point = @subsolutions_path_points[subset][point]
      subset = smaller_subset
    end while point

    #As the path was reconstructed last-to-first point visited, it has to be reversed.
    @optimal_path.reverse!
  end

  def remove_subsolutions_of_size size
    puts "Removing subsolutions of size: " + size.to_s
    @points_subsets[size].each { |subset|
      @subsolutions_path_lengths[subset] = nil
      @subsolutions_path_lengths.delete(subset)
    }
    @points_subsets[size] = nil
    @points_subsets.delete(size)
    time_elapsed
  end

  # every subset of points is represented as a binary string.
  # For ex., 10011: points 1, 2, 5 are included in subset, and 3, 4 are not. (counting from right to left)
  # 10011 binary = 19 decimal
  def find_subsets_of_points(options={})
    puts "Calculating subsets"
    puts "Set of #{@points_amount} points: 2^#{@points_amount} subsets = #{2**@points_amount} different subsets"
    @points_subsets = Hash.new{|h, k| h[k] = []}
    # amount of all subsets of a set 2^n-1 (-1, as we're excluding empty set {})
    (1..2**@points.length-1).each { |i|
      p i if i%100000 == 0
      subset_size = i.to_s(2).count("1")
      subset_size = subset_size_fast i
      if (options[:with_first_point_only] != true) || (options[:with_first_point_only] == true and i % 2 == 1)
        @points_subsets[subset_size] << i
      end
    }

    (2..@points_amount).each do |subset_size|
      subsets = @points_subsets[subset_size]
      puts "Subset size: " + subset_size.to_s + "; Subsets total: " + subsets.size.to_s
    end

    puts "Done calculating subsets"
  end

  # Subset "01101" (in binary, 13 in decimal) contains 3 points out of 5: 1st, 3rd, 4th.
  def self.filter_subsets_containing_first_point subsets
    subsets.select {|subset| subset.to_s(2)[-1,1] == "1" }
  end

  # Subset "01101" (in binary, 13 in decimal) contains 3 points out of 5: 1st, 3rd, 4th.
  # As 1st point is always represented by "1" in both decimal and binary, it's sufficient to filter
  # subsets that are represented by odd numbers.
  def self.filter_subsets_containing_first_point_fast subsets
    subsets.select {|subset| subset % 2 == 1 }
  end

  # 27 decimal = 11011 binary, counting right to left:
  # 1st (excluded), 2nd, 4th, 5th.
  def self.points_of_subset subset
    subset = subset.to_s(2).split("")
    subset.pop # skip 1st point
    points_of_subset = []
    i = 2 # starting from 2, as we have skipped the first point
    while point = subset.pop
      points_of_subset << i if point.to_i == 1
      i += 1
    end
    points_of_subset
  end

  # 27 decimal = 11011 binary, counting right to left:
  # 1st (excluded), 2nd, 4th, 5th.
  def self.simple_points_of_subset subset
    subset = subset.to_s(2)
    (2 ... subset.length+1).find_all { |i| subset[-i,1] == '1' }
  end

  #27 = 11011, counting right to left: 1st, 2nd, 4th, 5th.
  #11011 - 4th point = 10011 = 19, or a set of 1st, 2nd and 5th points.
  def self.find_subset_minus_point(subset, point)
    subset = subset.to_s(2)
    subset[-point] = "0"
    subset.to_i(2)
  end

  # 27 = 11011, counting right to left: 1st, 2nd, 4th, 5th.
  # 11011 - 4th point = 10011 = 19, or a set of 1st, 2nd and 5th points.
  # CORRECT ONLY WHEN a subset has that point (point position set to 1),
  # otherwise bitwise & would need to be used
  def self.find_subset_minus_point_fast subset, point
    subset - 2**(point-1)
  end

  def subset_size_fast subset
    points_of_subset_fast(subset).size
  end

  # bitwise AND is used to determine if incoming subset has a specific bit set:
  # points_of_subset <<  4 if (subset & 0b00000_00000_00000_00000_01000 == 0b00000_00000_00000_00000_01000)
  def points_of_subset_fast subset, options={}
    points_of_subset = []
    lower_range_bound = options[:omit_first] ? 2 : 1
    power = 1; while (2**power <= subset) do power +=1 end

    (lower_range_bound .. power).each do |i|
      points_of_subset << i if (subset & 2**(i-1) == 2**(i-1))
    end
    points_of_subset
  end

  def time_elapsed
    time = Time.now.to_f
    diff = time - @start_time
    puts "start_time: #{@start_time}; finish: #{time}; diff: #{diff}"
  end

  def calculate_optimal_path
    @start_time = Time.now.to_f

    find_subsets_of_points({:with_first_point_only=>true})
    time_elapsed
    held_karp_algorithm
    time_elapsed
    reconstruct_optimal_path
    time_elapsed

    puts "Optimal solution: " + @solution.to_s
    puts "Optimal path: " + @optimal_path.to_s
  end
end

 tsp = TravellingSalesman.new("tsp.txt")

# GC::Profiler.enable
# report = MemoryProfiler.report do
 tsp.calculate_optimal_path
# end
# puts GC::Profiler.result

# report.pretty_print

# GC::Tracer.start_logging("gc_tracer.csv") do
#   tsp.calculate_optimal_path
# end
