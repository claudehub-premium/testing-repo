# Wordlist Manager
# Manages wordlist selection and loading for password checking
class WordlistManager
  DEFAULT_WORDLISTS = {
    "common"    => "wordlists/common.txt",
    "top100"    => "wordlists/top100.txt",
    "top1000"   => "wordlists/top1000.txt",
    "rockyou"   => "wordlists/rockyou.txt",
  }

  # Built-in minimal wordlist for when files aren't available
  BUILTIN_WEAK_PASSWORDS = [
    "password", "123456", "admin", "root", "test", "default",
    "12345678", "qwerty", "letmein", "welcome", "monkey",
    "1234567890", "abc123", "password123", "Password1",
    "admin123", "root123", "pass", "passwd", "changeme"
  ]

  def self.list_available_wordlists : Hash(String, String)
    available = {} of String => String

    DEFAULT_WORDLISTS.each do |name, path|
      if File.exists?(path)
        # Count lines in file
        count = 0
        File.each_line(path) { count += 1 }
        available[name] = "#{path} (#{count} entries)"
      end
    end

    # Always include built-in option
    available["builtin"] = "Built-in minimal wordlist (#{BUILTIN_WEAK_PASSWORDS.size} entries)"

    available
  end

  def self.load_wordlist(name_or_path : String) : Array(String)
    # Check if it's a built-in wordlist name
    if name_or_path == "builtin"
      return BUILTIN_WEAK_PASSWORDS
    end

    # Check if it's a predefined wordlist name
    if DEFAULT_WORDLISTS.has_key?(name_or_path)
      path = DEFAULT_WORDLISTS[name_or_path]
      return load_from_file(path) if File.exists?(path)
    end

    # Try loading as a file path
    if File.exists?(name_or_path)
      return load_from_file(name_or_path)
    end

    # Fallback to built-in
    puts "⚠️  Wordlist '#{name_or_path}' not found, using built-in minimal wordlist"
    BUILTIN_WEAK_PASSWORDS
  end

  def self.select_wordlist : String?
    available = list_available_wordlists

    if available.empty?
      puts "⚠️  No wordlists available, using built-in minimal wordlist"
      return "builtin"
    end

    puts "╔═══════════════════════════════════════════════════════════╗"
    puts "║                 Wordlist Selection                        ║"
    puts "╚═══════════════════════════════════════════════════════════╝"
    puts ""

    available.each_with_index do |(name, desc), idx|
      puts "  [#{idx + 1}] #{name.ljust(15)} - #{desc}"
    end
    puts "  [0] Specify custom wordlist path"
    puts "  [q] Skip wordlist selection (use default)"
    puts ""

    loop do
      print "Select a wordlist (enter number): "
      input = gets

      return nil if input.nil?

      choice = input.strip.downcase

      if choice == "q" || choice == "quit"
        return "builtin"
      elsif choice == "0"
        print "Enter wordlist file path: "
        custom = gets
        return custom.strip unless custom.nil? || custom.strip.empty?
      else
        begin
          index = choice.to_i - 1
          if index >= 0 && index < available.size
            return available.keys[index]
          else
            puts "⚠️  Invalid selection. Please choose a number between 0 and #{available.size}."
          end
        rescue
          puts "⚠️  Invalid input. Please enter a number."
        end
      end
    end
  end

  private def self.load_from_file(path : String) : Array(String)
    passwords = [] of String

    File.each_line(path) do |line|
      # Strip whitespace and skip empty lines and comments
      line = line.strip
      next if line.empty? || line.starts_with?("#")
      passwords << line
    end

    passwords
  end
end
