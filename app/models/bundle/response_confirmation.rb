class Bundle::ResponseConfirmation < ActiveRecord::Base
  #validates :bundle_uuid, presence: true
  #validates :receiver_uuid, presence: true, uniqueness: { scope: :bundle_uuid }
end
