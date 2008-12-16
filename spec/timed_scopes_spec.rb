require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
require 'timed_scopes'
require 'sqlite3'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

silence_warnings do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile => ":memory:"
  )

  ActiveRecord::Schema.define do
    create_table :things do |table|
      table.datetime  :published_at
      table.timestamps
    end
    
    create_table :thongs do |table|
      table.string :name
    end
  end
end

class Thing < ActiveRecord::Base
end

class Thong < ActiveRecord::Base
end

describe TimedScopes do
  
  it "should be mixed into ActiveRecord::Base" do
    ActiveRecord::Base.should include(TimedScopes)
  end
  
  describe "#has_timed_scopes" do
    
    it "should define three named_scopes" do
      Thing.should_receive(:named_scope).at_least(3).times
      Thing.has_timed_scopes
    end

    it "should define (attr)_after, (attr)_before, and (attr)_between named scopes for each column ending in '_on' or '_at" do
      Thing.has_timed_scopes
      Thing.should respond_to(:created_after)
      Thing.should respond_to(:created_before)
      Thing.should respond_to(:created_between)
      Thing.should respond_to(:updated_after)
      Thing.should respond_to(:updated_before)
      Thing.should respond_to(:updated_between)
      Thing.should respond_to(:published_after)
      Thing.should respond_to(:published_before)
      Thing.should respond_to(:published_between)
    end

    it "should not define anything for a model with no '_on' or '_at' columns" do
      Thong.should_not_receive(:named_scope)
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
  end
end