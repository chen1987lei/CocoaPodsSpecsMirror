#!/usr/bin/env ruby

#
# scripts/mirror.rb
#
# Updates specs for any new releases of tracked pods.
#

require 'net/http'


# Switch the current dir to be the one containing this script.
Dir.chdir(File.dirname(__FILE__))

#
# Functions
#

def parse_list
  # File containing the list of pods to mirror. Assumed in same dir as this script.
  pods_list_file = "pods"
  pods_list = []
  begin
    file = File.new(pods_list_file, "r")
    while (line = file.gets)
      pods_list.push line
    end
    file.close
  rescue => err
    puts "Exception: #{err}"
    err
  end

  return pods_list
end

def fetch_spec(spec_name)
  base_url = 'http://search.cocoapods.org/api/v1/pods.flat.hash.json'
  query_string = "query=on%3Aios%20#{spec_name}&amount=1"
  url = URI.parse("#{base_url}?#{query_string}")
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  puts res.body
end

#
# Main script logic
#

counter = 1
parse_list.each do |pod_name|
  puts "#{counter}: Fetching spec for #{pod_name}"
  counter = counter + 1
  fetch_spec(pod_name)
end
