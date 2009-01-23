class Teaser < ActiveRecord::Base
  belongs_to :account
  has_many :subscribers
  has_attached_file :logo
  
  def title
    self[:title] || 'Be a Part of Something Amazing'
  end
  
  def description
    self[:description] || 'Enter your name and email below to be among the first to participate in our beta program.'
  end
end