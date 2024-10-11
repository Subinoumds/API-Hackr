class CreateLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :logs do |t|
      t.string :action_type
      t.integer :user_id
      t.text :details

      t.timestamps
    end
  end
end
