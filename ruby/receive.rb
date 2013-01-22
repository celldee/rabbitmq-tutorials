#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
queue   = channel.queue("hello")

Signal.trap("INT") do
  channel.work_pool.shutdown
end

puts " [*] Waiting for messages. To exit press CTRL+C"

queue.subscribe(:block => true) do |delivery_info, metadata, payload|
  puts " [x] Received #{payload}"
end

connection.close
