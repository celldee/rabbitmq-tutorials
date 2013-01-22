#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
queue   = channel.queue("task_queue", :durable => true)
message = ARGV.empty? ? "Hello World!" : ARGV.join(" ")

channel.default_exchange.publish(message, :routing_key => queue.name, :persistent => true)
puts " [x] Sent #{message}"

connection.close
