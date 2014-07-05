require 'coffee-script'

PUBLIC_DIR = "public/"
namespace :assets do
  task :precompile do
    # coffee => js
    js_dir = PUBLIC_DIR << "js/"
    `mkdir -p #{js_dir}`
    Dir["assets/coffeescript/*.coffee"].each do |cf|
      base = cf.match(%r{/(\w+)\.coffee$})[1]
      ofile = js_dir << base <<  ".js"
      File.open(ofile, 'w') do |file|
        file.write CoffeeScript.compile(File.read(cf))
      end
    end
  end
end
