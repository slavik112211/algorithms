require_relative '../../lib/heap.rb'

=begin
Greedy algorithms for minimizing the weighted sum of completion times.
This file describes a set of jobs with positive and integral weights and lengths. It has the format

[number_of_jobs]
[job_1_weight] [job_1_length]
[job_2_weight] [job_2_length]

You should NOT assume that edge weights or lengths are distinct.

1. Your task in this problem is to run the greedy algorithm that schedules jobs in decreasing order 
of the difference (weight - length). Recall from lecture that this algorithm is not always optimal. 
IMPORTANT: if two jobs have equal difference (weight - length), you should schedule the job with 
higher weight first. You should report the sum of weighted completion times of the resulting schedule
(a positive integer).
Answer: 3119219110

2. Your task now is to run the greedy algorithm that schedules jobs (optimally)
in decreasing order of the ratio (weight/length). In this algorithm, it does not 
matter how you break ties. You should report the sum of weighted completion times
of the resulting schedule (a positive integer)
Answer: 3087839038

=end

class TaskScheduler
  attr_reader :heap, :completion_times
  def initialize file_name, schedule_by
    file_name ||= "jobs.txt"
    schedule_by ||= :difference
    @heap = Heap.new(Heap::MAX)

    File.open(file_name, 'r').each_line.with_index { |line, index|
      if index == 0 #skip first line, as it denotes the total amount of jobs
        @completion_times = Array.new(line.to_i)
        next
      end
      line = line.split(" ")
      task = Task.new(index, schedule_by, line[0].to_i, line[1].to_i)
      @heap.push task
    }
  end

  def calculate_completion_times
    accumulated_completion_time = 0
    i = 0
    while (task = @heap.pop) != nil
      accumulated_completion_time = task.weight + accumulated_completion_time
      @completion_times[i] = accumulated_completion_time
      i+=1
    end
  end

  def sum_of_completion_times
    @completion_times.inject(0) { |result, element| result + element }
  end
end

class Task
  include Comparable
  attr_reader :id, :weight, :length, :weight_minus_length, :weight_length_ratio, :completion_time

  def initialize id, schedule_by, weight, length
    @id = id
    @weight = weight
    @length = length
    @weight_minus_length = weight - length
    @weight_length_ratio = weight.to_f / length.to_f
    @schedule_by = schedule_by
  end

  def <=> other_task
    if @schedule_by == :difference
      compare_by_weight_length_difference(other_task)
    elsif @schedule_by == :ratio
      compare_by_weight_length_ratio(other_task)
    end
  end

  private

  # Sorts jobs in decreasing order of the difference (weight - length).
  # If two jobs have equal difference (weight - length), schedule the job with 
  # higher weight first.
  # This algorithm is not always optimal.
  # Optimal - to schedule jobs by weight/length ratio.
  def compare_by_weight_length_difference other_task
    compare_result = @weight_minus_length <=> other_task.weight_minus_length
    compare_result = @weight <=> other_task.weight if compare_result == 0
    compare_result
  end

  def compare_by_weight_length_ratio other_task
    @weight_length_ratio <=> other_task.weight_length_ratio
  end
end

scheduler = TaskScheduler.new("jobs.txt", :difference)
scheduler.calculate_completion_times

puts "By weight - length difference: " + scheduler.sum_of_completion_times.to_s
# 3119219110

scheduler = TaskScheduler.new("jobs.txt", :ratio)
scheduler.calculate_completion_times

puts "By weight / length ratio: " + scheduler.sum_of_completion_times.to_s
# 3087839038