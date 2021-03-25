class Nonce < ApplicationRecord
  def self.remember(id)
    nonce = find_or_initialize_by(id: id)

    if nonce.new_record?
      nonce.save!
    else
      return false
    end
  end
end
