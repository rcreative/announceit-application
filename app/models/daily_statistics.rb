class DailyStatistics < ActivityStatistics
  def initialize(account, teaser)
    super('Visitors and Subscribers in the Past 7 Days', account, teaser, Date.today-6.days)
  end
  
  def kind; 'daily'; end
  
  def xlabels
    @dates.collect {|d| d.strftime('%a') }
  end
  
  def xsteps
    1
  end
end