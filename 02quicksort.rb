require 'debugger'

def quick_sort(array, min_index, max_index)
  if (max_index - min_index < 1)
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
    swap(array, min_index, max_index) #putting the pivot from last element to first element
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

def swap(array, i, j)
  swap = array[j] 
  array[j] = array[i]
  array[i] = swap
end

a = [3,2,7,4,6,1,5,9,0,8]


array = Array.new(10000)
i = 0
File.open("QuickSort.txt", 'r').each_line do |number|
  array[i] = number.to_i
  i+=1
end

#first_element_pivot = 162085 comparisons
#last_element_pivot  = 164123 comparisons

result = quick_sort(array, 0, array.length-1)
print result[:number_of_comparisons].to_s + "\n"
print "\n"