require "#{Rails.root}/lib/matcher/matchers/generic_matcher"
class BitcoinMatcher < GenericMatcher
  def self.matches
    ['bitcoin', 'bitcoin price', 'btc','btc price']
  end
  def weight
    10
  end
  def execute
    prices = {}
    http = Net::HTTP.new "coinbase.com", 443
    http.use_ssl = true

    resp, data = http.get '/api/v1/currencies/exchange_rates'

    json = JSON.parse(resp.body)
    return nil if json.nil?
    currencies = ['usd','gbp','eur','jpy']
    matched_currencies = []
    split = @term.downcase.split(' ')
    currencies.each do |c|
      if split.include? c
        matched_currencies << c
      end
    end
    if matched_currencies.empty?
      prices[:usd] = json['btc_to_usd']
      prices[:btc] = json['btc_to_gbp']
      prices[:eur] = json['btc_to_eur']
    else
      matched_currencies.each do |c|
        prices[c.to_sym] = json["btc_to_#{c}"]
      end
    end

    {
      name: "Bitcoin Prices",
      method: "upper",
      type: 'inline',
      data: prices,
      link: '<a href="https://coinbase.com/?r=5212431ce73770adac000003">Setup a free CoinBase account to easily use Bitcoin</a>',
      weight: weight
    }
  end
end