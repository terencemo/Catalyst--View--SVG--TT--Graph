#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Image::LibRSVG;

# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

# make sure testapp works
use ok 'TestApp';

# a live test against TestApp, the test application
use Test::WWW::Mechanize::Catalyst 'TestApp';
my $mech = Test::WWW::Mechanize::Catalyst->new;

my @formats = qw(gif jpeg png bmp ico pnm xbm xpm);
foreach my $format (@formats) {
    next unless Image::LibRSVG->isFormatSupported($format);
    for my $type (qw(bar pie bar_horizontal line)) {
        $mech->get_ok('http://localhost/chart/' . $type, "get $type chart");
    }
}

done_testing;
