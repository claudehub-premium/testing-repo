require "./src/scanner_engine"
require "./src/scanners/port_scanner"
require "./src/scanners/file_permission_scanner"
require "./src/scanners/config_scanner"
require "./src/network_discovery"
require "./src/wordlist_manager"

# Vulnerability Assessment Tool
# A basic, extensible framework for scanning systems for security vulnerabilities

puts "╔═══════════════════════════════════════════════════════════╗"
puts "║     Vulnerability Assessment Tool v1.0                    ║"
puts "║     Basic Security Scanner Framework                      ║"
puts "╚═══════════════════════════════════════════════════════════╝"
puts ""

# Parse command line arguments
discover_mode = false
wordlist_mode = false
wordlist_path : String? = nil
target = "localhost"

# Check for flags
i = 0
while i < ARGV.size
  arg = ARGV[i]
  if arg == "--discover" || arg == "-d"
    discover_mode = true
  elsif arg == "--wordlist" || arg == "-w"
    wordlist_mode = true
    # Check if next argument is a path (not a flag)
    if i + 1 < ARGV.size && !ARGV[i + 1].starts_with?("-")
      wordlist_path = ARGV[i + 1]
      i += 1
    end
  elsif !arg.starts_with?("-")
    target = arg
  end
  i += 1
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
end

# Handle wordlist selection
weak_passwords = ConfigScanner::DEFAULT_WEAK_PASSWORDS

if wordlist_mode
  # If a path was provided, use it directly; otherwise, let user select
  if wordlist_path.nil?
    selected_wordlist = WordlistManager.select_wordlist
    if selected_wordlist.nil?
      puts "Using default wordlist"
    else
      weak_passwords = WordlistManager.load_wordlist(selected_wordlist)
      puts "✓ Loaded #{weak_passwords.size} passwords from wordlist"
      puts ""
    end
  else
    weak_passwords = WordlistManager.load_wordlist(wordlist_path)
    puts "✓ Loaded #{weak_passwords.size} passwords from #{wordlist_path}"
    puts ""
  end
end

# Validate target
if target.empty?
  puts "Error: Target cannot be empty"
  puts ""
  puts "Usage: crystal run vuln_scanner.cr [OPTIONS] [target]"
  puts "Options:"
  puts "  -d, --discover              Discover devices on local network and select target"
  puts "  -w, --wordlist [PATH]       Use wordlist for password checking (interactive or specify path)"
  puts ""
  puts "Examples:"
  puts "  crystal run vuln_scanner.cr --discover"
  puts "  crystal run vuln_scanner.cr --wordlist 192.168.1.100"
  puts "  crystal run vuln_scanner.cr -w wordlists/top1000.txt 192.168.1.100"
  puts "  crystal run vuln_scanner.cr 192.168.1.100"
  exit 1
end

# Initialize the scanner engine
engine = ScannerEngine.new

# Register all scanners
engine.register_scanner(PortScanner.new)
engine.register_scanner(FilePermissionScanner.new)
engine.register_scanner(ConfigScanner.new(weak_passwords))

# Run the scan
engine.run_scan(target)

puts ""
puts "Scan completed. Add more scanners by creating new classes that inherit from ScannerInterface."
puts "Place them in src/scanners/ and register them in vuln_scanner.cr"
