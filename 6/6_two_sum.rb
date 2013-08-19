require 'debugger'
require 'ruby-prof'

class HashTable
  attr_accessor :hash_table, :sum_pairs

  def initialize filename
    #number_of_input_lines = %x{wc -l #{filename}}.split.first.to_i
    #number_of_buckets = (Math.sqrt(number_of_input_lines) * 4.1).to_i
    @hash_table = Hash.new# number_of_buckets
    i = 0
    File.open(filename, 'r').each_line { |line|
      insert(line.to_i)
      i+=1
      puts i if i%10000 == 0
    }

    @sum_pairs = Hash.new
  end

  def insert(element)
    key = hash_by_20000_element_buckets(element)
    #hash_table[key].nil? ? hash_table[key]=[element] : hash_table[key]<<element
    hash_table.has_key?(key) ? hash_table[key]<<element : hash_table[key]=[element]
  end

  def include?(element)
    key = hash(element)
    hash_table[key].include? element
  end

  def number_of_buckets
    hash_table.length
  end

  # working only when @hash_table is stored internally as Ruby#Hash
#=begin
  def bucket_lengths
    buckets = hash_table.values.sort {|a,b| b.length <=> a.length }.first(50)
    buckets.each{|bucket| puts "number: #{bucket.length}; bucket: #{hash_table.key(bucket)}, numbers: #{bucket.inspect}" }
  end
  
  def buckets_used
    hash_table.keys.sort.each{|bucket| puts "bucket: #{bucket}" }
  end
#=end

  def hash(element)
    hash = 0
    element_chars_array = element.abs.to_s.split("").map(&:to_i)
    element_chars_array.each_with_index{ |char, i|
      hash += char
    }

    element_chars_array.each_with_index{ |char, i|
      break if i == 8
      char = 1 if char == 0
      hash *= char
    }

    element_chars_array.reverse.each_with_index{ |char, i|
      break if i == 3
      char = 1 if char == 0
      hash /= char
    }

    hash
  end
  private :hash

  def hash_by_20000_element_buckets(element)
    hash = (element / 20000).to_i
  end


  def find_sum_pairs
    i=0
    hash_table.each{|bucket_key, bucket|
      #next unless bucket
      bucket.each{|element|
        i+=1
        find_pair_to_element bucket_key, element
        puts i# if i%10000 == 0
        break if sum_pairs.length > 0
      }
    }
  end

  def find_pair_to_element bucket_key, x
    [-bucket_key-1, -bucket_key, -bucket_key+1].each{ |inverse_bucket_key|
      if hash_table.has_key?(inverse_bucket_key)
        hash_table[inverse_bucket_key].each{|y|
          sum = x + y
          if sum >= -10000 and sum <= 10000 and x != y
            sum_pairs[sum]=true if sum_pairs[sum].nil?
          end
        }
      end
    }
  end

=begin
  def find_pair_to_element x
    -10000.upto(10000){|sum|
      y = sum - x
      if hash_table.include? y
        sum_pairs[sum].nil? ? sum_pairs[sum]=[x, y] : sum_pairs[sum]<<[x, y]
      end
    }
  end
  private :find_pair_to_element
=end
end

hash_table = HashTable.new "algo1_programming_prob_2sum.txt"
#puts hash_table.number_of_buckets
#hash_table.bucket_lengths

# result = RubyProf.profile do
  hash_table.find_sum_pairs
# end

# # Print a flat profile to text
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)
puts hash_table.sum_pairs.length
#427