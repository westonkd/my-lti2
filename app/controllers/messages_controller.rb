require 'lti/tool_profile'
require 'lti/tool_proxy'

class MessagesController < ApplicationController
  after_action :allow_iframe

  def register
    @tc_profile = tool_consumer_profile
    @tool_proxy = Lti::ToolProxy.new(tc_profile: @tc_profile,
                                     security_contract: security_contract)

    response = HTTParty.post(@tc_profile.tool_proxy_endpoint, tool_proxy_post)
    puts "-----------"
    puts response
    puts "==========="
  end

  def assignment_config?
    @tc_profile.placements.include? 'Canvas.placements.assignmentConfiguration'
  end
  helper_method :assignment_config?

  private

  def tool_proxy_post
    puts "===="
    puts @tool_proxy.as_json
    puts "===="

    options = {
      consumer_secret: params[:reg_password],
      consumer_key: params[:reg_key],
      callback: 'about:blank',
      oauth_nonce: OAuthNonce.create!
    }

    header = SimpleOAuth::Header.new(
      :post,
      @tc_profile.tool_proxy_endpoint,
      {},
      options
    )

    {
      body: @tool_proxy.as_json,
      headers: {
        'Content-Type' => 'application/vnd.ims.lti.v2.toolproxy+json',
        'Authorization' => header.to_s
      }
    }
  end

  def tool_consumer_profile
    tcp_url = params.require(:tc_profile_url)
    Lti::ToolProfile.new(tcp_url)
  end

  def security_contract
    {
      tp_half_shared_secret: SecureRandom.hex(64),
      # tool_service: [
      #   {
      #     '@type' => 'RestService',
      #     service: @tc_profile.tool_proxy_endpoint_id,
      #     action: ['POST']
      #   }
      # ]
    }
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
