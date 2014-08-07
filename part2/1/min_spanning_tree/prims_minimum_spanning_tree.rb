require_relative '../../../lib/graph.rb'
require_relative '../../../lib/heap.rb'

=begin
Prim–Jarník algorithm is a greedy algorithm that finds a minimum spanning tree 
for a connected weighted undirected graph. This means it finds a subset 
of the edges that forms a tree that includes every vertex, where 
the total weight of all the edges in the tree is minimized.

The algorithm starts with a tree consisting of a single vertex, and continuously
increases its size one edge at a time, until it spans all vertices.

Input: A non-empty connected weighted graph with vertices V and edges E 
  (the weights can be negative).
Initialize: Vnew = {x}, where x is an arbitrary node (starting point) from V, Enew = {}
Repeat until Vnew = V:
    1. Choose an edge {u, v} with minimal weight such that u is in Vnew and v is not
    (if there are multiple edges with the same weight, any of them may be picked)
    2. Add v to Vnew, and {u, v} to Enew
Output: Vnew and Enew describe a minimal spanning tree

=end

class PrimJarnikMST
  attr_reader :MST_edges
  def initialize file_name
    file_name ||= "edges.txt"

    @MST_vertices = Array.new
    @MST_edges    = Array.new
    @frontier_edges = Array.new

    @graph = Graph.new file_name
  end

  def vertices
    @graph.vertices
  end

  def compute_minimum_spanning_tree
    while !vertices.empty?
      vertex = pick_edge_to_mst
      vertices.delete(vertex)
      @MST_vertices << vertex

      # when a vertex is added to MST, the set of edges that 
      # cross the frontier (of explored - unexplored vertices) has to be updated.
      # 1. If both vertices of an edge are now in explored subset (@MST_vertices),
      #    such edges have to be removed from frontier.
      # 2. All edges of a newly added vertex, that lead to yet unexplored vertices (to @vertices)
      #    have to be added to frontier.

      vertex.edges.each { |edge|
        opposite_vertex = edge.opposite_vertex(vertex)
        if @MST_vertices.include?(opposite_vertex)
          @frontier_edges.delete(edge)
        else
          @frontier_edges << edge
        end
      }
    end
  end

  def MST_cost
    @MST_edges.inject(0) { |result, edge| result + edge.path_length }
  end

  private

  # by greedy criteria of PrimJarnikMST, an edge with a minimum length (weight) 
  # is chosen to form MST.
  def pick_edge_to_mst
    if @MST_vertices.empty?
      #initially, any vertex can be picked
      vertex = vertices.find{|vertex| vertex.id == 1}
    else
      edge = @frontier_edges.min_by { |edge| edge.path_length }
      @MST_edges << edge
      vertex = @MST_vertices.include?(edge.tail_vertex) ? edge.head_vertex : edge.tail_vertex
    end
    vertex
  end
end

def execute
  start = Time.now.to_f

  mst = PrimJarnikMST.new("edges.txt")
  mst.compute_minimum_spanning_tree
  
  finish = Time.now.to_f
  diff = finish - start
  puts "start: #{start}; finish: #{finish}; diff: #{diff}"
  #0.72 seconds, when an Array is used to store @frontier_edges
  puts mst.MST_cost #-3612829
end
# execute