begin
  require "json"
rescue LoadError
  puts "! error requiring json"
  puts "> Path is:"
  puts $:.map { |line| "  #{line}" }
  exit 1
end

puts { :hello => "world" }.to_json
