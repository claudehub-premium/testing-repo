require "./scanner_interface"
require "./vulnerability"
require "./report"

# Core scanning engine that orchestrates vulnerability scans
class ScannerEngine
  @scanners : Array(ScannerInterface)
  @vulnerabilities : Array(Vulnerability)

  def initialize
    @scanners = [] of ScannerInterface
    @vulnerabilities = [] of Vulnerability
  end

  # Register a scanner with the engine
  def register_scanner(scanner : ScannerInterface)
    @scanners << scanner
  end

  # Run all registered scanners
  def run_scan(target : String = "localhost")
    puts "=" * 60
    puts "Vulnerability Assessment Tool"
    puts "=" * 60
    puts "Target: #{target}"
    puts "Scanners loaded: #{@scanners.size}"
    puts "=" * 60
    puts

    @scanners.each do |scanner|
      next unless scanner.enabled?

      puts "Running scanner: #{scanner.name}"
      puts "  Description: #{scanner.description}"

      begin
        results = scanner.scan
        @vulnerabilities.concat(results)
        puts "  Found: #{results.size} vulnerabilities"
      rescue ex
        puts "  Error: #{ex.message}"
      end
      puts
    end

    # Generate report
    generate_report
  end

  private def generate_report
    report = Report.new(@vulnerabilities)
    report.generate
  end
end
