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

use DOEKBase::DataAPI::taxonomy::taxon::thrift_service;
use DOEKBase::DataAPI::taxonomy::taxon::Types;

package DOEKBase::DataAPI::taxonomy::taxon::ClientAPI;
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
  my $client    = new DOEKBase::DataAPI::taxonomy::taxon::thrift_serviceClient($protocol);

  $transport->open();

  $self->{'client'} = $client;
  $self->{'token'} = $vals->{'token'};
  $self->{'ref'} = $vals->{'ref'};

  return bless($self,$classname);
  
}

sub get_info {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_info($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}



1;
