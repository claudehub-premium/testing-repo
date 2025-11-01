require "http/server"
require "socket"

# Simple HTTP web server that serves static files
class SimpleWebServer
  DEFAULT_PORT = 8080
  DEFAULT_HOST = "0.0.0.0"
  PUBLIC_DIR = "./public"

  def initialize(@port : Int32 = DEFAULT_PORT, @host : String = DEFAULT_HOST)
    @server = HTTP::Server.new do |context|
      handle_request(context)
    end
  end

  def start
    ensure_public_directory

    puts "Starting web server on http://#{@host}:#{@port}"
    puts "Serving files from: #{PUBLIC_DIR}"
    puts "Press Ctrl+C to stop the server"

    @server.bind_tcp(@host, @port)
    @server.listen
  end

  private def ensure_public_directory
    Dir.mkdir_p(PUBLIC_DIR) unless Dir.exists?(PUBLIC_DIR)
  end

  private def handle_request(context)
    path = context.request.path

    # Default to index.html for root path
    path = "/index.html" if path == "/"

    # Construct the file path
    file_path = File.join(PUBLIC_DIR, path)

    # Security: Prevent directory traversal
    unless file_path.starts_with?(File.expand_path(PUBLIC_DIR))
      context.response.status = HTTP::Status::FORBIDDEN
      context.response.content_type = "text/plain"
      context.response.print "403 Forbidden"
      log_request(context, 403)
      return
    end

    # Serve the file if it exists
    if File.file?(file_path)
      serve_file(context, file_path)
    else
      context.response.status = HTTP::Status::NOT_FOUND
      context.response.content_type = "text/html"
      context.response.print generate_404_page(path)
      log_request(context, 404)
    end
  end

  private def serve_file(context, file_path : String)
    content_type = get_content_type(file_path)

    begin
      context.response.content_type = content_type
      context.response.status = HTTP::Status::OK

      File.open(file_path, "r") do |file|
        IO.copy(file, context.response)
      end

      log_request(context, 200)
    rescue ex
      context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
      context.response.content_type = "text/plain"
      context.response.print "500 Internal Server Error: #{ex.message}"
      log_request(context, 500)
    end
  end

  private def get_content_type(file_path : String) : String
    case File.extname(file_path).downcase
    when ".html", ".htm"
      "text/html"
    when ".css"
      "text/css"
    when ".js"
      "application/javascript"
    when ".json"
      "application/json"
    when ".png"
      "image/png"
    when ".jpg", ".jpeg"
      "image/jpeg"
    when ".gif"
      "image/gif"
    when ".svg"
      "image/svg+xml"
    when ".txt"
      "text/plain"
    when ".xml"
      "application/xml"
    when ".pdf"
      "application/pdf"
    else
      "application/octet-stream"
    end
  end

  private def generate_404_page(path : String) : String
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>404 Not Found</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          max-width: 600px;
          margin: 100px auto;
          text-align: center;
        }
        h1 { color: #e74c3c; }
      </style>
    </head>
    <body>
      <h1>404 - Not Found</h1>
      <p>The requested file <strong>#{path}</strong> was not found on this server.</p>
    </body>
    </html>
    HTML
  end

  private def log_request(context, status : Int32)
    method = context.request.method
    path = context.request.path
    timestamp = Time.local.to_s("%Y-%m-%d %H:%M:%S")

    puts "[#{timestamp}] #{method} #{path} - #{status}"
  end
end

# Parse command line arguments
port = ARGV.size > 0 ? ARGV[0].to_i : SimpleWebServer::DEFAULT_PORT
host = ARGV.size > 1 ? ARGV[1] : SimpleWebServer::DEFAULT_HOST

# Start the server
server = SimpleWebServer.new(port, host)
server.start
