use strict;
use warnings;

use RT::Test tests => 9;

my ( $baseurl, $m ) = RT::Test->started_ok;

ok( $m->login, 'logged in' );

$m->get_ok('Search/Build.html?NewQuery=1');

my @orderby = qw(
AdminCc.EmailAddress
Cc.EmailAddress
Created
Creator
Custom.Ownership
Due
FinalPriority
InitialPriority
LastUpdated
LastUpdatedBy
Owner
Priority
Queue
Requestor.EmailAddress
Resolved
SLA
Started
Starts
Status
Subject
TimeEstimated
TimeLeft
TimeWorked
Told
Type
id);

my $orderby = join(' ', sort @orderby);

my $cf1 = RT::Test->load_or_create_custom_field(
                      Name  => 'Location',
                      Queue => 'General',
                      Type  => 'FreeformSingle', );
isa_ok( $cf1, 'RT::CustomField' );

my $scraped_orderby = $m->scrape_text_by_attr('name', 'OrderBy');

is($scraped_orderby, $orderby);

$m->submit_form_ok(
    {
        form_number => 3,
        fields => {
            SavedSearchId => 'new',
            ValueOfQueue => 'General',
            AddClause => 'Add these terms',
        }
    },
    'Add these terms',
    );

$scraped_orderby = $m->scrape_text_by_attr('name', 'OrderBy');

push @orderby, 'CustomField.{Location}';

$orderby = join(' ', sort @orderby);

is($scraped_orderby, $orderby);
