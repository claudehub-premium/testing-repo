require "../scanner_interface"

# Scans for insecure configurations and exposed secrets
class ConfigScanner < ScannerInterface
  PATTERNS = {
    "password" => /password\s*[=:]\s*["']?(\w+)["']?/i,
    "api_key" => /api[_-]?key\s*[=:]\s*["']?([a-zA-Z0-9_\-]+)["']?/i,
    "secret" => /secret\s*[=:]\s*["']?(\w+)["']?/i,
    "token" => /token\s*[=:]\s*["']?([a-zA-Z0-9_\-]+)["']?/i,
    "aws_access" => /(aws_access_key_id|aws_secret_access_key)\s*[=:]\s*["']?([A-Z0-9]+)["']?/i
  }

  WEAK_PASSWORDS = ["password", "123456", "admin", "root", "test", "default"]

  def name : String
    "Configuration Scanner"
  end

  def description : String
    "Scans configuration files for exposed secrets and weak passwords"
  end

  def scan : Array(Vulnerability)
    vulnerabilities = [] of Vulnerability

    # Scan common config file types
    Dir.glob("**/*.{yml,yaml,env,conf,config,json,ini,xml}").each do |file|
      next if file.includes?("node_modules") || file.includes?("vendor")

      scan_file(file, vulnerabilities)
    end

    # Also check for .env files specifically
    Dir.glob("**/.env*").each do |file|
      scan_file(file, vulnerabilities)
    end

    vulnerabilities
  end

  private def scan_file(filepath : String, vulnerabilities : Array(Vulnerability))
    return unless File.file?(filepath)

    begin
      content = File.read(filepath)
      line_number = 0

      content.each_line do |line|
        line_number += 1

        PATTERNS.each do |type, pattern|
          if match = pattern.match(line)
            # Extract the value (usually in capture group 1)
            value = match[1]?

            # Check for weak passwords
            if type == "password" && value && WEAK_PASSWORDS.includes?(value.downcase)
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
