#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
queue = channel.queue("hello")

channel.default_exchange.publish("Hello World!", :routing_key => queue.name)
puts " [x] Sent 'Hello World!'"

connection.close
