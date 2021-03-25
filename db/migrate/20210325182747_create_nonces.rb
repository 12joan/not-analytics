class CreateNonces < ActiveRecord::Migration[6.1]
  def change
    create_table :nonces, id: :string do |t|
    end

    Nonce.record_timestamps = false
  end
end
