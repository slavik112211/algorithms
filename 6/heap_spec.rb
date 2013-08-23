require_relative 'heap.rb'

# Heap is stored as array of elements
# 1st element - root, 2nd, 3rd elements - 2nd level
# 4th, 5th, 6th, 7th elements - 3rd level, etc
describe Heap do
  it "should return child's node parent index" do
    nodes = [4,4,8,9,4,12,9,11,13]
    heap = Heap.new(Heap::MIN, nodes)
    
    # parent of 12 is 8
    heap.send(:get_parent_index, 5).should == 2
    # parent of 11 is 9
    heap.send(:get_parent_index, 7).should == 3
  end

  describe "Min" do
    it "should return smallest child node index for min-heaps" do
      nodes = [4,4,8,9,4,12,9,11,13,7]
      heap = Heap.new(Heap::MIN, nodes)
      
      # children of 9 = [11,13], smallest = 11
      heap.send(:get_swap_child_index, 3).should == 7
      # children of 8 = [12,9], smallest = 9
      heap.send(:get_swap_child_index, 2).should == 6
      # children of 4 = [7,nil], smallest = 7
      heap.send(:get_swap_child_index, 4).should == 9
      # children of 13 = [nil,nil], smallest = nil
      heap.send(:get_swap_child_index, 8).should be_nil
    end

    it "should maintain order in min-heap on insertions" do
      nodes = [4,4,8,9,4,12,9,11,13]
      heap = Heap.new(Heap::MIN, nodes)
      heap.push 7
      heap.push 10
      heap.push 5
      heap.container.should == [4,4,5,9,4,8,9,11,13,7,10,12]
      heap.push 2
      heap.container.should == [2,4,4,9,4,5,9,11,13,7,10,12,8]
    end

    it "should maintain order in min-heap on extractions" do
      nodes = [4,4,5,9,4,8,9,11,13,7,10,12]
      heap = Heap.new(Heap::MIN, nodes)
      
      popped_element = heap.pop
      popped_element.should == 4
      heap.container.should == [4,4,5,9,7,8,9,11,13,12,10]
      
      popped_element = heap.pop
      popped_element.should == 4
      heap.container.should == [4,7,5,9,10,8,9,11,13,12]
      
      popped_element = heap.pop
      popped_element.should == 4
      heap.container.should == [5,7,8,9,10,12,9,11,13]

      popped_element = heap.pop
      popped_element.should == 5
      heap.container.should == [7,9,8,11,10,12,9,13]
    end
  end

  describe "Max" do
    it "should return largest child node index for max-heaps" do
      nodes = [13,11,12,9,8,9,4,3,7,2]
      heap = Heap.new(Heap::MAX, nodes)
      
      # children of 9 = [3,7], largest = 7
      heap.send(:get_swap_child_index, 3).should == 8
      # children of 12 = [9,4], largest = 9
      heap.send(:get_swap_child_index, 2).should == 5
      # children of 8 = [2,nil], largest = 2
      heap.send(:get_swap_child_index, 4).should == 9
      # children of 4 = [nil,nil], largest = nil
      heap.send(:get_swap_child_index, 6).should be_nil
    end

    it "should maintain order in max-heap on insertions" do
      nodes = [13,11,12,9,8,9,4,3,7,2]
      heap = Heap.new(Heap::MAX, nodes)
      heap.push 7
      heap.push 10
      heap.container.should == [13,11,12,9,8,10,4,3,7,2,7,9]
      heap.push 15
      heap.container.should == [15,11,13,9,8,12,4,3,7,2,7,9,10]
    end

    it "should maintain order in max-heap on extractions" do
      nodes = [13,11,12,9,8,9,4,3,7,2]
      heap = Heap.new(Heap::MAX, nodes)
      
      popped_element = heap.pop
      popped_element.should == 13
      heap.container.should == [12,11,9,9,8,2,4,3,7]
      
      popped_element = heap.pop
      popped_element.should == 12
      heap.container.should == [11,9,9,7,8,2,4,3]
      
      popped_element = heap.pop
      popped_element.should == 11
      heap.container.should == [9,8,9,7,3,2,4]

      popped_element = heap.pop
      popped_element.should == 9
      heap.container.should == [9,8,4,7,3,2]
    end
  end
end