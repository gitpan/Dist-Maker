package Dist::Maker::Command::init;
use Mouse;
use MouseX::StrictConstructor;

use Dist::Maker::Scatter;
use Dist::Maker::Name;
use Dist::Maker::Util qw(parse_options p rmtree);

extends 'Dist::Maker::Base';

sub pass_through { 0 }

sub option_spec {
    return(
        'dry-run|n',
        'force|f',
    );
}

sub run {
    my $self = shift;

    my($options, $distname, $template) = $self->parse_options(@_);
    if(!$distname) {
        $self->diag("Distribution name is not given.\n");
        return undef;
    }

    my $cmd = ref($self);

    $template //= 'Default';

    my $config_data = $self->config_data;
    $self->note("running with $distname $template ...\n");

    my $dist    = Dist::Maker::Name->new($distname);
    my $distdir = $dist->name;

    if(-e $distdir) {
        if($options->{force}) {
            $self->info("rmtree $distdir\n");
            $self->rmtree($distdir);
        }
        else {
            $self->diag("$distdir already exists. Finished.\n");
            return undef;
        }
    }

    my $dms = Dist::Maker::Scatter->new(
        dist     => $dist,
        template => $template,
        config   => $self->config,
    );

    if(!$options->{'dry-run'}) {
        $dms->scatter($distdir);

        my %meta = (
            template => $template,
            dist     => $distname,
        );
        $self->config->save_data("$distdir/.dim.pl" => \%meta);
        # TODO: initialize repository
        # TODO: setting repository data (github?)
    }
    else {
        $self->info($_, "\n") for sort keys %{ $dms->content_map };
    }

    $self->note("finished.\n");
    return 1;
}

no Mouse;
__PACKAGE__->meta->make_immutable();
__END__

=head1 NAME

Dist::Maker::Command::init - Initializes a distribution

=cut
