class User < ApplicationRecord
  before_save :encrypt_access_token, if: :access_token?
  validates :foursquare_id, uniqueness: true, presence: true

  # use hash sent by Foursquare to look up user in DB
  # if user does not exist, create new user and save. if info has changed, update user and save.
  def self.find_or_create_from_auth_hash(auth)
    where(foursquare_id: auth.uid).first_or_initialize.tap do |user|
      user.foursquare_id = auth.uid
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.photo = auth.info.image
      user.email = auth.info.email
      user.access_token = auth.credentials.token
      user.home_city = auth.info.location
      # add default parameter nil in case if facebook key does not exist
      user.facebook_id = auth.extra.raw_info['contact'].fetch('facebook') { nil }

      user.save!
    end
  end

  def self.create_or_update_friend(friend)
    where(foursquare_id: friend['id']).first_or_initialize.tap do |user|
      user.foursquare_id = friend['id']
      user.first_name = friend['firstName']
      user.last_name = friend['lastName']
      user.photo = { prefix: friend['photo']['prefix'], suffix: friend['photo']['suffix'] }
      # add default parameter nil in case if facebook and email keys do not exist
      user.facebook_id = friend['contact'].fetch('facebook') { nil }
      user.email = friend['contact'].fetch('email') { nil }
      user.home_city = friend['homeCity']

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
