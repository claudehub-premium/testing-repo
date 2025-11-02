require "socket"

# Utility module for target-related operations
module TargetUtils
  # Check if the target is a local address (localhost, 127.*, local IP, etc.)
  def self.is_local_target?(target : String) : Bool
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
end
