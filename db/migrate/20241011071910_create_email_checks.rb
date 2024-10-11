class CreateEmailChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :email_checks do |t|
      t.string :email

      t.timestamps
    end
  end
end
