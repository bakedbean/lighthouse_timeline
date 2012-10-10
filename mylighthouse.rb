require 'lighthouse'
require_relative './config'

class MyLighthouse
    def self.config
      MyConfig.for("lighthouse")
    end

    attr_accessor :state, :tagged, :responsible

    def initialize(state,tagged,responsible)
      self.state = state
      self.tagged = tagged
      self.responsible = responsible
      Lighthouse.account = self.class.config.account
      Lighthouse.authenticate(*self.class.config.credentials)
    end

    def marketing_tickets
      q = ""
      unless state.nil?
        q << "state:#{state}"
      end

      unless tagged.nil?
        q << " tagged:#{tagged}"
      end

      unless responsible.nil?
        q << " responsible:'#{responsible}'"
      end

      Lighthouse::Ticket.find(:all, :params => { :project_id => 41389, :q => "#{q}" }, :limit => 100)
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
        if t.respond_to?(:assigned_user_name)
          hash = { :startDate => t.created_at, :headline => "<a href='#{t.url}' target='_blank'>#{t.title}</a> (#{t.number})", :text => t.latest_body, :asset => { :media => "<blockquote>Assigned: #{t.assigned_user_name}<br/>Created by: #{t.creator_name}<br/>State: #{t.state}</blockquote><a href='#' id='tracker' onclick='Javascript: tracker(#{t.number})'>Add to Tracker</a>", :credit => "", :caption => "" } }
        else
          hash = { :startDate => t.created_at, :headline => "<a href='#{t.url}' target='_blank'>#{t.title}</a> (#{t.number})", :text => t.latest_body, :asset => { :media => "<blockquote>Assigned: <br/>Created by: #{t.creator_name}<br/>State: #{t.state}</blockquote><a href='#' id='tracker' onclick='Javascript: tracker(#{t.number})'>Add to Tracker</a>", :credit => "", :caption => "" } }
        end
        date << hash
      end

      main = { :timeline => { :headline => 'Lighthouse Tickets', :type => 'default', :text => 'Marketing tickets', :date => date }}
    end

    def get_ticket(id)
      Lighthouse::Ticket.find(:first, :params => { :project_id => 41389, :q => id })
    end 
end
