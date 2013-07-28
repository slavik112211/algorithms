=begin
http://en.wikipedia.org/wiki/Karger%27s_algorithm

In computer science and graph theory, Karger's algorithm is a randomized algorithm 
to compute a minimum cut of a connected graph. It was invented by David Karger 
and first published in 1993.

The idea of the algorithm is based on the concept of contraction of an edge (u, v) 
in an undirected graph G = (V, E). Informally speaking, the contraction of an edge 
merges the nodes u and v into one, reducing the total number of nodes of the graph by one. 
All other edges connecting either u or v are "reattached" to the merged node, 
effectively producing a multigraph. Karger's basic algorithm iteratively contracts 
randomly chosen edges until only two nodes remain; those nodes represent a cut 
in the original graph. By iterating this basic algorithm a sufficient number of times, 
a minimum cut can be found with high probability.
=end

require 'debugger'
require 'graphviz'

class Graph
  attr_accessor :vertices

  def initialize(vertices)
    if(vertices.kind_of?(Array))
      @vertices = vertices
    else
      create_vertices(vertices)
    end
  end

  def create_vertices(filename)
    array = Array.new(File.foreach(filename).inject(0) {|c, line| c+1})
    i = 0
    File.open(filename, 'r').each_line do |line|
      array[i] = Vertex.new(line)
      i+=1
    end
    @vertices = array
  end

  def find(vertex_id)
    @vertices.select{|vertex| vertex.id == vertex_id }[0]
  end

  def remove_vertex(vertex)
    @vertices.delete(vertex)
  end

  def random_contraction
    return self if(@vertices.length == 2)
    edge = select_edge_to_contract
    contract(edge)
    random_contraction
  end

  def select_edge_to_contract
    vertex_1    = @vertices[rand(@vertices.length)]
    vertex_2_id = vertex_1.adjacent_vertices[rand(vertex_1.adjacent_vertices.length)]
    vertex_2    = find vertex_2_id
    return [vertex_1, vertex_2]
  end

  #1. for all the adjacent_vertices of vertex_2, ensure these point to vertex_1 now;
  #2. merge adjacent_vertices of vertex_1 with adjacent_vertices of vertex_2
  #3. find edges that point from vertex_1 to vertex_1 (after contraction step) and remove them;
  #   such edges are loops - that is, an edge that connects a vertex to itself.
  def contract edge
    vertex_1 = edge[0]
    vertex_2 = edge[1]
    #puts "contracting edge " + vertex_1.id.to_s + ", " + vertex_2.id.to_s
    remove_vertex vertex_2

    vertex_2.adjacent_vertices.each{ |adjacent_vertex|
      vertex = find(adjacent_vertex)
      vertex_2_index = vertex.adjacent_vertices.index(vertex_2.id)
      vertex.adjacent_vertices[vertex_2_index] = vertex_1.id
    }
    vertex_1.adjacent_vertices.concat(vertex_2.adjacent_vertices)
    vertex_1.adjacent_vertices.delete_if {|adjacent_vertex| adjacent_vertex == vertex_1.id }
  end

  def count_edges_of_2_vertices_graph
    @vertices[0].adjacent_vertices.length
  end

  def clone
    vertices_clone = @vertices.map{|vertex| vertex.clone }
    Graph.new(vertices_clone)
  end
end

class Vertex
  attr_accessor :id, :adjacent_vertices

  def initialize(line=nil)
    if(line)
      line = line.split(" ").map{|vertex_id| vertex_id.to_i }
      @id = line.shift
      @adjacent_vertices = line
    end 
  end

  def to_s  
    "Vertex #{@id}. Adjacent vertices: #{@adjacent_vertices}"  
  end

  def clone
    vertex = Vertex.new
    vertex.id = self.id
    vertex.adjacent_vertices = self.adjacent_vertices.clone
    vertex
  end
end

def create_graphviz_graph
  graph = GraphViz.new(:G, :type => :graph)
  File.open("kargerMinCut.txt", 'r').each_line do |line|  #visual min_cut = 17
    array = line.split(" ")
    node_id = array.shift
    node_adjacent_nodes = array
    node = graph.get_node(node_id) || GraphViz::Node.new(node_id, graph)
    node_adjacent_nodes.each{|adjacent_node_id|
      adjacent_node = graph.get_node(adjacent_node_id) || GraphViz::Node.new(adjacent_node_id, graph)
      neighbors = adjacent_node.neighbors
      edge_present = false
      neighbors.each{|neighbor|
        edge_present = true if neighbor.id == node.id 
      }
      node<<adjacent_node if edge_present == false # Create an edge between the current node and the adjacent_node
    } 
  end
  return graph
end

def print_graphviz_graph graph
  graph.output( :none => "graph.dot" ) #creates .dot graph format output
  #/usr/bin/fdp -v -q1   -Tsvg -ograph.svg graph.dot 
  #http://stackoverflow.com/questions/3428448/reducing-graph-size-in-graphviz
end

#to achieve a 1/n probability of NOT finding min_cut (high probability of finding),
#we need to run contraction of graph at least n^2*log^e(n) times
#where n - number of vertices, m - number of edges
def karger_graph_min_cut graph
  number_of_vertices = graph.vertices.length
  min_cut_number_of_edges = number_of_vertices * (number_of_vertices - 1) / 2;
  #n = (number_of_vertices**2) * Math::log(number_of_vertices, Math::E)
  #n = n.floor
  n = 300
  puts "#{n} contraction runs"

  n.times { |i|
    puts "running #{i} time"
    graph_copy = graph.clone
    graph_copy = graph_copy.random_contraction
    current_min_cut_number_of_edges = graph_copy.count_edges_of_2_vertices_graph
    if (min_cut_number_of_edges > current_min_cut_number_of_edges)
      min_cut_number_of_edges = current_min_cut_number_of_edges
    end
    puts "current_min_cut_number_of_edges: #{current_min_cut_number_of_edges}"
    puts "min_cut_number_of_edges: #{min_cut_number_of_edges}"
  }
  return min_cut_number_of_edges
end

graph = Graph.new("kargerMinCut.txt")
min_cut = karger_graph_min_cut(graph)
print min_cut