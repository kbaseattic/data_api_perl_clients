#!perl -T

use Test::More;
use Test::Exception;

#plan skip_all => 'not ready yet';
#exit(0);

use DOEKBase::DataAPI::annotation::genome_annotation::ClientAPI;

my $url='http://localhost:9101';
my $token=$ENV{'KB_AUTH_TOKEN'};
my $ref='ReferenceTaxons/242159_taxon';
my $badref='ReferenceTaxons/000000_taxon';

my @functions = qw(
);

plan tests => 2 * (scalar(@functions) + 1);

my $api = new_ok(DOEKBase::DataAPI::annotation::genome_annotation::ClientAPI=>[{url=>$url,token=>$token,ref=>$ref}]);

foreach my $function (@functions)
{
    ok($result = $api->$function(), "$function goodref" );
}

my $badapi = new_ok(DOEKBase::DataAPI::annotation::genome_annotation::ClientAPI=>[{url=>$url,token=>$token,ref=>$badref}]);

foreach my $function (@functions)
{
    dies_ok { $result = $badapi->$function() } "$function badref" ;
}

