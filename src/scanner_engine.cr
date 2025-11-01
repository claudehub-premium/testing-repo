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

  # Run all registered scanners concurrently
  def run_scan(target : String = "localhost")
    puts "=" * 60
    puts "Vulnerability Assessment Tool"
    puts "=" * 60
    puts "Target: #{target}"
    puts "Scanners loaded: #{@scanners.size}"
    puts "⚡ Running scanners in parallel for faster results"
    puts "=" * 60
    puts

    # Channel to collect results from each scanner
    results_channel = Channel({String, Array(Vulnerability)?}).new(@scanners.size)
    mutex = Mutex.new

    # Spawn a fiber for each enabled scanner
    enabled_scanners = @scanners.select(&.enabled?)
    enabled_scanners.each do |scanner|
      spawn do
        mutex.synchronize do
          puts "▶ Starting scanner: #{scanner.name}"
          puts "  Description: #{scanner.description}"
        end

        begin
          results = scanner.scan(target)
          results_channel.send({scanner.name, results})

          mutex.synchronize do
            puts "✓ Completed: #{scanner.name} - Found #{results.size} vulnerabilities"
          end
        rescue ex
          results_channel.send({scanner.name, nil})

          mutex.synchronize do
            puts "✗ Error in #{scanner.name}: #{ex.message}"
          end
        end
      end
    end

    # Collect results from all scanners
    enabled_scanners.size.times do
      name, results = results_channel.receive
      @vulnerabilities.concat(results) if results
    end

    puts
    puts "=" * 60

    # Generate report
    generate_report
  end

  private def generate_report
    report = Report.new(@vulnerabilities)
    report.generate
  end
end
