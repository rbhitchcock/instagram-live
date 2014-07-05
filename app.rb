set server: :thin, connections: []
enable :sessions
set :haml, format: :html5
$stdout.sync = true

ACCESS_TOKEN = ENV['IG_ACCESS_TOKEN']
CLIENT_ID = ENV['IG_CLIENT_ID']
CLIENT_SECRET = ENV['IG_CLIENT_SECRET']

class Instagram
  include HTTParty
  format :json
  base_uri 'api.instagram.com:443'
  headers 'X-Requested-With' => "XMLHttpRequest", "X-Target-URI" => "https://api.instagram.com"

  def initialize(access_token)
    @access_token = access_token
  end

  def tagged_with(tag, options={})
    self.class.get "/v1/tags/#{tag}/media/recent?access_token=#{@access_token}"
  end
end

class Streamer < Sinatra::Application
  get '/subscribe', provides: 'text/event-stream' do
    puts params.inspect
    stream :keep_open do |out|
      settings.connections << out
      out.callback { settings.connections.delete out }
    end
  end

  get '/somethingelse' do
    logger.info params.inspect
  end

  get '/listener' do
    if params[:"hub.mode"] == "subscribe"
      params[:"hub.challenge"]
    end
  end

  post '/listener' do
    puts request.inspect
    puts "BODY: #{request.body.read}"
    puts "PARAMS: #{JSON.parse(request.body.read)}"
    settings.connections.each do |out|
      out << "data: #{params[:msg]}\n\n"
    end
    204
  end

  get '/tag/:tag' do
    Instagram.new(ACCESS_TOKEN).tagged_with(params[:tag]).body
  end

  get '/' do
    haml :index
  end
end
