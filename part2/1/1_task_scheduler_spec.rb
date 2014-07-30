require_relative '1_task_scheduler.rb'

describe TaskScheduler do

=begin
  Sorts jobs in decreasing order of the difference (weight - length).
  If two jobs have equal difference (weight - length), schedule the job with 
  higher weight first.

  1.   8 – 50 = -42; #10
  2.  74 – 59 =  15; #4
  3.  31 – 73 = −42; #9
  4.  45 – 87 = −42; #7
  5.  24 – 10 =  14; #5
  6.  41 – 83 = -42; #8
  7.  93 – 43 =  50; #2
  8.  88 –  4 =  84; #1
  9.  28 – 30 =  -2; #6
  10. 41 – 13 =  28; #3
=end
  describe "Jobs ordered by decreasing weight-length difference" do
    it "should sort jobs" do
      scheduler = TaskScheduler.new("jobs_test.txt", :difference)

      scheduler.heap.pop.id.should == 8
      scheduler.heap.pop.id.should == 7
      scheduler.heap.pop.id.should == 10
      scheduler.heap.pop.id.should == 2
      scheduler.heap.pop.id.should == 5
      scheduler.heap.pop.id.should == 9

      # weight-length=-42 for all the rest, should maintain order by weight only.
      scheduler.heap.pop.id.should == 4
      scheduler.heap.pop.id.should == 6
      scheduler.heap.pop.id.should == 3
      scheduler.heap.pop.id.should == 1
    end

    # Job completion time is calculated as a weight of a job, 
    # and a sum of all job weights, that were executed prior running the job
    # (all jobs, that the job had to wait for, before it could have been run)
    it "should calculate completion times for jobs" do
      scheduler = TaskScheduler.new("jobs_test.txt", :difference)
      scheduler.calculate_completion_times

      scheduler.completion_times.should == [88, 181, 222, 296, 320, 348, 393, 434, 465, 473]
      scheduler.sum_of_completion_times.should == 3220
    end
  end

=begin
  Sorts jobs (optimally) in decreasing order of the ratio (weight/length)

  1.   8 / 50 = 0.16; #10
  2.  74 / 59 = 1.25; #5
  3.  31 / 73 = 0.43; #9
  4.  45 / 87 = 0.52; #7
  5.  24 / 10 = 2.4;  #3
  6.  41 / 83 = 0.49; #8
  7.  93 / 43 = 2.16; #4
  8.  88 /  4 = 22;   #1
  9.  28 / 30 = 0.93; #6
  10. 41 / 13 = 3.15; #2
=end
  describe "Jobs ordered by decreasing order of the ratio weight/length" do
    it "should sort jobs" do
      scheduler = TaskScheduler.new("jobs_test.txt", :ratio)

      scheduler.heap.pop.id.should == 8
      scheduler.heap.pop.id.should == 10
      scheduler.heap.pop.id.should == 5
      scheduler.heap.pop.id.should == 7
      scheduler.heap.pop.id.should == 2
      scheduler.heap.pop.id.should == 9
      scheduler.heap.pop.id.should == 4
      scheduler.heap.pop.id.should == 6
      scheduler.heap.pop.id.should == 3
      scheduler.heap.pop.id.should == 1
    end

    it "should calculate completion times for jobs" do
      scheduler = TaskScheduler.new("jobs_test.txt", :ratio)
      scheduler.calculate_completion_times

      scheduler.completion_times.should == [88, 129, 153, 246, 320, 348, 393, 434, 465, 473]
      scheduler.sum_of_completion_times.should == 3049
    end
  end
end