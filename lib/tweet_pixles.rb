require "pixela"
require "active_support/all"

require_relative "./twilog"

class TweetPixels
  attr_reader :twilog, :client, :graph

  def initialize(twitter_id:, pixela_username:, pixela_token:, pixela_graph_id:)
    raise "pixela_username is required" unless pixela_username
    raise "pixela_token is required"    unless pixela_token
    raise "pixela_graph_id is required" unless pixela_graph_id

    @twilog = Twilog.new(twitter_id)

    @client = Pixela::Client.new(username: pixela_username, token: pixela_token)
    @graph = @client.graph(pixela_graph_id)

    Time.zone = "Tokyo"
  end

  def update_yesterday
    update(Date.current - 1)
  end

  def update_today
    update(Date.current)
  end

  def update(date)
    twilog.update
    tweet = twilog.stat_tweets_count[date] || 0
    graph.pixel(date).update(quantity: tweet)
    puts "date=#{date}, quantity=#{tweet}"
  end

  def update_multi(start_date: 1.years.ago.to_date, end_date: Date.current)
    twilog.update
    twilog.stat_tweets_count.select{ |date, _| (start_date..end_date).include?(date) }.each do |date, tweet|
      graph.pixel(date).update(quantity: tweet)
      puts "date=#{date}, quantity=#{tweet}"
    end
  end
end
