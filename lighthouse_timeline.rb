$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'sinatra'
require 'sinatra/streaming'
require 'json'
require 'xmlsimple'
require 'pry'
require 'pry-remote'
require './mylighthouse'
require './mygoogleapi'

class LighthouseTimeline < Sinatra::Base
  helpers Sinatra::Streaming

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

  ["/tickets.json/:state/:tagged?", "/tickets.json/:state?"].each do |path|
    get path do
      content_type :json

      obj = MyLighthouse.new(params[:state],params[:tagged])
      obj.tickets_to_timeline.to_json
    end
  end

  get '/tracker/:number' do
    stream do |out|
      found = nil
      tObj = MyLighthouse.new('marketing','open')
      ticket = tObj.get_ticket(params[:number])
      
      obj = MyGoogleAPI.new(ticket)
      obj.authenticate

      sheets = obj.fix_sheet_urls

        sheets.each do |sheet|
          response = obj.get_feed(sheet)
          listfeed_doc = XmlSimple.xml_in(response.body, 'KeyAttr' => 'name')
          
          if !obj.check_sheet_for_dupe(listfeed_doc)
            out <<  "Not found in: #{listfeed_doc['title'][0]['content']}\n"
          else
            out << "Found in: #{listfeed_doc['title'][0]['content']}\n" 
            found = true
          end
        end

      if !found.nil?
        result = obj.update_worksheet
        out << "Ticket added to spreadsheet"
      end
    end
  end
end
