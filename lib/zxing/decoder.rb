require 'uri'
require 'pry'

module ZXing
  if RUBY_PLATFORM != 'java'
    require 'zxing/client'
    Decoder = Client.new
  else
    require 'java'
    require 'zxing/core.jar'
    require 'zxing/javase.jar'

    java_import com.google.zxing.MultiFormatReader
    java_import com.google.zxing.BinaryBitmap
    java_import com.google.zxing.Binarizer
    java_import com.google.zxing.common.GlobalHistogramBinarizer
    java_import com.google.zxing.LuminanceSource
    java_import com.google.zxing.client.j2se.BufferedImageLuminanceSource
    java_import com.google.zxing.multi.GenericMultipleBarcodeReader

    java_import javax.imageio.ImageIO
    java_import java.net.URL
    java_import java.awt.geom.AffineTransform
    java_import java.awt.image.AffineTransformOp
    java_import java.awt.image.BufferedImage

    class Decoder
      attr_accessor :file, :options, :image, :retry_count

      MAX_RETRIES = 3
      ROTATION_INCREMENT = 5

      def self.decode!(file, options = nil)
        new(file, options).decode
      rescue NativeException
        raise UndecodableError
      end

      def self.decode(file, options = nil)
        decode!(file, options)
      rescue UndecodableError
        nil
      end

      def self.decode_all!(file)
        new(file).decode_all
      rescue NativeException
        raise UndecodableError
      end

      def self.decode_all(file)
        decode_all!(file)
      rescue UndecodableError
        []
      end

      def initialize(file, options = nil)
        self.file = file
        self.options = options || {}
        self.retry_count = 0
      end

      def reader
        MultiFormatReader.new
      end

      def decode
        if options[:rotate_and_retry_on_failure]
          decode_with_retry
        else
          reader.decode(bitmap).to_s
        end
      end

      def decode_with_retry
        reader.decode(bitmap).to_s
      rescue com.google.zxing.NotFoundException
        puts "Failed on try #{retry_count}"
        self.retry_count += 1
        retry if retry_count <= MAX_RETRIES
        raise com.google.zxing.NotFoundException
      end

      def decode_all
        multi_barcode_reader = GenericMultipleBarcodeReader.new(reader)

        multi_barcode_reader.decode_multiple(bitmap).map do |result|
          result.get_text
        end
      end

      private

      def bitmap
        BinaryBitmap.new(binarizer)
      end

      def io
        if file =~ URI.regexp(['http', 'https'])
          URL.new(file)
        else
          raise ArgumentError, "File #{file} could not be found" unless File.exist?(file)
          Java::JavaIO::File.new(file)
        end
      end

      def luminance
        BufferedImageLuminanceSource.new(rotated)
      end

      def binarizer
        GlobalHistogramBinarizer.new(luminance)
      end

      def rotated
        return buffered unless retry_count > 0
        op = AffineTransformOp.new(transformation, AffineTransformOp::TYPE_NEAREST_NEIGHBOR)
        op.java_send(:filter, [BufferedImage, BufferedImage], buffered, nil)
      end

      def buffered
        unless image
          self.image = ImageIO.read(io)
          self.image = cropped(options[:crop]) if options[:crop]
        end
        image
      end

      def transformation
        width = buffered.getWidth
        height = buffered.getHeight
        hypot = java.lang.Math.hypot(width, height)
        transform = AffineTransform.getRotateInstance(java.lang.Math.toRadians(retry_count*ROTATION_INCREMENT), hypot/2, hypot/2)
        transform.translate((hypot-width)/2, (hypot-height)/2)
        transform
      end

      def cropped(x: 0, y: 0, width: 1, height: 1)
        i_width = image.getWidth
        i_height = image.getHeight
        image.getSubimage(x*i_width, y*i_height, width*i_width, height*i_height)
      end
    end
  end
end
