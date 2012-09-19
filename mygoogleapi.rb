require 'net/https'

class MyGoogleAPI

  def self.config
    MyConfig.for("google") 
  end

  attr_accessor :ticket, :headers, :tracker_spreadsheet_key

  def initialize(ticket)
    self.headers = nil
    self.ticket = ticket
    self.tracker_spreadsheet_key = "0AvQ4HHVmrGwodFJlNVctVHNVTHBJUVJkVHlrWDZRa1E"
  end

  def authenticate
    cl_string = ''
    http = Net::HTTP.new('www.google.com', 443)
    http.use_ssl = true

    path = '/accounts/ClientLogin'

    self.headers = \
      { 'Content-Type' => 'application/x-www-form-urlencoded' }

    creds = \
      "accountType=#{self.class.config.account}&Email=#{self.class.config.email}" \
      "&Passwd=#{self.class.config.password}" \
      "&service=#{self.class.config.service}"

    http.post(path, creds, headers) do |str|
      cl_string = str[/Auth=(.*)/, 1]
    end

    self.headers["Authorization"] = "GoogleLogin auth=#{cl_string}"
  end

  def get_feed(uri)
    uri = URI.parse(uri)
    Net::HTTP.start(uri.host, uri.port) do |http|
      return http.get(uri.path, headers)
    end
  end

  def post(uri, data)
    self.headers["Content-Type"] = "application/atom+xml"
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    return http.post(uri.path, data, self.headers)
  end

  def get_worksheets 
    worksheets = []
    worksheet_feed_uri = "http://spreadsheets.google.com/feeds/worksheets/#{self.tracker_spreadsheet_key}/private/full"
    worksheet_response = get_feed(worksheet_feed_uri)
    worksheet_data = XmlSimple.xml_in(worksheet_response.body, 'KeyAttr' => 'name')

    worksheet_data["entry"].each do |sheet|
      worksheets << sheet["link"][0]["href"]
    end

    return worksheets
  end
  
  def fix_sheet_urls 
    sheets = get_worksheets
    fixed_sheets = []

    sheets.each do |sheet|
      fixed_sheets << sheet.gsub(/https/, "http")
    end

    return fixed_sheets
  end

  def check_for_existing_row
    sheets = fix_sheet_urls

    sheets.each do |sheet|
      response = get_feed(sheet)
      listfeed_doc = XmlSimple.xml_in(response.body, 'KeyAttr' => 'name')

      if !check_sheet_for_dupe(listfeed_doc)
        return listfeed_doc["title"][0]["content"]
      else
        return "true"
      end
    end
  end
  
  def check_sheet_for_dupe(sheet)
    found = false

    sheet["entry"].each do |t|
      if self.ticket.number.to_s == t["number"][0]
        found = true
        break
      end
    end

    found
  end

  def update_worksheet
    post_url = \
      "http://spreadsheets.google.com/feeds/list/0AvQ4HHVmrGwodFJlNVctVHNVTHBJUVJkVHlrWDZRa1E/od7/private/full"

    new_row = \
      "<atom:entry xmlns:atom='http://www.w3.org/2005/Atom'>" <<
      "<gsx:priority xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "</gsx:priority>" <<
      "<gsx:number xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "=hyperlink(\"#{self.ticket.url}\";\"#{self.ticket.number}\")</gsx:number>" <<
      "<gsx:title xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "#{CGI::escapeHTML(self.ticket.title)}</gsx:title>" <<
      "<gsx:assigned xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "#{self.ticket.assigned_user_name}</gsx:assigned>" <<
      "<gsx:created xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "#{Date.parse(self.ticket.created_at).strftime('%m/%d/%y')}</gsx:created>" <<
      "<gsx:tags xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "#{self.ticket.tag}</gsx:tags>" <<
      "<gsx:status xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>" <<
      "#{self.ticket.state}</gsx:status>" <<
      "</atom:entry>"

    post_response = post(post_url, new_row)
  end
end
