require 'rack'
require 'mail'

class SendMail
  options = { :address              => "smtp.gmail.com",
              :port                 => 587,
              :domain               => 'rationalizeit.us',
              :user_name            => 'support@rationalizeit.us',
              :password             => ENV['RATIONALIZEIT_LLC_SUPPORT_PASSWORD'],
              :authentication       => 'plain',
              :enable_starttls_auto => true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  def self.call(env)
    req = Rack::Request.new(env)
    params = Rack::Utils.parse_nested_query(req.env["rack.input"].read)
    send_mail(params)
    [200, {"Content-Type" => 'text/plain'}, ["OK"]]
  end

  def self.send_mail(params, subject='Message from the website')
    puts params
    mail_body = params['contact_message'] + "\nPhone Number: " + params["contact_number"] + "\n Name: " + params["contact_name"]
    mail = Mail.new do
      from params['contact_email']
      to 'messages@rationalizeit.us'
      subject subject
      body mail_body
    end
    mail.deliver!
  end

end


use Rack::Static,
  :urls => ["/images", "/js", "/css"],
  :root => "public"
map "/" do
  run lambda { |env|

    [
      200,
      {
        'Content-Type' => 'text/html',
        'Cache-Control' => 'public, max-age=86400'
      },

      File.open('public/index.html', File::RDONLY)
    ]
  }
end

map "/process" do
  run SendMail
end
