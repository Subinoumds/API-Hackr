class CreateDomainChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :domain_checks do |t|
      t.string :domain

      t.timestamps
    end
  end
end
