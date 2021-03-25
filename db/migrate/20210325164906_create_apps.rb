class CreateApps < ActiveRecord::Migration[6.1]
  def change
    create_table :apps, id: :string do |t|
      t.string :name
      t.string :key

      t.timestamps
    end
  end
end
