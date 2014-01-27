require 'rubygems'
require 'rmagick'
require 'zxing'

dir = '/Users/palfvin/avlats/tmp/'
png_filename = dir+'crop6.png'
image = Magick::Image.read(png_filename)[0]
fails = (1..359).map do |rotation|
  image.rotate(rotation).write(png_rotated = dir+"rotated-#{rotation}.png")
  unless (text = ZXing.decode(png_rotated)) == "Cover:\n62 Canyon Terrace Rd".upcase
    puts "Rotation #{rotation} got #{text.inspect}"
    rotation
  end
end
puts fails.compact.inspect
