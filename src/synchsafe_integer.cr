require "log"

class InvalidSynchsafeInteger < Exception
  def initialize(bytes, n, i)
    bytes = bytes.map { |byte| "0b" + byte.to_s 2, precision: 8 }
    super "#{n} (#{bytes}) is not a valid synchsafe integer, byte #{i}, bit 7 is high"
  end
end

{% for t in [Int32, UInt32] %}
struct {{ t }}
  SYNCH_SAFE_FROM_MAX = 0b0111_1111_0111_1111_0111_1111_0111_1111_{{ t.stringify[0...1].downcase.id }}32
  SYNCH_SAFE_TO_MAX   = 0b0111_1111_0111_1111_0111_1111_0111_1111_{{ t.stringify[0...1].downcase.id }}32.synchsafe_decode

  def synchsafe_decode
    bytes = uninitialized UInt8[4]
    IO::ByteFormat::BigEndian.encode self, bytes.to_slice
    bytes.each_with_index { |n, i| raise InvalidSynchsafeInteger.new(bytes, self, i) if n & 0b1000_0000_u8 != 0 }
    bytes[3] = bytes[3] | ((bytes[2] & 0b0000_0001_u8) << 7)
    bytes[2] = ((bytes[2] & 0b0111_1110_u8) >> 1) | ((bytes[1] & 0b0000_0011_u8) << 6)
    bytes[1] = ((bytes[1] & 0b0111_1100_u8) >> 2) | ((bytes[0] & 0b0000_0111_u8) << 5)
    bytes[0] = ((bytes[0] & 0b0111_1000_u8) >> 3)
    IO::ByteFormat::BigEndian.decode typeof(self), bytes.to_slice
  end

  def synchsafe_encode
    raise OverflowError.new "#{self} is too large to be converted to synchsafe" if self > SYNCH_SAFE_TO_MAX
    bytes = uninitialized UInt8[4]
    IO::ByteFormat::BigEndian.encode self, bytes.to_slice
    # grab bit 7 of byte 3 (the least order)
    carry = bytes[3] & 0b1000_0000_u8
    # zero bit 7 of byte 3
    bytes[3] &= 0b0111_1111_u8
    # grab bits 6 & 7 of byte 2
    carry2 = bytes[2] & 0b1100_0000_u8
    # shift bits 0-5 of byte 2 to the left one, leaving them as bits 6-1. Put
    # bit 7 of byte 0 at bit 0 of byte 2
    bytes[2] = ((bytes[2] & 0b0011_1111_u8) << 1) | (carry >> 7)
    # grab bits 5-7 of byte 1
    carry = bytes[1] & 0b1110_0000_u8
    # shift bits 0-4 of byte 1 to the left by 2, put bits 6 & 7 of byte 2 at
    # bits 0 and 1 of byte 1
    bytes[1] = ((bytes[1] & 0b0001_1111_u8) << 3) | (carry2 >> 6)
    # shift bits 0-3 of byte 0 to the left by 3 (putting them at bits 6-3, mask
    # 0b0111_1000, which also zeroes the 7th bit), then fill in bits 0-2 with
    # bits 5-7 of byte 1.
    bytes[0] = ((bytes[0] & 0b0000_1111_u8) << 3) | (carry >> 5)
    result = IO::ByteFormat::BigEndian.decode Int32, bytes.to_slice
    result
  end
end
{% end %}

{% for t in [Int16, UInt16] %}
struct {{ t }}
  SYNCH_SAFE_FROM_MAX = 0b0111_1111_0111_1111_{{ t.stringify[0...1].downcase.id }}16
  SYNCH_SAFE_TO_MAX = 0b0111_1111_0111_1111_{{ t.stringify[0...1].downcase.id }}16.synchsafe_decode

  def synchsafe_decode
    bytes = uninitialized UInt8[2]
    IO::ByteFormat::BigEndian.encode self, bytes.to_slice
    bytes.each_with_index { |n, i| raise InvalidSynchsafeInteger.new(bytes, self, i) if n & 0b1000_0000_u8 != 0 }
    # put the first bit of byte 0 in the high bit of byte 1
    bytes[1] = bytes[1] | ((bytes[0] & 0b0000_0001_u8) << 7)
    # shift bits 6-1 down one, leaving a max-14-bit properly encoded i/u16
    bytes[0] = ((bytes[0] & 0b0111_1110_u8) >> 1)
    IO::ByteFormat::BigEndian.decode typeof(self), bytes.to_slice
  end

  def synchsafe_encode
    raise OverflowError.new "#{self} is too large to be converted to synchsafe" if self > SYNCH_SAFE_TO_MAX
    bytes = uninitialized UInt8[2]
    IO::ByteFormat::BigEndian.encode self, bytes.to_slice
    # grab bit 7 of byte 1 (the least order)
    carry = bytes[1] & 0b1000_0000_u8
    # zero bit 7 of byte 1
    bytes[1] &= 0b0111_1111_u8
    # shift bits 6-0 of byte 0 up one, then shift the high-bit of byte 1 into bit 0 of byte 0.
    bytes[0] = ((bytes[0] & 0b0111_1111_u8) << 1) | (carry >> 7)
    IO::ByteFormat::BigEndian.decode typeof(self), bytes.to_slice
  end
end
{% end %}
