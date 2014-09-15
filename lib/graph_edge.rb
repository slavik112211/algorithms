class Edge
  include Comparable
  attr_accessor :tail_vertex, :head_vertex, :path_length

  def initialize(tail_vertex, head_vertex, path_length)
    @tail_vertex = tail_vertex
    @head_vertex = head_vertex
    @path_length = path_length
  end

  def to_s  
    "#{head_vertex.id}, #{tail_vertex.id}, #{path_length}"
  end

  def opposite_vertex(vertex)
    tail_vertex.eql?(vertex) ? head_vertex : tail_vertex
  end

  # This ensures that for object's equality comparison,
  # objects are compared by their ids (are both the same object),
  # and not by <=> method (which compares only path lengths of two edges)
  def ==(another_edge)
    self.equal? another_edge
  end

  # Used to sort an array of edges by their path_lengths
  def <=>(another_edge)
    if @path_length < another_edge.path_length
      -1
    elsif @path_length > another_edge.path_length
      1
    else
      0
    end
  end
end