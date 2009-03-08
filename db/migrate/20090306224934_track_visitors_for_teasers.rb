class TrackVisitorsForTeasers < ActiveRecord::Migration
  def self.up
    create_table :visitors, :force => true do |t|
      t.belongs_to :teaser
      t.string :cookie
    end
    
    create_table :visits, :force => true do |t|
      t.belongs_to :visitor
      t.datetime :visited_at
    end
    
    create_table :subscribes, :force => true do |t|
      t.belongs_to :teaser
      t.belongs_to :visitor
      t.belongs_to :subscriber
      t.date :subscribed_on
    end
    
    add_column :teasers, :page_views, :integer, :default => 0
  end
  
  def self.down
    drop_table :visitors
    drop_table :visits
    drop_table :subscribes
    remove_column :teasers, :page_views
  end
end
