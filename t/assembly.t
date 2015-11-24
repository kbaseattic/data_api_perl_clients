#!perl -T

use Test::More;

plan skip_all => 'not ready yet';
exit(0);

use DOEKBase::DataAPI::sequence::assembly::ClientAPI;

my $url='http://localhost:9102';
my $token=$ENV{'KB_AUTH_TOKEN'};
my $ref='PrototypeReferenceGenomes/kb|g.166819_assembly';

my $api = DOEKBase::DataAPI::sequence::assembly::ClientAPI->new({url=>$url,token=>$token,ref=>$ref});

my @functions = qw(
get_assembly_id
get_genome_annotations
get_external_source_info
get_stats
get_number_contigs
get_gc_content
get_dna_size
get_contig_ids
get_contig_lengths
get_contig_gc_content
get_contigs
);

plan tests => scalar(@functions);

foreach my $function (@functions)
{
#    my $start_time=time();
    ok($result = $api->$function() );
#    my $elapsed_time=time()-$start_time;
#    warn Dumper($result);
#    warn "Got and parsed data from $function in $elapsed_time seconds";
}

