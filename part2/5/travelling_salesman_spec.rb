require_relative 'travelling_salesman.rb'

describe TravellingSalesman do
  it "should calculate distances matrix" do
    tsp = TravellingSalesman.new("tsp_test1.txt")
    distances = tsp.distances.map {|row| row[1].map{|distance| distance.round(2)} }
    distances.should ==
    [[0,       74.54,   4109.91, 3048.0,  2266.91], 
     [74.54,   0,       4069.71, 2999.49, 2213.59], 
     [4109.91, 4069.71, 0,       1172.37, 1972.94], 
     [3048.0,  2999.49, 1172.37, 0,       816.67 ], 
     [2266.91, 2213.59, 1972.94, 816.67,  0      ]]
  end

  it "should find all the subsets of a complete set of points" do
    tsp = TravellingSalesman.new("tsp_test1.txt")
    tsp.find_subsets_of_points

    # tsp_test1.txt has 5 points total set, subsets include upto 4 points.
    tsp.points_subsets.should == 
      { 
        1=>[1, 2, 4, 8, 16], 
        2=>[3, 5, 6, 9, 10, 12, 17, 18, 20, 24], 
        3=>[7, 11, 13, 14, 19, 21, 22, 25, 26, 28], 
        4=>[15, 23, 27, 29, 30],
        5=>[31]
      }

    # same subsets, but in binary form
    points_subsets = tsp.points_subsets.each { |subset_size| 
      subset_size[1].map! { |subset| 
        subset.to_s(2).rjust(tsp.points_amount, padstr='0')
      }
    }
    points_subsets.should ==
      {
        1=>["00001", "00010", "00100", "01000", "10000"], 
        2=>["00011", "00101", "00110", "01001", "01010", "01100", "10001", "10010", "10100", "11000"], 
        3=>["00111", "01011", "01101", "01110", "10011", "10101", "10110", "11001", "11010", "11100"], 
        4=>["01111", "10111", "11011", "11101", "11110"],
        5=>["11111"]
      }
  end

  it "should find all the point subsets containing 1st point" do
    tsp = TravellingSalesman.new("tsp_test1.txt")
    tsp.find_subsets_of_points({:with_first_point_only=>true})

    # tsp_test1.txt has 5 points total set, subsets include upto 4 points.
    tsp.points_subsets.should == 
      { 
        1=>[1], 
        2=>[3, 5, 9, 17], 
        3=>[7, 11, 13, 19, 21, 25], 
        4=>[15, 23, 27, 29],
        5=>[31]
      }

    # same subsets, but in binary form
    points_subsets = tsp.points_subsets.each { |subset_size| 
      subset_size[1].map! { |subset| 
        subset.to_s(2).rjust(tsp.points_amount, padstr='0')
      }
    }
    points_subsets.should ==
      {
        1=>["00001"], 
        2=>["00011", "00101", "01001", "10001"], 
        3=>["00111", "01011", "01101", "10011", "10101", "11001"], 
        4=>["01111", "10111", "11011", "11101"],
        5=>["11111"]
      }
  end

  it "should filter subsets containing first point" do
    subsets = [7, 11, 13, 14, 19, 21, 22, 25, 26, 28]
    # subsets = ["00111", "01011", "01101", "01110", "10011", "10101", "10110", "11001", "11010", "11100"]
    filtered_subsets = TravellingSalesman.filter_subsets_containing_first_point(subsets)
    filtered_subsets.should == [7, 11, 13, 19, 21, 25]
    # filtered_subsets.should == ["00111", "01011", "01101", "10011", "10101", "11001"]

    filtered_subsets = TravellingSalesman.simple_filter_subsets_containing_first_point(subsets)
    filtered_subsets.should == [7, 11, 13, 19, 21, 25]
  end

  it "should return points of a subset" do 
    points = TravellingSalesman.points_of_subset(27) #"11011"

    #"11011", counting right to left: 1st (excluded), 2nd, 4th, 5th.
    points.should == [2, 4, 5]
  end

  it "should subtract a point from a set of points" do
    subset = TravellingSalesman.find_subset_minus_point(27, 4) #"11011"

    #27 = 11011, counting right to left: 1st, 2nd, 4th, 5th.
    #11011 - 4th point = 10011 = 19, or a set of 1st, 2nd and 5th points.
    subset.should == 19
  end

  it "should calculate the TSP path using Held-Karp algorithm" do
    tsp = TravellingSalesman.new("tsp_test1.txt")
    tsp.calculate_optimal_path
    tsp.solution.should == {:prev_point=>2, :path_length=>8387.077130278542} 
    tsp.optimal_path.should == [1, 3, 4, 5, 2, 1]
  end
end