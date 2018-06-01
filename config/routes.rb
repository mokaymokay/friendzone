Rails.application.routes.draw do
  # Mandatory route for app access, display Foursquare account selection or login menu
  get 'login', to: redirect('/auth/foursquare'), as: 'login'
  # Destroy current session
  get 'logout', to: 'sessions#destroy', as: 'logout'
  # Create session with user object (turned auth hash) returned by Foursquare, i.e. log user in
  get 'auth/:provider/callback', to: 'sessions#create'
  # Redirect to root if user fails to authorize Foursquare
  get 'auth/failure', to: redirect('/')
  # Publicly available page with Login option
  get 'home', to: 'home#show'
  # Show user info
  get 'me', to: 'me#show', as: 'me'

  root to: 'home#show'
end
