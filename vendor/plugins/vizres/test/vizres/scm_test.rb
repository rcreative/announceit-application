require 'test/unit'
require 'rubygems'
require 'mocha'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))
require 'vizres'

class SCMTest < Test::Unit::TestCase
  
  def test_create_tmp_if_missing_with_git
    ignore_path = RAILS_ROOT + '/.gitignore'
    already_exists = File.exists?(ignore_path)
    content = already_exists ? File.read(ignore_path) : nil
    
    SCM.expects(:git?).returns(true)
    tmp_directory = File.join(RAILS_ROOT, 'public', 'tmp')
    
    begin
      SCM.create_tmp_if_missing tmp_directory
      new_content = File.read(ignore_path)
      assert new_content.match('public/tmp/*')
    ensure
      FileUtils.rm_f RAILS_ROOT + '/.gitignore' unless already_exists
      FileUtils.rm_rf RAILS_ROOT + '/public'
      system "echo '#{content.strip}' > #{ignore_path}" if already_exists
    end
  end
  
  def test_create_tmp_if_missing_with_svn
    SCM.expects(:git?).returns(false)
    SCM.expects(:svn?).returns(true)
    SCM.expects(:system).with("svn propset svn:ignore tmp #{RAILS_ROOT}/public")
    
    begin
      SCM.create_tmp_if_missing File.join(RAILS_ROOT, 'public', 'tmp')
    ensure
      FileUtils.rm_rf RAILS_ROOT + '/public'
    end
  end
  
end
