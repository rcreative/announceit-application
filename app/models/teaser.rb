class Teaser < ActiveRecord::Base
  belongs_to :account
  
  has_many :subscribers, :order => 'name, email'
  has_many :subscribes
  
  has_many :visitors
  has_many :visits, :through => :visitors
  
  has_attached_file :logo
  
  def title
    self[:title] || 'Be a Part of Something Amazing'
  end
  
  def description
    self[:description] || 'Enter your name and email below to be among the first to participate in our beta program.'
  end
  
  def subscribe!(visitor, subscriber_attributes)
    returning(subscribers.create!(subscriber_attributes)) do |s|
      subscribes.create!(
        :visitor => visitor,
        :subscriber => s,
        :subscribed_on => s.created_at.to_date
      )
    end
  end
end