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

sub get_history {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_history($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_provenance {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_provenance($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_id {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_id($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_name {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_name($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_version {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_version($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_genetic_code {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_genetic_code($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_aliases {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_aliases($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_domain {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_domain($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_kingdom {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_kingdom($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_taxonomic_id {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_taxonomic_id($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_scientific_lineage {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_scientific_lineage($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}

sub get_genome_annotations {
  my $self=shift;

  my $result = try {
    $self->{'client'}->get_genome_annotations($self->{'token'},$self->{'ref'});
  } catch {
    confess 'Exception thrown: code ' . $_->{'code'} . ' message ' . $_->{'message'};
  };

  return $result;
}



1;
