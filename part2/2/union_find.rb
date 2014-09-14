class UnionFind
  attr_reader :subsets
  def initialize
    @subsets = Array.new
  end

  def nodes
    nodes = Array.new
    @subsets.each { |subset| nodes += subset.nodes }
    nodes
  end

  def add_subset elements
    subset = LinkedList.new elements
    @subsets << subset
  end

  def add_subsets elements
    elements.each { |element|
      add_subset [element]
    }
  end

  # finds a subset, to which the node belongs,
  # returns the subset's leader object.
  def find_subset node
    node.leader.object
  end

  def union node1, node2
    leader1 = node1.leader
    leader2 = node2.leader
    subset1 = find_subset_of_node(node1)
    subset2 = find_subset_of_node(node2)

    if leader1 == leader2
      return
    elsif subset1.size >= subset2.size
      subset1.add_list subset2
      delete_set(subset2)
    else
      subset2.add_list subset1
      delete_set(subset1)
    end
  end

  private

  def delete_set set
    @subsets.delete set
  end

  def find_subset_of_node node
    node_subset = nil
    @subsets.each { |subset|
      if subset.leader == node.leader
        node_subset = subset
        break
      end 
    }
    node_subset
  end

  class LinkedList
    attr_accessor :size, :nodes, :leader
    def initialize objects
      @leader = nil
      @size = 0
      @nodes = Array.new(objects.size)
      objects.each.with_index {|object, index|
        node = Node.new object, @leader
        @nodes[index] = node
        @size += 1
        @leader = node unless @leader
      }
    end

    def add_list list
      list.nodes.each {|node|
        node.leader = @leader
        @nodes << node
      }
      @size += list.size
    end
  end

  class Node
    attr_reader :object
    attr_accessor :leader
    def initialize object, leader=nil
      @object = object
      @leader = leader ? leader : self
    end
  end
end

