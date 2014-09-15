require_relative 'union_find.rb'

describe UnionFind do
  it "should find a subset of a node" do
    uf = UnionFind.new(10, [0,1,2,3,4,5,6,7,8,9])
    
    uf.nodes.size.should == 10
    uf.nodes[4].leader.element.should == 4

    # find_subset_leader doesn't return a subset, but a subset's leader-node,
    # that represents the subset
    uf.find_subset_leader(uf.nodes[4]).element.should == 4
  end

  it "should unite subsets into general sets" do
    uf = UnionFind.new(10, [0,1,2,3,4,5,6,7,8,9])

    uf.union(uf.nodes[4], uf.nodes[5])
    uf.union(uf.nodes[2], uf.nodes[9])
    uf.union(uf.nodes[5], uf.nodes[7])
    uf.union(uf.nodes[7], uf.nodes[9])

    uf.union(uf.nodes[6], uf.nodes[3])

    #Element "0" belongs to subset "0", which has 1 element
    uf.nodes[0].leader.element.should     == 0
    uf.nodes[0].leader.subset_size.should == 1

    #Element "1" belongs to subset "1", which has 1 element
    uf.nodes[1].leader.element.should     == 1
    uf.nodes[1].leader.subset_size.should == 1

    #Elements "2", "4", "5", "7", "9" belongs to subset "4", which has 5 elements
    uf.nodes[2].leader.element.should     == 4
    uf.nodes[4].leader.element.should     == 4
    uf.nodes[5].leader.element.should     == 4
    uf.nodes[7].leader.element.should     == 4
    uf.nodes[9].leader.element.should     == 4
    uf.nodes[9].leader.subset_size.should == 5

    #Elements "3", "6" belongs to subset "6", which has 2 elements
    uf.nodes[6].leader.element.should     == 6
    uf.nodes[3].leader.element.should     == 6
    uf.nodes[3].leader.subset_size.should == 2

    #Element "8" belongs to subset "8", which has 1 element
    uf.nodes[8].leader.element.should     == 8
    uf.nodes[8].leader.subset_size.should == 1

    # ------------------------------------------------------------

    uf.union(uf.nodes[8], uf.nodes[3])
    uf.union(uf.nodes[3], uf.nodes[0])
    uf.union(uf.nodes[0], uf.nodes[1])
    uf.union(uf.nodes[3], uf.nodes[2])

    #Extra union to ensure that it doesn't brake things
    uf.union(uf.nodes[7], uf.nodes[1])

    #All elements belongs to subset "6", which has all 10 elements
    uf.nodes[0].leader.element.should     == 6
    uf.nodes[1].leader.element.should     == 6
    uf.nodes[2].leader.element.should     == 6
    uf.nodes[3].leader.element.should     == 6
    uf.nodes[4].leader.element.should     == 6
    uf.nodes[5].leader.element.should     == 6
    uf.nodes[6].leader.element.should     == 6
    uf.nodes[7].leader.element.should     == 6
    uf.nodes[8].leader.element.should     == 6
    uf.nodes[9].leader.element.should     == 6
    uf.nodes[9].leader.subset_size.should == 10
  end
end