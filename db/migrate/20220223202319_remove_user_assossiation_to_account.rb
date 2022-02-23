class RemoveUserAssossiationToAccount < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      t.remove_references :account, null: false, foreign_key: true, index: false
    end
  end
end
