require "../scanner_interface"
require "socket"

# Scans for insecure file permissions
class FilePermissionScanner < ScannerInterface
  SENSITIVE_FILES = [
    "/etc/shadow",
    "/etc/passwd",
    "~/.ssh/id_rsa",
    "~/.ssh/id_ed25519",
    ".env",
    "config.yml",
    "database.yml"
  ]

  # Directories to exclude from scanning for performance
  EXCLUDED_DIRS = [
    ".git",
    "node_modules",
    ".venv",
    "venv",
    "__pycache__",
    ".cache",
    "dist",
    "build",
    "target",
    ".npm",
    ".yarn",
    "vendor",
    ".bundle",
    "bower_components",
    ".next",
    ".nuxt"
  ]

  def name : String
    "File Permission Scanner"
  end

  def description : String
    "Checks for overly permissive file permissions on sensitive files"
  end

  def scan(target : String) : Array(Vulnerability)
    vulnerabilities = [] of Vulnerability

    # Only scan if target is localhost or local IP
    # File permission scanning only works on the local filesystem
    if is_local_target?(target)
      # Check current directory for sensitive files
      check_local_files(vulnerabilities)

      # Check for world-writable files in current directory
      check_world_writable(vulnerabilities)
    end

    vulnerabilities
  end

  private def is_local_target?(target : String) : Bool
    # Check if target is localhost, 127.0.0.1, or empty
    return true if target.empty?
    return true if target == "localhost"
    return true if target.starts_with?("127.")
    return true if target == "::1"

    # Check if target matches local IP
    begin
      socket = TCPSocket.new("8.8.8.8", 53)
      local_ip = socket.local_address.address
      socket.close
      return true if target == local_ip
    rescue
      # If we can't determine local IP, assume it might be local
      return true
    end

    false
  end

  private def check_local_files(vulnerabilities : Array(Vulnerability))
    [".env", "config.yml", "database.yml", "secrets.yml"].each do |filename|
      next unless File.exists?(filename)

      info = File.info(filename)
      permissions = info.permissions.value

      # Check if file is readable by others (permissions & 0o004)
      if (permissions & 0o004) != 0
        vulnerabilities << Vulnerability.new(
          title: "Sensitive File Readable by Others",
          description: "The file #{filename} contains potentially sensitive information and is readable by all users",
          severity: Vulnerability::Severity::HIGH,
          location: File.expand_path(filename),
          recommendation: "Run: chmod 600 #{filename}",
          metadata: {"permissions" => permissions.to_s(8), "file" => filename}
        )
      end

      # Check if file is writable by others (permissions & 0o002)
      if (permissions & 0o002) != 0
        vulnerabilities << Vulnerability.new(
          title: "Sensitive File Writable by Others",
          description: "The file #{filename} is writable by all users, allowing potential tampering",
          severity: Vulnerability::Severity::CRITICAL,
          location: File.expand_path(filename),
          recommendation: "Run: chmod 600 #{filename}",
          metadata: {"permissions" => permissions.to_s(8), "file" => filename}
        )
      end
    end
  end

  private def check_world_writable(vulnerabilities : Array(Vulnerability))
    Dir.glob("**/*").each do |file|
      # Skip excluded directories for performance
      next if EXCLUDED_DIRS.any? { |dir| file.includes?("/#{dir}/") || file.starts_with?("#{dir}/") }
      next unless File.file?(file)
      next if file.starts_with?(".")

      begin
        info = File.info(file)
        permissions = info.permissions.value

        # Check if world-writable
        if (permissions & 0o002) != 0
          vulnerabilities << Vulnerability.new(
            title: "World-Writable File",
            description: "File is writable by any user on the system",
            severity: Vulnerability::Severity::MEDIUM,
            location: File.expand_path(file),
            recommendation: "Remove write permissions for others: chmod o-w #{file}",
            metadata: {"permissions" => permissions.to_s(8)}
          )
        end
      rescue
        # Skip files we can't read
      end
    end
  end
end
