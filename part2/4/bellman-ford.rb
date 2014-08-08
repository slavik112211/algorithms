require_relative '../../lib/graph.rb'

class BellmanFordShortestPath
  attr_reader :shortest_paths, :min_shortest_path
  def initialize file_name
    @graph = Graph.new file_name
  end

  def vertices
    @graph.vertices
  end

  def array_index vertex
    vertex.id-1
  end

  def compute_shortest_paths
    result = true
    @min_shortest_path = 0
    vertices.each.with_index { |vertex, index|
      puts index
      result = compute_bellman_ford_shortest_path vertex
      @min_shortest_path = minimum(@min_shortest_path, @min_shortest_path_per_vertex)
      break if !result
    }
    result
  end

  def compute_bellman_ford_shortest_path start_vertex
    # a table storing the shortest paths;
    # outer array (i): amount of edges limit, that are allowed for shortest path 
    # inner array (j): path ending vertex id
    @shortest_paths = Array.new(vertices.size+1) { Array.new(vertices.size, Float::INFINITY) }
    @shortest_paths[0][array_index(start_vertex)] = 0
    @min_shortest_path_per_vertex = 0

    for i in 1..(vertices.size)
      vertices.each { |vertex|
        previous_path_length = @shortest_paths[i-1][array_index(vertex)]

        relaxed_smallest_path_length = Float::INFINITY
        vertex.incoming_edges.each { |edge|
          relaxed_path_length = @shortest_paths[i-1][array_index(edge.tail_vertex)] + edge.path_length
          relaxed_smallest_path_length = minimum(relaxed_smallest_path_length, relaxed_path_length)
        }
        @shortest_paths[i][array_index(vertex)] = minimum(previous_path_length, relaxed_smallest_path_length)
        @min_shortest_path_per_vertex = minimum(@min_shortest_path_per_vertex, @shortest_paths[i][array_index(vertex)])
      }
      #quit if no improvement over iteration, and it's not the last iteration
      return true if no_improvement(i) and (i != vertices.size)
    end
    negative_cycle_present ? false : true
  end

  def print_shortest_paths
    puts @shortest_paths.inspect
  end

  private
  def minimum left_value, right_value
    left_value <= right_value ? left_value : right_value
  end

  def negative_cycle_present
    @shortest_paths[vertices.size-1] != @shortest_paths[vertices.size] ? true : false
  end

  def no_improvement i
    @shortest_paths[i] == @shortest_paths[i-1] ? true : false
  end

end

def execute
  start = Time.now.to_f

  bfsp = BellmanFordShortestPath.new("g3.txt")

  result = bfsp.compute_shortest_paths
  if !result
    puts "Negative cycle present."
    exit
  end
  
  finish = Time.now.to_f
  diff = finish - start
  puts "start: #{start}; finish: #{finish}; diff: #{diff}"

  puts "Min shortest path: " + bfsp.min_shortest_path.to_s
  # bfsp.print_shortest_paths
end
execute