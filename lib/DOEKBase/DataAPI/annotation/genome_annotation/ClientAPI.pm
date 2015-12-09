# Data API for Taxon entities.  This API provides methods for traversing
# taxonomic parent/child relationships, and accessing information such as
# NCBI taxonomic id, scientific name, scientific lineage, etc.

require 5.6.0;
use strict;
use warnings;

use Thrift;
use Thrift::BinaryProtocol;
use Thrift::HttpClient;
use Thrift::BufferedTransport;

use DOEKBase::DataAPI::annotation::genome_annotation::thrift_service;
use DOEKBase::DataAPI::annotation::genome_annotation::Types;

package DOEKBase::DataAPI::annotation::genome_annotation::ClientAPI;

use Try::Tiny;
use Carp;
use Data::Dumper;

sub new {
  my $classname = shift;
  my $self      = {};
  my $vals      = shift || {};

  foreach my $arg ('url','ref')
  {
    confess "Need to provide a $arg" unless $vals->{$arg};
  }

  my $transport = new Thrift::HttpClient($vals->{'url'});
  # the default timeout is too short
  $transport->setSendTimeout(30000);
  my $protocol  = new Thrift::BinaryProtocol($transport);
  my $client    = new DOEKBase::DataAPI::annotation::genome_annotation::thrift_serviceClient($protocol);

  $transport->open();

  $self->{'client'} = $client;
  $self->{'token'} = $vals->{'token'};
  $self->{'ref'} = $vals->{'ref'};

  return bless($self,$classname);
  
}

my @functions = qw(
get_taxon
get_assembly
get_feature_types
get_feature_type_descriptions
get_feature_type_counts
get_features
get_proteins
get_feature_locations
get_feature_dna
get_feature_functions
get_feature_aliases
get_feature_publications
get_mrna_by_cds
get_cds_by_mrna
get_gene_by_cds
get_gene_by_mrna
get_cds_by_gene
get_mrna_by_gene
);

# Some methods can not be generated
# get_feature_ids

foreach my $function (@functions)
{
  no strict 'refs';
  *$function = sub {
    my $self=shift;

    my @args=@_;

    my $result = try {
      $self->{'client'}->$function($self->{'token'},$self->{'ref'}, @args);
    } catch {
      no warnings 'uninitialized';
      confess "$_ Exception thrown by $function: code " . $_->{'code'} . ' message ' . $_->{'message'};
    };

    return $result;
  };
}

# Custom methods, can not be generated

sub get_feature_ids {
    my $self=shift;

    my %args=@_;

#    print Dumper(@args);

    my $converted_filters = DOEKBase::DataAPI::annotation::genome_annotation::Feature_id_filters->new();
    foreach my $filter (keys %{$args{'filters'}})
    {
        $converted_filters->{$filter}=$args{'filters'}{$filter};
    }
    if ($args{'filters'}{'region_list'})
    {
        my @regions = map { DOEKBase::DataAPI::annotation::genome_annotation::Region->new($_) } @{$args{'filters'}{'region_list'}};
        $converted_filters->{'region_list'} = \@regions;
    }

    my $group_by = $args{'group_by'} || 'type';

    my $result = try {
      $self->{'client'}->get_feature_ids($self->{'token'},$self->{'ref'},$converted_filters,$group_by);
    } catch {
      no warnings 'uninitialized';
      no strict 'refs';
      confess "$_ Exception thrown by get_feature_ids: code " . $_->{'code'} . ' message ' . $_->{'message'};
    };

    # strip out extraneous group_by keys
    my $final_result = {};
    $final_result->{"by_$group_by"} = $result->{"by_$group_by"};

    return $final_result;
  }

1;
