class CreateDDoS < ActiveRecord::Migration[7.1]
  def change
    create_table :d_do_s do |t|
      t.string :target_url

      t.timestamps
    end
  end
end
