class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def authenticate
    redirect_to :login unless user_signed_in?
  end

  def current_user
    # Set current_user as helper method to be usable in .erb views
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    # Convert !current_user to boolean by negating the negation
    !!current_user
  end

end
