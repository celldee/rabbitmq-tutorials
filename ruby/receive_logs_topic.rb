#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel  = connection.create_channel
exchange = channel.topic("topic_logs")
queue    = channel.queue("", :exclusive => true)

if ARGV.empty?
  abort "Usage: #{$0} [binding key]"
end

ARGV.each do |binding_key|
  queue.bind(exchange, :routing_key => binding_key)
end

Signal.trap("INT") do
  channel.work_pool.shutdown
end

puts " [*] Waiting for logs. To exit press CTRL+C"

queue.subscribe(:block => true) do |delivery_info, metadata, payload|
  puts " [x] #{delivery_info.routing_key}:#{payload}"
end

connection.close
