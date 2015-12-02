# Data API for Assembly entities.  This API provides methods for retrieving
# summary information such as GC content, total length, external source information
# as well as methods for retrieving individual contig sequences and gathering contig lengths and contig GC.

require 5.6.0;
use strict;
use warnings;

use Thrift;
use Thrift::BinaryProtocol;
use Thrift::HttpClient;
use Thrift::BufferedTransport;

use DOEKBase::DataAPI::sequence::assembly::thrift_service;
use DOEKBase::DataAPI::sequence::assembly::Types;

package DOEKBase::DataAPI::sequence::assembly::ClientAPI;
use Try::Tiny;
use Carp;

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
  my $client    = new DOEKBase::DataAPI::sequence::assembly::thrift_serviceClient($protocol);

  $transport->open();

  $self->{'client'} = $client;
  $self->{'token'} = $vals->{'token'};
  $self->{'ref'} = $vals->{'ref'};

  return bless($self,$classname);
  
}

# cheat: use function generator
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
  no strict 'refs';
  *$function = sub {
    my $self=shift;

    my @args=@_;

    my $result = try {
      $self->{'client'}->$function($self->{'token'},$self->{'ref'}, @args);
    } catch {
      no warnings 'uninitialized';
      confess "Exception thrown by $function: code " . $_->{'code'} . ' message ' . $_->{'message'};
    };

    return $result;
  };
}

1;
