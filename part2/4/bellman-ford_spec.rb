require_relative 'bellman-ford.rb'

describe BellmanFordShortestPath do
  it "should compute shortest paths from a given vertex to all others" do
    bfsp = BellmanFordShortestPath.new("no_negative_cycle_test.txt")
    result = bfsp.compute_bellman_ford_shortest_path(bfsp.vertices[0])
    result.should == true # no negative cycles
    bfsp.shortest_paths.inspect.should == "[[0, Infinity, Infinity, Infinity, Infinity], [0, 2, 4, Infinity, Infinity], [0, 2, 3, 4, 8], [0, 2, 3, 4, 6], [0, 2, 3, 4, 6], [0, 2, 3, 4, 6]]"
  end

  it "should detect negative cycles" do
    bfsp = BellmanFordShortestPath.new("negative_cycle_test.txt")
    result = bfsp.compute_bellman_ford_shortest_path(bfsp.vertices[0])
    result.should == false # negative cycle found
  end
end