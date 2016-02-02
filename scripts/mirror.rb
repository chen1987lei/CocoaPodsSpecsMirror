#!/usr/bin/env ruby

#
# scripts/mirror.rb
#
# Updates specs for any new releases of tracked pods.
#

# File containing the list of pods to mirror. Assumed in same dir as this script.
pods_list = "pods"

# Switch the current dir to be the one containing this script.
Dir.chdir(File.dirname(__FILE__))

counter = 1
begin
  file = File.new(pods_list, "r")
  while (line = file.gets)
    puts "#{counter}: #{line}"
    counter = counter + 1
  end
  file.close
rescue => err
  puts "Exception: #{err}"
  err
end
