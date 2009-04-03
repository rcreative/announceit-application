namespace :prototype do
  
  desc "Copy SASS assets from prototype"
  task :sass do
    FileUtils.rm_rf "public/stylesheets/sass"
    FileUtils.cp_r "../prototype/stylesheets/sass", "public/stylesheets"
    Dir['public/stylesheets/sass/**/*.sass'].each do |sass_file|
      old_content = File.read(sass_file)
      File.truncate(sass_file, 0)
      File.open(sass_file, 'w') do |f|
        f.write(old_content.gsub(/@import \/stylesheets\/sass\//, '@import '))
      end
    end
  end
  
end