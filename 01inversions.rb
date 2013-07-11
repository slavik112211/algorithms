require 'debugger'

def merge_sort(array)
  return array if array.length == 1

  left_half  = array[0..(array.length/2 - 1)]
  right_half = array[(array.length/2)..(array.length - 1)]
  sorted_left_half  = merge_sort(left_half)
  sorted_right_half = merge_sort(right_half)
  merge_sorted_halfs(sorted_left_half, sorted_right_half)
end


def merge_sorted_halfs(sorted_left_half, sorted_right_half)
  array = Array.new(sorted_left_half.length + sorted_right_half.length)

  i = 0; j = 0
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
    elsif sorted_left_half[i] < sorted_right_half[j]
      value = sorted_left_half[i]
      i+=1
    end
    value
  }

  return array
end

a = [3,2,7,4,6,1,5,9,0,8]
b = [0,1,2,3,4,9,6,7,8,5] #4 inversions: 9 and 6, 9 and 7, 9 and 8, 9 and 5.

print merge_sort(a)
print "\n"