task :start do
  puts `bundle exec rackup`
end

task :install => [:install_gems, :install_bower_packages, :install_config] do
  puts "\nDone.  No you could rake install_neo if you'd like."
end

task :install_gems do
  puts 'Installing gems with bundle.'
  puts `bundle install --path vendor`
end

task :install_bower_packages do
  puts 'Installing bootstrap with bower.'
  puts `bower install bootstrap`
end

task :install_config do
  if File.file?('config.rb')
    puts 'config.rb already present.'
  else
    puts 'Installing config.rb.'
    FileUtils.cp('config.rb.sample', 'config.rb');
  end
end

task :install_neo do
  if Dir.exists?('vendor/neo4j-community-2.0.3')
    puts "Neo4j is already installed in vendor."
  else
    puts 'Getting neo and installing into vendor.'
    `cd vendor &&
     wget "http://dist.neo4j.org/neo4j-community-2.0.3-unix.tar.gz"  -qO- |
    tar -zx`
  end
end

task :start_neo do
  puts `vendor/neo4j-community-2.0.3/bin/neo4j start`
end
