#!/opt/resque/embedded/bin/ruby
require 'resque'

$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))
# This will also setup Redis connection:
require 'url_title'

abort("Usage #{$0} url1 ...\nFor example: #{$0} https://slashdot.org/") unless ARGV.length > 0

ARGV.each do|url|
  puts "Enqeueing URL '#{url}' to url_title queue"
  Resque.enqueue(PIL::Jobs::UrlTitle, url)
end
puts "Please tail -f /var/log/resque/workers/url_title/current" 
puts "To see processsed queue results"
# vim: set ts=4 sw=4 expandtab:
