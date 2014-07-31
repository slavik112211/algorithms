require_relative 'graph_vertex.rb'
require 'set'

describe Vertex do
  it "should be identified as unique by Set by id property" do
    set = Set.new
    vertex1 = Vertex.new 5
    set.add(vertex1)

    vertex2 = Vertex.new 5
    
    puts set.find{|obj| obj.id == 5}
    set.include?(vertex2).should be_true

  end
end