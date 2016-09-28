require 'net/http'

class MessagesController < ApplicationController
  after_action :allow_iframe

  def register
    @tc_profile = tc_profile(params['tc_profile_url'])
    @placements = get_tc_placements
  end

  private


  def tc_profile(profile_url)
    profile = {}
    response = HTTParty.get(profile_url)
    profile = JSON.parse(response.body) if response.success?
    profile
  end

  def allow_iframe
   response.headers.except! 'X-Frame-Options'
  end
end
