class CreateHits < ActiveRecord::Migration[6.1]
  def change
    create_table :hits do |t|
      t.references :app, type: :string, null: false, foreign_key: true
      t.datetime :time, null: false
      t.string :event
      t.integer :count, default: 0
    end

    Hit.record_timestamps = false
  end
end
