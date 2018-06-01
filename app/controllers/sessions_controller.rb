class SessionsController < ApplicationController

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
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
