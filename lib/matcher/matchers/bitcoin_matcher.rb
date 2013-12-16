# encoding: utf-8

require "#{Rails.root}/lib/matcher/matchers/generic_matcher"

# generic matcher initializes the matcher

class BitcoinMatcher < GenericMatcher

  def self.matches
    ['bitcoin', 'bitcoin price', 'btc', 'btc price']
  end

  def weight
    10
  end

  def execute
    prices = get_prices

    return [] if prices.nil?
    {
      name: 'Bitcoin Prices',
      method: 'upper',
      type: 'inline',
      data: prices,
      link: "<a href='#{coinbase_url}'>#{coinbase_message}</a>",
      weight: weight
    }
  end

  private

  def currencies
    %w(usd gbp eur jpy)
  end

  def coinbase_url
    'https://coinbase.com/?r=5212431ce73770adac000003'
  end

  def coinbase_message
    'Setup a free CoinBase account to easily use Bitcoin'
  end

  def matched_currencies
    matched_currencies = []
    split = @term.downcase.split(' ')
    currencies.each do |c|
      matched_currencies << c if split.include? c
    end
    matched_currencies = default_currencies if matched_currencies.empty?
    matched_currencies
  end

  def default_currencies
    %w(usd gbp eur)
  end

  def get_coinbase_data
    http = Net::HTTP.new 'coinbase.com', 443
    http.use_ssl = true

    resp = http.get '/api/v1/currencies/exchange_rates'
    begin
      JSON.parse(resp.body)
    rescue
      nil
    end
  end

  def get_prices
    json = get_coinbase_data
    return nil if json.nil?
    prices = {}
    matched_currencies.each do |c|
      prices[c.to_sym] = json["btc_to_#{c}"]
    end
    prices
  end
end
