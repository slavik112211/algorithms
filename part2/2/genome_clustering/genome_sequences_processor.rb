# require 'debugger'
require 'thread'
require_relative '../union_find.rb'

=begin
  GenomeSequencesProcessor divides a set of binary sequences into
  clusters of [0-bit-difference (identical), 1-bit-difference, 2-bit-difference] sequences.
  Clustering technique used is akin to finding a minimum spanning tree of a graph with Kruskal's algorithm,
  with one substantial difference.
  In Kruskal's MST, we're looking to find a minimum amount (and min total length) of Edges, that unite all Vertexes.
  For that reason, Kruskal's MST has to progress from smallest to largest Edge, picking one at a time.
  Kruskal's MST output is a set of Edges.
  
  On the contrary, in this clustering task, it doesn't matter 
  how many Edges were picked to unite a cluster (set of vertexes), and in what order.
  It doesn't even matter, if another picked Edge will create a cycle of Edges.
  What's important is to produce these clusters.
  Clustering algo output is a set of clusters of Vertices (and not a set of Edges, as in Kruskal's MST).

  So our algorithm iterates over Edges (bit-difference length of 2 points),
  and checks for all 3 cases at the same time: 0-bit difference, 1-bit difference, 2-bit difference,
  and not in subsequent order of 0, then 1, then 2.
  
  See clustering_test_2_explanation.png image to see how algorithm
  creates a subgraph (cluster) with Edge loops and extra Edges. 

  ruby-prof -p graph_html -f profiler.html genome_sequences_processor.rb
  jruby -J-Xmn512m -J-Xms2048m -J-Xmx2048m genome_sequences_processor.rb
=end
class GenomeSequencesProcessor
  attr_reader :sequence_xor1, :sequence_xor2, :points_amount,
              :sequence_bit_length, :points, :clusters
  def initialize filename=nil
    return unless filename
    File.open(filename, 'r').each_line.with_index { |line, index|
      if index == 0
        line = line.split(" ")
        @points_amount = line[0].to_i
        @sequence_bit_length = line[1].to_i
        @points    = Array.new(@points_amount)
        
        next
      end
      @points[index-1] = line.gsub(/ /, "").to_i(2)
    }
    find_sequence_xor1
    find_sequence_xor2
    @clusters = UnionFind.new
    #to ensure that threads are performing write operations on @clusters one at a time
    @mutex = Mutex.new
  end

  def find_sequence_xor1(sequence_bit_length=nil)
    sequence_bit_length ||= @sequence_bit_length
    @sequence_xor1 = Array.new(sequence_bit_length)
    power = 0
    while(power<sequence_bit_length)
      @sequence_xor1[power] = 2**power
      power += 1
    end
  end

  def find_sequence_xor2(sequence_bit_length=nil)
    sequence_bit_length ||= @sequence_bit_length
    @sequence_xor2 = Array.new

    power_1 = 0 #2**power -> iterating the first bit
    while(power_1<sequence_bit_length)
      one_bit_sequence_1 = 2**power_1

      power_2 = 0 #2**power -> iterating the second bit
      #2 bits cannot be on the same spot (this makes a 1 bit number),
      #so 2nd bit has to skip the spots, where 1st bit is located.
      while(power_2<sequence_bit_length)
        if (power_2 != power_1)
          one_bit_sequence_2 = 2**power_2
          two_bit_number = one_bit_sequence_1 | one_bit_sequence_2
          (@sequence_xor2 << two_bit_number) unless @sequence_xor2.index(two_bit_number)
        end
        power_2 += 1
      end

      power_1 += 1
    end
    @sequence_xor2.sort!
  end

  def sequences_into_binary_form(array, bit_length)
    array.map! { |sequence| 
      sequence.to_s(2).rjust(bit_length, padstr='0')
    }
  end

  # Defines amount of clusters left after clustering [identical, 
  # 1-bit different and 2-bit different] sequences together.
  # Initially every point belongs to it's own cluster.
  def clusters_amount
    @points_amount - @clusters.nodes.size + @clusters.clusters_amount
  end

  # in outer(i-iterator) and inner(j-iterator) loops, we are traversing the matrix of @points array:
  # @points = [3, 5, 7, 9]
  # Matrix:
  #     3  5  7  9
  # 3: [-, x, x, x]
  # 5: [0, -, x, x]
  # 7: [0, 0, -, x]
  # 9: [0, 0, 0, -]
  #
  # Only the x-positions have to be traversed, since 0-positions are 
  # their direct reflections (i->j, only changes to j->i, the processing would work on exactly same pair of points)
  # Hence inner loop lower bound is always j_lower_bound = i+1
  # Outer loop is iterating from first to pre-last point. last point is covered by inner j-iterations.
  def find_clusters_of_sequences(i_lower=nil, i_upper=nil, timer=nil, thread_number=nil)
    timer   ||= Time.now.to_f
    thread_number ||= 1
    i_lower ||= 0
    i_upper ||= @points.size-2
    (i_lower..i_upper).each { |i|
      puts "Thread: #{thread_number}; i: #{i.to_s};\tFound sequence clusters: #{@clusters.clusters_amount};\tTime: #{(Time.now.to_f-timer).round(2)} sec" if i%500==0
      (i+1..@points.size-1).each { |j|

        # The XOR will detect only the bits set differently in two bit-strings, 
        # and not bits that are set (1) in both bit-strings or unset (0) in both bit-strings.
        # (a = 18).to_s(2) #=> "10010"; (b = 20).to_s(2) #=> "10100"; (a ^ b).to_s(2)  #=> "00110"
        points_difference = @points[i] ^ @points[j]
           
        if 
        @points[i] == @points[j] or                # 1. Points are identical
        @sequence_xor1.index(points_difference) or # 2. Points are different by 1 bit
        @sequence_xor2.index(points_difference)    # 3. Points are different by 2 bits
          @mutex.synchronize do
            node_i = @clusters.find_or_add_element(i+1)
            node_j = @clusters.find_or_add_element(j+1)
            @clusters.union(node_i, node_j)
          end
        end
      }
    }
  end

  def find_clusters_of_sequences_threaded
    timer = Time.now.to_f
    points_quarter = (@points.size/4).to_i
    thread1 = Thread.new { find_clusters_of_sequences(0                 ,   points_quarter, timer, 1) }
    thread2 = Thread.new { find_clusters_of_sequences(  points_quarter+1, 2*points_quarter, timer, 2) }
    thread3 = Thread.new { find_clusters_of_sequences(2*points_quarter+1, 3*points_quarter, timer, 3) }
    thread4 = Thread.new { find_clusters_of_sequences(3*points_quarter+1,   @points.size-2, timer, 4) }
    thread1.join; thread2.join; thread3.join; thread4.join
  end
end

def execute
  processor = GenomeSequencesProcessor.new("clustering_big.txt")
  # processor.find_clusters_of_sequences
  processor.find_clusters_of_sequences_threaded

  # p processor.clusters.to_s
  puts "Clusters left after clustering: #{processor.clusters_amount} out of #{processor.points_amount}"
end

# execute
