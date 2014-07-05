require 'sinatra'
set server: :thin, connections: []
enable :sessions
set :haml, format: :html5

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete out }
  end
end

get '/listener' do
  if params[:"hub.mode"] == "subscribe"
    params[:"hub.challenge"]
  end
end

post '/listener' do
  puts request.inspect
  puts "PARAMS: #{JSON.parse(request.body.read)}"
end

post '/' do
  settings.connections.each do |out|
    out << "data: #{params[:msg]}\n\n"
  end
  204
end

get '/' do
  halt haml(:login) unless params[:user]
  haml :chat, locals: { user: params[:user].gsub(/\W/, '') }
end
