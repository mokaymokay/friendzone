class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :user_first_id
      t.integer :user_second_id
      t.string :relationship_type

      t.timestamps
    end
  end
end
