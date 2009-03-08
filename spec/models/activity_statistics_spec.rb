require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityStatistics do
  dataset {
    @account_one = Account.create!(account_attributes)
    @teaser_one = @account_one.teaser
    @vone = @teaser_one.visitors.create!
    @vtwo = @teaser_one.visitors.create!
  }
  
  describe 'last 7 days' do
    before do
      Time.stub!(:now).and_return(Time.local(2009,3,6))
      
      @vone.visits.create!(:visited_at => Time.local(2009,2,28))
      @vone.visits.create!(:visited_at => Time.local(2009,3,1))
      @vtwo.visits.create!(:visited_at => Time.local(2009,3,1))
      
      @stats = ActivityStatistics.new(@account_one, @teaser_one)
    end
    
    it 'should answer labels for each day' do
      @stats.xlabels.should == %w(Sat Sun Mon Tue Wed Thu Fri)
    end
    
    it 'should answer visits for each day' do
      @stats.visits.should == [1,2,0,0,0,0,0]
    end
    
    it 'should answer subscribes for each day' do
      @sone = @teaser_one.subscribe!(@vone, subscriber_attributes)
      @stats.subscribes.should == [0,0,0,0,0,0,1]
    end
  end
end
