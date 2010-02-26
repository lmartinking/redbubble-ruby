#--
#   redbubble-ruby - a Redbubble.com API of sorts, implemented in Ruby	
#
#   Copyright (C) 2010  Lucas Martin-King  <lmartinking@gmail.com>
# 
#   redbubble-ruby is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   redbubble-ruby is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with redbubble-ruby; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++

# TODO:
#  * Add more in the way of error checking
#  * Callbacks (?)
#  * Calendar Support

require 'rubygems'
require 'hpricot'
require 'open-uri'

class Redbubble
	@@domain = 'http://www.redbubble.com'
	@@custom_fetch = nil

	def initialize(username)
		@user = User.new(username)

		@shirts = []
		@artworks = []
	end

	def user
		@user
	end

	def Redbubble.domain
		@@domain
	end

	def custom_fetch=(func)
		@@custom_fetch = func
	end

	class User
		attr_accessor :username, :img_small, :img_medium, :name, :url, :groups

		@@sml_sz = '45x45'
		@@med_sz = '135x135'

		def initialize(username)
			@username = username
			@img_small = ""
			@img_medium = ""
			@name = ""
			@url = ""

			@groups = UserGroups.new
		end

		def url
			@url = "#{Redbubble.domain}/people/#{@username}"
		end

		def img_medium=(url)
			@img_medium = url
			img_small_refresh
			@img_medium
		end

		def img_small_refresh
			@img_small = @img_medium.gsub(@@med_sz, @@sml_sz)			
			@img_small
		end

		def extended_info_refresh
			profile = Redbubble.fetch_page(url)

			# grab the avatar img
			profile.at("#avatar").search("img").each {
				|avatar|
				@name = avatar['alt']
				self.img_medium = avatar['src'].to_s
			}

			# grab the groups
			profile.at("#profile-groups").search("a").each {
				|a|
				g = UserGroup.new
				g.name = a.inner_html
				g.url = Redbubble.domain + a['href']
				@groups << g
			}
		end
	end

	class UserGroups < Array
		def initialize
			super
		end

		def to_s
			@gs = []
			self.each { |g|
				@gs << g.to_s
			}
			str = @gs.join(', ')

			if str == ""
				return "None"
			else
				return str
			end
		end
	end

	class UserGroup
		attr_accessor :name, :url

		def initialize
			@name = ""
			@url = ""
		end

		def to_s
			@name
		end
	end


	class Item
		attr_accessor :title, :img_small, :img_medium, :img_large, :url, :buy_url, :price, :tags, :groups, :owner, :forms

		@@nsfw_sml = 'nsfw_small.jpg'
		@@nsfw_med = 'nsfw_medium.jpg'
		@@nsfw_lge = 'nsfw_large.jpg'

		def initialize
			@owner = nil

			@title = ""
			@img_small = ""
			@img_medium = ""
			@img_large = ""
			@url = ""
			@buy_url = ""
			@tags = []
			@groups = UserGroups.new
			@forms = []
			@price = []
		end

		def to_s
			"[#{@title}] #{@url} : #{@img_small} : #{@img_medium} : #{@img_large}"
		end

		def print
			puts "Title:  #{@title}"
			puts "URL:    #{@url}"
			puts "ImgSml: #{@img_small}"
			puts "ImgMed: #{@img_medium}"
			puts "ImgLge: #{@img_large}"
		end

		def print_extra
			puts "Prices: #{self.price}"
			puts "Forms:  #{@forms}"
			puts "Tags:   #{@tags.to_s}"
			puts "Groups: #{@groups.to_s}"
			puts "BuyUrl: #{@buy_url}"
		end

		def nsfw?
			@img_small.include? @@nsfw_sml
		end

		def img_small=(url)
			@img_small = url
			img_medium_refresh
			img_large_refresh
			@img_small
		end

		def img_medium_refresh
			nil
		end

		def img_large_refresh
			nil
		end

		def buy_url
			if @buy_url.empty?
				extended_info_refresh
			end
			@buy_url
		end

		def price
			if @price.empty?
				extended_info_refresh
			end
			@price
		end

		def tags
			if @tags.empty?
				extended_info_refresh
			end
			@tags
		end

		def extended_info_refresh
			nil
		end

		private

		def item_extended_info_refresh
			url = @url
			doc = Redbubble.fetch_page(url)
			update_price(doc)
			update_buy_url(doc)
			update_tags(doc)
			update_groups(doc)
			update_forms(doc)
			return doc
		end

		def update_tags(doc)
			# get the tags
			doc.at("div#tags").search("a").each {
				|a|
				@tags << a.inner_html
			}	
		end

		def update_groups(doc)
			doc.at("#description").search("a") {
				|a|
				@owner.groups.each {
					|group|
					if group.url == Redbubble.domain + a['href']
						@groups << group	
					end
				}
			}
		end

		def update_buy_url(doc)
			# get the buy link
			doc.at("div#buy").search("a[@title=buy]").each { |a| @buy_url = a['href'].to_s }
		end

		def update_price(doc)
			# get the price
			doc.at("div#buy").search("a").each {
				|a|
				price = a.inner_html.scan(/(.*[0-9]+\.[0-9]+)$/)

				if price.empty?
					next
				end

				@price << price[0][0].to_s.gsub('from ','')
			}
		end

		def update_forms(doc)
			[ 'T-Shirt:', 'Card:', 'Print:' ].each {
				|f|
				result = doc.at("div#buy").inner_html.scan(f)
				if not result.empty?
					@forms << result[0].gsub(':','').downcase
				end
			}			
		end
	end

	# Class for Redbuble Clothing
	class Shirt < Item
		attr_accessor :color, :colors, :colors_rgb, :gender

		@@sml_sz = '135x135' # Don't change
		@@med_sz = '482x482' # ...or this!
		@@lge_sz = '550x550' # Unless redbubble changes this
		@@bgcolor = 'ffffff'		

		def initialize
			super

			@color = ""		# Default colour
			@gender = "mens"	# Default gender
			@colors = []
			@colors_rgb = []
		end

		def img_small=(url)
			@img_small = url
			@color = @img_small.to_s.scan(/.*,(.*)\.jpg/)		
			img_medium_refresh
			img_large_refresh
			@img_small
		end

		def img_medium_refresh
			# Our clever little dodad to figure out the larger size	
			@img_medium = @img_small.gsub(/fc/,'ts').gsub(@@sml_sz,@@med_sz).gsub(/\.jpg$/,",#{@gender},#{@@bgcolor}.jpg").gsub(@@nsfw_sml, @@nsfw_med)	
		end

		def img_large_refresh
			# Our clever little dodad to figure out the larger size
			@img_large = @img_small.gsub(@@sml_sz,@@lge_sz).gsub(@@nsfw_sml, @@nsfw_lge)
		end



		#
		# All the attributes after here require an extra page fetch!
		#
		def colors
			if self.nsfw?
				@colors
			end

			if @colors.empty?
				extended_info_refresh
			end
			@colors
		end

		def extended_info_refresh
			doc = item_extended_info_refresh

			# get the shirt colour options
			doc.search("ul#color-options").each {
				|element|
				element.search("a").each {
					|this|
					@colors << this.at("span").inner_html.to_s.downcase
					style = this['style'].to_s
					rgb = style.scan(/background: (#.+);/)[0][0]
					@colors_rgb << rgb.to_s.downcase
				}
			}
		end
	end

	# Class for Redbuble Artwork
	class Artwork < Item
		@@sml_sz = '135x135'
		@@med_sz = '550x550'
		@@lge_sz = '800x800'
		
		def initialize()
			super
		end

		def img_medium_refresh
			# Our clever little dodad to figure out the larger size	
			@img_medium = @img_small.gsub(/fc/,'ts').gsub(@@sml_sz,@@med_sz).gsub(@@nsfw_sml, @@nsfw_med)	
		end

		def img_large_refresh
			# Our clever little dodad to figure out the larger size
			@img_large = @img_small.gsub(@@sml_sz,@@lge_sz).gsub(@@nsfw_sml, @@nsfw_lge)
		end

		def extended_info_refresh
			doc = item_extended_info_refresh
		end
	end

	###


	def init_shirts
		pages = gather_pages('t-shirts')

		pages.each {
			|doc|

			works = doc.search("span.work-info")
			works.map.each {
				|item|
			
				s = Shirt.new
				s.owner = @user

				s.url = @@domain + item.at("a")['href'].to_s
				s.title = item.at("span.title").at("a")['title'].to_s
				s.img_small = item.at("img")['src'].to_s

				@shirts << s
			}
		}
	end

	def init_artworks
		pages = gather_pages('art')

		pages.each {
			|doc|

			works = doc.search("span.work-info")
			works.map.each {
				|item|
			
				a = Artwork.new
				a.owner = @user

				a.url = @@domain + item.at("a")['href'].to_s
				a.title = item.at("span.title").at("a")['title'].to_s
				a.img_small = item.at("img")['src'].to_s

				@artworks << a
			}
		}					
	end

	def shirts
		if @shirts.empty?
			init_shirts()
		end

		@shirts
	end

	def artworks
		if @artworks.empty?
			init_artworks()
		end

		@artworks
	end

	def gather_pages(item_type)
		url = "#{@@domain}/people/#{@user.username}/#{item_type}/everything"

		docs = []
		doc = Redbubble.fetch_page(url)
		docs << doc

		page_links = doc.search('//li[@class=page-link]')
		page_links.map.each { |this|
			u = this.at("a")['href'].to_s
			u = @@domain + u
			doc = Redbubble.fetch_page(u)
			docs << doc
		}

		docs
	end

	def Redbubble.fetch_page(url)
		if @@custom_fetch
			puts "Calling custom fetch"
			data = @@custom_fetch.call(url)	
		else
			data = open(url)
		end

		Hpricot(data)
	end
end
