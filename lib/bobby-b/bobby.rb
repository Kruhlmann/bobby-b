# frozen_string_literal: true

require 'discordrb'

class Bobby
  def initialize(options)
    @queue = []
    @last_message_time = 0
    @cooldown = 0.5
    @discord_token = options.api_key
    @responses = File.readlines(options.responses_file)
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
    puts "Responded with #{response}"
  end

  def start_queue
    Thread.new do
      puts 'Message queue started'
      loop do
        sleep 0.1
        now = Time.now.to_f
        next unless !@queue.empty? && now - @last_message_time >= @cooldown

        send_newest_message
        @last_message_time = now
      end
    end
  end
end
