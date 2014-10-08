class Knapsack
  attr_reader :max_weight, :items, :subsolutions, :items_in_knapsack, :max_value
  def initialize filename=nil
    return unless filename
    File.open(filename, 'r').each_line.with_index { |line, index|
      break if line == "\n"
      line = line.split(" ")
      if index == 0
        @max_weight = line[0].to_i
        @items = Array.new(line[1].to_i)
        next
      end
      @items[index-1] = Item.new(line[0].to_i, line[1].to_i)
    }
  end

  # Dynamic programming algorithm to solve Knapsack problem.
  # Building the subsolutions matrix
  # @subsolutions is an Array, that stores Arrays of subsolutions.
  # Outer array is indexed by the amount of items stored,
  # inner array is indexed by the max_weight, that can be fit into a knapsack.
  def calculate_subsolutions
    @subsolutions = Array.new(@items.size+1) { Array.new(@max_weight+1) }
    @subsolutions[0].map!{|value| 0}
    (1..@items.size).each { |i|
      (0..@max_weight).each { |j|
        # case 1. Item i excluded, no additional weight added to knapsack
        value1 = @subsolutions[i-1][j]
        # case 2. Item i is included, requires adding item's weight to knapsack
        value2 = (@items[i-1].weight<=j) ? (@items[i-1].value + @subsolutions[i-1][j-@items[i-1].weight]) : -1
        # a total value stored in a knapsack, when i items and j max_knapsack_weight
        @subsolutions[i][j] = (value1>value2) ? value1 : value2
      }
    }
    @max_value = @subsolutions[@items.size][@max_weight]
  end

  # Space efficient version of calculate_subsolutions()
  # will store only 2 iterations of solutions at once (previously computed data can be disposed of)
  def calculate_subsolutions_space_efficient
    @subsolutions_1 = Array.new(@max_weight+1, 0)
    @subsolutions_2 = Array.new(@max_weight+1)

    (1..@items.size).each { |i|
      puts i
      (0..@max_weight).each { |j|
        # case 1. Item i excluded, no additional weight added to knapsack
        value1 = @subsolutions_1[j]
        # case 2. Item i is included, requires adding item's weight to knapsack
        value2 = (@items[i-1].weight<=j) ? (@items[i-1].value + @subsolutions_1[j-@items[i-1].weight]) : -1
        # a total value stored in a knapsack, when i items and j max_knapsack_weight
        @subsolutions_2[j] = (value1>value2) ? value1 : value2
      }
      # move newly found subsolutions to subsolutions1
      (0..@subsolutions_2.size-1).each {|i| @subsolutions_1[i] = @subsolutions_2[i] }
    }
    @max_value = @subsolutions_2[@max_weight]
  end

  # Backtracking through the @subsolutions to figure out which items are in knapsack
  def find_items_in_knapsack
    j = @max_weight
    @items_in_knapsack = Array.new
    @items.size.downto(0) { |i|
      # case 1. knapsack doesn't have space for anymore items, quit
      break if @subsolutions[i][j] == 0
      # case 2. the value stored in knapsack is the same i or with i-1 items.
      #this means i-th item is not in knapsack
      next if @subsolutions[i][j] == @subsolutions[i-1][j]
      # case 3. i-th item is in knapsack.
      # backtracing to the knapsack value without i-th item.
      @items_in_knapsack << @items[i-1]
      j = j-@items[i-1].weight
    }
  end

  def print_items_in_knapsack
    @items_in_knapsack.each {|item| p item.to_s }
  end

  class Item
    attr_reader :value, :weight
    def initialize(value, weight)
      @value = value  # how valuable the item is
      @weight = weight # how heavy the item is. Knapsack capacity is measured by weight.
    end
    def to_s; "Item weight: #{@weight}, value: #{@value}"; end
  end
end

def exec
  knapsack = Knapsack.new("knapsack_big.txt")
  knapsack.calculate_subsolutions_space_efficient
  puts "Max total value of items that could be stored in #{knapsack.max_weight} (weight) knapsack is #{knapsack.max_value} (value)"
  # knapsack.find_items_in_knapsack
  # knapsack.print_items_in_knapsack
end

exec

# knapsack1.txt:
# max value, that fits into 10000 (weight) knapsack = 2493893 (value)

# knapsack_big.txt:
# running time: approx. 1 hour 20 mins.
# Max total value of items that could be stored in 2000000 (weight) knapsack is 4243395 (value)
# running time of C++ program: 50 seconds.