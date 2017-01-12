require 'net/http'

module Lti
  class ToolProfile
    attr_reader :url, :data, :placements
    def initialize(url)
      puts "Fetching TCP from #{url}"
      @url = URI.parse(url)
      @data = request_tp.with_indifferent_access
      @placements = process_placements
    end

    def friendly_placements
      @placements.map do |p|
        name_array = p.split('.').last.split(/(?=[A-Z])/)
        name_array.map(&:capitalize).join(' ')
      end
    end

    def tool_proxy_endpoint
      return nil unless @data
      tp_services = @data[:service_offered].select { |s| s['@id'].include? 'ToolProxy.collection' }
      return URI.parse(tp_services.first['endpoint']) unless tp_services.blank?
    end

    def tool_proxy_endpoint_id
      tp_services = @data[:service_offered].select { |s| s['@id'].include? 'ToolProxy.collection' }
      return tp_services.first['@id'] unless tp_services.blank?
    end

    private

    def request_tp
      response = HTTParty.get(@url, tcp_authorized_get)
      JSON.parse(response.body) || {}
    end

    def tcp_authorized_get
      options = {
        consumer_secret: "RaqHh8gHJTq9dUWt6W6wkpSyiC8ColOJGSJtWKCyTAZ01VmArqIQAlopWmlIQxEI",
        consumer_key: 10000000000002,
        callback: 'about:blank',
        oauth_nonce: OAuthNonce.create!
      }

      query = {
        consumer_key: 10000000000002
      }

      header = SimpleOAuth::Header.new(
        :get,
        "#{@url}?consumer_key=#{query[:consumer_key]}",
        {},
        options
      )

      # puts header.send(:signature_base)

      {
        query: query,
        headers: {
          'Authorization' => header.to_s
        }
      }
    end

    def process_placements
      return nil unless @data[:capability_offered]
      @placmenents = @data[:capability_offered].select { |c| c.include? 'Canvas.placements' }
    end
  end
end
