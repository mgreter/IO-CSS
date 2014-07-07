#! /usr/bin/perl
#---------------------------------------------------------------------
# 30-open.t
# Copyright 2012 Christopher J. Madsen
# Copyright 2014 Marcel Greter
#
# Actually open files and check the encoding
#---------------------------------------------------------------------

use strict;
use warnings;

use Test::More 0.88;

plan tests => 49;

use IO::CSS;
use File::Temp;
use Scalar::Util 'blessed';

#---------------------------------------------------------------------
my $default_encoding = $^O eq 'MSWin32' ? 'cp1252' : 'utf8';
#---------------------------------------------------------------------
sub test
{
  my ($expected, $out, $data, $name, $nextArg) = @_;

  my $options;
  if (ref $name) {
    $options = $name;
    $name    = $nextArg;
  }

  unless ($name) {
    $name = 'test ' . ($expected || $default_encoding);
  }

  my $tmp = File::Temp->new(UNLINK => 1);
  open(my $mem, '>', \(my $buf)) or die;

  binmode $tmp, ':raw';
  binmode $mem, ':raw';

	if ($out eq 'UTF-16BE') { print $tmp "\xFe\xFF"; print $mem "\xFe\xFF"; }
	elsif ($out eq 'UTF-16LE') { print $tmp "\xFF\xFe"; print $mem "\xFF\xFe"; }

  if ($out) {
    $out = ":encoding($out)" unless $out =~ /^:/;
    binmode $tmp, $out;
    binmode $mem, $out;
  }

  print $mem $data;
  print $tmp $data;
  close $mem;
  $tmp->close;

  my ($fh, $encoding, $bom) = IO::CSS::file_and_encoding("$tmp", $options);

  if ($options and $options->{encoding}) {
    ok(blessed($encoding), 'returned an object');
    $encoding = eval { $encoding->name };
  }

  is($encoding, $expected || $default_encoding, sprintf("%s (1)", $name));

  my $firstLine = <$fh>;

  close $fh;

  $fh = css_file("$tmp", $options);

  is(<$fh>, $firstLine, sprintf("%s (2)", $name));

  close $fh;

  undef $mem;
  # Test sniff_encoding:
  open($mem, '<', \$buf) or die "Can't open in-memory file: $!";

  delete $options->{encoding} if $options;

  ($encoding, $bom) = IO::CSS::sniff_encoding($mem, undef, $options);

  is($encoding, $expected, sprintf("%s (3)", $name));

  seek $mem, 0, 0;

  $options->{encoding} = 1;

  ($encoding, $bom) = IO::CSS::sniff_encoding($mem, undef, $options);

  if (defined $expected) {
    ok(blessed($encoding), 'encoding is an object');

    is(eval { $encoding->name }, $expected, sprintf("%s (4)", $name));
  } else {
    is($encoding, undef, sprintf("%s (5)", $name));
  }
} # end test

#---------------------------------------------------------------------
test 'utf-8-strict', 'utf8' => <<'';
@charset "UTF-8"
.path { content: "äöü"; }

test 'UTF-16LE', 'UTF-16LE' => <<'';
@charset 'utf-16-le'
.path { content: "äöü"; }

test 'UTF-16BE', 'UTF-16BE' => <<'';
@charset "utf-16-be"
.path { content: "äöü"; }

test 'cp1252', 'iso-8859-1' => <<'';
@charset 'ISO-8859-1'
.path { content: "äöü"; }

test 'iso-8859-15', 'iso-8859-15' => <<'';
@charset 'ISO-8859-15'

test 'iso-8859-15', 'iso-8859-15' => <<'';
@charset
 "ISO-8859-15"

test 'utf-8-strict', 'utf-8-strict' => <<'';
@charset "UTF-8"

test 'cp1252', 'cp1252' => <<'';
@charset "Windows-1252"

test undef, 'utf8' => <<'', 'misspelled charset';
@charseat "Windows-1252"

test 'utf-8-strict', 'utf8' => <<'';
@charset "UTF-8"
@charset "Windows-1252"
@charseat "Windows-1252"

