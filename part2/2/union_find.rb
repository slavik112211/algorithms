# http://en.wikipedia.org/wiki/Disjoint-set_data_structure

# A disjoint-set data structure, also called a union–find data structure 
# or merge–find set, is a data structure that keeps track of a set of elements 
# partitioned into a number of disjoint (nonoverlapping) subsets. 
# It supports two useful operations:
# 1. Find: Determine which subset a particular element is in. Find typically
#    returns an item from this set that serves as its "representative"; by comparing 
#    the result of two Find operations, one can determine whether two elements 
#    are in the same subset.
# 2. Union: Join two subsets into a single subset.

class UnionFind
  attr_reader :nodes, :clusters_amount
  def initialize size=nil, elements=nil
    if elements
      @nodes = Array.new(size)
      @clusters_amount = size
      make_set elements
    else
      @nodes = Array.new
      @clusters_amount = 0
    end
  end

  def to_s
    @nodes.inject("") {|accumulator, node| accumulator+node.to_s+" " }
  end

  def make_set elements
    elements.each.with_index {|element, index|
      node = Node.new element
      @nodes[index] = node
    }
  end

  def find_or_add_element element
    node = @nodes.find {|node| node.element == element }
    return node if node
    node = Node.new element
    @nodes << node
    @clusters_amount += 1
    node
  end

  # finds a subset, to which the node belongs,
  # returns the subset's leader object.
  def find_subset_leader node
    node.leader
  end

  def union node1, node2
    leader1 = node1.leader
    leader2 = node2.leader

    if leader1 == leader2
      return
    elsif leader1.subset_size >= leader2.subset_size
      join_subsets leader1, leader2
    else
      join_subsets leader2, leader1
    end
    @clusters_amount -= 1
  end

  private

  # Make subset_1 bigger by joining subset_2 to it
  def join_subsets subset_leader1, subset_leader2
    @nodes.each {|node|
      if node.leader == subset_leader2
        node.leader = subset_leader1
      end
    }
    # only the subset_leader has an updated counter of the set size
    subset_leader1.subset_size += subset_leader2.subset_size 
  end

  class Node
    attr_reader :element
    attr_accessor :leader, :subset_size
    def initialize element
      @element = element
      @leader = self
      @subset_size = 1
    end

    def to_s
      "Point: #{@element}, cluster: #{@leader.element};"
    end
  end
end

