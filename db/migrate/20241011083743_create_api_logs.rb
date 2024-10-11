class CreateApiLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :api_logs do |t|
      t.string :action
      t.integer :user_id
      t.string :feature

      t.timestamps
    end
  end
end
