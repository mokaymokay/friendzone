class CreateGeocodes < ActiveRecord::Migration[5.2]
  def up
    create_table :geocodes do |t|
      t.string :query
      t.decimal :lat, { precision: 10, scale: 6 }
      t.decimal :lng, { precision: 10, scale: 6 }
      t.string :time_zone
      t.timestamps
    end
  end

  def down
    drop_table :geocodes
  end
end
