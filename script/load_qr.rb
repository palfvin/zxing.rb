require 'rubygems'
require 'pry'
require 'prawn'

require 'rqrcode'
require 'prawn/qrcode'

prawn = Prawn::Document.new

# qr_code = RQRCode::QRCode.new('438 Crescent')
prawn.print_qr_code('438 Crescent', :extent=>144)
prawn.render_file('foo.pdf')
`convert foo.pdf foo.png`

load '/Users/palfvin/qrio/lib/qrio.rb'

qr = Qrio::Qr.load('/Users/palfvin/avlats/foo.png')

puts qr.qr.text

