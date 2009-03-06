module Admin
  module StatisticsHelper
    def remote_graph(dom_id, options = {}, html_options = {})
      html_options.merge!({:id => dom_id})
      javascript_tag(swf_object(dom_id, options)).concat(content_tag("div", nil, html_options))
    end
    
    def swf_object(dom_id, options = {})
      default_options = {:width => 300, :height => 150}
      options = default_options.merge(options)
      remote = options[:url] ? ", {'data-file':'#{url_for(options[:url])}'}" : ''
      "swfobject.embedSWF('/open-flash-chart.swf', '#{dom_id}', '#{options[:width]}', '#{options[:height]}', '9.0.0', 'expressInstall.swf'#{remote});"
    end
  end
end