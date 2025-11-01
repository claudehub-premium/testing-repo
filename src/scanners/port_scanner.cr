require "../scanner_interface"
require "socket"

# Scans for open ports on the target system
class PortScanner < ScannerInterface
  COMMON_PORTS = [21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 5432, 6379, 8080, 27017]
  HIGH_RISK_PORTS = {
    21 => "FTP - Unencrypted file transfer",
    23 => "Telnet - Unencrypted remote access",
    3389 => "RDP - Remote Desktop (commonly targeted)",
    6379 => "Redis - Often misconfigured without authentication"
  }

  def name : String
    "Port Scanner"
  end

  def description : String
    "Scans for open ports that may expose services to attackers"
  end

  def scan : Array(Vulnerability)
    vulnerabilities = [] of Vulnerability

    COMMON_PORTS.each do |port|
      if port_open?("localhost", port)
        severity = HIGH_RISK_PORTS.has_key?(port) ?
          Vulnerability::Severity::HIGH :
          Vulnerability::Severity::MEDIUM

        description = HIGH_RISK_PORTS[port]? || "Port #{port} is open and accessible"

        vulnerabilities << Vulnerability.new(
          title: "Open Port Detected: #{port}",
          description: description,
          severity: severity,
          location: "localhost:#{port}",
          recommendation: "Review if this port needs to be exposed. Consider firewall rules or closing unused services.",
          metadata: {"port" => port.to_s, "service" => guess_service(port)}
        )
      end
    end

    vulnerabilities
  end

  private def port_open?(host : String, port : Int32, timeout : Float64 = 1.0) : Bool
    begin
      socket = TCPSocket.new(host, port, connect_timeout: timeout)
      socket.close
      true
    rescue
      false
    end
  end

  private def guess_service(port : Int32) : String
    case port
    when 21 then "FTP"
    when 22 then "SSH"
    when 23 then "Telnet"
    when 25 then "SMTP"
    when 53 then "DNS"
    when 80 then "HTTP"
    when 110 then "POP3"
    when 143 then "IMAP"
    when 443 then "HTTPS"
    when 445 then "SMB"
    when 3306 then "MySQL"
    when 3389 then "RDP"
    when 5432 then "PostgreSQL"
    when 6379 then "Redis"
    when 8080 then "HTTP-ALT"
    when 27017 then "MongoDB"
    else "Unknown"
    end
  end
end
