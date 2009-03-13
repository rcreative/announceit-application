class Visitor < ActiveRecord::Base
  belongs_to :teaser
  has_many :visits, :order => 'visited_at'
  
  before_create :assign_cookie
  
  private
    def assign_cookie
      self.cookie = Digest::SHA1.hexdigest([Time.now, (1..10).map{ rand.to_s }].join('--'))
    end
end