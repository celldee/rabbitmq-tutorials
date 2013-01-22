#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
queue   = channel.queue("task_queue", :durable => true)

Signal.trap("INT") do
  channel.work_pool.shutdown
end

puts " [*] Waiting for messages. To exit press CTRL+C"

channel.prefetch(1)

queue.subscribe(:ack => true, :block => true) do |delivery_info, metadata, payload|
  puts " [x] Received #{payload}"
  channel.ack(delivery_info.delivery_tag, false)
  puts " [x] Done"
end

connection.close
