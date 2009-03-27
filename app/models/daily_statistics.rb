class DailyStatistics < ActivityStatistics
  def initialize(account, teaser)
    super(account, teaser, Date.today-6.days)
  end
  
  def xlabels
    @dates.collect {|d| d.strftime('%a') }
  end
  
  def xsteps
    1
  end
end