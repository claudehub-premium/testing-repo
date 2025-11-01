# Crystal Web Server 💎

A fully self-hosted web server built in Crystal that can serve static files with zero external dependencies.

## Features

- 🚀 **Fast and Lightweight**: Built with Crystal for maximum performance
- 📁 **Static File Serving**: Serves HTML, CSS, JavaScript, images, and more
- 🔒 **Security**: Built-in directory traversal protection
- 📝 **Request Logging**: Automatic logging of all requests with timestamps
- 🎨 **Custom 404 Pages**: User-friendly error pages
- 🔧 **Configurable**: Customize host and port via command-line arguments
- 💎 **Pure Crystal**: No external dependencies required

## Prerequisites

- [Crystal](https://crystal-lang.org/install/) installed on your system (version 1.0.0 or higher)

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd testing-repo
```

2. No dependencies to install - the server uses only Crystal's standard library!

## Usage

### Quick Start

Run the server with default settings (localhost:8080):

```bash
crystal run server.cr
```

The server will start and serve files from the `public/` directory.

### Custom Port

Run on a different port:

```bash
crystal run server.cr -- 3000
```

### Custom Host and Port

Run on a specific host and port:

```bash
crystal run server.cr -- 8080 0.0.0.0
```

### Compile and Run

For better performance, compile the server first:

```bash
crystal build server.cr --release
./server
```

Or with custom settings:

```bash
./server 3000 0.0.0.0
```

## Project Structure

```
.
├── server.cr           # Main web server implementation
├── public/             # Static files directory
│   └── index.html      # Default index page
├── shard.yml           # Crystal project configuration
└── README.md           # This file
```

## How It Works

1. **File Serving**: The server looks for files in the `public/` directory
2. **Default Route**: Accessing `/` automatically serves `public/index.html`
3. **MIME Types**: Automatically detects and sets correct content types
4. **Security**: Prevents directory traversal attacks
5. **Logging**: All requests are logged with timestamp, method, path, and status code

## Adding Your Own Content

Simply place your files in the `public/` directory:

```bash
# Add a new HTML page
echo "<h1>About Page</h1>" > public/about.html

# Add CSS
mkdir public/css
echo "body { background: blue; }" > public/css/style.css

# Add JavaScript
mkdir public/js
echo "console.log('Hello!');" > public/js/app.js
```

Then access them at:
- `http://localhost:8080/about.html`
- `http://localhost:8080/css/style.css`
- `http://localhost:8080/js/app.js`

## Supported File Types

The server automatically sets the correct `Content-Type` header for:

- HTML (`.html`, `.htm`)
- CSS (`.css`)
- JavaScript (`.js`)
- JSON (`.json`)
- Images (`.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`)
- Text (`.txt`)
- XML (`.xml`)
- PDF (`.pdf`)
- Other files (served as `application/octet-stream`)

## Example Output

```
Starting web server on http://0.0.0.0:8080
Serving files from: ./public
Press Ctrl+C to stop the server
[2025-11-01 10:30:15] GET / - 200
[2025-11-01 10:30:16] GET /css/style.css - 200
[2025-11-01 10:30:17] GET /notfound.html - 404
```

## Development

The server is implemented as a single `SimpleWebServer` class with the following features:

- **Request Handling**: Parses HTTP requests and routes to appropriate handlers
- **File System Integration**: Reads and serves files from the file system
- **Content Type Detection**: Automatically determines MIME types
- **Error Handling**: Graceful error handling with custom error pages
- **Security**: Path validation to prevent directory traversal

## Technical Details

- **Language**: Crystal
- **HTTP Server**: Uses Crystal's built-in `HTTP::Server` from the standard library
- **Default Host**: `0.0.0.0` (accepts connections from any network interface)
- **Default Port**: `8080`
- **Public Directory**: `./public`

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License - feel free to use this project for any purpose.

## Credits

Built with Crystal 💎 - A language with Ruby-like syntax and C-like performance.
