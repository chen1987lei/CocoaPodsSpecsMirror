#!/usr/bin/env ruby

#
# scripts/mirror.rb
#
# Updates specs for any new releases of tracked pods.
#

pods_list = "pods"

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
