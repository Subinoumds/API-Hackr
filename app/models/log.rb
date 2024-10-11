class Log < ApplicationRecord
    belongs_to :user, optional: true 
    validates :action_type, presence: true
    validates :details, presence: true
  end
  