class User < ApplicationRecord
  before_save :encrypt_access_token, if: :access_token?
  validates :foursquare_id, uniqueness: true, presence: true
  # Establish relationships with two custom foreign keys
  has_many :direct_relationships, class_name: "Relationship", foreign_key: "user_first_id"
  has_many :inverse_relationships, class_name: "Relationship", foreign_key: "user_second_id"
  # Query friends
  has_many :direct_friends, -> { where(relationships: { relationship_type: 'friends'}) }, through: :direct_relationships, source: :user_second
  has_many :inverse_friends, -> { where(relationships: { relationship_type: 'friends'}) }, through: :inverse_relationships, source: :user_first

  # Call all of the user's friends
  def friends
    direct_friends | inverse_friends
  end

  # Use hash sent by Foursquare to look up user in DB
  # If user does not exist, create new user and save. If info has changed, update user and save.
  def self.find_or_create_from_auth_hash(auth)
    where(foursquare_id: auth.uid).first_or_initialize.tap do |user|
      user.foursquare_id = auth.uid
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.photo = auth.info.image
      user.email = auth.info.email
      user.access_token = auth.credentials.token
      location = auth.info.location
      # Remove text that follows a comma if it is not a US state
      check_for_US_state = /(,)(?> [A-Z][A-Z])/
      before_comma = /(.*),/
      # Check if location does not include comma OR does include comma followed by a US state
      # If true, return location; else, return text before comma
      location = (!location.include?(',') || check_for_US_state.match(location) ? location : before_comma.match(location)[1])
      user.home_city = location
      # Add default parameter nil in case if Facebook key does not exist
      user.facebook_id = auth.extra.raw_info['contact'].fetch('facebook') { nil }

      user.save!
    end
  end

  # Find or create friends when user authorizes Foursquare
  def self.find_or_create_friend(friend)
    where(foursquare_id: friend['id']).first_or_initialize.tap do |user|
    # NOTE: This code block shouldn't be run if if record exists... but it's okay because it's a good idea to update attributes
      user.foursquare_id = friend['id']
      user.first_name = friend['firstName']
      user.last_name = friend['lastName']
      user.photo = { prefix: friend['photo']['prefix'], suffix: friend['photo']['suffix'] }
      # Add default parameter nil in case if Facebook and email keys do not exist
      user.facebook_id = friend['contact'].fetch('facebook') { nil }
      user.email = friend['contact'].fetch('email') { nil }
      location = friend['homeCity']
      # Remove text that follows a comma if it is not a US state
      check_for_US_state = /(,)(?> [A-Z][A-Z])/
      before_comma = /(.*),/
      # Check if location does not include comma OR includes comma followed by a US state
      # If true, return location; else, return text before comma
      location = (!location.include?(',') || check_for_US_state.match(location) ? location : before_comma.match(location)[1])
      user.home_city = location

      user.save!
    end
  end

  private

  # Encrypt access token before save
  def encrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    encrypted_access_token = crypt.encrypt_and_sign(self.access_token)
    self.access_token = encrypted_access_token
  end
end
