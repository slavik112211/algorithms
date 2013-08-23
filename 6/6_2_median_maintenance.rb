require_relative 'heap.rb'

left_half_heap  = Heap.new(Heap::MAX)
right_half_heap = Heap.new(Heap::MIN)

medianas = Array.new 10001

i = 0

File.open("Median.txt", 'r').each_line { |line|
  i+=1
  number = line.to_i
  if(left_half_heap.size == 0 and right_half_heap.size == 0)
  	left_half_heap.push(number)
  	medianas[i] = left_half_heap.next
  	next
  end
  (number > left_half_heap.next) ? right_half_heap.push(number) : left_half_heap.push(number)
  size_diff = right_half_heap.size - left_half_heap.size
  if (size_diff > 0)
  	element = right_half_heap.pop
  	left_half_heap.push element
  elsif (size_diff < -1) 
  	element = left_half_heap.pop
  	right_half_heap.push element
  end
  medianas[i] = left_half_heap.next
}

puts left_half_heap.size
puts right_half_heap.size

medianas.shift
#puts medianas.inspect
puts medianas.inject(0){|sum,mediana| sum + mediana } % 10000
puts medianas.inject(0){|sum,mediana| sum + mediana }

#46831213
#1213