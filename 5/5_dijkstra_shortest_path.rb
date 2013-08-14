require 'debugger'

class Graph
  attr_accessor :vertices, :explored_vertices, :edges, :shortest_paths

  def initialize(number_of_vertices)
    @vertices                = Array.new(number_of_vertices)
    @explored_vertices       = Array.new(number_of_vertices)
    @edges                   = Array.new(number_of_vertices) #approx
    @shortest_paths          = Array.new(number_of_vertices)
  end

  def find_or_create_vertex(id)
  	vertex = find_vertex(id)
  	if !vertex
  	  vertex = Vertex.new(id)
  	  @vertices[id.to_i-1] = vertex
  	end
  	vertex
  end

  def find_vertex(id)
    @vertices[id.to_i-1]
  end

  def remove_vertex(vertex)
    @vertices.delete(vertex)
  end

  def to_s
    @vertices.map{|vertex| vertex.to_s }.join("; ")
  end

  def dijkstra_shortest_path
    current_vertex = @vertices[0]
    @shortest_paths[0] = 0

    while !all_vertices_explored?
      next_vertex=nil
      shortest_path_amongst_head_vertices = 1000000
      current_vertex.edges.each{ |edge|
        next if @explored_vertices[edge.head_vertex.id-1] == true
        shortest_path_to_vertex = @shortest_paths[current_vertex.id-1] + edge.path_length
        if(@shortest_paths[edge.head_vertex.id-1].nil? or 
           @shortest_paths[edge.head_vertex.id-1] > shortest_path_to_vertex)
          @shortest_paths[edge.head_vertex.id-1] = shortest_path_to_vertex
        end
        if(shortest_path_to_vertex < shortest_path_amongst_head_vertices and 
           @explored_vertices[edge.head_vertex.id-1] != true)
          shortest_path_amongst_head_vertices = shortest_path_to_vertex
          next_vertex = edge.head_vertex
        end
      }
      @explored_vertices[current_vertex.id-1] = true
      current_vertex = next_vertex
      puts "current vertex: #{current_vertex.id.to_s}"
      puts "next vertex: #{next_vertex.id.to_s}"
      puts "explored_vertices: #{@explored_vertices}"
      puts "shortest_paths: #{@shortest_paths}"
    end
  end

  def all_vertices_explored?
    found = @explored_vertices.select{|explored_vertex| explored_vertex.nil? }
    return found.length>0 ? false : true
  end
end

class Vertex
  attr_accessor :id, :head_vertices, :edges

  def initialize(id)
    @id = id
    @head_vertices = Array.new
    @edges         = Array.new
  end

  def to_s  
    "Vertex #{@id}. Head vertices: " + @head_vertices.map{|head_vertex| head_vertex.id.to_s }.join(" ") 
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
end

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

def create_graph(filename, number_of_vertices)
  graph = Graph.new(number_of_vertices)
    
  File.open(filename, 'r').each_line do |line|
  	vertices = line.strip.split

    tail_vertex_id = vertices.shift
  	tail_vertex = graph.find_or_create_vertex(tail_vertex_id.to_i)

    vertices.each {|vertex_data|
      vertex_data = vertex_data.split(",")
      head_vertex = graph.find_or_create_vertex(vertex_data[0].to_i)
      tail_vertex.find_or_add_head(head_vertex)
      edge = Edge.new(tail_vertex, head_vertex, vertex_data[1].to_i)
      tail_vertex.edges<<edge
      graph.edges<<edge
    }

  end
  return graph
end

graph = create_graph("graph3.txt", 6)
graph.dijkstra_shortest_path
puts graph.shortest_paths.each_with_index.map { |shortest_path,i| "#{i+1}: #{shortest_path}" }.inspect