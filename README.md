# Vulnerability Assessment Tool 🔒

A basic, extensible vulnerability assessment framework built in Crystal. Designed to be expanded with custom scanners for identifying security weaknesses in systems and applications.

## Features

- 🔌 **Plugin Architecture**: Easy-to-extend scanner interface for adding new vulnerability checks
- 🎯 **Multiple Scanner Types**: Includes port, file permission, and configuration scanners
- 📊 **Severity-Based Reporting**: Vulnerabilities categorized as LOW, MEDIUM, HIGH, or CRITICAL
- 🚀 **Fast and Lightweight**: Built with Crystal for maximum performance
- 📝 **Detailed Reports**: Clear descriptions and actionable recommendations
- 💎 **Pure Crystal**: No external dependencies required

## Prerequisites

- [Crystal](https://crystal-lang.org/install/) installed on your system (version 1.0.0 or higher)

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd testing-repo
```

2. No dependencies to install - uses only Crystal's standard library!

## Usage

### Quick Start

Run a basic vulnerability scan on localhost:

```bash
crystal run vuln_scanner.cr
```

### Scan a Specific Target

```bash
crystal run vuln_scanner.cr -- 192.168.1.100
```

### Compile for Production

For better performance, compile the scanner first:

```bash
crystal build vuln_scanner.cr --release -o vuln_scanner
./vuln_scanner
```

## Built-in Scanners

### 1. Port Scanner
Scans for open ports that may expose services to attackers.
- Checks common ports (21, 22, 23, 80, 443, 3306, etc.)
- Identifies high-risk services (FTP, Telnet, RDP, Redis)
- Provides service identification

### 2. File Permission Scanner
Checks for insecure file permissions on sensitive files.
- Detects world-readable sensitive files (.env, config files)
- Identifies world-writable files
- Recommends proper permission settings

### 3. Configuration Scanner
Scans configuration files for exposed secrets and weak passwords.
- Detects hardcoded credentials (passwords, API keys, tokens)
- Identifies weak passwords
- Scans YAML, JSON, ENV, and other config file formats

## Extending the Framework

### Creating a New Scanner

1. Create a new file in `src/scanners/`:

```crystal
require "../scanner_interface"

class MyCustomScanner < ScannerInterface
  def name : String
    "My Custom Scanner"
  end

  def description : String
    "Description of what this scanner does"
  end

  def scan : Array(Vulnerability)
    vulnerabilities = [] of Vulnerability

    # Your scanning logic here
    # Add vulnerabilities as you find them

    vulnerabilities << Vulnerability.new(
      title: "Vulnerability Title",
      description: "Detailed description",
      severity: Vulnerability::Severity::HIGH,
      location: "/path/to/issue",
      recommendation: "How to fix this",
      metadata: {"key" => "value"}
    )

    vulnerabilities
  end
end
```

2. Register your scanner in `vuln_scanner.cr`:

```crystal
require "./src/scanners/my_custom_scanner"

# In the main section:
engine.register_scanner(MyCustomScanner.new)
```

### Vulnerability Severity Levels

- **CRITICAL**: Immediate threat requiring urgent attention
- **HIGH**: Significant security risk that should be addressed soon
- **MEDIUM**: Moderate risk that should be reviewed
- **LOW**: Minor security concern

## Project Structure

```
.
├── vuln_scanner.cr              # Main entry point
├── src/
│   ├── vulnerability.cr         # Vulnerability data structure
│   ├── scanner_interface.cr     # Base interface for scanners
│   ├── scanner_engine.cr        # Core scanning engine
│   ├── report.cr                # Report generation
│   └── scanners/                # Individual scanner modules
│       ├── port_scanner.cr
│       ├── file_permission_scanner.cr
│       └── config_scanner.cr
├── shard.yml                    # Crystal project configuration
└── README.md                    # This file
```

## Example Output

```
╔═══════════════════════════════════════════════════════════╗
║     Vulnerability Assessment Tool v1.0                    ║
║     Basic Security Scanner Framework                      ║
╚═══════════════════════════════════════════════════════════╝

============================================================
Vulnerability Assessment Tool
============================================================
Target: localhost
Scanners loaded: 3
============================================================

Running scanner: Port Scanner
  Description: Scans for open ports that may expose services to attackers
  Found: 2 vulnerabilities

Running scanner: File Permission Scanner
  Description: Checks for overly permissive file permissions on sensitive files
  Found: 1 vulnerabilities

Running scanner: Configuration Scanner
  Description: Scans configuration files for exposed secrets and weak passwords
  Found: 0 vulnerabilities

============================================================
VULNERABILITY ASSESSMENT REPORT
============================================================
Generated: 2025-11-01 10:30:00
Total Vulnerabilities: 3

Summary by Severity:
  CRITICAL: 0
  HIGH: 2
  MEDIUM: 1
  LOW: 0

------------------------------------------------------------
HIGH SEVERITY VULNERABILITIES (2)
------------------------------------------------------------

1. Open Port Detected: 22
   Location: localhost:22
   Description: Port 22 is open and accessible
   Recommendation: Review if this port needs to be exposed. Consider firewall rules or closing unused services.
   Additional Info:
     - port: 22
     - service: SSH

2. Sensitive File Readable by Others
   Location: /home/user/.env
   Description: The file .env contains potentially sensitive information and is readable by all users
   Recommendation: Run: chmod 600 .env
   Additional Info:
     - permissions: 644
     - file: .env

------------------------------------------------------------
MEDIUM SEVERITY VULNERABILITIES (1)
------------------------------------------------------------

1. World-Writable File
   Location: /home/user/temp.txt
   Description: File is writable by any user on the system
   Recommendation: Remove write permissions for others: chmod o-w temp.txt
   Additional Info:
     - permissions: 666

============================================================
```

## Future Expansion Ideas

- **Web Application Scanners**: SQL injection, XSS, CSRF detection
- **Network Scanners**: SSL/TLS configuration, DNS issues
- **Docker/Container Scanners**: Image vulnerabilities, misconfigurations
- **Database Scanners**: Weak credentials, exposed databases
- **Compliance Checkers**: CIS benchmarks, OWASP Top 10
- **JSON/HTML Report Export**: Multiple output format support
- **Parallel Scanning**: Concurrent scanner execution
- **Custom Rules Engine**: User-defined vulnerability patterns

## Development

The framework is designed around three core concepts:

1. **Vulnerability**: Data structure representing a security issue
2. **ScannerInterface**: Abstract base class that all scanners implement
3. **ScannerEngine**: Orchestrates scanner execution and report generation

This separation allows for easy extension without modifying core code.

## Contributing

Feel free to submit issues and enhancement requests! When contributing new scanners:

1. Inherit from `ScannerInterface`
2. Implement required methods: `name`, `description`, `scan`
3. Return an array of `Vulnerability` objects
4. Add clear recommendations for remediation

## License

MIT License - feel free to use this project for any purpose.

## Security Note

This tool is designed for authorized security assessments only. Always ensure you have permission before scanning systems you don't own. Unauthorized scanning may be illegal in your jurisdiction.

## Credits

Built with Crystal 💎 - A language with Ruby-like syntax and C-like performance.
