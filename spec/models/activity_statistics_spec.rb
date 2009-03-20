require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityStatistics do
  dataset do
    @account_one = Account.create!(account_attributes)
    @teaser_one = @account_one.teaser
    @vone = @teaser_one.visitors.create!
    @vtwo = @teaser_one.visitors.create!
  end
  
  before do
    Time.stub!(:now).and_return(Time.local(2009,3,6))
  end
  
  describe 'last 7 days' do
    dataset do
      @vone.visits.create!(:visited_at => Time.local(2009,2,28))
      @vone.visits.create!(:visited_at => Time.local(2009,3,1,12))
      @vone.visits.create!(:visited_at => Time.local(2009,3,1,15))
      @vtwo.visits.create!(:visited_at => Time.local(2009,3,1))
    end
    
    before { @stats = ActivityStatistics.new(@account_one, @teaser_one) }
    
    it 'should answer the start date from 7 days ago' do
      @stats.start_date.should == Date.new(2009,2,28)
    end
    
    it 'should answer labels for each day' do
      @stats.xlabels.should == %w(Sat Sun Mon Tue Wed Thu Fri)
    end
    
    it 'should answer visitors for date range' do
      @stats.visitors_total.should == 3
    end
    
    it 'should answer visitors today' do
      @stats.visitors_today.should == 0
    end
    
    it 'should answer visit counts for each day' do
      @stats.visit_counts.should == [1,3,0,0,0,0,0]
    end
    
    it 'should answer subscribe counts for each day' do
      @sone = @teaser_one.subscribe!(@vone, subscriber_attributes)
      @stats.subscribe_counts.should == [0,0,0,0,0,0,1]
    end
    
    it 'should answer unique visitor counts for each day' do
      @stats.visitor_counts.should == [1,2,0,0,0,0,0]
    end
  end
  
  describe 'before first visit' do
    before { @stats = ActivityStatistics.new(@account_one, @teaser_one) }
    
    it 'should answer visitors with nil for days that were before we began collecting' do
      @vone.visits.create!(:visited_at => Time.now)
      @stats.visitors.should == [nil,nil,nil,nil,nil,0,1]
    end
    
    it 'should answer subscribers with nil for days that were before we began collecting' do
      @teaser_one.subscribe!(@vone, subscriber_attributes)
      @stats.subscribes.should == [nil,nil,nil,nil,nil,0,1]
    end
  end
  
  describe 'y axis' do
    before do
      @stats = ActivityStatistics.new(@account_one, @teaser_one)
      @stats.stub!(:visitor_counts).and_return([0,0,0,0,0,0,0])
      @stats.stub!(:subscribe_counts).and_return([0,0,0,0,0,0,0])
    end
    
    describe 'max' do
      it 'should answer a minimum of 4' do
        @stats.ymax.should == 4
      end
      
      it 'should answer an additional 10% of highest x' do
        @stats.stub!(:visitor_counts).and_return([40])
        @stats.ymax.should == 44
        
        @stats.stub!(:visitor_counts).and_return([5237])
        @stats.ymax.should == 5760
      end
      
      it 'should consider visitors and subscribes' do
        @stats.stub!(:subscribe_counts).and_return([40])
        @stats.stub!(:visitor_counts).and_return([1])
        @stats.ymax.should == 44
        
        @stats.stub!(:subscribe_counts).and_return([1])
        @stats.stub!(:visitor_counts).and_return([40])
        @stats.ymax.should == 44
      end
      
      describe 'steps' do
        it 'should answer a minimum of 1' do
          @stats.ysteps.should == 1
        end
        
        it 'should scale' do
          @stats.stub!(:visitor_counts).and_return([40])
          @stats.ysteps.should == 11
          
          @stats.stub!(:visitor_counts).and_return([5237])
          @stats.ysteps.should == 1440
        end
      end
    end
    
  end
end
