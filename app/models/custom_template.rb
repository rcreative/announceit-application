class CustomTemplate < ActiveRecord::Base
  belongs_to :teaser
  belongs_to :template
end