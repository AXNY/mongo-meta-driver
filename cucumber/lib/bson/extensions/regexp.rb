module BSON
  module Extensions
    module Regexp
      def to_bson(io, key)
        io << Types::REGEX
        io << key.to_bson_cstring
        io << source.to_bson_cstring

        io << 'i'  if (options & ::Regexp::IGNORECASE) != 0
        io << 'ms' if (options & ::Regexp::MULTILINE) != 0
        io << 'x'  if (options & ::Regexp::EXTENDED) != 0
        io << NULL_BYTE
      end

      module ClassMethods
        def from_bson(io)
          pattern = io.gets(NULL_BYTE).from_utf8_binary.chop!
          options = 0
          while (option = io.readbyte) != 0
            case option
            when 105 # 'i'
              options |= ::Regexp::IGNORECASE
            when 109, 115 # 'm', 's'
              options |= ::Regexp::MULTILINE
            when 120 # 'x'
              options |= ::Regexp::EXTENDED
            end
          end

          new(pattern, options)
        end
      end
    end
  end
end