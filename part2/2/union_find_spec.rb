require_relative 'union_find.rb'
require 'debugger'

describe UnionFind do
  it "should find a subset of a node" do
    uf = UnionFind.new
    uf.add_subsets [0,1,2,3,4,5,6,7,8,9]
    
    uf.nodes.size.should == 10
    uf.nodes[4].leader.object.should == 4

    # find_subset doesn't return a subset, but a subset's leader-node,
    # that represents the subset
    uf.find_subset(uf.nodes[4]).should == 4
  end

  it "should unite subsets into general sets" do
    uf = UnionFind.new
    uf.add_subsets [0,1,2,3,4,5,6,7,8,9]

    uf.union(uf.nodes[4], uf.nodes[5])
    uf.subsets.size.should == 9

    uf.union(uf.nodes[2], uf.nodes[9])
    uf.union(uf.nodes[5], uf.nodes[7])
    uf.union(uf.nodes[7], uf.nodes[9])

    uf.union(uf.nodes[6], uf.nodes[3])

    debugger
    uf.subsets.size.should == 5
  end
end