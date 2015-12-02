#!perl -T

use Test::More;
use Test::Exception;

#plan skip_all => 'not ready yet';
#exit(0);

use DOEKBase::DataAPI::annotation::genome_annotation::ClientAPI;

my $url='http://localhost:9103';
my $token=$ENV{'KB_AUTH_TOKEN'};
my $ref='ReferenceGenomeAnnotations/kb|g.166819';
my $badref='ReferenceGenomeAnnotations/kb|g.000000';

my @functions = qw(
get_taxon
get_assembly
get_feature_types
get_feature_type_descriptions
get_feature_type_counts
get_proteins
get_feature_ids
get_features
get_feature_locations
get_feature_dna
get_feature_functions
get_feature_aliases
get_feature_publications
);

# not ready yet
#get_cds_by_mrna
#get_mrna_by_cds
#get_gene_by_cds
#get_gene_by_mrna
#get_cds_by_gene
#get_mrna_by_gene

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

