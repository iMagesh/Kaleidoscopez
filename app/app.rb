require 'sinatra'
require './app/boot'
require 'sass'

class App < Sinatra::Base

  dir = File.dirname(File.expand_path(__FILE__))
  set :public_folder, "#{dir}/../public"

  get '/' do
    send_file 'public/index.html'
  end

  get '/all_news' do
    items = Item.all.collect {|item| item.attributes.merge("source" => item.source.name)}
    content_type :json
    {:items => items.shuffle!}.to_json
  end

  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:"stylesheets/#{params[:name]}" )
  end

  get '/news/:channel_name' do |name|
    content_type :json
    channel = Channel.where(:name => name).to_a[0]
    items = channel.sources.collect do |source|
      Item.where(:source => source).collect {|item| item.attributes.merge("source" => item.source.name)}
    end.flatten
    {:items => items.shuffle}.to_json
  end

end
