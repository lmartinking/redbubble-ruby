# example.rb - just a little example of the redbubble-ruby "api"

require 'redbubble'

rb = Redbubble.new('lmartinking')

shirts = rb.shirts

shirts.each {
	|shirt|
	
	shirt.print

	if shirt.nsfw?
		puts "NSFW!!!"
	else
		puts shirt.colors.to_s
		puts shirt.colors_rgb.to_s
	end

	puts "buy url: " + shirt.buy_url.to_s
	puts "price:   " + shirt.price.to_s
	puts "tags:    " + shirt.tags.to_s
	puts
}

exit
