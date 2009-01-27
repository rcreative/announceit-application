class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    Notifications.deliver_account_created(account)
  end
end
