Redbubble Ruby Api
==================

Notes
-----

This API is read only at the moment. There is no facility for modifying
anything on the redbubble servers. Essentially it fetches the apropriate
pages from redbubble.com and scrapes them for the required information,
performing a few little tricks when it can (to reduce the need for extended
info fetching too early). ;-)

Because this API must fetch pages for certain info, you must be aware there
will be delays...

You can make the API fetch this info in advance by calling
extended_info_refresh upon insances of the User, Shirt or Artwork object.


Usage
-----

	require 'redbubble'
	rb = Redbubble.new('username')

	# Shirts is an array of Shirt
	Redbubble.shirts.each {
		|item|

		item.print
	}

	# Artworks is an array of Artwork
	Redbubble.artworks.each {
		|item|

		item.print
	}


API Functions
-------------

	Redbubble
		User
			extended_info_refresh

			username
			name
			img_small
			img_medium
			groups
			url

		Shirt
			title
			url
			img_small
			img_medium
			img_large
			nsfw?

			extended_info_refresh

			price
			forms
			tags
			buy_url

			colors
			colors_rgb

		Artwork
			title
			url
			img_small
			img_medium
			img_large
			nsfw?

			extended_info_refresh

			price
			forms
			tags
			buy_url
