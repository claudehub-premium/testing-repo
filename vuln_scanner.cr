require "./src/scanner_engine"
require "./src/scanners/port_scanner"
require "./src/scanners/file_permission_scanner"
require "./src/scanners/config_scanner"
require "./src/network_discovery"

# Vulnerability Assessment Tool
# A basic, extensible framework for scanning systems for security vulnerabilities

puts "╔═══════════════════════════════════════════════════════════╗"
puts "║     Vulnerability Assessment Tool v1.0                    ║"
puts "║     Basic Security Scanner Framework                      ║"
puts "╚═══════════════════════════════════════════════════════════╝"
puts ""

# Parse command line arguments
discover_mode = false
target = "localhost"

# Check for flags
ARGV.each do |arg|
  if arg == "--discover" || arg == "-d"
    discover_mode = true
  elsif !arg.starts_with?("-")
    target = arg
  end
end

# If discover mode is enabled, scan the network and let user select
if discover_mode
  devices = NetworkDiscovery.discover_devices
  selected_target = NetworkDiscovery.select_device(devices)

  if selected_target.nil? || selected_target.empty?
    puts "❌ No target selected. Exiting."
    exit 0
  end

  target = selected_target
  puts ""
  puts "🎯 Target selected: #{target}"
  puts ""
elsif ARGV.size > 0 && !ARGV[0].starts_with?("-")
  target = ARGV[0]
end

# Validate target
if target.empty?
  puts "Error: Target cannot be empty"
  puts ""
  puts "Usage: crystal run vuln_scanner.cr [OPTIONS] [target]"
  puts "Options:"
  puts "  -d, --discover    Discover devices on local network and select target"
  puts ""
  puts "Examples:"
  puts "  crystal run vuln_scanner.cr --discover"
  puts "  crystal run vuln_scanner.cr 192.168.1.100"
  exit 1
end

# Initialize the scanner engine
engine = ScannerEngine.new

# Register all scanners
engine.register_scanner(PortScanner.new)
engine.register_scanner(FilePermissionScanner.new)
engine.register_scanner(ConfigScanner.new)

# Run the scan
engine.run_scan(target)

puts ""
puts "Scan completed. Add more scanners by creating new classes that inherit from ScannerInterface."
puts "Place them in src/scanners/ and register them in vuln_scanner.cr"
