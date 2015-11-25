#!perl -T

use Test::More;
use Test::Exception;

#plan skip_all => 'not ready yet';
#exit(0);

use DOEKBase::DataAPI::taxonomy::taxon::ClientAPI;

my $url='http://localhost:9101';
my $token=$ENV{'KB_AUTH_TOKEN'};
my $ref='ReferenceTaxons/242159_taxon';
my $badref='ReferenceTaxons/000000_taxon';

my $api = DOEKBase::DataAPI::taxonomy::taxon::ClientAPI->new({url=>$url,token=>$token,ref=>$ref});

my @functions = qw(
get_info
get_history
get_provenance
get_id
get_name
get_version
get_genetic_code
get_aliases
get_domain
get_kingdom
get_taxonomic_id
get_scientific_lineage
get_scientific_name
get_genome_annotations
get_parent
get_children
);


plan tests => scalar(@functions);

foreach my $function (@functions)
{
    ok($result = $api->$function(), "$function goodref" );
}

