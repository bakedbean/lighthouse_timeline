require 'spec_helper'

describe MyLighthouse do

  describe "#marketing_tickets" do

    it "finds tickets" do
      Lighthouse::Ticket.should_receive(:find)
      MyLighthouse.new.marketing_tickets
    end
  end

  describe "#sort_tickets_by_created" do
    
    before do
      
      @obj = MyLighthouse.new

      @ticket_today = mock(:created_at => Time.now)
      @ticket_yesterday = mock(:created_at => Time.now - 1.day)
      @obj.stub(:marketing_tickets => [@ticket_yesterday, @ticket_today])
    end
    
    #subject { @obj.sort_tickets_by_created }

    it "sorts tickets by date created" do

      #subject.should == [@ticket_yesterday, @ticket_today]
      @obj.sort_tickets_by_created.should == [@ticket_yesterday, @ticket_today]
    end
  end

  describe "#get_tickets" do

    context 'with valid ticket #' do
      
      subject { MyLighthouse.new.get_ticket(1) }
      it 'returns not nil' do
        Lighthouse::Ticket.should_receive(:find)

        subject
      end
    end
  end
end
