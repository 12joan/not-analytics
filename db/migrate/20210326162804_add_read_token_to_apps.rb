class AddReadTokenToApps < ActiveRecord::Migration[6.1]
  def change
    add_column :apps, :read_token, :string
  end
end
