class SessionsController < ApplicationController
  include HTTParty
  before_action :decrypt_access_token, only: :get_current_location

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    # Set user ID as globally accessible session hash so user can make multiple requests without having to log in
    session[:user_id] = @user.id
    redirect_to :userlocation
  end

  def get_current_location
    # Get current user's most recent checkin
    response = JSON.parse(HTTParty.get("https://api.foursquare.com/v2/users/#{current_user.foursquare_id}/checkins?oauth_token=#{@token}&v=#{Date.today.strftime('%Y%m%d')}").body)
    most_recent = response['response']['checkins']['items'][0]
    # Update user with dynamic location attributes and save
    current_user.lat = most_recent['venue']['location']['lat']
    current_user.lng = most_recent['venue']['location']['lng']
    time_zone_response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/timezone/json?location=#{current_user.lat},#{current_user.lng}&timestamp=#{Time.now.to_i}&key=#{ENV['GOOGLE_GEOCODING_API_KEY']}").body)
    current_user.time_zone = time_zone_response['timeZoneId']
    current_user.save
    # Redirect to profile
    redirect_to :me
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  # Decrypt access token before API call
  def decrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    # Use instance variable to pass into another action within controller
    @token = crypt.decrypt_and_verify(current_user.access_token)
  end

end
