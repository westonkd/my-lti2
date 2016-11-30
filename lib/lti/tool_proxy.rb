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
        lti_version: 'LTI-2p1',
        tool_consumer_profile: @tc_profile.data,
        tool_profile: tool_profile,
        custom: @custom,
        security_contract: @security_contract
      }.to_json
    end

    def tool_profile
      file = File.read 'lib/lti/tool_profile.json'
      JSON.parse(file)
    end
  end
end
