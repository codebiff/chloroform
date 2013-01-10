require "spec_helper"

describe AdminMailer do
  describe "registered" do
    let(:mail) { AdminMailer.registered }

    it "renders the headers" do
      mail.subject.should eq("Registered")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
