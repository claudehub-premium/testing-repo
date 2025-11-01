require "socket"

# Network Device Discovery Module
# Discovers devices on the local network for scanning
class NetworkDiscovery
  class Device
    property ip : String
    property hostname : String?
    property open_ports : Array(Int32)

    def initialize(@ip : String, @hostname : String? = nil, @open_ports : Array(Int32) = [] of Int32)
    end

    def to_s
      host_info = hostname ? "#{hostname} (#{ip})" : ip
      port_info = open_ports.empty? ? "no open ports detected" : "ports: #{open_ports.join(", ")}"
      "#{host_info} - #{port_info}"
    end
  end

  # Get the local IP address and subnet
  def self.get_local_subnet : String?
    begin
      # Try to connect to a public IP to determine local IP
      socket = TCPSocket.new("8.8.8.8", 53)
      local_ip = socket.local_address.address
      socket.close

      # Extract subnet (assuming /24)
      parts = local_ip.split(".")
      if parts.size == 4
        return "#{parts[0]}.#{parts[1]}.#{parts[2]}"
      end
    rescue
      # Fallback to common private subnets
      return nil
    end
    nil
  end

  # Check if a specific IP is reachable on common ports
  def self.check_host(ip : String, ports : Array(Int32) = [80, 443, 22, 445, 8080]) : Device?
    open_ports = [] of Int32

    ports.each do |port|
      begin
        socket = TCPSocket.new(ip, port, connect_timeout: 0.5)
        socket.close
        open_ports << port
      rescue
        # Port is closed or host unreachable
      end
    end

    # If at least one port is open, consider the device as alive
    if !open_ports.empty?
      hostname = resolve_hostname(ip)
      return Device.new(ip, hostname, open_ports)
    end

    nil
  end

  # Try to resolve hostname for an IP
  def self.resolve_hostname(ip : String) : String?
    begin
      # Use a simple system call to resolve hostname
      result = `host #{ip} 2>/dev/null`.strip
      if result.includes?("domain name pointer")
        parts = result.split("domain name pointer")
        if parts.size > 1
          return parts[1].strip.rstrip('.')
        end
      end
    rescue
      # Hostname resolution failed
    end
    nil
  end

  # Discover devices on the local network
  def self.discover_devices(subnet : String? = nil, range : Range(Int32, Int32) = 1..254) : Array(Device)
    puts "🔍 Scanning local network for devices..."
    puts ""

    # Get subnet if not provided
    subnet = get_local_subnet if subnet.nil?

    if subnet.nil?
      puts "❌ Could not determine local subnet automatically."
      puts "Please specify a target manually or check your network connection."
      return [] of Device
    end

    puts "📡 Subnet detected: #{subnet}.0/24"
    puts "⏳ This may take a few minutes... (scanning #{range.size} addresses)"
    puts ""

    devices = [] of Device
    scanned = 0
    total = range.size

    range.each do |i|
      ip = "#{subnet}.#{i}"

      # Show progress every 10 IPs
      scanned += 1
      if scanned % 10 == 0
        progress = (scanned.to_f / total * 100).round(1)
        print "\rProgress: #{progress}% (#{scanned}/#{total}) - Found: #{devices.size} devices"
      end

      device = check_host(ip)
      if device
        devices << device
        print "\r✓ Found device: #{device.ip.ljust(15)} "
        print "#{device.open_ports.map { |p| p.to_s }.join(", ").ljust(20)}"
        puts ""
      end
    end

    print "\r" + " " * 80 + "\r"  # Clear progress line
    puts ""
    puts "✅ Scan complete! Found #{devices.size} device(s)"
    puts ""

    devices
  end

  # Display devices and allow user to select one
  def self.select_device(devices : Array(Device)) : String?
    if devices.empty?
      puts "❌ No devices found on the network."
      puts "   You can still specify a target manually."
      return nil
    end

    puts "═" * 70
    puts "Available Devices:"
    puts "═" * 70

    devices.each_with_index do |device, idx|
      puts "  [#{idx + 1}] #{device}"
    end

    puts "  [0] Enter custom target"
    puts "  [q] Quit"
    puts "═" * 70
    puts ""

    loop do
      print "Select a device to scan (enter number): "
      input = gets

      return nil if input.nil?

      choice = input.strip.downcase

      if choice == "q" || choice == "quit"
        return nil
      elsif choice == "0"
        print "Enter target IP or hostname: "
        custom = gets
        return custom.strip unless custom.nil? || custom.strip.empty?
      else
        begin
          index = choice.to_i - 1
          if index >= 0 && index < devices.size
            return devices[index].ip
          else
            puts "⚠️  Invalid selection. Please choose a number between 0 and #{devices.size}."
          end
        rescue
          puts "⚠️  Invalid input. Please enter a number."
        end
      end
    end
  end
end
