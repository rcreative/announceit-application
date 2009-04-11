# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Teaser do
  before do
    @teaser = Teaser.new
  end
  
  it "should default the title to 'Be a Part of Something Amazing'" do
    @teaser.title.should == 'Be a Part of Something Amazing'
  end
  
  it "should default the description to 'Enter your name and email below to be among the first to participate in our beta program.'" do
    @teaser.description.should == 'Enter your name and email below to be among the first to participate in our beta program.'
  end
  
  it "should default to the default built-in template" do
    default_template = Template.new
    BuiltinTemplate.should_receive(:default).and_return(BuiltinTemplate.new(:template => default_template))
    @teaser.template.should == default_template
  end
  
  it 'should answer the assigned template' do
    assigned = Template.new
    @teaser.template = assigned
    @teaser.template.should == assigned
  end
end