require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/timed_scopes')
require File.expand_path(File.dirname(__FILE__) + '/../init.rb')
require 'sqlite3'

describe TimedScopes do
  
  it "should be mixed into ActiveRecord::Base" do
    ActiveRecord::Base.should include(TimedScopes)
  end
  
  describe "when the table doesn't exist" do
    before(:each) do
      class Stuff < ActiveRecord::Base
      end
    end
    
    it "should do nothing instead of throwing errors complaining that the table doesn't exist" do
      lambda { Stuff.has_timed_scopes }.should_not raise_error(ActiveRecord::StatementInvalid)
    end
  end
  
  describe "#has_timed_scopes" do
    
    it "should define five named_scopes on each datetime or timestamp column" do
      Thing.expects(:named_scope).times(15)
      Thing.has_timed_scopes
    end

    it "should define (attr)_after, (attr)_before, and (attr)_between named scopes for each column ending in '_on' or '_at" do
      Thing.has_timed_scopes
      Thing.should respond_to(:created_after)
      Thing.should respond_to(:created_at_or_after)
      Thing.should respond_to(:created_before)
      Thing.should respond_to(:created_at_or_before)
      Thing.should respond_to(:created_between)
      Thing.should respond_to(:updated_after)
      Thing.should respond_to(:updated_at_or_after)
      Thing.should respond_to(:updated_before)
      Thing.should respond_to(:updated_at_or_before)
      Thing.should respond_to(:updated_between)
      Thing.should respond_to(:published_after)
      Thing.should respond_to(:published_at_or_after)
      Thing.should respond_to(:published_before)
      Thing.should respond_to(:published_at_or_before)
      Thing.should respond_to(:published_between)
    end

    it "should not create named scopes for an attribute without a time type" do
      Thing.should_not respond_to(:light_switch_after)
      Thing.should_not respond_to(:light_switch_on_or_after)
      Thing.should_not respond_to(:light_switch_before)
      Thing.should_not respond_to(:light_switch_on_or_before)
      Thing.should_not respond_to(:light_switch_between)
    end

    it "should not define anything for a model with no '_on' or '_at' columns" do
      Thong.expects(:named_scope).never
      Thong.has_timed_scopes
    end
  end
  
  describe "#(attr)_after" do
    it "should have the correct proxy_options" do
      prox = Thing.published_after(1.month.ago).proxy_options
      prox[:conditions][0].should include("things.published_at > ?")
      prox[:conditions][1].should == Time.parse(1.month.ago.to_s)
    end

    it "should default to ordering by the given column DESC" do
      prox = Thing.published_after(1.month.ago).proxy_options
      prox[:order].should include("DESC")
    end
    
    it "should allow ascending order by passing 'ASC' as an additional argument" do
      prox = Thing.published_after(1.month.ago, "ASC").proxy_options
      prox[:order].should include("ASC")
    end

    it "should allow no ordering by passing false as an additional argument" do
      prox = Thing.published_after(1.month.ago, false).proxy_options
      prox[:order].should be_nil
    end
  end

  describe "#(attr)_(at|on)_or_after" do
    it "should have the correct proxy_options" do
      prox = Thing.published_at_or_after(1.month.ago).proxy_options
      prox[:conditions][0].should include("things.published_at >= ?")
      prox[:conditions][1].should == Time.parse(1.month.ago.to_s)
    end

    it "should default to ordering by the given column DESC" do
      prox = Thing.published_after(1.month.ago).proxy_options
      prox[:order].should include("DESC")
    end
    
    it "should allow ascending order by passing 'ASC' as an additional argument" do
      prox = Thing.published_after(1.month.ago, "ASC").proxy_options
      prox[:order].should include("ASC")
    end

    it "should allow no ordering by passing false as an additional argument" do
      prox = Thing.published_after(1.month.ago, false).proxy_options
      prox[:order].should be_nil
    end
  end
  
  describe "#(attr)_before" do
    it "should have the correct proxy_options" do
      prox = Thing.published_before(1.month.ago).proxy_options
      prox[:conditions][0].should include("things.published_at < ?")
      prox[:conditions][1].should == Time.parse(1.month.ago.to_s)
    end

    it "should default to ordering by the given column DESC" do
      prox = Thing.published_before(1.month.ago).proxy_options
      prox[:order].should include("DESC")
    end
    
    it "should allow ascending order by passing 'ASC' as an additional argument" do
      prox = Thing.published_before(1.month.ago, "ASC").proxy_options
      prox[:order].should include("ASC")
    end

    it "should allow no ordering by passing false as an additional argument" do
      prox = Thing.published_before(1.month.ago, false).proxy_options
      prox[:order].should be_nil
    end
  end
  
  describe "#(attr)_(at|on)_or_before" do
    it "should have the correct proxy_options" do
      prox = Thing.published_at_or_before(1.month.ago).proxy_options
      prox[:conditions][0].should include("things.published_at <= ?")
      prox[:conditions][1].should == Time.parse(1.month.ago.to_s)
    end

    it "should default to ordering by the given column DESC" do
      prox = Thing.published_before(1.month.ago).proxy_options
      prox[:order].should include("DESC")
    end
    
    it "should allow ascending order by passing 'ASC' as an additional argument" do
      prox = Thing.published_before(1.month.ago, "ASC").proxy_options
      prox[:order].should include("ASC")
    end

    it "should allow no ordering by passing false as an additional argument" do
      prox = Thing.published_before(1.month.ago, false).proxy_options
      prox[:order].should be_nil
    end
  end
  
  describe "#(attr)_between" do
    it "should have the correct proxy_options" do
      prox = Thing.published_between(1.month.ago, 1.week.ago).proxy_options
      prox[:conditions][0].should include("things.published_at > ?")
      prox[:conditions][0].should include("things.published_at < ?")      
      prox[:conditions][1].should == Time.parse(1.month.ago.to_s)
      prox[:conditions][2].should == Time.parse(1.week.ago.to_s)
    end

    it "should default to ordering by the given column DESC" do
      prox = Thing.published_between(1.month.ago, 1.week.ago).proxy_options
      prox[:order].should include("DESC")
    end
    
    it "should allow ascending order by passing 'ASC' as an additional argument" do
      prox = Thing.published_between(1.month.ago, 1.week.ago, "ASC").proxy_options
      prox[:order].should include("ASC")
    end    

    it "should allow no ordering by passing false as an additional argument" do
      prox = Thing.published_between(1.month.ago, 1.week.ago, false).proxy_options
      prox[:order].should be_nil
    end
  end
end