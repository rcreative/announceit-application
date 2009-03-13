require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityStatistics do
  dataset {
    @account_one = Account.create!(account_attributes)
    @teaser_one = @account_one.teaser
    @vone = @teaser_one.visitors.create!
    @vtwo = @teaser_one.visitors.create!
  }
  
  before do
    Time.stub!(:now).and_return(Time.local(2009,3,6))
    @stats = ActivityStatistics.new(@account_one, @teaser_one)
  end
  
  describe 'last 7 days' do
    before do
      @vone.visits.create!(:visited_at => Time.local(2009,2,28))
      @vone.visits.create!(:visited_at => Time.local(2009,3,1))
      @vtwo.visits.create!(:visited_at => Time.local(2009,3,1))
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
  
  describe 'y axis' do
    before do
      @stats.stub!(:visits).and_return([0,0,0,0,0,0,0])
      @stats.stub!(:subscribes).and_return([0,0,0,0,0,0,0])
    end
    
    describe 'max' do
      it 'should answer a minimum of 5' do
        @stats.ymax.should == 5
      end
      
      it 'should answer an additional 10% of highest x' do
        @stats.stub!(:visits).and_return([40])
        @stats.ymax.should == 44
        
        @stats.stub!(:visits).and_return([5237])
        @stats.ymax.should == 5760
      end
      
      it 'should consider visits and subscribes' do
        @stats.stub!(:subscribes).and_return([40])
        @stats.stub!(:visits).and_return([1])
        @stats.ymax.should == 44
        
        @stats.stub!(:subscribes).and_return([1])
        @stats.stub!(:visits).and_return([40])
        @stats.ymax.should == 44
      end
      
      describe 'steps' do
        it 'should answer a minimum of 1' do
          @stats.ysteps.should == 1
        end
        
        it 'should scale' do
          @stats.stub!(:visits).and_return([40])
          @stats.ysteps.should == 11
          
          @stats.stub!(:visits).and_return([5237])
          @stats.ysteps.should == 1440
        end
      end
    end
    
  end
end
