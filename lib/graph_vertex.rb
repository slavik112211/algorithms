class Vertex
  attr_accessor :id, :head_vertices, :edges, :processed

  def initialize(id)
    @id = id
    @head_vertices = Array.new
    @edges         = Array.new
    @processed = false
  end

  def to_s  
    "Vertex #{@id}"# Head vertices: " + @head_vertices.map{|head_vertex| head_vertex.id.to_s }.join(" ") 
  end

  def find_or_add_head(vertex)
    @head_vertices<<vertex if !has_as_head?(vertex)
  end

  def add_edge(edge)
    @edges<<edge
  end

  def has_as_head?(vertex)
    found = @head_vertices.select{|head_vertex| head_vertex.id == vertex.id }
    return found.length>0 ? true : false
  end

  def incoming_edges
    return @incoming_edges if @incoming_edges
    @incoming_edges = @edges.select {|edge| @id == edge.head_vertex.id }
  end

  def eql?(other)
    @id == other.id
  end

  def hash
    @id
  end
end