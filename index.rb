require 'sinatra'
require 'json'
require 'xmlsimple'
require 'pry'
require './mylighthouse'
require './mygoogleapi'

get '/' do
  if params[:state].nil?
    @tickets = { :state => "open", :tagged => "marketing" }
  else
    @tickets = { :state => params[:state], :tagged => params[:tagged] }
  end

  binding.pry
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

get '/tracker/:number' do
  tObj = MyLighthouse.new('marketing','open')
  ticket = tObj.get_ticket(params[:number])
  
  obj = MyGoogleAPI.new(ticket)
  obj.authenticate
  obj.update_worksheet
end
