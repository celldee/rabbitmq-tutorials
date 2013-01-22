#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

def fib(n)
  return n if n == 0 || n == 1
  return fib(n - 1) + fib(n - 2)
end

connection = Bunny.new
connection.start

channel = connection.create_channel
queue   = channel.queue("rpc_queue")

Signal.trap("INT") do
  channel.work_pool.shutdown
end

channel.prefetch(1)

puts " [x] Awaiting RPC requests"

queue.subscribe(:ack => true, :block => true) do |delivery_info, metadata, payload|
  n = payload.to_i

  puts " [.] fib(#{n})"
  response = fib(n)

  channel.default_exchange.publish(response.to_s,
                                   :routing_key => metadata.reply_to,
                                   :correlation_id => metadata.correlation_id
                                  )
  channel.ack(delivery_info.delivery_tag, false)
end

connection.close
