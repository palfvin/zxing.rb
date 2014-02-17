# $REQUIRE_TIMES = {}
# $LOAD_TIMES = {}

# class Object
#   require 'benchmark'
#   def load(file_name, wrap=false)        
#     output = "loading #{file_name}"    
#     puts output   
#     result = nil
#     time = Benchmark.realtime do  
#       result = super
#     end
#     $LOAD_TIMES[file_name] ||= [0, 0, caller] 
#     $LOAD_TIMES[file_name][0] += time 
#     $LOAD_TIMES[file_name][1] += 1 
#     return result 
#   end 

# def require(file_name) 
#   output = "requiring #{file_name}" 
#   puts output 
#   result = nil 
#   time = Benchmark.realtime do 
#     result = super 
#   end 
#   $REQUIRE_TIMES[file_name] ||= [0, 0, caller] 
#   $REQUIRE_TIMES[file_name][0] += time 
#   $REQUIRE_TIMES[file_name][1] += 1 
#   return result 
#   end 
# end

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Avlats::Application.initialize!
