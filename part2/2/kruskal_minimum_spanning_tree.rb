require_relative '../../02quicksort.rb'
require_relative 'union_find.rb'
require_relative '../../lib/graph.rb'

=begin
Kruskal's algorithm is a greedy algorithm in graph theory that finds
a minimum spanning tree for a connected weighted graph. This means 
it finds a subset of the edges that forms a tree that includes 
every vertex, where the total weight of all the edges in the tree 
is minimized. If the graph is not connected, then it finds a
minimum spanning forest (a minimum spanning tree for each connected component).

Algorithm:
1. create a forest F (a set of trees), where each vertex in the graph is a separate tree
2. create a set S containing all the edges in the graph
3. while S is nonempty and F is not yet spanning
  1. remove an edge with minimum weight from S
  2. if that edge connects two different trees, then add it to the forest, 
     combining two trees into a single tree

At the termination of the algorithm, the forest forms a minimum spanning forest 
of the graph. If the graph is connected, the forest has a single component 
and forms a minimum spanning tree.
=end  

class KruskalMST
  attr_reader :MST_edges
  def initialize file_name
    file_name ||= "edges.txt"
    @MST_edges    = Array.new
    @graph = Graph.new file_name
    @vertices_trees_forest = UnionFind.new(@graph.vertices.size, @graph.vertices)
    wrap_edges
    quick_sort(@graph.edges, 0, @graph.edges.length-1) #sort edges smallest to largest
  end

  def compute_minimum_spanning_tree
    @graph.edges.each {|edge|
      # Comparing if two vertices belong to different subsets. Subsets are represented by 
      # their leader vertexes
      if(edge.tail_vertex.leader != edge.head_vertex.leader)
        @MST_edges << edge
        @vertices_trees_forest.union(edge.tail_vertex, edge.head_vertex)
      end
    }
  end

  def MST_cost
    @MST_edges.inject(0) { |result, edge| result + edge.path_length }
  end

  private

  #Each edge stores a link to 2 vertices. These 2 vertices need to be wrapped into UnionFind Nodes.
  #UnionFind Node stores the vertex itself, and additional info per vertex within it.
  def wrap_edges
    @graph.edges.each {|edge|
      edge.tail_vertex = @vertices_trees_forest.nodes.find {|node| node.element == edge.tail_vertex}
      edge.head_vertex = @vertices_trees_forest.nodes.find {|node| node.element == edge.head_vertex}
    }
  end
end

def execute
  start = Time.now.to_f

  mst = KruskalMST.new("edges.txt")
  mst.compute_minimum_spanning_tree
  
  finish = Time.now.to_f
  diff = finish - start
  puts "start: #{start}; finish: #{finish}; diff: #{diff}"
  puts mst.MST_cost #-3612829, 0.82 seconds
end

execute