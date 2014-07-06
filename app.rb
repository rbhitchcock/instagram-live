set server: :thin, connections: []
enable :sessions
set :haml, format: :html5
$stdout.sync = true

Instagram.configure do |config|
  config.client_id = ENV['IG_CLIENT_ID']
  config.client_secret = ENV['IG_CLIENT_SECRET']
end
ACCESS_TOKEN = ENV['IG_ACCESS_TOKEN']
#CLIENT_ID = ENV['IG_CLIENT_ID']
#CLIENT_SECRET = ENV['IG_CLIENT_SECRET']

#class Instagram
#  include HTTParty
#  format :json
#  base_uri 'api.instagram.com:443'
#  headers 'X-Requested-With' => "XMLHttpRequest", "X-Target-URI" => "https://api.instagram.com"
#
#  def initialize(access_token)
#    @access_token = access_token
#  end
#
#  def tagged_with(tag, options={})
#    self.class.get "/v1/tags/#{tag}/media/recent?access_token=#{@access_token}"
#  end
#
#  def subscribe_to_tag(tag, callback)
#    puts "EHEEHEYEEEY #{callback.inspect}"
#    self.class.post "/v1/subscriptions", query: {verify_token: "YADAYADA", client_id: CLIENT_ID, client_secret: CLIENT_SECRET, object: "tag", aspect: "media", object_id: tag, callback_url: callback}
#  end
#
#  def unsubscribe_all
#    self.class.delete "/v1/subscriptions", query: {client_secret: CLIENT_SECRET, client_id: CLIENT_ID, object: "all"}
#  end
#
#  def subscriptions
#    self.class.get "/v1/subscriptions?client_secret=#{CLIENT_SECRET}&client_id=#{CLIENT_ID}"
#  end
#end

class Streamer < Sinatra::Application
  register Sinatra::AssetPack
  assets do
    serve '/js', from: 'assets/js'
    serve '/bower_components', from: 'bower_components'
    serve '/css', from: 'assets/css'

    js :modernizr, [
      '/bower_components/modernizr/modernizr.js'
    ]

    js :libs, [
      '/js/lib/react.js',
      '/bower_components/jquery/dist/jquery.js',
      '/bower_components/foundation/js/foundation.js',
      '/bower_components/slick-carousel/slick/slick.js'
    ]

    js :application, [
      '/js/app.js'
    ]

    css :application, [
      '/bower_components/slick-carousel/slick/slick.css',
      '/css/app.css'
    ]
  end

  before do
    @client = Instagram.client(access_token: ACCESS_TOKEN)
  end

  get '/subscribe', provides: 'text/event-stream' do
    stream :keep_open do |out|
      settings.connections << out
      out.callback { settings.connections.delete out }
    end
  end

  post '/iglistener' do
    @client.process_subscription(request.body.read, signature: request.headers["X_HUB_SIGNATURE"] do
      logger.info @changes.inspect
    end
    settings.connections.each do |out|
      out << "data: image processed\n\n"
    end
    204
  end

  get '/iglistener' do
    if params[:"hub.mode"] == "subscribe"
      params[:"hub.challenge"]
    end
  end

  get '/igsubscribe' do
    callback = params[:url] || "http://intense-atoll-3212.herokuapp.com/iglistener"
    tag = params[:tag] || "hammersubscriptiontest"
    @client.create_subscription callback_url: callback, object: "tag", object_id: tag
  end

  get '/igunsubscribe' do
    ig.unsubscribe_all
  end

  get '/igsubscriptions' do
    logger.info @client.subscriptions.inspect
    200
  end

  get '/tag/:tag' do
    ig.tagged_with(params[:tag]).body
  end

  get '/' do
    haml :index
  end
end
