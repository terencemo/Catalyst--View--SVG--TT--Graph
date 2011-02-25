package Catalyst::View::SVG::TT::Graph;

use Moose;
BEGIN { extends 'Catalyst::View'; }

use Carp;
use Image::LibRSVG;
use MIME::Types;

our $VERSION = 0.02;

has 'format' => ( is => 'ro', isa => 'Str', default => 'svg' );

has 'chart_conf' => ( is => 'ro', isa => 'HashRef', default => sub {{}} );

has 't' => ( is => 'ro', isa => 'MIME::Types', default => sub { MIME::Types->new } );

=head1 NAME

Catalyst::View::SVG::TT::Graph - SVG::TT::Graph charts (in svg/png/gif/jpeg..) for your Catalyst application

=head1 SYNOPSIS

Create your view class:

    ./script/myapp_create.pl view Chart SVG::TT::Graph

Set your chart preferences in your config:

    <View::Chart>
        format         png
        <chart_conf>
            style_sheet         /path/to/stylesheet.css
            show_graph_title    1
        </chart_conf>
    </View::Chart>

Stash your chart data in your controller:

    $c->stash->{chart_title} = 'Sales data'; # optional
    
    $c->stash->{chart_type} = 'Bar'; # or Pie/Line/BarHorizontal
    
    $c->stash->{chart_conf} = {
        height  => 400,
        width   => 600
    };
    
    $c->stash->{chart_fields} = [ qw(Jan Feb March ..) ];
    $c->stash->{chart_data} = [ 120, 102, ..];

In your end method:

    $c->forward($c->view('Chart'));

If you want, say a comparative line graph of mutiple sets of data:

    $c->stash->{chart_type} = 'Line';
    
    $c->stash->{chart_data} = [
        { title => 'Barcelona', data => [ ... ] },
        { title => 'Atletico', data => [ ... ] },
    ];

=cut

sub process {
    my ( $self, $c ) = @_;

    my ( $type, $title, $fields, $data ) = map {
        $c->stash->{"chart_" . $_} or croak("\$c->stash->{chart_$_} not set")
    } qw(type title fields data);

    $type =~ m/^(Bar(Horizontal)?|Pie|Line)$/ or croak("Invalid chart type $type");

    my $conf = {
        %{ $self->chart_conf },
        %{ $c->stash->{chart_conf} }
    };

    $conf->{fields} = $fields;
    $conf->{graph_title} = $title if $title;

    my $class = "SVG::TT::Graph::$type";

    Catalyst::Utils::ensure_class_loaded($class);
    my $svgttg = $class->new($conf);
    if ('HASH' eq ref($data)) {
        $svgttg->add_data($data);
    } elsif ('ARRAY' eq ref($data)) {
        if ('HASH' eq ref($data->[0])) {
            foreach my $datum (@$data) {
                $svgttg->add_data($datum);
            }
        } else {
            $svgttg->add_data( { data => $data } );
        }
    }

    my @formats = qw(gif jpeg png bmp ico pnm xbm xpm);
    my $frestr = '^(' . join('|', @formats) . ')$';
    my $format = $c->stash->{format} || $self->format;

    if ($format =~ m/$frestr/) {
        Image::LibRSVG->isFormatSupported($format)
            or croak("Format $format is not supported");
        $svgttg->compress(0);
        my $img = $svgttg->burn;
        my $rsvg = Image::LibRSVG->new();
        $rsvg->loadImageFromString($img);
        my $mtype = $self->t->mimeTypeOf($format);
        $c->res->content_type($mtype);
        $c->res->body($rsvg->getImageBitmap($format));
    } elsif ($format eq 'svg') {
        $c->res->content_type("image/svg+xml");
        $c->res->content_encoding("gzip");
        $c->res->body($svgttg->burn);
    }
}

=head1 OPTIONS

Options can be set in the config or in the stash

=head2 format

Can be svg, png, gif, jpeg or any other format supported by L<Image::LibRSVG>

=head2 chart_conf

All options taken by L<SVG::TT::Graph> can be provided

=head1 SEE ALSO

L<SVG::TT::Graph>, L<Image::LibRSVG>

=head1 AUTHOR

Terence Monteiro <terencemo[at]cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;

1;
