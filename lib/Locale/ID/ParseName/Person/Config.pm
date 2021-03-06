package Lingua::ID::NameParse::Config;

use Moo;

=head1 NAME

Lingua::ID::NameParse::Config - Lingua::ID::NameParse configuration

=head1 SYNOPSIS

    # getting configuration
    if ($nparse->config->gender_from_first_name) { ... }

    # setting configuration
    $nparse->config->gender_from_first_name(0);

=head1 DESCRIPTION

Configuration variables for L<Lingua::ID::NameParse>.

=head1 ATTRIBUTES

=head2 gender_from_first_name => BOOL

Whether to guess after parsing. Default is 0. Requires
L<Lingua::ID::GenderFromName>.

=cut

has gender_from_first_name => (is => 'rw', default => sub{0});

=head1 SEE ALSO

L<Lingua::ID::NameParse>

=cut

1;
