class CreateEntitiesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :entities_users do |t|
      t.integer :entity_id
      t.integer :user_id

      t.timestamps
    end
    add_index :entities_users, :entity_id
    add_index :entities_users, :user_id
  end
end
