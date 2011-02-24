use 5.008008;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Catalyst::View::SVG::TT::Graph',
    VERSION_FROM      => 'lib/Catalyst/View/SVG/TT/Graph.pm', # finds $VERSION
    PREREQ_PM         => {
                            'Image::LibRSVG'                => '0.07',
                            'Carp'                          => 1.11
                        }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Catalyst/View/SVG/TT/Graph.pm', # retrieve abstract from module
       AUTHOR         => 'Terence Monteiro <terencemo@cpan.org>') : ()),
);
