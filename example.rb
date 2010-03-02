# example.rb - just a little example of the redbubble-ruby "api"

require 'redbubble'

rb = Redbubble.new('lmartinking')

rb.custom_fetch = proc {
	|url|
	puts "Opening... #{url}"
	open(url)
}


rb.user.extended_info_refresh

puts
puts "Username: " + rb.user.username
puts "Name:     " + rb.user.name
puts "ImgSml:   " + rb.user.img_small
puts "ImgMed:   " + rb.user.img_medium
puts "Groups:   " + rb.user.groups.to_s
puts "URL:      " + rb.user.url
puts


artworks = rb.artworks

artworks.each {
	|art|

	art.print
#	art.print_extra
	puts
}


shirts = rb.shirts

shirts.each {
	|shirt|

	shirt.print
#	shirt.print_extra


#	if shirt.nsfw?
#		puts "NSFW!!!"
#	else
#		puts shirt.colors.to_s
#		puts shirt.colors_rgb.to_s
#	end

	puts
}

exit
