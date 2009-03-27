class ActivityStatistics
  extend ActiveSupport::Memoizable
  
  attr_reader :start_date, :title
  
  def initialize(title, account, teaser, start_date)
    @title, @account, @teaser, @start_date = title, account, teaser, start_date
    @dates = (start_date..Date.today)
  end
  
  def activity?
    subscribes? || visitors?
  end
  
  def ymax
    highest_value = ([visitor_counts.max, subscribe_counts.max].max * 1.10).to_i
    [highest_value, 4].max
  end
  
  def ysteps
    [(ymax / 4).to_i, 1].max
  end
  
  def subscribe_counts
    counts = @teaser.subscribes.count(:all,
      :group => 'date(subscribed_on)',
      :conditions => ['subscribed_on >= ? and subscribed_on <= ?', @dates.first, @dates.last])
    @dates.collect {|d| counts[d.to_s(:db)] || 0 }
  end
  memoize :subscribe_counts
  
  def subscribes
    first = @teaser.subscribes.first
    day_before_first = (first ? first.subscribed_on : Date.today) - 1.day
    data = subscribe_counts.dup
    @dates.each_with_index do |d,i|
      data[i] = nil if d < day_before_first
    end
    data
  end
  
  def subscribes?
    subscribe_counts.inject(0) {|sum,c| sum + c} != 0
  end
  
  def visit_counts
    counts = @teaser.visits.count(:all,
      :group => 'date(visited_at)',
      :conditions => ['visited_at >= ? and visited_at < ?', @dates.first.midnight, (@dates.last + 1).midnight])
    @dates.collect {|d| counts[d.to_s(:db)] || 0 }
  end
  memoize :visit_counts
  
  def visits?
    visit_counts.inject(0) {|sum,c| sum + c} != 0
  end
  
  def visitors
    first = @teaser.visits.first
    day_before_first = (first ? first.visited_at.to_date : Date.today) - 1.day
    data = visitor_counts.dup
    @dates.each_with_index do |d,i|
      data[i] = nil if d < day_before_first
    end
    data
  end
  
  def visitor_counts
    counts = @teaser.visits.count(
      'date(visited_at), visitor_id',
      :distinct => true,
      :group => 'date(visited_at)',
      :conditions => ['visited_at >= ? and visited_at < ?', @dates.first.midnight, (@dates.last + 1).midnight]
    )
    @dates.collect {|d| counts[d.to_s(:db)] || 0 }
  end
  memoize :visitor_counts
  
  def visitors?
    visitors_total != 0
  end
  
  def visitors_today
    visitor_counts.last
  end
  
  def visitors_total
    visitor_counts.inject(0) {|sum,c| sum + c}
  end
end