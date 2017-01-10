module Lti
  class ToolProxy
    attr_accessor :tc_profile, :custom, :security_contract
    def initialize(params = {})
      @tc_profile = params[:tc_profile]
      @custom = params[:custom]
      @security_contract = params[:security_contract]
    end

    def as_json
      {
        '@context' => 'http://purl.imsglobal.org/ctx/lti/v2/ToolProxy',
        '@type' => 'ToolProxy',
        'tool_proxy_guid': '584a140c-01a8-44e8-aa84-0d654d284bd5',
        lti_version: 'LTI-2p1',
        tool_consumer_profile: @tc_profile.url.to_s,
        tool_profile: tool_profile,
        security_contract: @security_contract,
        enabled_capability: [ "OAuth.splitSecret" ]
      }.to_json
    end

    def tool_profile
      file = File.read 'lib/lti/tool_profile.json'
      JSON.parse(file)
    end
  end
end
