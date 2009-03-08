class Subscribe < ActiveRecord::Base
  belongs_to :teaser
  belongs_to :subscriber
  belongs_to :visitor
end