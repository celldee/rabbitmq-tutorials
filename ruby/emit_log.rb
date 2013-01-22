#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel  = connection.create_channel
exchange = channel.fanout("logs")
message  = ARGV.empty? ? "info: Hello World!" : ARGV.join(" ")

exchange.publish(message)
puts " [x] Sent #{message}"

connection.close
