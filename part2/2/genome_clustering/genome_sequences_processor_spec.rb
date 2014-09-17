require_relative 'genome_sequences_processor.rb'

describe GenomeSequencesProcessor do
  it "should read sequences from file" do
    processor = GenomeSequencesProcessor.new("testdata/clustering_test_2.txt")
    processor.points_amount.should       == 15
    processor.points.size.should         == 15
    processor.sequence_bit_length.should == 8

    processor.points.should == [200, 63, 169, 38, 174, 219, 167, 228, 
      1, 70, 192, 150, 62, 43, 30]
  end
  
  # see clustering_test_2_explanation.txt for details
  it "should find clusters of sequences" do
    processor = GenomeSequencesProcessor.new("testdata/clustering_test_2.txt")
    processor.find_clusters_of_sequences

    processor.clusters.to_s.should ==
    "Point: 1, cluster: 1; "  + 
    "Point: 11, cluster: 1; " + 
    "Point: 2, cluster: 2; "  + 
    "Point: 13, cluster: 2; " + 
    "Point: 14, cluster: 2; " + 
    "Point: 15, cluster: 2; " + 
    "Point: 3, cluster: 2; "  + 
    "Point: 4, cluster: 2; "  + 
    "Point: 5, cluster: 2; "  + 
    "Point: 7, cluster: 2; "  + 
    "Point: 10, cluster: 2; " + 
    "Point: 8, cluster: 1; "  + 
    "Point: 12, cluster: 2; "

    processor.clusters_amount.should == 4
  end

  it "should find sequence_xor of size 1" do
    processor = GenomeSequencesProcessor.new
    sequence_bit_length = 11
    processor.find_sequence_xor1(sequence_bit_length)
    processor.sequence_xor1.should ==
      [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    processor.sequence_xor1.size.should == 11

    processor.sequences_into_binary_form(processor.sequence_xor1, sequence_bit_length)
    processor.sequence_xor1.should ==
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

  it "should find sequence_xor of size 2" do
    processor = GenomeSequencesProcessor.new
    sequence_bit_length = 5
    processor.find_sequence_xor2(sequence_bit_length)
    processor.sequence_xor2.should ==
      [3, 5, 6, 9, 10, 12, 17, 18, 20, 24]
    processor.sequence_xor2.size.should == 10

    processor.sequences_into_binary_form(processor.sequence_xor2, sequence_bit_length)
    processor.sequence_xor2.should ==
      ["00011", "00101", "00110", "01001", "01010", "01100", "10001", "10010", "10100", "11000"]
  end
end