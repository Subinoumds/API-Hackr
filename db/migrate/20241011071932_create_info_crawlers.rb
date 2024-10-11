class CreateInfoCrawlers < ActiveRecord::Migration[7.1]
  def change
    create_table :info_crawlers do |t|
      t.string :name
      t.string :surname

      t.timestamps
    end
  end
end
