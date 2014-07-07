#! /usr/bin/perl
#---------------------------------------------------------------------
# 10-unicode.t
# Copyright 2014 Marcel Greter
#
# Check for bom and charset recognition
# http://www.w3.org/TR/CSS2/syndata.html#charset
#---------------------------------------------------------------------

use strict;
use warnings;

use Test::More 0.88;

plan tests => 19;

use IO::CSS 'sniff_encoding';

use Encode qw(encode);

is(scalar sniff_encoding(\ "ascii"), undef, 'ascii only string');
is(scalar sniff_encoding(\ "\xC3\x84"), 'utf-8-strict', 'utf8 string');

is(scalar sniff_encoding(\ "ascii", undef, { encoding => 1 }), undef, 'ascii only string');
is(scalar sniff_encoding(\ "\xC3\x84", undef, { encoding => 1 })->name, 'utf-8-strict', 'utf8 string');

is(scalar sniff_encoding(\ "\xFE\xFF"), 'UTF-16BE', 'testing UTF-16BE bom');
is(scalar sniff_encoding(\ "\xFF\xFE"), 'UTF-16LE', 'testing UTF-16LE bom');
is(scalar sniff_encoding(\ "\xEF\xBB\xBF"), 'utf-8-strict', 'testing utf-8-strict bom');

is(scalar sniff_encoding(\ "\x00\x00\xFE\xFF"), 'UTF-32BE', 'testing UTF-32BE bom');
is(scalar sniff_encoding(\ "\xFF\xFE\x00\x00"), 'UTF-32LE', 'testing UTF-32LE bom');
# is(scalar sniff_encoding(\ "\x00\x00\xFF\xFE"), 'UCS-4-2143', 'testing UCS-4-2143 bom');
# is(scalar sniff_encoding(\ "\xFE\xFF\x00\x00"), 'UCS-4-3412', 'testing UCS-4-3412 bom');

is(scalar sniff_encoding(\(encode('UTF-16BE', '@charset'))), 'UTF-16BE', 'testing UTF-16BE without bom');
is(scalar sniff_encoding(\("\xFE\xFF".encode('UTF-16BE', '@charset'))), 'UTF-16BE', 'testing UTF-16BE with bom');
is(scalar sniff_encoding(\(encode('UTF-16LE', '@charset'))), 'UTF-16LE', 'testing UTF-16LE without bom');
is(scalar sniff_encoding(\("\xFF\xFE".encode('UTF-16LE', '@charset'))), 'UTF-16LE', 'testing UTF-16LE with bom');

is(scalar sniff_encoding(\(encode('UTF-32BE', '@charset'))), 'UTF-32BE', 'testing UTF-32BE without bom');
is(scalar sniff_encoding(\("\x00\x00\xFE\xFF".encode('UTF-32BE', '@charset'))), 'UTF-32BE', 'testing UTF-32BE with bom');
is(scalar sniff_encoding(\(encode('UTF-32LE', '@charset'))), 'UTF-32LE', 'testing UTF-32LE without bom');
is(scalar sniff_encoding(\("\xFF\xFE\x00\x00".encode('UTF-32LE', '@charset'))), 'UTF-32LE', 'testing UTF-32LE with bom');

# is(scalar sniff_encoding(\(encode('UCS-4-2143', '@charset'))), 'UCS-4-2143', 'testing UCS-4-2143 without bom');
# is(scalar sniff_encoding(\("\x00\x00\xFF\xFE".encode('UCS-4-2143', '@charset'))), 'UCS-4-2143', 'testing UCS-4-2143 with bom');
# is(scalar sniff_encoding(\(encode('UCS-4BE', '@charset'))), 'UCS-4-3412', 'testing UCS-4-3412 without bom');
# is(scalar sniff_encoding(\("\xFE\xFF\x00\x00".encode('UCS-4-3412', '@charset'))), 'UCS-4-3412', 'testing UCS-4-2143 with bom');

my $rv = eval { sniff_encoding(\("\xFF\xFE\x00\x00" . encode('UTF-32LE', '@charset "UTF-32BE"'))) };
is($rv, undef, 'mismatched encodings errors out');
like($@, qr/different/, 'and dies with an error message');

done_testing;

