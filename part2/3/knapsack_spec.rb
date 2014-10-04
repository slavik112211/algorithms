require_relative 'knapsack.rb'

describe Knapsack do
  it "should read input file" do
    knapsack = Knapsack.new("knapsack_test.txt")
    knapsack.max_weight.should == 2000
    knapsack.items.size.should == 30
    knapsack.items[10].value.should == 843
    knapsack.items[10].weight.should == 532
  end

  it "should calculate subsolutions matrix" do
    knapsack = Knapsack.new("knapsack_test.txt")
    knapsack.calculate_subsolutions
    knapsack.max_value.should == 8681
  end

  it "should calculate subsolutions space-efficient" do
    knapsack = Knapsack.new("knapsack_test.txt")
    knapsack.calculate_subsolutions_space_efficient
    knapsack.max_value.should == 8681
  end

  it "should find items that have fit into the knapsack" do
    knapsack = Knapsack.new("knapsack_test.txt")
    knapsack.calculate_subsolutions
    knapsack.subsolutions.size.should == 31
    knapsack.subsolutions[0].size.should == 2001
    knapsack.find_items_in_knapsack
    knapsack.items_in_knapsack.size.should == 9
    knapsack.items_in_knapsack
      .inject(0) {|sum, item| sum+item.value}.should == 8681
  end
end
