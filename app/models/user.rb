class User < ApplicationRecord
  # Make photo hash accessible, i.e. 'user.photo.prefix' and 'user.photo.suffix'
  serialize :photo
  before_save :encrypt_access_token, if: :access_token?

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
      # add default parameter nil in case if contact and facebook keys does not exist
      user.facebook_id = auth.extra.raw_info.fetch("contact").fetch("facebook") { nil }

      user.save!
    end
  end

  private

  # Encrypt access token before save
  def encrypt_access_token
    crypt = ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['KEY']))
    encrypted_access_token = crypt.encrypt_and_sign(self.access_token)
    self.access_token = encrypted_access_token
    # When we need to use access token: crypt.decrypt_and_verify(access_token)
  end
end
