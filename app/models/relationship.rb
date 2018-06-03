class Relationship < ApplicationRecord
  belongs_to :user_first, class_name: "User"
  belongs_to :user_second, class_name: "User"
  validates :user_first_id, presence: true, uniqueness: { scope: :user_second_id }
  validates :user_second_id, presence: true
  validates_numericality_of :user_second_id, greater_than: :user_first_id
end
