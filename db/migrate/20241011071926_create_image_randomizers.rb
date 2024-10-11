class CreateImageRandomizers < ActiveRecord::Migration[7.1]
  def change
    create_table :image_randomizers do |t|
      t.string :api_url

      t.timestamps
    end
  end
end
