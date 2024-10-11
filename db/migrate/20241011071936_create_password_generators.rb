class CreatePasswordGenerators < ActiveRecord::Migration[7.1]
  def change
    create_table :password_generators do |t|
      t.integer :length

      t.timestamps
    end
  end
end
