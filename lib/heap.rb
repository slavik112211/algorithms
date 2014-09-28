# Heap is stored as array of elements
# 1st element - root, 2nd, 3rd elements - 2nd level
# 4th, 5th, 6th, 7th elements - 3rd level, etc
# Heap property
# All nodes are either [greater than or equal to] or [less than or equal to]
# each of its children, according to a comparison predicate defined for the heap.
# The ordering of siblings in a heap is not specified by the heap property, 
# a single node's two children can be freely interchanged.

# Property @maintain_indexes allows to store an index of an element in the @container array.
# This way, when an element will need to be deleted(), this can be done in O(log n) time,
# instead of O(n) (searching the location of an element in an array) + 
# O(log n) (removing). To use @maintain_indexes elements must provide a #index_in_heap field.
class Heap
  MIN = 1; MAX = 2
  attr_reader :container
  def initialize(type=Heap::MIN, container=nil, options={})
    @container = container ||= Array.new
    @type = type
    @maintain_indexes = options[:maintain_indexes]
  end

  def push element
    @container << element
    index = @container.length-1
    element.index_in_heap = index if @maintain_indexes
    bubble_up(index)
  end
  alias_method :insert, :push

  def pop
    delete nil, 0
  end
  alias_method :extract, :pop

  # running time: 
  # O(n) (to find index of element in array) + O(log n) (to delete and reheapify the Heap)
  # O(n) can be avoided, if #index_in_heap is stored for elements
  def delete element=nil, index=nil
    index   ||= @maintain_indexes ? element.index_in_heap : @container.index(element)
    element ||= @container[index]

    substitute = @container.pop
    return substitute if @container.length == 0 or !index
    @container[index] = substitute
    substitute.index_in_heap = index if @maintain_indexes
    bubble_down(index)
    element
  end

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
    if @maintain_indexes
      @container[x_index].index_in_heap = x_index
      @container[y_index].index_in_heap = y_index
    end
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

  class Node
    include Comparable
    attr_accessor :element, :index_in_heap
    def initialize(element)
      @element = element
      @index_in_heap = nil
    end

    # def ==(another_node)
    #   @element.equal? another_node.element
    # end

    def <=>(another_node)
      if @element < another_node.element
        -1
      elsif @element > another_node.element
        1
      else
        0
      end
    end
  end
end