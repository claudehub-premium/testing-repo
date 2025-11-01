require "./src/scanner_engine"
require "./src/scanners/port_scanner"
require "./src/scanners/file_permission_scanner"
require "./src/scanners/config_scanner"

# Vulnerability Assessment Tool
# A basic, extensible framework for scanning systems for security vulnerabilities

puts "╔═══════════════════════════════════════════════════════════╗"
puts "║     Vulnerability Assessment Tool v1.0                    ║"
puts "║     Basic Security Scanner Framework                      ║"
puts "╚═══════════════════════════════════════════════════════════╝"
puts ""

# Parse command line arguments
target = ARGV.size > 0 ? ARGV[0] : "localhost"

# Validate target
if target.empty?
  puts "Error: Target cannot be empty"
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
