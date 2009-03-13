class Visit < ActiveRecord::Base
  belongs_to :visitor
  before_create :assign_visited_at
  
  private
    def assign_visited_at
      self.visited_at = Time.now
    end
end