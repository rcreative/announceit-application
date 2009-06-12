# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe TemplateImage do
  it 'should destroy image when no other template references the image' do
    Image.should_receive(:delete).with(1)
    TemplateImage.create!(:template_id => 1, :image_id => 1).destroy
  end
  
  it 'should not destroy image when other template references the image' do
    Image.should_not_receive(:delete)
    TemplateImage.create!(:template_id => 1, :image_id => 1)
    TemplateImage.create!(:template_id => 2, :image_id => 1).destroy
  end
end