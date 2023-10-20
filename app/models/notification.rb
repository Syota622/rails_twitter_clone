class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true
end
