require_relative '../../../lib/graph.rb'
require_relative '../../../lib/heap.rb'
# require 'set'
# require 'ruby-prof'

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
  attr_reader :graph
  def initialize file_name
    file_name ||= "edges.txt"
    @frontier_edges = Heap.new(Heap::MIN, nil, {maintain_indexes: true}) # Set.new
    @graph = Graph.new file_name
  end

  def compute_minimum_spanning_tree
    (1..@graph.vertices.size).each { |index|
      vertex = (index == 1) ? @graph.vertices[0] : pick_edge_to_mst #initially, any vertex can be picked
      vertex.processed = true # marking vertex as explored

      # when a vertex is added to MST, the set of edges that 
      # cross the frontier (of explored - unexplored vertices) has to be updated.
      # 1. If both vertices of an edge are now in explored subset (@MST_vertices),
      #    such edges have to be removed from frontier.
      # 2. All edges of a newly added vertex, that lead to yet unexplored vertices (to @vertices)
      #    have to be added to frontier.

      vertex.edges.each { |edge|
        opposite_vertex = edge.opposite_vertex(vertex)
        if opposite_vertex.processed
          @frontier_edges.delete(edge)
        else
          @frontier_edges.insert(edge)
        end
      }
    }
  end

  def print_edges_in_frontier index
    puts "Iteration #{index}"
    @frontier_edges.container.each{|edge| puts edge.to_s }
    # @frontier_edges.each{|edge| puts edge.to_s }
  end

  def MST_cost
    mst_edges.inject(0) { |result, edge| result + edge.path_length }
  end

  def mst_edges
    @graph.edges.select{|edge| edge.mst }
  end

  private

  # by greedy criteria of PrimJarnikMST, an edge with a minimum length (weight) 
  # is chosen to form MST.
  def pick_edge_to_mst
    edge = @frontier_edges.next
    # if @frontier_edges is a Set: @frontier_edges.min_by { |edge| edge.path_length }
    edge.mst = true
    vertex = edge.tail_vertex.processed ? edge.head_vertex : edge.tail_vertex
  end
end

def execute
  start = Time.now.to_f

  mst = PrimJarnikMST.new("clustering.txt")
  puts "Time to read graph: #{Time.now.to_f - start}"
  mst.compute_minimum_spanning_tree
  puts "Total time: #{Time.now.to_f - start}"
  puts mst.MST_cost
end
execute

# edges.txt
# MST length: -3612829
# Total running time: 0.4(to read graph) + 0.27(to process MST) = 0.67 secs

# clustering.txt
# MST length: 12320
# Total running time:
# 1. Using Set to store @frontier_edges
# (relatively fast, even though a search for min edge is performed every time an edge is picked)
# 20.63(to read graph) + 14.3(to process MST) = 34.93 secs
# 2. Using my own implementation of Heap to store @frontier_edges.
# (insert(), pop(), delete() running time O(log n))
# 21.09(to read graph) + 1.92(to process MST) = 23.01 secs


# RubyProf.start
# mst.compute_minimum_spanning_tree
# result = RubyProf.stop
# puts "Total time: #{Time.now.to_f - start}"
# puts mst.MST_cost
# printer = RubyProf::GraphHtmlPrinter.new(result)
# file = File.open("profiler.html", 'w')
# printer.print(file, :min_percent => 2, :print_file => true)
# file.close