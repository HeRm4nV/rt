#!/usr/local/bin/perl

use strict;
use WWW::Mechanize;
use HTTP::Request::Common;
use HTTP::Cookies;
use LWP;
use Encode;

my $cookie_jar = HTTP::Cookies->new;
my $agent = WWW::Mechanize->new();

# give the agent a place to stash the cookies

$agent->cookie_jar($cookie_jar);


# get the top page
my $url = "http://localhost".$RT::WebPath."/";
$agent->get($url);

is ($agent->{'status'}, 200, "Loaded a page");


# {{{ test a login

# follow the link marked "Login"

ok($agent->{form}->find_input('user'));

ok($agent->{form}->find_input('pass'));
ok ($agent->{'content'} =~ /username:/i);
$agent->field( 'user' => 'root' );
$agent->field( 'pass' => 'password' );
# the field isn't named, so we have to click link 0
$agent->click(0);
is($agent->{'status'}, 200, "Fetched the page ok");
ok( $agent->{'content'} =~ /Logout/i, "Found a logout link");



$agent->get($url."Ticket/Create.html?Queue=1");
is ($agent->{'status'}, 200, "Loaded Create.html");
$agent->form(3);
# Start with a string containing characters in latin1
my $string = "I18N Web Testing ���";
Encode::from_to($string, 'iso-8859-1', 'utf8');
$agent->field('Subject' => "Foo");
$agent->field('Content' => $string);
ok($agent->submit(), "Created new ticket with $string");

ok( $agent->{'content'} =~ qr{$string} , "Found the content");

$agent->get($url."Ticket/Create.html?Queue=1");
is ($agent->{'status'}, 200, "Loaded Create.html");
$agent->form(3);
# Start with a string containing characters in latin1
my $string = "I18N Web Testing ���";
Encode::from_to($string, 'iso-8859-1', 'utf8');
$agent->field('Subject' => $string);
$agent->field('Content' => "BAR");
ok($agent->submit(), "Created new ticket with $string");

ok( $agent->{'content'} =~ qr{$string} , "Found the content");



# }}}



use File::Find;
find ( \&wanted , 'html/');

sub wanted {
        -f  && /\.html$/ && $_ !~ /Logout.html$/  && test_get($File::Find::name);
}       

sub test_get {
        my $file = shift;


        $file =~ s#^html/##; 
        ok ($agent->get("$url/$file", "GET $url/$file"));
        is ($agent->{'status'}, 200, "Loaded $file");
        ok( $agent->{'content'} =~ /Logout/i, "Found a logout link on $file ");
        ok( $agent->{'content'} !~ /Not logged in/i, "Still logged in for  $file");
        ok( $agent->{'content'} !~ /System error/i, "Didn't get a Mason compilation error on $file");
        
}

# }}}

1;
