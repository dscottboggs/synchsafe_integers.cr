# "Synchsafe" Integers

"Synchsafe" integers are defined by section 6.2 of the ID3 standard structure as
follows:

> Synchsafe integers are integers that keep its highest bit (bit 7) zeroed,
making seven bits out of eight available. Thus a 32 bit synchsafe integer can
store 28 bits of information.

The spec then provides a single example:
```
   Example:
     255 (%11111111) encoded as a 16 bit synchsafe integer is 383
     (%00000001 01111111).
```

This is, of course, a huge pain in the ass, so I hope this implementation will
help someone else not have to deal with this headache.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     synchsafe_integer:
       github: dscottboggs/synchsafe_integer.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "synchsafe_integer"

puts 255.synchsafe_encode # => 383
puts 383.synchsafe_decode # => 255
```

An error is thrown at run-time if the number is larger than 28 bits when
encoding, or contains any bytes with the 7th (high) bit set to 1 when decoding.

## Contributing

1. Fork it (<https://github.com/dscottboggs/synchsafe_integer.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D. Scott Boggs](https://github.com/dscottboggs) - creator and maintainer
