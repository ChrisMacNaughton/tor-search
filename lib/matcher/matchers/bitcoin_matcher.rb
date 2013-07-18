require "#{Rails.root}/lib/matcher/matchers/generic_matcher"
class BitcoinMatcher < GenericMatcher
  def self.matches
    ['bitcoin', 'bitcoin price', 'btc','btc price']
  end
  def weight
    10
  end
  def execute
    hydra = Typhoeus::Hydra.new

    prices = {}

    usd = Typhoeus::Request.new("data.mtgox.com/api/2/BTCUSD/money/ticker_fast")
    usd.on_complete do |resp|
      if resp.success?
        json = JSON.parse(resp.body)
        unless json.nil?
          prices[:usd] = json['data']['last_all']['display']
        end
      end
    end
    gbp = Typhoeus::Request.new("data.mtgox.com/api/2/BTCGBP/money/ticker_fast")
    gbp.on_complete do |resp|
      if resp.success?
        json = JSON.parse(resp.body)
        unless json.nil?
          prices[:gbp]= json['data']['last_all']['display']
        end
      end
    end
    eur = Typhoeus::Request.new("data.mtgox.com/api/2/BTCEUR/money/ticker_fast")
    eur.on_complete do |resp|
      if resp.success?
        json = JSON.parse(resp.body)
        unless json.nil?
          prices[:eur] = json['data']['last_all']['display']
        end
      end
    end

    hydra.queue usd
    hydra.queue gbp
    hydra.queue eur

    hydra.run

    {
      name: "Bitcoin Prices",
      method: "upper",
      type: 'inline',
      data: prices,
      weight: weight
    }
  end
end