#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel  = connection.create_channel
exchange = channel.direct("direct_logs")
severity = ARGV.shift || "info"
message  = ARGV.empty? ? "Hello World!" : ARGV.join(" ")

exchange.publish(message, :routing_key => severity)
puts " [x] Sent #{severity}:#{message}"

connection.close
