#!/usr/bin/env ruby

require 'ascii_charts'
require 'yaml'
require 'optparse'

default_options = {
  :data_set  => 30,
  :time_int  => 10,
  :interface => "eth0",
  :port      => 53,
}

@options = default_options

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"
  opts.on("-s", "--dataset", "Data Set - How many graph points to show") do |v|
    @options[:data_set] = v
  end
  opts.on("-t", "--time", "Time integer - How long to average packets per second over") do |v|
    @options[:time_int] = v
  end
  opts.on("-i", "--interface", "Which interface to watch with tcpdump") do |v|
    @options[:interface] = v
  end
  opts.on("-p", "--port", "Which port to listen on") do |v|
    @options[:port] = v
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit 1
  end
end

option_parser.parse!

data = Array.new
i = 0

cmd = "tcpdump -G #{@options[:time_int]} -W 1 -w /tmp/test -nnl -i #{@options[interface]} port #{@options[:port]} |& grep captured | awk '{print $1}'"

puts "Starting...."

loop do
  plot = Array.new
  plot.push(i)
  i += @options[:time_int]
  cnt = `#{cmd}`
  plot.push(cnt.strip.to_i / @options[:time_int])
  data.push(plot)
  if data.length > data_set
    data = data.drop(data.length - @options[:data_set])
  end
  system "clear"
  puts "Packets per Second for port #{@options[:port]} on #{@options[:interface]}"
  puts AsciiCharts::Cartesian.new(data, :bar => true).draw
end

