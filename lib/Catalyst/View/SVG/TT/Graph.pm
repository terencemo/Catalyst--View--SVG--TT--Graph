package Catalyst::View::SVG::TT::Graph;

use Moose;
BEGIN { extends 'Catalyst::View'; }

use Carp;
use Image::LibRSVG;
#use YAML;

our $VERSION = 0.01;

=head1 NAME

Catalyst::View::SVG::TT::Graph - SVG::TT::Graph charts (in svg/png/jpeg.. format) for your Catalyst application

=head1 SYNOPSIS

Create your view class:

    ./script/myapp_create.pl view Chart SVG::TT::Graph

Set your chart preferences in your view:

    __PACKAGE__->config( {
        format      => 'png',
        style_sheet => '/path/to/stylesheet.css',
        show_graph_title => 1
    } );

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
        %{ $self->config },
        %{ $c->stash->{"chart_conf"} }
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

    my $format = $conf->{format} || 'svg';
    if (Image::LibRSVG->isFormatSupported($format)) {
        $svgttg->compress(0);
        my $img = $svgttg->burn;
        my $rsvg = Image::LibRSVG->new();
        $rsvg->loadImageFromString($img);
        $c->res->content_type("image/$format");
        $c->res->body($rsvg->getImageBitmap($format));
    } elsif ($format eq 'svg') {
        $c->res->content_type("image/svg+xml");
        $c->res->content_encoding("gzip");
        $c->res->body($svgttg->burn);
    } else {
        croak("Format $format is not supported");
    }
}

=head1 OPTIONS

=head2 format

Can be svg, png or jpeg or any other format supported by L<Image::LibRSVG>

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
