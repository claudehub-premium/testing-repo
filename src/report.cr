require "./vulnerability"

# Generates vulnerability assessment reports
class Report
  @vulnerabilities : Array(Vulnerability)

  def initialize(@vulnerabilities : Array(Vulnerability))
  end

  def generate
    puts "=" * 60
    puts "VULNERABILITY ASSESSMENT REPORT"
    puts "=" * 60
    puts "Generated: #{Time.local}"
    puts "Total Vulnerabilities: #{@vulnerabilities.size}"
    puts

    # Group by severity
    by_severity = @vulnerabilities.group_by(&.severity)

    puts "Summary by Severity:"
    Vulnerability::Severity.each do |severity|
      count = by_severity[severity]?.try(&.size) || 0
      puts "  #{severity}: #{count}"
    end
    puts

    if @vulnerabilities.empty?
      puts "No vulnerabilities found!"
      puts "=" * 60
      return
    end

    # Display vulnerabilities by severity
    Vulnerability::Severity.each do |severity|
      vulns = by_severity[severity]?
      next unless vulns && !vulns.empty?

      puts "-" * 60
      puts "#{severity} SEVERITY VULNERABILITIES (#{vulns.size})"
      puts "-" * 60

      vulns.each_with_index do |vuln, index|
        puts "\n#{index + 1}. #{vuln.title}"
        puts "   Location: #{vuln.location}"
        puts "   Description: #{vuln.description}"
        puts "   Recommendation: #{vuln.recommendation}"

        unless vuln.metadata.empty?
          puts "   Additional Info:"
          vuln.metadata.each do |key, value|
            puts "     - #{key}: #{value}"
          end
        end
      end
      puts
    end

    puts "=" * 60
  end

  # Generate JSON report (for future expansion)
  def to_json
    {
      "generated_at" => Time.local.to_s,
      "total_vulnerabilities" => @vulnerabilities.size,
      "vulnerabilities" => @vulnerabilities.map do |v|
        {
          "title" => v.title,
          "description" => v.description,
          "severity" => v.severity.to_s,
          "location" => v.location,
          "recommendation" => v.recommendation,
          "metadata" => v.metadata
        }
      end
    }
  end
end
