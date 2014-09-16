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


Kruskal's algorithm for minimum spanning trees can also be used as a CLUSTERING algorithm.
However, in single-linkage clustering, the order in which clusters are formed is important, 
while for minimum spanning trees what matters is the set of pairs of points that form 
distances chosen by the algorithm.
http://en.wikipedia.org/wiki/Single-linkage_clustering

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
  attr_reader :MST_edges, :vertices_trees_forest
  def initialize file_name
    file_name ||= "edges.txt"
    @MST_edges    = Array.new
    @graph = Graph.new file_name
    @vertices_trees_forest = UnionFind.new(@graph.vertices.size, @graph.vertices)
    wrap_edges
    quick_sort(@graph.edges, 0, @graph.edges.length-1) #sort edges smallest to largest
  end

  def compute_minimum_spanning_tree options = {}
    edge_index = 0
    while @vertices_trees_forest.clusters_amount > 1
      edge = @graph.edges[edge_index]
      if options[:stop_at_clusters_amount] and
         @vertices_trees_forest.clusters_amount == options[:stop_at_clusters_amount]
        return
      end
      # Comparing if two vertices belong to different subsets. Subsets are represented by 
      # their leader vertexes
      if(edge.tail_vertex.leader != edge.head_vertex.leader)
        @MST_edges << edge
        @vertices_trees_forest.union(edge.tail_vertex, edge.head_vertex)
      end
      edge_index += 1
    end
  end

  # We have a set of points. We divide them into groups (clusters) such that 
  # we have as much space between the individual groups as possible. 
  # The "as much space" is a maximization problem. Hence the phrase Maximum Spacing.
  #
  # The task is to determine the distance between k clusters. 
  # Distance is defined as the distance between 2 closest of the k clusters.
  # k=4 clusters can be joined into 1 cluster using k-1=3 edges.   
  # As edges added to MST are sorted smallest to largest, 
  # we simply need to return [k-1 from last-added to MST] edge
  def distance_for_k_clusters k
    @MST_edges[@MST_edges.size-k+1]
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

  mst = KruskalMST.new("clustering.txt")
  mst.compute_minimum_spanning_tree
  clusters = 4
  max_spacing_edge = mst.distance_for_k_clusters(clusters)
  
  finish = Time.now.to_f
  diff = finish - start
  puts "start: #{start}; finish: #{finish}; diff: #{diff}"
  puts mst.MST_cost #
  puts "Max spacing distance for #{clusters} clusters: " + 
       "edge of length #{max_spacing_edge.path_length} " +
       "between #{max_spacing_edge.head_vertex.element.id} " +
       "and #{max_spacing_edge.tail_vertex.element.id}"
end

execute

# edges.txt:
# MST length: -3612829, 0.82 seconds.

# clustering.txt:
# MST length: 12320
# Max spacing distance for 4 clusters: edge of length 106 between 455 and 414