require "../scanner_interface"
require "../target_utils"
require "socket"

# Scans for insecure configurations and exposed secrets
class ConfigScanner < ScannerInterface
  PATTERNS = {
    "password" => /password\s*[=:]\s*["']?(\w+)["']?/i,
    "api_key" => /api[_-]?key\s*[=:]\s*["']?([a-zA-Z0-9_\-]+)["']?/i,
    "secret" => /secret\s*[=:]\s*["']?(\w+)["']?/i,
    "token" => /token\s*[=:]\s*["']?([a-zA-Z0-9_\-]+)["']?/i,
    "aws_access" => /(?:aws_access_key_id|aws_secret_access_key)\s*[=:]\s*["']?([A-Z0-9]+)["']?/i
  }

  DEFAULT_WEAK_PASSWORDS = ["password", "123456", "admin", "root", "test", "default"]

  property weak_passwords : Array(String)

  def initialize(@weak_passwords : Array(String) = DEFAULT_WEAK_PASSWORDS)
  end

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
    "Configuration Scanner"
  end

  def description : String
    "Scans configuration files for exposed secrets and weak passwords"
  end

  def scan(target : String) : Array(Vulnerability)
    vulnerabilities = [] of Vulnerability
    scanned_files = Set(String).new

    # Only scan if target is localhost or local IP
    # Config file scanning only works on the local filesystem
    if TargetUtils.is_local_target?(target)
      # Scan common config file types and .env files in a single pass
      # Using brace expansion to include hidden .env files
      patterns = ["**/*.{yml,yaml,env,conf,config,json,ini,xml}", "**/.env*"]

      patterns.each do |pattern|
        Dir.glob(pattern).each do |file|
          # Skip if already scanned (avoid duplicates)
          next if scanned_files.includes?(file)

          # Skip excluded directories for performance
          next if EXCLUDED_DIRS.any? { |dir| file.includes?("/#{dir}/") || file.starts_with?("#{dir}/") }

          scanned_files.add(file)
          scan_file(file, vulnerabilities)
        end
      end
    end

    vulnerabilities
  end

  private def scan_file(filepath : String, vulnerabilities : Array(Vulnerability))
    return unless File.file?(filepath)

    begin
      line_number = 0

      # Stream file line-by-line instead of loading entirely into memory
      File.each_line(filepath) do |line|
        line_number += 1

        # Early exit after finding first match to avoid redundant pattern checks
        found_match = false

        PATTERNS.each do |type, pattern|
          break if found_match  # Skip remaining patterns once we've found a match

          if match = pattern.match(line)
            found_match = true
            # Extract the value (usually in capture group 1)
            value = match[1]?

            # Check for weak passwords
            if type == "password" && value && @weak_passwords.includes?(value.downcase)
              vulnerabilities << Vulnerability.new(
                title: "Weak Password in Configuration",
                description: "A weak password '#{value}' was found in a configuration file",
                severity: Vulnerability::Severity::CRITICAL,
                location: "#{filepath}:#{line_number}",
                recommendation: "Use a strong password with at least 12 characters, including uppercase, lowercase, numbers, and symbols",
                metadata: {"type" => type, "line" => line_number.to_s}
              )
            else
              # Generic hardcoded credential
              vulnerabilities << Vulnerability.new(
                title: "Hardcoded Credential Detected",
                description: "A #{type.gsub('_', ' ')} is hardcoded in the configuration file",
                severity: Vulnerability::Severity::HIGH,
                location: "#{filepath}:#{line_number}",
                recommendation: "Use environment variables or a secure secret management system instead of hardcoding credentials",
                metadata: {"type" => type, "line" => line_number.to_s}
              )
            end
          end
        end
      end
    rescue
      # Skip files we can't read
    end
  end
end
