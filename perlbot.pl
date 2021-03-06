#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use WWW::Telegram::BotAPI;
use Log::Log4perl qw(get_logger);

# Log4perl initialization
my $log_conf = "conf/log4perl.conf";
Log::Log4perl->init($log_conf);

# Obtain a logger instance
my $logger = get_logger();

# Get the Bot API
my $api = WWW::Telegram::BotAPI->new (
  token => ( $ENV{'TELEGRAM_TOKEN'} or die "TELEGRAM_TOKEN not defined.\n")
);

# Get the Bot
my $me = $api->getMe or die;

$logger->info("Starting ", $me->{result}{username}, ".");

# Initialization
my ($offset, $updates) = 0;

# Start polling
while (1) {

  # Get updates
  $updates = $api->getUpdates ({
    timeout => 30, # Long polling
    $offset ? (offset => $offset) : ()
  });

  # Check updates content
  unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
      warn "WARNING: getUpdates returned a false value - trying again...";
      next;
  }

  # Process each update
  for my $u (@{$updates->{result}}) {

    # Dump JSON update content
    $logger->debug("Update: ", Dumper($u));
 
    # Increment offset
    $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
  }
}
