class Notifications < ActionMailer::Base
  
  def account_created(account)
    subject    '[Announce] Account Created'
    recipients %w(adam@thewilliams.ws me@johnwlong.com)
    from       'Announce App <deploy@recursivecreative.com>'
    body       "A new account was created. See the teaser at the subdomain #{account.subdomain}."
  end
  
end
