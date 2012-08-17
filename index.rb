require 'sinatra'
require 'json'
require 'pry'
require './mylighthouse'

get '/' do
  if params[:state].nil?
    @tickets = { :state => "open", :tagged => "marketing" }
  else
    @tickets = { :state => params[:state], :tagged => params[:tagged] }
  end

  haml :index
end

get '/ticket/:id' do
  #obj = MyLighthouse.new()
  #@ticket = obj.get_ticket(params[:id])
  #haml :ticket
end

get '/tickets.json/:state/:tagged' do
  content_type :json

  obj = MyLighthouse.new(params[:state],params[:tagged])
  obj.tickets_to_timeline.to_json
end
