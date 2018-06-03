class MeController < ApplicationController
  include HTTParty
  before_action :authenticate
  before_action :decrypt_access_token, only: :add_friends

  def show
  end

  def add_friends
    response = JSON.parse(HTTParty.get("https://api.foursquare.com/v2/users/#{current_user.foursquare_id}/friends?oauth_token=#{@token}&v=#{Date.today.strftime('%Y%m%d')}").body)
    response['response']['friends']['items'].each do |friend|
      User.create_or_update_friend(friend)
    end
  end

  private

  # Decrypt access token before API call
  def decrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    @token = crypt.decrypt_and_verify(current_user.access_token)
  end

end
