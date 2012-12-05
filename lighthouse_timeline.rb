$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'sinatra'
require 'json'
require 'xmlsimple'
require 'pry'
require 'pry-remote'
require 'logger'
require './mylighthouse'
require './mygoogleapi'

class LighthouseTimeline < Sinatra::Base
  #include AcsAuthentication::Base
  
  configure do
    LOGGER = Logger.new("log/#{ENV['RACK_ENV']}_timeline.log")
    enable :raise_errors
    enable :logging, :dump_errors, :show_exceptions
  end

  get '/' do
    if params[:state].nil?
      @tickets = { :state => "open", :tagged => "marketing" }
    else
      @tickets = { :state => params[:state], :tagged => params[:tagged] }
    end

    if !params[:responsible].nil?
      @tickets[:responsible] = params[:responsible]
    else
      @tickets[:responsible] = ""
    end

    haml :index
  end

  get '/ticket/:id' do
    #obj = MyLighthouse.new()
    #@ticket = obj.get_ticket(params[:id])
    #haml :ticket
  end

  ["/tickets.json/:state/:tagged/:responsible?", "/tickets.json/:state/:responsible?", "/tickets.json/:state/:tagged?", "/tickets.json/:state?"].each do |path|
    get path do
      content_type :json

      obj = MyLighthouse.new(params[:state],params[:tagged],params[:responsible])
      obj.tickets_to_timeline.to_json
    end
  end

  get '/tracker/:number' do
    found = nil
    out = ""
    tObj = MyLighthouse.new('marketing','open','')
    ticket = tObj.get_ticket(params[:number])

    obj = MyGoogleAPI.new(ticket)
    obj.authenticate

    sheets = obj.fix_sheet_urls

    sheets.each do |sheet|
      response = obj.get_feed(sheet)
      listfeed_doc = XmlSimple.xml_in(response, 'KeyAttr' => 'name')
      
      if !obj.check_sheet_for_dupe(listfeed_doc)
        out <<  "Not found in: #{listfeed_doc['title'][0]['content']}<br />"
      else
        out << "Found in: #{listfeed_doc['title'][0]['content']}<br />" 
        found = true
        break
      end
    end

    if found.nil?
      result = obj.update_worksheet
      out << "Ticket added to spreadsheet"
    end
    out
  end

  helpers do
    def logger
      LOGGER
    end
  end

  before {logger.info( {PATH_INFO: request.env["PATH_INFO"], QUERY_STRING: request.env["QUERY_STRING"], REMOTE_HOST: request.env["REMOTE_HOST"], REQUEST_URI: request.env["REQUEST_URI"], HTTP_USER_AGENT: request.env["HTTP_USER_AGENT"], PARAMS: params })}

  after do
    logger.info("Status: #{response.status}")
    if response.status == 500
      logger.info "Error: #{request.env['sinatra.error'].inspect}\n==== backtrace  ====\nError: #{request.env['sinatra.error'].backtrace.join("\n")}\n==== /backtrace ===="
    end
    logger.info response.body
  end
end
