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
  # this is excessive (5min) but at least we'll get data back
  $transport->setSendTimeout(300000);
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

    my $final_result = {};

    foreach my $group_key (qw(by_type by_function by_alias))
    {
        foreach my $type (keys %{$result->{$group_key}})
        {
            push @{$final_result->{$group_key}{$type}}, map { [ $_->feature_type(),$_->feature_id() ] } @{$result->{$group_key}{$type}};
        }
    }

# taken from python api, will need to translate
# by_region won't work yet, its structure is different from the others
# there must be a nicer way to do this
#        for contig in result.by_region.keys():
#            output['by_region'][contig] = dict()
#            for strand in result.by_region[contig]:
#                output['by_region'][contig][strand] = dict()
#                for region in result.by_region[contig][strand]:
#                    output['by_region'][contig][strand][region] = list()
#                    for featuretuple in result.by_region[contig][strand][region]:
#                        output['by_region'][contig][strand][region].append( (featuretuple.feature_type,featuretuple.feature_id) )

    # only return relevant group_by key
    return {"by_$group_by",$final_result->{"by_$group_by"} };

  }

sub get_features {
    my $self=shift;

    my @args=@_;

    my @feature_tuples=();
    foreach my $tuple (@{$args[0]})
    {
        push @feature_tuples, DOEKBase::DataAPI::annotation::genome_annotation::Feature_tuple->new({feature_type=>$tuple->[0],feature_id=>$tuple->[1]});
    }
    
    # need to make sure to pass right arguments; can not pass an empty list
    my @arguments = ();
    @arguments = (\@feature_tuples) if (scalar(@feature_tuples)>0);

    my $result = try {
#      $self->{'client'}->get_features($self->{'token'},$self->{'ref'},\@feature_tuples);
      $self->{'client'}->get_features($self->{'token'},$self->{'ref'},@arguments);
    } catch {
      no warnings 'uninitialized';
      no strict 'refs';
      confess "$_ Exception thrown by get_feature_ids: code " . $_->{'code'} . ' message ' . $_->{'message'};
    };

    return $result;
}

1;
