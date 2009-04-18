# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Teaser do
  before do
    @template = stub_model(Template, :name => 'C', :source => 'S', :styles => 'SS')
    @teaser = Teaser.new
  end
  
  it "should default the title to 'Be a Part of Something Amazing'" do
    @teaser.title.should == 'Be a Part of Something Amazing'
  end
  
  it "should default the description to 'Enter your name and email below to be among the first to participate in our beta program.'" do
    @teaser.description.should == 'Enter your name and email below to be among the first to participate in our beta program.'
  end
  
  it "should assign the default built-in template when created" do
    default_template = stub_model(Template)
    BuiltinTemplate.should_receive(:default).and_return(BuiltinTemplate.new(:template => default_template))
    @teaser.save!
    @teaser.template.should == default_template
  end
  
  it 'should answer the assigned template' do
    assigned = Template.new
    @teaser.template = assigned
    @teaser.template.should == assigned
  end
  
  it 'should clone the customizable default template' do
    BuiltinTemplate.should_receive(:customizable).and_return(stub_model(BuiltinTemplate, :template => @template))
    lambda do
      @teaser.template_id = '0'
      @teaser.save!
    end.should change(@teaser.custom_templates, :size).by(1)
    @teaser.template.should be_clone_of(@template)
  end
  
  it 'should clone the current template if there is not already a Custom Template…' do
    @teaser.template = @template
    @teaser.customize_selected = 'true'
    lambda do
      @teaser.save!
    end.should change(@teaser.custom_templates, :size).by(1)
    @teaser.template.should be_clone_of(@template, :name => 'Custom Template…')
  end
  
  it 'should ignore a request to clone the current template if there is already a Custom Template…' do
    @template.name = 'Custom Template…'
    @teaser.custom_templates.build(:template => @template)
    @teaser.customize_selected = 'true'
    lambda do
      @teaser.save!
    end.should_not change(@teaser.custom_templates, :size)
  end
  
  def be_clone_of(expected, options = {})
    simple_matcher('clone') do |actual|
      actual.should_not == expected
      if options[:name]
        actual.name.should == options[:name]
      else
        actual.name.should == expected.name
      end
      actual.source.should == expected.source
      actual.styles.should == expected.styles
    end
  end
end