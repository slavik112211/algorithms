require 'algorithms'
require 'debugger'

left_half_heap  = Containers::MaxHeap.new
right_half_heap = Containers::MinHeap.new

# Heap is stored as array of elements
# 1st element - root, 2nd, 3rd elements - 2nd level
# 4th, 5th, 6th, 7th elements - 3rd level, etc
class Heap
  MIN = 1; MAX = 2
  def initialize(type=Heap::MIN)
    @container = Array.new
    @type = type 
  end

  def push element
    @container << element
    index = @container.rindex
    bubble_up(index)
  end

  def pop
    element = next()
    
  end

  def next
    @container[0]
  end

  private
  def bubble_up index
    element = @container[index]
    parent_index = get_parent_index(index)
    parent_element = @container[parent_index]
    if parent_element.present?
      if (@type == Heap::MIN and element < parent_element) or
         (@type == Heap::MAX and element > parent_element)
        swap(index, parent_index)
        bubble_up(parent_index)
      end
    end
  end

  def bubble_down index
    element = @container[index]
    child_index = get_smallest_child_index(index)
    child_element = @container[child_index]
    if child_element.present?
      if (@type == Heap::MIN and element > child_element) or
         (@type == Heap::MAX and element < child_element)
        swap(index, child_index)
        bubble_down(child_index)
      end
    end
  end

  def swap x_index, y_index
    return if x_index == y_index
    element = @container[x_index]
    @container[x_index] = @container[y_index]
    @container[y_index] = element
  end

  def get_parent_index index
    ((index+1)/2).floor - 1
  end

  def get_children_indexes index
    left_child_index  = (index+1)*2-1
    right_child_index = left_child_index+1
    [left_child_index, right_child_index]
  end

  def get_smallest_child_index index
    children_indexes = get_children_indexes index
    left_child = @container[children_indexes[0]]
    right_child = @container[children_indexes[1]]
    smallest_child_index = nil
    if left_child.nil? and right_child.nil?
      smallest_child_index = nil
    elsif left_child.nil?
      smallest_child_index = children_indexes[1]
    elsif right_child.nil?
      smallest_child_index = children_indexes[0]
    elsif left_child < right_child
      smallest_child_index = children_indexes[0]
    elsif right_child < left_child
      smallest_child_index = children_indexes[1]
    elsif right_child == left_child
      smallest_child_index = children_indexes[0]
    end
    smallest_child_index
  end
end

medianas = Array.new 10001

i = 0

File.open("Median.txt", 'r').each_line { |line|
  i+=1
  number = line.to_i
  if(left_half_heap.size == 0 and right_half_heap.size == 0)
  	left_half_heap.push(number)
  	medianas[i] = left_half_heap.next
  	next
  end
  (number > left_half_heap.next) ? right_half_heap.push(number) : left_half_heap.push(number)
  size_diff = right_half_heap.size - left_half_heap.size
  if (size_diff > 0)
  	element = right_half_heap.pop
  	left_half_heap.push element
  elsif (size_diff < -1) 
  	element = left_half_heap.pop
  	right_half_heap.push element
  end
  medianas[i] = left_half_heap.next
}

puts left_half_heap.size
puts right_half_heap.size

medianas.shift
#puts medianas.inspect
puts medianas.inject(0){|sum,mediana| sum + mediana } % 10000
puts medianas.inject(0){|sum,mediana| sum + mediana }

#46831213
#1213