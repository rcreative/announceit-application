class Teaser < ActiveRecord::Base
  belongs_to :account
  has_many :subscribers
  has_attached_file :logo
end