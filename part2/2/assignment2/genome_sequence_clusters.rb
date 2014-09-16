# require 'debugger'
require 'thread'
mutex = Mutex.new

class GenomeSequenceClusters
  attr_reader :sequences_of_size1, :sequences_of_size2, :points_amount,
              :sequence_bit_length, :points, :sequences
  def initialize filename=nil
    return unless filename
    File.open(filename, 'r').each_line.with_index { |line, index|
      if index == 0
        line = line.split(" ")
        @points_amount = line[0].to_i
        @sequence_bit_length = line[1].to_i
        @points    = Array.new(@points_amount)
        #sequences of 0-bit-difference (identical), 1-bit-difference, 2-bit-difference
        @sequences = {0=>{}, 1=>[], 2=>[]} 
        next
      end
      @points[index-1] = line.gsub(/ /, "").to_i(2)
    }
  end

  def find_sequences_of_size1(sequence_bit_length=nil)
    sequence_bit_length ||= @sequence_bit_length
    @sequences_of_size1 = Array.new(sequence_bit_length)
    power = 0
    while(power<sequence_bit_length)
      @sequences_of_size1[power] = 2**power
      power += 1
    end
  end

  def find_sequences_of_size2(sequence_bit_length=nil)
    sequence_bit_length ||= @sequence_bit_length
    @sequences_of_size2 = Array.new

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
          (@sequences_of_size2 << two_bit_number) unless @sequences_of_size2.index(two_bit_number)
        end
        power_2 += 1
      end

      power_1 += 1
    end
    @sequences_of_size2.sort!
  end

  def sequences_into_binary_form(array, bit_length)
    array.map! { |sequence| 
      sequence.to_s(2).rjust(bit_length, padstr='0')
    }
  end

  def find_subsets_of_identical_sequences
    @points.each.with_index {|point1, i|
      puts "i: #{i.to_s}; found identical-sequence clusters: #{@sequences[0].size}" if i%500==0
      # debugger if i%1000==0 and i!=0
      @points.each.with_index {|point2, j|
        next if j <= i
        if @points[i] == @points[j]
          point = @points[i]
          @sequences[0][point] ||= []
          @sequences[0][point] << i unless @sequences[0][point].index(i)
          @sequences[0][point] << j unless @sequences[0][point].index(j)
        end
      }
    }
  end

  class Cluster
    def initialize(length)
      @point1 = point1
      @point2 = point2
      @length = length
    end
  end
end

def execute
  start = Time.now.to_f

  cluster = GenomeSequenceClusters.new("clustering_big.txt")
  cluster.find_sequences_of_size1
  cluster.find_sequences_of_size2
  cluster.find_subsets_of_identical_sequences
  
  finish = Time.now.to_f
  diff = finish - start
  puts "start: #{start}; finish: #{finish}; diff: #{diff}"

  p @sequences[0]
  # p cluster.sequences_of_size1
  # p cluster.sequences_of_size2

  # p cluster.sequences_of_size1.size
  # p cluster.sequences_of_size2.size
end

execute