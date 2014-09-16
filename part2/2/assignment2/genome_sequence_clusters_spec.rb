require_relative 'genome_sequence_clusters.rb'
require 'debugger'

describe GenomeSequenceClusters do
  it "should read sequences from file" do
    cluster = GenomeSequenceClusters.new("clustering_sample.txt")
    cluster.points_amount.should       == 10
    cluster.points.size.should         == 10
    cluster.sequence_bit_length.should == 24

    cluster.points.should == [14734287, 6709165, 7344869, 6709165, 
      5157860, 14734287, 1628832, 556504, 14734287, 8049727]
  end
  
  it "should find duplicate sequences" do
    cluster = GenomeSequenceClusters.new("clustering_sample.txt")
    cluster.find_subsets_of_identical_sequences

    cluster.sequences[0].should == {14734287=>[0, 5, 8], 6709165=>[1, 3]}
  end



  it "should find sequences of size 1" do
    cluster = GenomeSequenceClusters.new
    sequence_bit_length = 11
    cluster.find_sequences_of_size1(sequence_bit_length)
    cluster.sequences_of_size1.should ==
      [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    cluster.sequences_of_size1.size.should == 11

    cluster.sequences_into_binary_form(cluster.sequences_of_size1, sequence_bit_length)
    cluster.sequences_of_size1.should ==
      ["00000000001", 
       "00000000010", 
       "00000000100", 
       "00000001000", 
       "00000010000", 
       "00000100000", 
       "00001000000", 
       "00010000000", 
       "00100000000", 
       "01000000000", 
       "10000000000"]
  end

  it "should find sequences of size 2" do
    cluster = GenomeSequenceClusters.new
    sequence_bit_length = 5
    cluster.find_sequences_of_size2(sequence_bit_length)
    cluster.sequences_of_size2.should ==
      [3, 5, 6, 9, 10, 12, 17, 18, 20, 24]
    cluster.sequences_of_size2.size.should == 10

    cluster.sequences_into_binary_form(cluster.sequences_of_size2, sequence_bit_length)
    cluster.sequences_of_size2.should ==
      ["00011", "00101", "00110", "01001", "01010", "01100", "10001", "10010", "10100", "11000"]
  end
end