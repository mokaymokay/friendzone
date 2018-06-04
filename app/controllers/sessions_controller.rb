class SessionsController < ApplicationController

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    # TODO: might need to add regex to rid of number for foreign homeCities
    user_query = @user.home_city
    # Get geocode, coordinates, and time zone from Google Geocoding API or database
    geocode = Geocode.find_or_create_from_query(user_query)
    # Set user static location attributes and save
    @user.lat = geocode.lat
    @user.lng = geocode.lng
    @user.time_zone = geocode.time_zone
    @user.save
    # Set user ID as globally accessible session hash so user can make multiple requests without having to log in
    session[:user_id] = @user.id
    # Redirect to profile after logging in
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

end
