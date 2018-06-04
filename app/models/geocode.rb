class Geocode < ApplicationRecord
  validates :query, uniqueness: true

  # Find geocode, if cannot find one, create it by querying and saving search results from APIs
  def self.find_or_create_from_query(query)
      where(query: query).first_or_initialize.tap do |geocode|
      # Set geocode query
      geocode.query = query
      # Get coordinates from Geocoding API using city
      coordinates_response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{query}&key=#{ENV['GOOGLE_GEOCODING_API_KEY']}").body)
      if coordinates_response['status'] == 'OK'
        location = coordinates_response['results'][0]['geometry']['location']
        # Set geocode coordinates
        geocode.lat = location['lat']
        geocode.lng = location['lng']
        # Get time zone from Time Zone API using coordinates
        time_zone_response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/timezone/json?location=#{location['lat']},#{location['lng']}&timestamp=#{Time.now.to_i}&key=#{ENV['GOOGLE_GEOCODING_API_KEY']}").body)
        geocode.time_zone = time_zone_response['timeZoneId']
      end
      # Save geocode if time zone attribute exists
      if geocode.time_zone
        geocode.save!
      end
    end
  end
end
