require 'debugger'

def merge_sort_and_count_inversions(array)
  if array.length == 1
    return {:sorted_array => array,
            :inversions   => 0}
  end

  left_half  = array[0..(array.length/2 - 1)]
  right_half = array[(array.length/2)..(array.length - 1)]

  left_half_result  = merge_sort_and_count_inversions(left_half)
  right_half_result = merge_sort_and_count_inversions(right_half)

  sorted_array_result = merge_sorted_halfs_and_count_inversions(left_half_result[:sorted_array], right_half_result[:sorted_array])
  return {:sorted_array => sorted_array_result[:sorted_array],
          :inversions   => left_half_result[:inversions] + right_half_result[:inversions] + sorted_array_result[:inversions]}
end


def merge_sorted_halfs_and_count_inversions(sorted_left_half, sorted_right_half)
  array = Array.new(sorted_left_half.length + sorted_right_half.length)

  i = 0; j = 0; inversions = 0
  array.map! {|value|
    if sorted_left_half[i].nil?
      value = sorted_right_half[j]
      j+=1
    elsif sorted_right_half[j].nil?
      value = sorted_left_half[i]
      i+=1
    elsif sorted_left_half[i] > sorted_right_half[j]
      value = sorted_right_half[j]
      j+=1
      inversions += sorted_left_half.length - i
    elsif sorted_left_half[i] < sorted_right_half[j]
      value = sorted_left_half[i]
      i+=1
    end
    value
  }

  return {:sorted_array => array,
          :inversions   => inversions}
end

a = [3,2,7,4,6,1,5,9,0,8] #17 inversions
b = [0,1,2,3,4,9,6,7,8,5] #7  inversions: 9 and 6, 9 and 7, 9 and 8, 9 and 5; 6 and 5, 7 and 5, 8 and 5
c = [0,3,2,1,4,9,6,7,8,5] #10 inversions: 9 and 6, 9 and 7, 9 and 8, 9 and 5; 6 and 5, 7 and 5, 8 and 5; 3 and 2, 3 and 1, 2 and 1
d = [1,3,5,2,4,6] #3 inversions: 3 and 2, 5 and 2, 5 and 4
e = [9,8,7,6,5,4,3,2,1,0] #45 inversions

result = merge_sort_and_count_inversions(e)
print result[:inversions]
print "\n"