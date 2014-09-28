require_relative 'prims_minimum_spanning_tree.rb'

describe PrimJarnikMST do
  it "should not create vertex duplicates" do
    mst = PrimJarnikMST.new("minimum_spanning_tree_test.txt")
    
    mst.graph.vertices.size.should == 10
    vertex = mst.graph.vertices.find{ |vertex| vertex.id == 4 }
    vertex.edges.size.should == 6
    vertex.edges.map(&:path_length).should include(8, 9, 8, 7, 9, 10)
  end

  it "should compute the minimum spanning tree" do
    mst = PrimJarnikMST.new("minimum_spanning_tree_test.txt")
    mst.compute_minimum_spanning_tree

    mst.mst_edges.size.should == 9
    mst.MST_cost.should == 38
    # mst.MST_edges.each { |edge| puts edge }
  end
end