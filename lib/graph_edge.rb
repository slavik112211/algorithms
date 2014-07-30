class Edge
  attr_accessor :tail_vertex, :head_vertex, :path_length

  def initialize(tail_vertex, head_vertex, path_length)
    @tail_vertex = tail_vertex
    @head_vertex = head_vertex
    @path_length = path_length
  end

  def to_s  
    "#{head_vertex.id}, #{path_length}"
  end
end