#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

class FibonacciRpcClient
  def initialize
    subscribe_to_callback_queue
  end

  def connection
    @connection ||= Bunny.new
  end

  def channel
    @channel ||= self.connection.create_channel
  end

  def callback_queue
    @callback_queue ||= self.channel.queue("", :exclusive => true)
  end

  def requests
    @requests ||= Hash.new
  end

  def call(n, &block)
    corr_id = rand(10_000_000).to_s
    self.requests[corr_id] = nil
    self.channel.default_exchange.publish(n.to_s, :routing_key => "rpc_queue", :reply_to => self.callback_queue.name, :correlation_id => corr_id)

    loop do
      sleep 0.1
      if result = self.requests[corr_id]
        block.call(result.to_i)
        break
      end
    end
  end

  private
  def subscribe_to_callback_queue
    self.callback_queue.subscribe do |delivery_info, metadata, payload|
      corr_id = metadata.correlation_id
      unless self.requests[corr_id]
        self.requests[corr_id] = payload
      end
    end
  end
end

fibonacci_rpc = FibonacciRpcClient.new()

puts " [x] Requesting fib(30)"
fibonacci_rpc.call(30) do |response|
  puts " [.] Got #{response}"
end
