class Visitor < ActiveRecord::Base
  belongs_to :teaser
  has_many :visits, :order => 'visited_at'
end