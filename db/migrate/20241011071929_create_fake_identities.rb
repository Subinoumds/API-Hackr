class CreateFakeIdentities < ActiveRecord::Migration[7.1]
  def change
    create_table :fake_identities do |t|
      t.string :name
      t.string :address

      t.timestamps
    end
  end
end
