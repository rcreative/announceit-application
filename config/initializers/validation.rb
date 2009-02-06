ActionView::Base.field_error_proc = Proc.new do |html, instance|
  unless html =~ /^<label/
    %{<span class="field_with_errors">#{html}</span> <span class="field_error">&bull; #{[instance.error_message].flatten.first}</span>}
  else
    %{<span class="label_with_errors"#{html}</span>}
  end
end

Authentication.bad_email_message = 'invalid email address'