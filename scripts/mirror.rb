#!/usr/bin/env ruby

#
# scripts/mirror.rb
#
# Updates specs for any new releases of tracked pods.
#

require 'net/http'
require 'rubygems'
require 'json'


# Switch the current dir to be the one containing this script.
Dir.chdir(File.dirname(__FILE__))

#
# Models
#

class Pod
  attr_reader :name, :summary, :authors, :version, :homepage, :source
  attr_accessor :spec
  def initialize(name, summary, authors, version, homepage, source)
    @name = name
    @summary = summary
    @authors = authors
    @version = version
    @homepage = homepage
    @source = source
  end
  def to_s
    return "#{@name}: #{@summary} (v#{@version}) <#{@homepage}>"
  end
end

#
# Functions
#

# Parses the pods file which is a flat list of pod spec names.
# Returns an array of strings.
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

# Fetches pod metadata for the given spec name.
# Returns a Pod object containing metadata.
def fetch_pod_metadata(spec_name)
  base_url = 'http://search.cocoapods.org/api/v1/pods.flat.hash.json'
  query_string = "query=on%3Aios%20#{spec_name}&amount=1"
  url = URI.parse("#{base_url}?#{query_string}")
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) { |http|
    http.request(req)
  }
  json = JSON.parse(res.body)[0]
  return Pod.new(json['id'], json['summary'], json['authors'], json['version'], json['link'], json['source']['git'])
end

# Fetches the spec for the given pod.
# Adds the body of the spec to the pod.
def fetch_spec(pod)
  base_url = 'https://raw.githubusercontent.com/CocoaPods/Specs/master/Specs/'
  url = URI.parse("#{base_url}#{pod.name}/#{pod.version}/#{pod.name}.podspec.json")
  puts url.to_s
  response = Net::HTTP.get_response(url)
  pod.spec = response.body
end

#
# Main script logic
#

counter = 1
parse_list.each do |pod_name|
  puts "#{counter}: Fetching spec for #{pod_name}"
  counter = counter + 1
  pod = fetch_pod_metadata(pod_name)
  fetch_spec(pod)
end
