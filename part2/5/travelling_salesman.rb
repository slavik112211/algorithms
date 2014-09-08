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
        @distances = Array.new(@points_amount) { Array.new(@points_amount) } # distances matrix
        @points    = Array.new(@points_amount) { Array.new(2) }# x,y point coordinates
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
    @subsolutions_path_lengths_1 = Array.new(1) { Array.new(1,0) }
    @subsolutions_path_lengths_2 = Array.new
    @subsolutions_path_points    = Array.new
    subset_index_general = 0 # index of a subset amongst all subsets of all sizes

    (2..@points_amount).each do |subset_size|
      exit if subset_size > 8
      subsets = @points_subsets[subset_size-1]
      puts "Subset size: " + subset_size.to_s + "; Subsets total: " + subsets.size.to_s
      subset_index = 0 # index of a subset in an array of subsets of equal size
      subsets.each do |subset|
        if subset_index%10000 == 0 then p subset_index; time_elapsed end; # debug info
        points_of_subset = points_of_subset_fast(subset, {omit_first: true})
        points_of_subset.each.with_index do |j, j_index| # j - destination point
          subset_without_j = TravellingSalesman.find_subset_minus_point_fast(subset, j)
          optimal_path = find_optimal_path_from_subset_to_destination_point(subset_without_j, j)

          prepare_2d_array(@subsolutions_path_lengths_2, subset_index)
          prepare_2d_array(@subsolutions_path_points,    subset_index_general)
          @subsolutions_path_lengths_2[subset_index]        [j_index] = optimal_path[0]
          @subsolutions_path_points   [subset_index_general][j_index] = optimal_path[1]
          optimal_path = nil
        end
        subset_index += 1
        subset_index_general += 1
      end

      empty_2d_array(@subsolutions_path_lengths_1)
      remove_leftover_empty_arrays(@subsolutions_path_lengths_2)
      copy_2d_array(@subsolutions_path_lengths_1, @subsolutions_path_lengths_2)
      empty_2d_array(@subsolutions_path_lengths_2)
      GC.start
    end
    #Last hop of the path - after visiting all points, calculating the shortest return path to point 1.
    #Subset = a complete set of all points, for ex. "11111", destination point - 1st.
    @complete_points_set = @points_subsets.last.first
    @solution = find_optimal_path_from_subset_to_destination_point(@complete_points_set, 1)
  end

  def prepare_2d_array(array, i)
    array[i] ||= Array.new
  end

  def empty_2d_array(array)
    array.each do |subarray|
      subarray.map! do |element| nil end
      subarray.compact!
    end
  end

  def copy_2d_array(array1, array2)
    (0..array2.length-1).each do |i|
      prepare_2d_array(array1, i)
      (0..array2[i].length-1).each do |j|
        array1[i][j] = array2[i][j] 
      end
    end
  end

  def remove_leftover_empty_arrays(array)
    i = -1
    while array[i].empty?
      array[i] = nil
      i -= 1
    end
    array.compact!
  end

  def find_optimal_path_from_subset_to_destination_point subset_without_j, j
    optimal_path_length = Float::INFINITY
    optimal_path = Array.new
    index = find_index_of_subset(subset_without_j)
    points_of_subset = points_of_subset_fast(subset_without_j, {omit_first: true})
    @subsolutions_path_lengths_1[index].each.with_index do |distance_to_k, k_index|
      # k - destination point in subset "subset_without_j"
      k = points_of_subset.empty? ? 1 : points_of_subset[k_index]
      path_length = distance_to_k + @distances[k-1][j-1]
      if path_length < optimal_path_length
        optimal_path_length = path_length
        optimal_path[0] = optimal_path_length
        optimal_path[1]  = k
      end
    end
    optimal_path
  end

  def find_index_of_subset subset
    subset_size = subset_size_fast(subset)
    @points_subsets[subset_size-1].index(subset)
  end

  def reconstruct_optimal_path
    puts "Reconstructing optimal path"
    @optimal_path = [1]
    subset = @complete_points_set
    point = @solution[1]
    @points_subsets_flattened = @points_subsets.flatten

    begin
      @optimal_path << point
      smaller_subset = TravellingSalesman.find_subset_minus_point_fast(subset, point)
      subset_index = @points_subsets_flattened.index(subset) - 1
      points_of_subset = points_of_subset_fast(subset, {omit_first: true})
      point_index = points_of_subset.index(point)
      point = point_index.nil? ? nil : @subsolutions_path_points[subset_index][point_index]
      subset = smaller_subset
    end while point

    #As the path was reconstructed last-to-first point visited, it has to be reversed.
    @optimal_path.reverse!
  end

  # every subset of points is represented as a binary string.
  # For ex., 10011: points 1, 2, 5 are included in subset, and 3, 4 are not. (counting from right to left)
  # 10011 binary = 19 decimal
  def find_subsets_of_points(options={})
    puts "Calculating subsets"
    puts "Set of #{@points_amount} points: 2^#{@points_amount} subsets = #{2**@points_amount} different subsets"
    @points_subsets = Array.new(@points_amount) { Array.new }
    # amount of all subsets of a set 2^n-1 (-1, as we're excluding the empty set {})
    (1..2**@points.length-1).each { |i|
      p i if i%100000 == 0
      subset_size = subset_size(i)
      if (options[:with_first_point_only] != true) || (options[:with_first_point_only] == true and i % 2 == 1)
        @points_subsets[subset_size-1] << i
      end
    }

    (2..@points_amount).each do |subset_size|
      subsets = @points_subsets[subset_size-1]
      puts "Subset size: " + subset_size.to_s + "; Subsets total: " + subsets.size.to_s
    end

    puts "Done calculating subsets"
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
  def points_of_subset_simple subset
    subset = subset.to_s(2)
    (2 ... subset.length+1).find_all { |i| subset[-i,1] == '1' }
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

  def subset_size subset
    subset.to_s(2).count("1")
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

    puts "Optimal path length: " + @solution[0].to_s
    puts "Optimal path: " + @optimal_path.to_s
  end
end

# tsp = TravellingSalesman.new("tsp.txt")

# GC::Profiler.enable
# report = MemoryProfiler.report do
# tsp.calculate_optimal_path
# end
# puts GC::Profiler.result

# report.pretty_print

# GC::Tracer.start_logging("gc_tracer.csv") do
#   tsp.calculate_optimal_path
# end
