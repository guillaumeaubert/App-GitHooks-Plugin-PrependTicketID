package App::GitHooks::Plugin::PrependTicketID;

use strict;
use warnings;

use base 'App::GitHooks::Plugin';

# Internal dependencies.
use App::GitHooks::Constants qw( :PLUGIN_RETURN_CODES );
use App::GitHooks::Utils;


=head1 NAME

App::GitHooks::Plugin::PrependTicketID - Derive a ticket ID from the branch name and prepend it to the commit-message.


=head1 DESCRIPTION

If you are using the C<App::GitHooks::Plugin::RequireTicketID> to force entering a ticket ID with each commit, it can become tedious if you need to do a lot of commits with the same ticket ID on a feature branch.

To help with this, this plugin derives a ticket ID from the branch name and prepends it to the commit message.


=head1 VERSION

Version 1.0.1

=cut

our $VERSION = '1.0.1';


=head1 CONFIGURATION OPTIONS

This plugin supports the following options in the main section of your
C<.githooksrc> file.

	project_prefixes = DEV
	extract_ticket_id_from_branch = /^($project_prefixes\d+)/
	normalize_branch_ticket_id = s/^(.*?)(\d+)$/\U$1-$2/


=head2 project_prefixes

The list of valid ticket prefixes.

	project_prefixes = OPS, DEV, TEST


=head2 extract_ticket_id_from_branch

A regular expression with one capturing group that will extract the ticket ID
from a branch name.

	extract_ticket_id_from_branch = /^($project_prefixes\d+)/

In the example above, if a branch is named C<dev1293_my_new_feature>, the
regular expression will identify C<dev1293> as the ticket ID corresponding to
that branch.

Note that:

=over 4

=item *

Prefixes used for private branches are recognized properly and ignored
accordingly. In other words, both C<dev1293_my_new_feature> and
C<ga/dev1293_my_new_feature> will be identified as tied to C<dev1293> with the
regex above.

=item *

$project_prefixes is replaced at run time by the prefixes listed in the
C<project_prefixes> configuration option, to avoid duplication of information.

=back


=head2 normalize_branch_ticket_id

A replacement expression to normalize the ticket ID extracted with
C<extract_ticket_id_from_branch>.

	normalize_branch_ticket_id = s/^(.*?)(\d+)$/\U$1-$2/

In the example above, C<dev1293_my_new_feature> gave C<dev1293>, which is then
normalized as C<DEV-1293>.


=head1 METHODS

=head2 run_prepare_commit_msg()

Code to execute as part of the prepare-commit-msg hook.

  my $success = App::GitHooks::Plugin::PrependTicketID->run_prepare_commit_msg();

=cut

sub run_prepare_commit_msg
{
	my ( $class, %args ) = @_;
	my $app = delete( $args{'app'} );
	my $commit_message = delete( $args{'commit_message'} );
	my $repository = $app->get_repository();

	# If we're on a branch that includes a ticket ID, prepend it to the commit
	# message.
	my $branch_ticket_id = App::GitHooks::Utils::get_ticket_id_from_branch_name( $app );
	if ( defined( $branch_ticket_id ) )
	{
		my $ticket_id = $commit_message->get_ticket_id();

		# Don't add the prefix again if a ticket ID is found in the commit message.
		# This catches ticket IDs specified via git commit -m "..." and edits via
		# git commit --amend.

		$commit_message->update_message( $branch_ticket_id . ': ' . $commit_message->get_message() )
			if !defined( $ticket_id );
	}

	return $PLUGIN_RETURN_PASSED;
}


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-PrependTicketID/issues/new>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc App::GitHooks::Plugin::PrependTicketID


You can also look for information at:

=over

=item * GitHub's request tracker

L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-PrependTicketID/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/app-githooks-plugin-prependticketid>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/app-githooks-plugin-prependticketid>

=item * MetaCPAN

L<https://metacpan.org/release/App-GitHooks-Plugin-PrependTicketID>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2013-2014 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
