# num-base-converters
## Convert integers between different numeric bases

This library defines the command **nbc-number-base-converter** to
translate a given integer

in a numeric base to a different one.

For instance, 10 in hexadecimal is 'A':

    (nbc-number-base-converter "10" 10 16)
    => "A"

In addition, this file adds the following commands to convert
between the most common bases (2, 8, 10, 16):

`nbc-hex2dec`, `nbc-hex2oct`, `nbc-hex2bin`

`nbc-dec2hex`, `nbc-dec2oct`, `nbc-dec2bin`

`nbc-oct2hex`, `nbc-oct2dec`, `nbc-oct2bin`

`nbc-bin2hex`, `nbc-bin2dec`, `nbc-bin2oct`.
