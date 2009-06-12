# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'

describe Template do
  before do
    @template = Template.new
  end
  
  it 'should destroy template images when destroyed' do
    Template.reflect_on_association(:template_images).options[:dependent].should == :destroy
  end
  
  it 'should render the source html' do
    @template.should render('hello, guys', 'hello, guys')
  end
  
  it 'should output a subscribe form' do
    @template.should render(
      '<r:subscribe_form><r:name_input id="subscriber_name" /><r:email_input id="subscriber_email" /></r:subscribe_form>',
      '<form action="/subscribe" method="post"><input type="text" name="subscriber[name]" id="subscriber_name" class="textbox" value="" /><input type="text" name="subscriber[email]" id="subscriber_email" class="textbox" value="" /></form>'
    )
  end
  
  it 'should expose the subscriber name and email' do
    @template.should render(
      '<r:subscriber:name />:<r:subscriber:email />',
      'Johnny:johnny@example.com',
      :subscriber => stub_model(Subscriber, :name => 'Johnny', :email => 'johnny@example.com')
    )
  end
  
  it 'should expose the teaser title and description' do
    @template.should render(
      '<r:teaser:title />:<r:teaser:description />',
      'Title:Description',
      :teaser => stub_model(Teaser, :title => 'Title', :description => 'Description')
    )
  end
  
  it 'should render the logo image' do
    @template.should render(
      '<r:logo />',
      '<img src="logourl" />',
      :teaser => stub_model(Teaser, :logo => OpenStruct.new(:url => 'logourl'))
    )
  end
  
  it 'should render if_logo block when a teaser has a logo' do
    @template.should render(
      '<r:if_logo>hola</r:if_logo>',
      'hola',
      :teaser => stub_model(Teaser, :logo => OpenStruct.new(:exists? => true))
    )
    @template.should render(
      '<r:if_logo>hola</r:if_logo>',
      '',
      :teaser => stub_model(Teaser, :logo => OpenStruct.new(:exists? => false))
    )
  end
  
  it 'should render if_success block when a subscriber is created without error' do
    @template.should render(
      '<r:if_success>Content</r:if_success>',
      'Content',
      :subscriber => stub_model(Subscriber, :new_record? => false)
    )
    @template.should render(
      '<r:if_success>Content</r:if_success>',
      '',
      :subscriber => stub_model(Subscriber, :new_record? => true)
    )
  end
  
  it 'should render unless_success block when a subscriber is a new record' do
    @template.should render(
      '<r:unless_success>Content</r:unless_success>',
      'Content'
    )
    @template.should render(
      '<r:unless_success>Content</r:unless_success>',
      'Content',
      :subscriber => stub_model(Subscriber, :new_record? => true)
    )
  end
  
  it 'should render if_error block when a subscriber is not valid' do
    @template.should render(
      '<r:if_error>Content</r:if_error>',
      'Content',
      :subscriber => stub_model(Subscriber, :errors => OpenStruct.new(:any? => true))
    )
    @template.should render(
      '<r:if_error>Content</r:if_error>',
      '',
      :subscriber => stub_model(Subscriber, :errors => OpenStruct.new(:any? => false))
    )
  end
  
  it 'should render unless_error block when a subscriber is valid' do
    @template.should render(
      '<r:unless_error>Content</r:unless_error>',
      'Content',
      :subscriber => stub_model(Subscriber, :errors => OpenStruct.new(:any? => false))
    )
    @template.should render(
      '<r:unless_error>Content</r:unless_error>',
      '',
      :subscriber => stub_model(Subscriber, :errors => OpenStruct.new(:any? => true))
    )
  end
  
  it 'should output a link to the styles of the template, using the update time stamp as an asset id' do
    @template.id = 232
    @template.updated_at = Time.parse('Mar 14, 2009 at 11:14AM UTC')
    @template.should render(
      '<r:styles media="screen" />',
      '<link href="/templates/232/styles.css?200903141114" media="screen" rel="stylesheet" type="text/css" />'
    )
  end
  
  def render(source, expected, locals = {})
    locals[:subscriber] ||= Subscriber.new
    simple_matcher(expected) do |template|
      template.source = source
      template.render(locals).should == expected
    end
  end
end