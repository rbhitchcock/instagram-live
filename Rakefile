PUBLIC_DIR = "public/"
namespace :assets do
  task :precompile do
    `npm install`
    # jsx => js
    js_dir = PUBLIC_DIR << "js/"
    `mkdir -p #{js_dir}`
    Dir["assets/jsx/*.jsx"].each do |jsx|
      base = jsx.match(%r{/(\w+)\.jsx$})[1]
      ofile = js_dir << base <<  ".js"
      `jsx #{jsx} > #{ofile}`
    end
  end
end
