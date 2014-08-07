require_relative 'graph_edge.rb'
require_relative 'graph_vertex.rb'

class Graph
  attr_reader :vertices, :edges

  # Graph input file format is as follows:
  #
  # [number_of_nodes] [number_of_edges]
  # [one_node_of_edge_1] [other_node_of_edge_1] [edge_1_cost]
  # [one_node_of_edge_2] [other_node_of_edge_2] [edge_2_cost]
  def initialize file_name
    file_name ||= "graph.txt"

    File.open(file_name, 'r').each_line.with_index { |line, index|
      line = line.split(" ")
      if index == 0
        @vertices = Array.new(line[0].to_i)
        @edges    = Array.new(line[1].to_i)
        next
      end
      
      vertex1 = find_or_create_vertex(line[0].to_i)
      vertex2 = find_or_create_vertex(line[1].to_i)

      edge = Edge.new(vertex1, vertex2, line[2].to_i)
      vertex1.add_edge(edge)
      vertex2.add_edge(edge)
    }
  end

  private
  def find_or_create_vertex(id)
    vertex = @vertices.find{|vertex| (vertex != nil and vertex.id == id) }
    unless(vertex)
      vertex = Vertex.new(id)
      @vertices[id-1] = vertex
    end
    vertex
  end
end