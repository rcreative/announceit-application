class Teaser < ActiveRecord::Base
  belongs_to :account
  belongs_to :template
  
  has_many :custom_templates, :include => :template
  
  has_many :subscribers, :order => 'name, email'
  has_many :subscribes
  
  has_many :visitors
  has_many :visits, :through => :visitors
  
  has_attached_file :logo
  
  validates_presence_of :template_id
  
  before_validation :assign_custom_template
  before_validation_on_create :assign_default_template
  
  attr_accessor :customize_selected
  
  def custom_template_defined?
    !!custom_templates.detect {|ct| ct.template.name == 'Custom Template…'}
  end
  
  def custom_template_selected?
    !!custom_templates.detect {|t| t.template == template}
  end
  
  def title
    self[:title] || 'Be a Part of Something Amazing'
  end
  
  def description
    self[:description] || 'Enter your name and email below to be among the first to participate in our beta program.'
  end
  
  def subscribe!(visitor, subscriber_attributes)
    returning(subscribers.create!(subscriber_attributes)) do |s|
      subscribes.create!(
        :visitor => visitor,
        :subscriber => s,
        :subscribed_on => s.created_at.to_date
      )
    end
  end
  
  def unmodified?
    !(title? || description? || logo_file_name?)
  end
  
  protected
    def assign_default_template
      self.template = BuiltinTemplate.default.template unless template
    end
    
    def assign_custom_template
      if template_id == 0
        customizable_template = BuiltinTemplate.customizable.template
        self.template = Template.new(customizable_template.attributes)
        custom_templates.build(:template => self.template)
      elsif customize_selected == 'true' && !custom_template_defined?
        self.template = Template.new(template.attributes)
        template.name = 'Custom Template…'
        custom_templates.build(:template => self.template)
      end
    end
end