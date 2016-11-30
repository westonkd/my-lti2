require 'lti/tool_profile'
require 'lti/tool_proxy'

class MessagesController < ApplicationController
  after_action :allow_iframe

  def register
    @tc_profile = tool_consumer_profile
    @tool_proxy = Lti::ToolProxy.new(tc_profile: @tc_profile,
                                     security_contract: security_contract)

    puts @tool_proxy.as_json
    # TODO: Create oauth nonce and sign post request to tproxy with reg_password
    # response = HTTParty.post(@tc_profile.tool_proxy_endpoint, req_data)
  end

  def assignment_config?
    @tc_profile.placements.include? 'Canvas.placements.assignmentConfiguration'
  end
  helper_method :assignment_config?

  private

  def tool_proxy_post
    req_data = {
      body: [{ test: 'test' }].to_json,
      headers: {
        'Content-Type' => 'application/vnd.ims.lti.v2.toolproxy+json',
        'oauth_consumer_key' => params['reg_key']
      }
    }
  end

  def tool_consumer_profile
    tcp_url = params.require(:tc_profile_url)
    Lti::ToolProfile.new(tcp_url)
  end

  def security_contract
    {
      tp_half_shared_secret: SecureRandom.hex(128),
      tool_service: [
        {
          '@type' => 'RestService',
          service: @tc_profile.tool_proxy_endpoint_id,
          action: ['POST']
        }
      ]
    }
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
