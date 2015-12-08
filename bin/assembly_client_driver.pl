#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
use Time::HiRes qw( time );

# Local
#use sequence::assembly::ClientAPI;
use DOEKBase::DataAPI::sequence::assembly::ClientAPI;

sub test_client {
    my ($url,$token,$ref) = @_;
    warn "Using URL $url and reference $ref";
    my $api = DOEKBase::DataAPI::sequence::assembly::ClientAPI->new({url=>$url,token=>$token,ref=>$ref});

    warn "Getting data..";

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

    foreach my $function (@functions)
    {
        my $start_time=time();
        my $result = $api->$function();
        my $elapsed_time=time()-$start_time;
        warn Dumper($result);
        warn "Got and parsed data from $function in $elapsed_time seconds";
    }

}

my $url='https://ci.kbase.us/services/data/assembly';
my $token=$ENV{'KB_AUTH_TOKEN'};
my $ref='ReferenceGenomeAnnotations/kb|g.166819_assembly';

GetOptions (
    'url=s' => \$url,
    'token=s' => \$token,
    'ref=s' => \$ref,
);

test_client($url,$token,$ref);

