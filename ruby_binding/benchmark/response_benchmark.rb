#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__))

require 'server_test'

trap('INT')  { exit(1) }
dumpfile = 'response_results.dump'
begin
  results = ServerTestResults.open(dumpfile)
  $servers.each { |s| s.start }
  sleep 3
  [1,10,20,30,50,100,200].map { |i| i.kilobytes }.rand_each do |size|
    $servers.rand_each do |server| 
      if r = server.trial(:size => size)
        results << r
      else
        puts "error! restarting server"
        server.kill
        server.start
      end
      sleep 0.2 # give the other process some time to cool down?
    end
    puts "---"
  end
ensure
  puts "\n\nkilling servers"
  $servers.each { |server| server.kill }  
  results.write(dumpfile)
end
