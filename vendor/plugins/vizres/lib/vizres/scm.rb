module Vizres
  class SCM
    class << self
      
      def create_tmp_if_missing(tmp_directory)
        unless File.exists?(tmp_directory)
          FileUtils.mkdir_p(tmp_directory)
          
          if git?
            system("echo '\npublic/tmp/*' >> #{RAILS_ROOT}/.gitignore")
          elsif svn?
            system("svn propset svn:ignore tmp #{RAILS_ROOT}/public")
          end
        end
      end
      
      def git?
        File.directory? File.join(RAILS_ROOT, '.git')
      end
      
      def svn?
        File.file? File.join(RAILS_ROOT, '.svn')
      end
      
    end
  end
end