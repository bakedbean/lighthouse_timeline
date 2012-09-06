require 'lighthouse'
require_relative './config'

class MyLighthouse
    def self.config
      MyConfig.for("lighthouse")
    end

    attr_accessor :state, :tagged

    def initialize(state,tagged)
      self.state = state
      self.tagged = tagged
      Lighthouse.account = self.class.config.account
      Lighthouse.authenticate(*self.class.config.credentials)
    end

    def marketing_tickets
        Lighthouse::Ticket.find(:all, :params => { :project_id => 41389, :q => "state:#{state} tagged:#{tagged}" }, :limit => 100)
    end

    def sort_tickets_by_created
      marketing_tickets.sort { |a,b| a.created_at <=> b.created_at }
    end

    def tickets_created_at_format
      sort_tickets_by_created.map do |ticket|
        ticket.created_at = Date.parse(ticket.created_at).strftime('%Y,%m,%d')
        ticket
      end
    end

    def tickets_to_timeline
      date = Array.new
      tickets = tickets_created_at_format
      
      tickets.each do |t|
        hash = { :startDate => t.created_at, :headline => "<a href='#{t.url}' target='_blank'>#{t.title}</a> (#{t.number})", :text => t.latest_body, :asset => { :media => "<blockquote>Assigned: #{t.assigned_user_name}<br/>Created by: #{t.creator_name}<br/>State: #{t.state}</blockquote><a href='#' id='tracker' onclick='Javascript: tracker(#{t.number})'>Add to Tracker</a>", :credit => "", :caption => "" } }
        date << hash
      end

      main = { :timeline => { :headline => 'Lighthouse Tickets', :type => 'default', :text => 'Marketing tickets', :date => date }}
    end

    def get_ticket(id)
      Lighthouse::Ticket.find(:first, :params => { :project_id => 41389, :q => id })
    end 
end
