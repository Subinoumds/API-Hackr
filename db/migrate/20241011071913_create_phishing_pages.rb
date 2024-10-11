class CreatePhishingPages < ActiveRecord::Migration[7.1]
  def change
    create_table :phishing_pages do |t|
      t.string :url
      t.text :content

      t.timestamps
    end
  end
end
