require "./spec_helper"

describe MartenSendgridEmailing::Backend do
  describe "#deliver" do
    it "delivers a simple email as expected" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [{"to" => [{"email" => "to@example.com"}]}],
            "headers"          => {} of String => String,
            "mail_settings"    => {"sandbox_mode" => {"enable" => false}},
            "content"          => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key")
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmail.new)
    end

    it "delivers a simple email as expected when sandbox mode is enabled" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [{"to" => [{"email" => "to@example.com"}]}],
            "headers"          => {} of String => String,
            "mail_settings"    => {"sandbox_mode" => {"enable" => true}},
            "content"          => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key", sandbox_mode: true)
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmail.new)
    end

    it "delivers a simple email with CC addresses as expected" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [
              {
                "to" => [{"email" => "to@example.com"}],
                "cc" => [{"email" => "cc1@example.com"}, {"email" => "cc2@example.com"}],
              },
            ],
            "headers"       => {} of String => String,
            "mail_settings" => {"sandbox_mode" => {"enable" => false}},
            "content"       => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key")
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmailWithCc.new)
    end

    it "delivers a simple email with BCC addresses as expected" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [
              {
                "to"  => [{"email" => "to@example.com"}],
                "bcc" => [{"email" => "bcc1@example.com"}, {"email" => "bcc2@example.com"}],
              },
            ],
            "headers"       => {} of String => String,
            "mail_settings" => {"sandbox_mode" => {"enable" => false}},
            "content"       => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key")
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmailWithBcc.new)
    end

    it "delivers a simple email with a reply-to address as expected" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [{"to" => [{"email" => "to@example.com"}]}],
            "headers"          => {} of String => String,
            "reply_to"         => {"email" => "replyto@example.com"},
            "mail_settings"    => {"sandbox_mode" => {"enable" => false}},
            "content"          => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key")
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmailWithReplyTo.new)
    end

    it "delivers a simple email with with custom headers as expected" do
      WebMock
        .stub(:post, "https://api.sendgrid.com/v3/mail/send")
        .with(
          body: {
            "subject"          => "Hello World!",
            "from"             => {"name" => "John Doe", "email" => "from@example.com"},
            "personalizations" => [{"to" => [{"email" => "to@example.com"}]}],
            "headers"          => {"Foo" => "bar"},
            "mail_settings"    => {"sandbox_mode" => {"enable" => false}},
            "content"          => [
              {"type" => "text/html", "value" => "HTML body"},
              {"type" => "text/plain", "value" => "Text body"},
            ],
          }.to_json,
          headers: {"Authorization" => "Bearer api-key", "Content-Type" => "application/json"}
        )
        .to_return(body: "")

      backend = MartenSendgridEmailing::Backend.new("api-key")
      backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmailWithHeaders.new({"Foo" => "bar"}))
    end

    it "raises as expected if the response is not a success" do
      WebMock.stub(:post, "https://api.sendgrid.com/v3/mail/send").to_return do
        HTTP::Client::Response.new(400, body: "This is bad!")
      end

      backend = MartenSendgridEmailing::Backend.new("api-key")

      expect_raises(MartenSendgridEmailing::Backend::UnexpectedResponseError, "This is bad!") do
        backend.deliver(MartenSendgridEmailing::BackendSpec::TestEmail.new)
      end
    end
  end
end

module MartenSendgridEmailing::BackendSpec
  class TestEmail < Marten::Email
    subject "Hello World!"
    to "to@example.com"

    def from
      Marten::Emailing::Address.new(address: "from@example.com", name: "John Doe")
    end

    def html_body
      "HTML body"
    end

    def text_body
      "Text body"
    end
  end

  class TestEmailWithCc < TestEmail
    cc ["cc1@example.com", "cc2@example.com"]
  end

  class TestEmailWithBcc < TestEmail
    bcc ["bcc1@example.com", "bcc2@example.com"]
  end

  class TestEmailWithReplyTo < TestEmail
    reply_to "replyto@example.com"
  end

  class TestEmailWithHeaders < TestEmail
    def initialize(@headers)
    end

    def headers
      @headers
    end
  end
end
