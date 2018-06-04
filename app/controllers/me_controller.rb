class MeController < ApplicationController
  include HTTParty
  before_action :authenticate
  # Make method only available to specific action
  before_action :decrypt_access_token, only: :add_friends_from_foursquare

  def show
    # redirect_to :addfriends
  end

  # /addfriends or addfriends_path
  def add_friends_from_foursquare
    response = JSON.parse(HTTParty.get("https://api.foursquare.com/v2/users/#{current_user.foursquare_id}/friends?oauth_token=#{@token}&v=#{Date.today.strftime('%Y%m%d')}").body)
    response['response']['friends']['items'].each do |friend|
      # Only add friend if relationship on Foursquare is 'friend'
      if friend['relationship'] == 'friend'
        # Find or create user for friend
        users_friend = User.find_or_create_friend(friend)
        user_query = users_friend.home_city
        # Get coordinates and time zone from Google Geocoding/Time Zone API or database
        geocode = Geocode.find_or_create_from_query(user_query)
        # Set user static location attributes and save
        users_friend.lat = geocode.lat
        users_friend.lng = geocode.lng
        users_friend.time_zone = geocode.time_zone
        users_friend.save
        # Create relationship
        Relationship.create(user_first_id: current_user.id, user_second_id: users_friend.id, relationship_type: 'friends')
      end
    end
    redirect_to :friends
  end

  def friends
    @friends = current_user.friends
  end

  private

  # Decrypt access token before API call
  def decrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    # Use instance variable to pass into another action within controller
    @token = crypt.decrypt_and_verify(current_user.access_token)
  end

end
