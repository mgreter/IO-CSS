#! /usr/bin/perl
#---------------------------------------------------------------------
# 20-find.t
# Copyright 2012 Christopher J. Madsen
# Copyright 2014 Marcel Greter
#
# Test the find_charset_in function
#---------------------------------------------------------------------

use strict;
use warnings;

use Test::More 0.88;            # done_testing
use Scalar::Util 'blessed';

use IO::CSS 'find_charset_in';

plan tests => 13;

sub test
{

	my $charset = shift;
	my @data = shift;
	# options for find_charset_in
	push @data, shift if ref $_[0];
	my $name = shift;

	is(scalar find_charset_in(@data), $charset, $name);

} # end test

#---------------------------------------------------------------------
test 'utf-8-strict' => <<'';
@charset "UTF-8"

test 'UTF-16LE' => <<'';
@charset 'utf-16-le'

test 'UTF-16BE' => <<'';
@charset "utf-16-be"

test 'iso-8859-15' => <<'';
@charset 'ISO-8859-15'

test 'iso-8859-15' => <<'';
@charset  "ISO-8859-15"

test 'iso-8859-15' => <<'';
@charset
 "ISO-8859-15"

test 'utf-8-strict' => <<'';
@charset UTF-8

test 'cp1252' => <<'';
@charset "Windows-1252"

test undef, <<'', 'misspelled charset';
@charseat "Windows-1252"

test 'utf-8-strict' => <<'';
@charset "UTF-8"
@charset "Windows-1252"
@charseat "Windows-1252"

#test 'cp1252' => <<'';
#.class { content: "utf8"; }
#@charset="ISO-8859-1"

test undef, <<'', 'incomplete attribute';
@charset="ISO-8859-1

{
  my $encoding = find_charset_in('@charset "UTF-8"', { encoding => 1 });
  ok(blessed($encoding), 'encoding is an object');
  is(eval { $encoding->name }, 'utf-8-strict', 'encoding is UTF-8');
}

done_testing;
