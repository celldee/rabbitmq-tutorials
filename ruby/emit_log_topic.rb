#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel  = connection.create_channel
exchange = channel.topic("topic_logs")
severity = ARGV.shift || "anonymous.info"
message  = ARGV.empty? ? "Hello World!" : ARGV.join(" ")

exchange.publish(message, :routing_key => severity)
puts " [x] Sent #{severity}:#{message}"

connection.close
