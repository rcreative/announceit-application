class DefaultDataset < Dataset::Base
  uses :accounts
  
  def load
    create_record :teaser, :quentin_teaser,
      :account => :quentin, :template => :white_background
  end
end