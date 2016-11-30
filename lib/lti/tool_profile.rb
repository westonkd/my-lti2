require 'net/http'

module Lti
  class ToolProfile
    attr_reader :url, :data, :placements
    def initialize(url)
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
      tp_services = @data[:service_offered].select { |s| s['@id'].include? 'ToolProxy.collection' }
      return URI.parse(tp_services.first['endpoint']) unless tp_services.blank?
    end

    def tool_proxy_endpoint_id
      tp_services = @data[:service_offered].select { |s| s['@id'].include? 'ToolProxy.collection' }
      return URI.parse(tp_services.first['@id']) unless tp_services.blank?
    end

    private

    def request_tp
      response = HTTParty.get(@url)
      JSON.parse(response.body) || {}
    end

    def process_placements
      return nil unless @data[:capability_offered]
      @placmenents = @data[:capability_offered].select { |c| c.include? 'Canvas.placements' }
    end
  end
end
