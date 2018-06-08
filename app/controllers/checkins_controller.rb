class CheckinsController < ApplicationController
  include HTTParty
  before_action :authenticate
  # Make method only available to specific action
  before_action :decrypt_access_token, only: :index

  def index
    response = JSON.parse(HTTParty.get("https://api.foursquare.com/v2/users/#{current_user.foursquare_id}/checkins?oauth_token=#{@token}&v=#{Date.today.strftime('%Y%m%d')}").body)
    @most_recent = response['response']['checkins']['items'][0]
  end

  private

  # Decrypt access token before API call
  def decrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    # Use instance variable to pass into another action within controller
    @token = crypt.decrypt_and_verify(current_user.access_token)
  end

end
