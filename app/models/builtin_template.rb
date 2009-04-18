class BuiltinTemplate < ActiveRecord::Base
  belongs_to :template
  
  def BuiltinTemplate.default
    first :include => :template, :conditions => {:default_template => true}
  end
  
  def BuiltinTemplate.customizable
    first :include => :template, :conditions => {:default_customizable => true}
  end
end