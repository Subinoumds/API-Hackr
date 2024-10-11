class CreatePasswordChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :password_checks do |t|
      t.string :password

      t.timestamps
    end
  end
end
