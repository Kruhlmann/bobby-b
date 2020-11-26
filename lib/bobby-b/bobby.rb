# frozen_string_literal: true

require 'discordrb'

# Bobby B discord bot instance.
class Bobby
  def initialize(options)
    @queue = []
    @last_message_time = 0
    @cooldown = 0.5
    @discord_token = options[:key]
    @responses = File.readlines(options[:responses])
  end

  def start
    start_queue
    start_bot
  end

  def start_bot
    bot = Discordrb::Bot.new token: @discord_token

    bot.message do |event|
      @queue.unshift(event) if event.message.to_s.include? bot.bot_user.id.to_s
    end

    bot.run
  end

  def send_newest_message
    response = @responses.sample
    event = @queue.pop
    event.respond(response)
  end
  
  def is_on_cooldown
    now = Time.now.to_f
    bot_is_on_cooldown = now - @last_message_time < @cooldown
    return bot_is_on_cooldown
  end

  def process_queue_item
    return if @queue.empty? || is_on_cooldown

    send_newest_message
    @last_message_time = now
  end

  def start_queue
    Thread.new do
      loop do
        sleep 0.1
        process_queue_item
      end
    end
  end
end
