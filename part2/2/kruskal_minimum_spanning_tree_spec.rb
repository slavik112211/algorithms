require_relative 'kruskal_minimum_spanning_tree.rb'
require 'debugger'

describe KruskalMST do
  it "should calculate minimum spanning tree" do
    mst = KruskalMST.new("clustering_test.txt")
    mst.compute_minimum_spanning_tree

    mst.MST_edges.size.should == 9
    mst.MST_cost.should == 38
  end

  # Kruskal's algorithm for minimum spanning trees can also be used as a CLUSTERING algorithm.
  # http://en.wikipedia.org/wiki/Single-linkage_clustering
  # points should be divided into 4 groups, see clustering_test.png
  it "should cluster points into a requested set of clusters" do
    mst = KruskalMST.new("clustering_test.txt")
    mst.compute_minimum_spanning_tree({:stop_at_clusters_amount => 4})

    #point 1 belongs to group "1"
    mst.vertices_trees_forest.nodes[0].leader.element.id.should == 1

    #point 4 belongs to group "4"
    mst.vertices_trees_forest.nodes[3].leader.element.id.should == 4

    #points 2,3,5,6 belong to group "3"
    mst.vertices_trees_forest.nodes[1].leader.element.id.should == 3
    mst.vertices_trees_forest.nodes[2].leader.element.id.should == 3
    mst.vertices_trees_forest.nodes[4].leader.element.id.should == 3
    mst.vertices_trees_forest.nodes[5].leader.element.id.should == 3

    #points 7,8,9,10 belong to group "8"
    mst.vertices_trees_forest.nodes[6].leader.element.id.should == 8
    mst.vertices_trees_forest.nodes[7].leader.element.id.should == 8
    mst.vertices_trees_forest.nodes[8].leader.element.id.should == 8
    mst.vertices_trees_forest.nodes[9].leader.element.id.should == 8
  end

  it "should find max-spacing between k clusters" do
    mst = KruskalMST.new("clustering_test.txt")
    mst.compute_minimum_spanning_tree
    max_spacing_edge = mst.distance_for_k_clusters 4

    max_spacing_edge.path_length.should == 7
    max_spacing_edge.head_vertex.element.id.should == 7
    max_spacing_edge.tail_vertex.element.id.should == 4
  end
end