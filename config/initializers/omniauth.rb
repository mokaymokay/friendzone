 # Add OmniAuth to Rack Middleware (All code inside initalizers is run when app starts up)
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :foursquare, ENV['FOURSQUARE_CLIENT_ID'], ENV['FOURSQUARE_CLIENT_SECRET']
end
