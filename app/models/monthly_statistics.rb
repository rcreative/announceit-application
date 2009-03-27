class MonthlyStatistics < ActivityStatistics
  def initialize(account, teaser)
    super('Visitors and Subscribers in the Past 2 Months', account, teaser, Date.today - (8*7).days)
  end
  
  def kind; 'monthly'; end
  
  def xlabels
    intervals = [@start_date]
    8.times { intervals.push(intervals.last + 7.days) }
    labels = []
    intervals.each do |date|
      labels.push(date.strftime('%b %e').squeeze(' '))
      labels.concat(Array.new(6, '')) unless intervals.last == date
    end
    labels
  end
  
  def xsteps
    7
  end
end