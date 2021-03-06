class CreateUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.bigint :foursquare_id
      t.string :first_name
      t.string :last_name
      t.jsonb :photo
      t.string :email
      t.string :home_city
      t.bigint :facebook_id
      t.string :access_token

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
