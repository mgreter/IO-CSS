IO-CSS
======

This is a shameless ripoff of [IO::HTML][1] by [Christopher J. Madsen](cjmweb.net).

It provides a practically identical interface as [IO::HTML][1], minus the output functionality. It allows a perl
coder to open css files in the correct encoding, which is taken from the `BOM` or from the `@charset` declaration.

[1]: http://search.cpan.org/dist/IO-HTML/lib/IO/HTML.pm

Installation
------------

[![Build Status](https://travis-ci.org/mgreter/IO-CSS.svg?branch=master)](https://travis-ci.org/mgreter/IO-CSS)
[![Coverage Status](https://img.shields.io/coveralls/mgreter/IO-CSS.svg)](https://coveralls.io/r/mgreter/IO-CSS?branch=master)

To install this module type the following:

    perl Build.PL
    ./Build verbose=1
    ./Build test verbose=1
    ./Build install verbose=1

On windows you may want to install [Strawberry Perl](http://strawberryperl.com/) first.
