module Admin
  module TeasersHelper
    def template_names
      template_names = BuiltinTemplate.all(:include => :template).collect(&:template).collect {|t| [t.name, t.id]}
      if @teaser.custom_templates.any?
        custom_names = @teaser.custom_templates.collect(&:template).collect {|t| [t.name, t.id]}
        template_names.concat(custom_names)
      end
      template_names
    end
  end
end