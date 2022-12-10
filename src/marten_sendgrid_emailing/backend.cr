module MartenSendgridEmailing
  # A Sendgrid emailing backend.
  class Backend < Marten::Emailing::Backend::Base
    # Raised upon receiving an unsuccessful response from Sendgrid.
    class UnexpectedResponseError < Exception; end

    @headers : HTTP::Headers?

    def initialize(@api_key : String, @sandbox_mode = false)
    end

    def deliver(email : Marten::Emailing::Email) : Nil
      response = HTTP::Client.post(MAIL_SEND_URL, body: data_for_email(email).to_json, headers: headers)
      raise UnexpectedResponseError.new(response.body) unless response.success?
    end

    private CONTENT_TYPE_HTML = "text/html"
    private CONTENT_TYPE_TEXT = "text/plain"
    private MAIL_SEND_URL     = "https://api.sendgrid.com/v3/mail/send"

    private getter api_key
    private getter? sandbox_mode

    private def content(type, value)
      return if value.nil?

      {"type" => type, "value" => value}
    end

    private def data_for_email(email)
      personalizations = {
        "to"  => sendgrid_addresses(email.to),
        "cc"  => email.cc.try { |cc| cc.empty? ? nil : sendgrid_addresses(cc) },
        "bcc" => email.bcc.try { |bcc| bcc.empty? ? nil : sendgrid_addresses(bcc) },
      }.compact

      {
        "subject"          => email.subject,
        "from"             => sendgrid_address(email.from),
        "personalizations" => [personalizations],
        "headers"          => email.headers,
        "reply_to"         => email.reply_to.try { |reply_to| sendgrid_address(reply_to) },
        "mail_settings"    => {sandbox_mode: {enable: sandbox_mode?}},
        "content"          => [
          content(CONTENT_TYPE_HTML, email.html_body),
          content(CONTENT_TYPE_TEXT, email.text_body),
        ].compact,
      }.compact
    end

    private def headers
      @headers ||= HTTP::Headers{
        "Authorization" => "Bearer #{api_key}",
        "Content-Type"  => "application/json",
      }
    end

    private def sendgrid_address(address)
      {"name" => address.name, "email" => address.address}.compact
    end

    private def sendgrid_addresses(addresses)
      addresses.map { |address| sendgrid_address(address).compact }
    end
  end
end
