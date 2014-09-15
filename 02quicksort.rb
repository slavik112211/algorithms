# require 'debugger'

def quick_sort(array, min_index, max_index)
  if (max_index - min_index < 1) #at least 2 elements to sort
    return {:number_of_comparisons => 0}
  end

  partition_result = quick_sort_partition(array, min_index, max_index)
  pivot_position   = partition_result[:pivot_position]

  number_of_comparisons_left_part  = quick_sort(array, min_index, pivot_position-1)
  number_of_comparisons_right_part = quick_sort(array, pivot_position+1, max_index)

  return {:number_of_comparisons => partition_result[:number_of_comparisons] +
                                    number_of_comparisons_left_part[:number_of_comparisons] + 
                                    number_of_comparisons_right_part[:number_of_comparisons]}
end

def quick_sort_partition(array, min_index, max_index)
    pivot_position = find_median(array, min_index, max_index)
    swap(array, min_index, pivot_position) #putting the pivot from median element to first element
    
    number_of_comparisons = max_index - min_index
    pivot_position = min_index

    j = min_index+1; #denotes the split position in array - that is where the next [element<pivot] should be put in swap. 

    for i in (min_index+1)..max_index #skipping the first element, as it contains pivot
      if(array[i] < array[pivot_position])
        swap(array, i, j)
        j+=1
      end
    end
    swap(array, j-1, pivot_position) #putting the pivot in between [less than pivot]..pivot..[more than pivot]

    return {:pivot_position        => j-1,
            :number_of_comparisons => number_of_comparisons}
end

=begin
If the array has odd length it should be clear what the "middle" element is; 
for an array with even length 2k, use the kth element as the "middle" element. 
So for the array 4 5 6 7, the "middle" element is the second one ---- 5 and not 6!

Identify which of these three elements is the median (i.e., the one whose value 
is in between the other two), and use this as your pivot.
=end
def find_median(array, min_index, max_index)
  #Note that the division expression 5/2 does not return 2.5. 
  #Because you are only working with integers (i.e. Fixnums), 
  #Ruby will return an integer with the decimal part cut off.
  middle_index = min_index + (max_index - min_index)/2
  
  #when only 2 elements in supplied array, both min_index and middle_index point to the left-most element.
  if   ((array[middle_index] <= array[min_index]    and array[min_index]    <= array[max_index]) or 
        (array[max_index]    <= array[min_index]    and array[min_index]    < array[middle_index]))
    return min_index
  elsif((array[min_index]    <= array[middle_index] and array[middle_index] <= array[max_index]) or
        (array[max_index]    <= array[middle_index] and array[middle_index] <= array[min_index]))
    return middle_index
  elsif((array[min_index]    <=  array[max_index]   and array[max_index]    <= array[middle_index]) or
        (array[middle_index] <=  array[max_index]   and array[max_index]    <= array[min_index]) or
        (min_index           == middle_index        and array[max_index])   < array[middle_index]) #only 2 elements, and the right-hand is smaller 
    return max_index
  end
end

def swap(array, i, j)
  return if i == j
  swap = array[j] 
  array[j] = array[i]
  array[i] = swap
end

# array = [3,2,7,4,6,1,5,9,0,8]


# array = Array.new(10000)
# i = 0
# File.open("QuickSort.txt", 'r').each_line do |number|
#   array[i] = number.to_i
#   i+=1
# end

#first_element_pivot = 162085 comparisons
#last_element_pivot  = 164123 comparisons
#median_element_pivot= 138382 comparisons, not including those in find_median()

# result = quick_sort(array, 0, array.length-1)
# print result[:number_of_comparisons].to_s + "\n"
# print array
# print "\n"