require 'debugger'

=begin
http://en.wikipedia.org/wiki/Kosaraju%27s_algorithm

Kosaraju's algorithm (also known as the Kosaraju-Sharir algorithm)
is an algorithm to find the strongly connected components of a directed graph.
It makes use of the fact that the transpose graph (the same graph with the direction of every edge reversed) 
has exactly the same strongly connected components as the original graph.
=end

class Graph
  attr_accessor :vertices, :explored_vertices, :finishing_times, :scc_leaders, :scc_vertex_count

  def initialize(number_of_vertices)
    @vertices = Array.new(number_of_vertices)

    #stores fresh array of booleans for each graph traverse
    @explored_vertices = Array.new(number_of_vertices)

    @finishing_times = Array.new(number_of_vertices)
    @scc_leaders = Array.new(number_of_vertices)
    @scc_leader_id = nil #s in algorithm description
    @finishing_time = 0 #t in algorithm description
    @pass = 0
  end

  def find_or_create_vertex(id)
  	vertex = find_vertex(id)
  	if !vertex
  	  vertex = Vertex.new(id)
  	  @vertices[id.to_i-1] = vertex
  	end
  	vertex
  end

  def find_vertex(id)
    @vertices[id.to_i-1]
  end

  def remove_vertex(vertex)
    @vertices.delete(vertex)
  end

  def to_s
    @vertices.map{|vertex| vertex.to_s }.join("; ")
  end


  # As this is a recursive method, the depth of the search is limited by function call stack settings.
  def depth_first_search_recursive(starting_vertex_id)
    @explored_vertices[starting_vertex_id.to_i-1] = true
    @scc_leaders[starting_vertex_id.to_i-1] = @scc_leader_id if @pass == 2
    tail_vertex = find_vertex starting_vertex_id
    tail_vertex.head_vertices.each{|head_vertex|
      depth_first_search_recursive(head_vertex.id) if !@explored_vertices[head_vertex.id.to_i-1]
    }
    if(@pass == 1)
      @finishing_time+=1
      @finishing_times[tail_vertex.id.to_i-1] = @finishing_time
    end
  end

  def depth_first_search_iterative(starting_vertex)
    dfs_vertices_stack = Array.new
    dfs_vertices_stack.push(starting_vertex)
    @scc_leader_id = starting_vertex.id

    while vertex = dfs_vertices_stack.last
      #puts "last stack vertex: " + vertex.id.to_s
      #puts "was it explored before: " + (@explored_vertices[vertex.id.to_i-1] == true).to_s

      if @pass == 2 and @explored_vertices[vertex.id.to_i-1] != true
        @scc_leaders[vertex.id.to_i-1] = @scc_leader_id
        #puts "assigning leader " + @scc_leader_id.to_s + "to vertex: " + vertex.id.to_s
      end

      @explored_vertices[vertex.id.to_i-1] = true

      head_vertex_to_explore = false
      vertex.head_vertices.each{|head_vertex|
        if @explored_vertices[head_vertex.id.to_i-1] != true
          dfs_vertices_stack.push(head_vertex)
          head_vertex_to_explore = true
          break
        end
      }
      next if head_vertex_to_explore

      finish_vertex = dfs_vertices_stack.pop
      if(@pass == 1)
        @finishing_time+=1
        @finishing_times[finish_vertex.id.to_i-1] = @finishing_time
        #puts "finishing vertex: " + finish_vertex.id.to_s + ", finishing time: " + @finishing_time.to_s
      end
    end
  end

  def find_finishing_times
    @explored_vertices.map!{|i| nil}
    @finishing_times.map!{|i| nil}
    @finishing_time = 0
    @pass = 1

    @vertices.reverse_each { |vertex|
      depth_first_search_iterative(vertex) if !@explored_vertices[vertex.id.to_i-1]
    }
  end

  def find_strongly_connected_components
    puts "find_strongly_connected_components"
    @explored_vertices.map!{|i| nil}
    @scc_leaders.map!{|i| nil}
    @scc_leader_id = nil
    @pass = 2
    sort_vertices_according_to_finishing_times

    @vertices.reverse_each { |vertex|
      depth_first_search_iterative(vertex) if !@explored_vertices[vertex.id.to_i-1]
    }
  end

  def sort_vertices_according_to_finishing_times
    sorted_vertices = Array.new(@vertices.length)
    @vertices.each_with_index {|vertex, vertex_index|
      new_vertex_index = @finishing_times[vertex_index] - 1
      sorted_vertices[new_vertex_index] = vertex
    }
    @vertices = sorted_vertices
  end

  def get_scc_vertex_count
    scc = Hash.new
    @scc_leaders.each{ |n| scc.has_key?(n) ? scc[n]+=1 : scc[n]=1 }
    @scc_vertex_count = scc.values.sort.reverse!.first(100).join(", ")
  end
end

class Vertex
  attr_accessor :id, :head_vertices

  def initialize(id)
    @id = id
    @head_vertices = Array.new
  end

  def to_s  
    "Vertex #{@id}. Head vertices: " + @head_vertices.map{|head_vertex| head_vertex.id.to_s }.join(" ") 
  end

  def find_or_add_head(vertex)
  	@head_vertices<<vertex if !has_as_head?(vertex)
  end

  def has_as_head?(vertex)
  	found = @head_vertices.select{|head_vertex| head_vertex.id == vertex.id }
  	return found.length>0 ? true : false
  end
end

def create_graphs(filename, number_of_vertices)
  forward_graph = Graph.new(number_of_vertices)
  reverse_graph = Graph.new(number_of_vertices)
  number_of_lines = %x{wc -l #{filename}}.split.first.to_i
  puts "number of lines in input graph file: #{number_of_lines}"
  
  i = 0
  File.open(filename, 'r').each_line do |line|
  	next if line.strip.empty?
  	edge = line.split(" ")

  	tail_vertex = forward_graph.find_or_create_vertex(edge[0])
  	head_vertex = forward_graph.find_or_create_vertex(edge[1])
  	tail_vertex.find_or_add_head(head_vertex)

  	tail_vertex = reverse_graph.find_or_create_vertex(edge[1])
  	head_vertex = reverse_graph.find_or_create_vertex(edge[0])
    tail_vertex.find_or_add_head(head_vertex)
    i+=1
    puts i if i%100000 == 0 
  end
  return [forward_graph, reverse_graph]
end

def kosaraju_strongly_connected_components
  puts "Building graphs. " + print_time
  graphs = create_graphs("SCC.txt", 875714)
  #graphs = create_graphs("scc5.txt", 11)
  puts "Finding finishing times. " + print_time
  graphs[1].find_finishing_times
  graphs[0].finishing_times = graphs[1].finishing_times
  puts "Finding SCCs. " + print_time
  graphs[0].find_strongly_connected_components
  #puts "Finishing times: " + graphs[1].finishing_times.join("; ")
  #puts "SCCs: " + graphs[0].scc_leaders.join("; ")
  puts "SCC vertex counts: " + graphs[0].get_scc_vertex_count
  puts "Algorithm finished. " + print_time
end

def print_time
  Time.now.strftime("Current time: %Y-%m-%d %I:%M:%S")
end

kosaraju_strongly_connected_components