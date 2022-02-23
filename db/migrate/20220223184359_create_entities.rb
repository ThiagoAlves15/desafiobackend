class CreateEntities < ActiveRecord::Migration[6.1]
  def change
    create_table :entities do |t|
      t.string :name
      t.integer :account_id

      t.timestamps
    end

    add_index :entities, :account_id
  end
end
