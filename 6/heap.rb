# Heap is stored as array of elements
# 1st element - root, 2nd, 3rd elements - 2nd level
# 4th, 5th, 6th, 7th elements - 3rd level, etc
class Heap
  MIN = 1; MAX = 2
  attr_reader :container
  def initialize(type=Heap::MIN, container=nil)
    @container = container ||= Array.new
    @type = type 
  end

  def push element
    @container << element
    index = @container.length-1
    bubble_up(index)
  end
  alias_method :insert, :push

  def pop
    root_element = @container[0]
    @container[0] = @container.pop
    bubble_down(0)
    return root_element
  end
  alias_method :extract, :pop

  def next
    @container[0]
  end

  def size
    @container.length
  end

  private
  def bubble_up index
    element = @container[index]
    parent_index = get_parent_index(index)
    unless parent_index.nil?
      parent_element = @container[parent_index]
      if (@type == Heap::MIN and element < parent_element) or
         (@type == Heap::MAX and element > parent_element)
        swap(index, parent_index)
        bubble_up(parent_index)
      end
    end
  end

  def bubble_down index
    element = @container[index]
    child_index = get_swap_child_index(index)
    unless child_index.nil?
      child_element = @container[child_index]
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
    parent_index = ((index+1)/2).floor - 1
    return nil if parent_index < 0 or parent_index >= @container.length
    parent_index
  end

  def get_children_indexes index
    left_child_index  = (index+1)*2-1
    right_child_index = left_child_index+1
    [left_child_index, right_child_index]
  end

  def get_swap_child_index index
    children_indexes = get_children_indexes index
    left_child = @container[children_indexes[0]]
    right_child = @container[children_indexes[1]]
    swap_child_index = nil
    if left_child.nil? and right_child.nil?
      swap_child_index = nil
    elsif left_child.nil?
      swap_child_index = children_indexes[1]
    elsif right_child.nil?
      swap_child_index = children_indexes[0]
    elsif right_child == left_child
      swap_child_index = children_indexes[0]
    elsif @type == Heap::MIN
      swap_child_index = (left_child<right_child) ? children_indexes[0] : children_indexes[1]
    elsif @type == Heap::MAX
      swap_child_index = (left_child>right_child) ? children_indexes[0] : children_indexes[1]
    end
    swap_child_index
  end
end