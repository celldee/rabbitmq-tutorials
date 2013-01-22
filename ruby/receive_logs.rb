#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel  = connection.create_channel
exchange = channel.fanout("logs")
queue    = channel.queue("", :exclusive => true)

queue.bind(exchange)

Signal.trap("INT") do
  channel.work_pool.shutdown
end

puts " [*] Waiting for logs. To exit press CTRL+C"

queue.subscribe(:block => true) do |delivery_info, metadata, payload|
  puts " [x] #{payload}"
end

connection.close
