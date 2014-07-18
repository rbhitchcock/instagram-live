set server: :thin, connections: []
enable :sessions
set :haml, format: :html5
$stdout.sync = true

Instagram.configure do |config|
  config.client_id = ENV['IG_CLIENT_ID']
  config.client_secret = ENV['IG_CLIENT_SECRET']
end
ACCESS_TOKEN = ENV['IG_ACCESS_TOKEN']
VERIFY_TOKEN = "WEEEEEEEE"
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
    serve '/fonts', from: 'assets/fonts'

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

  MEDIA_DATA = Hash.new do |h, k|
    h[k] = Hash.new do |h, k|
      h[k] = Hash.new do |h, k|
        h[k] = {}
      end
    end
  end

  before do
    @client = Instagram.client(access_token: ACCESS_TOKEN)
    @session = MEDIA_DATA[ACCESS_TOKEN.to_sym]
  end

  get '/subscribe', provides: 'text/event-stream' do
    stream :keep_open do |out|
      settings.connections << out
      out.callback { settings.connections.delete out }
    end
  end

  post '/iglistener' do
    ig_response = []
    @client.process_subscription request.body.read, signature: env["HTTP_X_HUB_SIGNATURE"] do |handler|
      handler.on_tag_changed do |tag, data|
        ig_response = @client.tag_recent_media tag, min_id: @session[:tags][tag.to_sym][:min_id]
        unless ig_response.empty?
          @session[:tags][tag.to_sym][:min_id] = ig_response.pagination[:min_tag_id]
        end
      end
      handler.on_geography_changed do |geo, data|
        ig_response = @client.geography_recent_media geo, min_id: @session[:geos][geo.to_sym][:min_id], client_id: @client.client_id
        unless ig_response.empty?
          @session[:geos][geo.to_sym][:min_id] = ig_response.pagination[:min_geography_id]
        end
      end
    end
    settings.connections.each do |out|
      out << "data: #{ig_response.to_json}\n\n"
    end
    204
  end

  get '/iglistener' do
    @client.meet_challenge params, VERIFY_TOKEN
  end

  get '/igsubscribe/:object' do
    callback = params[:url] || "http://intense-atoll-3212.herokuapp.com/iglistener"
    aspect = "media"
    case params[:object]
    when "geography"
      lat = params[:lat]
      lng = params[:lng]
      radius = params[:radius]
      if lat.nil? or lng.nil? or radius.nil?
        raise ArgumentError
      end
      args = {lat: lat, lng: lng, radius: radius}
    when "user"
      # implement later
    else
      tag = params[:tag] || "hammersubscriptiontest"
      args = {object_id: tag}
    end
    base_args = {object: params[:object], callback_url: callback, aspect: "media", verify_token: VERIFY_TOKEN}
    Thread.new do |t|
      @client.create_subscription base_args.merge(args)
      t.exit
    end
  end

  get '/igunsubscribe/:id' do
    @client.delete_subscription params[:id]
  end

  get '/igsubscriptions' do
    @client.subscriptions.to_json
  end

  get '/tag/:tag' do
    tag = params[:tag]
    response = @client.tag_recent_media tag, min_id: @session[:tags][tag.to_sym][:min_id]
    unless response.empty?
      @session[:tags][tag.to_sym][:min_id] = response.pagination[:min_tag_id]
    end
    settings.connections.each do |out|
      out << "data: #{response.to_json}\n\n"
    end
    204
  end

  get '/' do
    haml :index
  end
end
