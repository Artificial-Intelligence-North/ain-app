class Completion < ApplicationRecord
  belongs_to :user

  validates :model, presence: true
  validates :prompt, presence: true, length: { minimum: 2 }
  validates :response, presence: true
end
