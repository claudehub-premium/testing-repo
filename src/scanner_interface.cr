require "./vulnerability"

# Base interface that all vulnerability scanners must implement
abstract class ScannerInterface
  abstract def name : String
  abstract def description : String
  abstract def scan : Array(Vulnerability)

  # Optional: Perform any initialization before scanning
  def initialize
  end

  # Helper method to determine if scanner should run
  def enabled? : Bool
    true
  end
end
