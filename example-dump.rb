# example-dump.rb
#
# - Gather everything from a user's profile, etc and then dump it
#   so it can be worked with later

require 'redbubble'
require 'yaml'

dump_file = "rb.tmp"
yaml_file = "rb.yaml"
username = "lmartinking"

puts "Redbubble Dump"
puts

rb = Redbubble.new(username)

puts "Gathering user info..."
rb.user.extended_info_refresh

puts "Gathering shirts..." 
shirts = rb.shirts
shirts.each {
	|shirt|
	shirt.extended_info_refresh
	putc "."
}
puts

puts "Gathering artworks..."
artworks = rb.artworks
artworks.each {
	|artwork|
	artwork.extended_info_refresh
	putc "."
}
puts

puts "Dumping to file..."
File.open(dump_file, 'w+') do |f|
	Marshal.dump(rb, f)
end

puts "Dumping YAML to file..."
File.open(yaml_file, 'w+') do |f|
	YAML.dump(rb, f)
end

puts "Done!"
