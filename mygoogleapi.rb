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
    self.headers = \
      { 'Content-Type' => 'application/x-www-form-urlencoded' }

    self.headers["Authorization"] = "GoogleLogin auth=DQAAANIBAABv9swXUUYlYK1eAHFhMKjuJEk18NzMVSdiZalGPgtyT0eP__AUMJ1YR4gmm4DvSGf8MtQ18BIAU85EVT_d4SAHUh7dynpbRe0qK4mtsnpY03cFuz-c-ZaTe9JXs0B3zj9kmVEypYoYbAwtLGFglVUx4qbPsiJag8T5yn57o2cEbwPcviPxI6k1UJN1nftCWhkrn3OEOqPfntGfUXSQrU9QRmo44KwgO2w6aOMZDp337dbKD9f31yc0wrFAXKKjM2MNhaNmpGemmqfUsiVtXXEspNW7JwoYtjrM6VU_HLTgTqFxwMmE0SZyA6dD4CPy1mYLL-r11Aoa0iHraK2bm9Uu41BG0MDxaNbdWbrhPJSihxsHBikF0yI9Q9FtIX0o9dszHicY7Y9Y4qAfwcgnsB1B0aLeO6ymxYMRkvbnqnaf5c0CmMX2TE3GRVjNSMz-mF3N4kaeqZHOCUTgvBl5qwKm_MHxXEVpdls6BTtI3JJi_7b6UQsxxlO-K-1wyobMqy00qrNG1FDonM8KiDwvAErcyNNRAIvzdEXYWkKrWRJpdfF7taoZZWWxjrWf8AfeWFOUJiDq5fytu0Xw2R3Xq3JYSPfxZRr61XShVlpB1sGuUhi4wAJxxaFC_49492DU2Dc"
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
    found = false

    sheets.each do |sheet|
      response = get_feed(sheet)
      listfeed_doc = XmlSimple.xml_in(response.body, 'KeyAttr' => 'name')

      listfeed_doc["entry"].each do |t|
        if self.ticket.number.to_s == t["number"][0]
          found = true
          break
        end
      end

      if found
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
      "#{self.ticket.title}</gsx:title>" <<
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
