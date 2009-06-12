require 'radius'

class Template < ActiveRecord::Base
  has_many :template_images, :dependent => :destroy
  has_many :images, :through => :template_images
  
  def render(locals)
    parser = Radius::Parser.new(context(locals), :tag_prefix => 'r')
    parser.parse(source)
  end
  
  protected
    def context(locals)
      subscriber = locals[:subscriber]
      teaser     = locals[:teaser]
      
      Radius::Context.new do |c|
        c.define_tag "styles" do |tag|
          %(<link href="/templates/#{id}/styles.css?#{updated_at.to_s(:asset_id)}" media="#{tag.attr['media']}" rel="stylesheet" type="text/css" />)
        end
        c.define_tag "if_success" do |tag|
          tag.expand unless subscriber.new_record?
        end
        c.define_tag "unless_success" do |tag|
          tag.expand if subscriber.new_record?
        end
        c.define_tag "if_error" do |tag|
          tag.expand if subscriber.errors.any?
        end
        c.define_tag "unless_error" do |tag|
          tag.expand unless subscriber.errors.any?
        end
        c.define_tag "subscribe_form" do |tag|
          %(<form action="/subscribe" method="post">#{tag.expand}</form>)
        end
        c.define_tag "name_input" do |tag|
          %(<input type="text" name="subscriber[name]" id="#{tag.attr['id']}" class="textbox" value="#{subscriber.name}" />)
        end
        c.define_tag "email_input" do |tag|
          %(<input type="text" name="subscriber[email]" id="#{tag.attr['id']}" class="textbox" value="#{subscriber.email}" />)
        end
        c.define_tag "if_logo" do |tag|
          tag.expand if teaser.logo.exists?
        end
        c.define_tag "logo" do |tag|
          %(<img src="#{teaser.logo.url}" />)
        end
        
        c.define_tag "subscriber", :for => subscriber, :expose => [ :name, :email ]
        c.define_tag "teaser",     :for => teaser,     :expose => [ :title, :description ]
      end
    end
end