#!/usr/bin/perl -W

use strict;
use warnings;
use Cwd;
use POE;
use POE::Component::IRC::State;
use POE::Component::IRC::Plugin::Logger;
use POE::Component::IRC::Plugin::Connector;
use Gentoo;
$| = 1;

my $botpath = getcwd;
our $botver = "0.8";
our $botnick = "Agentoo";
our $logdir = "$botpath/logs/";
my $username = "Agentoo";
my $ircname	= "Agentoo Bot";
my $server = "irc.freenode.net";
my $port = "6667";
my $botpass	= "";
my @channels = ("#Agentoo", "#gentoo-br");
my $botmaster = "Agent_Smith";
my @botbosses = ( "Agent_Smith", "Agent_Out" );
my @cmdmasters = ( "addboss", "delboss", "shutdown", "reload" );
my @cmdbosses = ( "join", "part" );

my $irc = POE::Component::IRC::State->spawn(
	Nick	 => $botnick,
	Username => $username,
	Ircname  => $ircname,
	Server   => $server,
	Port     => $port,
	Password => $botpass,
#	Debug        => 1,
#	plugin_debug => 1,
) or die "Could not create an irc instance: $!.";
	
POE::Session->create(
	package_states => [
		main => [ qw(_start irc_001 irc_join irc_msg irc_public) ]
	],
#	heap => { irc => $irc },
 );

$poe_kernel->run();
exit 0;

sub _default {
	my ($event, $args) = @_[ARG0 .. $#_];
	my @output = ( "$event: " );

	for my $arg (@$args) {
	    if ( ref $arg eq 'ARRAY' ) {
		   push( @output, '[' . join(' ,', @$arg ) . ']' );
	    }
	    else {
		   push ( @output, "'$arg'" );
	    }
	}
	print join ' ', @output, "\n";
	return 0;
}

sub _start {
#	my $heap = $_[HEAP];
#	my $irc = $heap->{irc};
	
	$irc->plugin_add('Logger', POE::Component::IRC::Plugin::Logger->new(
		Path    => "$logdir",
		Sort_by_date => 1,
	));
	$irc->plugin_add('Connector', POE::Component::IRC::Plugin::Connector->new( ));

	$irc->yield(register => "all");
	$irc->yield(connect => { });
	return;
}

sub irc_001 {
#	my $sender = $_[SENDER];
#	my $irc = $sender->get_heap();

	print "Connected to ", $irc->server_name(), ".\n";
	$irc->yield( join => $_ ) for @channels;
	return;
}

sub irc_join {
	my $nick = (split /!/, $_[ARG0])[0];
	my $channel = $_[ARG1];
#	my $irc = $_[SENDER]->get_heap();
	
	if ($nick eq $irc->nick_name()) {
		$irc->yield(privmsg => $channel, "I'm in!");
	}
	return;
}
sub irc_msg {
	my ($who, $me, $text, $identified) = @_[ARG0 .. ARG3];
	my $nick = ( split /!/, $who )[0];
	
	if ($text =~ /^help/){
		$irc->yield( privmsg => $nick, "Hi, I'm $botnick bot version $botver. Do you want my help? Type help for me in any channel and you will know." );
	}
	return;
}

sub irc_public {
#	my ($sender, $who, $where, $text) = @_[SENDER, ARG0 .. ARG2];
	my ($who, $where, $text, $identified) = @_[ARG0 .. ARG3];
	my $nick = ( split /!/, $who )[0];
	my $channel = $where->[0];
	my @args = split / +/, $text;
	my @msgs = ();
	my $msg = "";

	if ($args[0] =~ /^$botnick/ and defined $args[1]){
		my $cmdtype = check_cmd($args[1]);
		my $nicktype = check_nick($nick);

		if ($cmdtype eq "MASTER" and $nicktype ne "MASTER") {
			$irc->yield( privmsg => $channel, "$nick: Should I know you?" ); 

		} elsif ($cmdtype eq "MASTER" and $nicktype eq "MASTER" and $identified == 0) {
			$irc->yield( privmsg => $channel, "$nick: Are you sure that you are my Master?" );
			
		} elsif ($cmdtype eq "MASTER" and $nicktype eq "MASTER" and $identified == 1) {
			if ( $args[1] eq "addboss" and defined $args[2] ) { ### ADDBOSS
					push @botbosses, $args[2];
				$irc->yield( privmsg => $channel, "$nick: Boss $args[2] added." );
				$irc->yield( privmsg => $args[2], "Now you are my boss as well." );
			} elsif ( $args[1] eq "delboss" and defined $args[2] ) { ### DELBOSS
				my $boss = "";
				my $iboss = 0;
				foreach $boss ( @botbosses ) {
					if ( $boss eq $args[2] ) {
						splice @botbosses, $iboss, 1;
						$irc->yield( privmsg => $channel, "$nick: Boss $args[2] deleted." );
						$irc->yield( privmsg => $args[2], "Now you are not my boss anymore." );
					}
					$iboss++;
				}
			} elsif ( $args[1] eq "shutdown" ) { ### SHUTDOWN
				$irc->yield( shutdown => $args[2] );
			} elsif ( $args[1] eq "reload" ) { ### RELOAD
				exec ('/usr/bin/perl', $0);
			}

		} elsif ($cmdtype eq "BOSS" and $nicktype eq "OTHER") {
			$irc->yield( privmsg => $channel, "$nick: Please talk to $botmaster." );
			
		} elsif ($cmdtype eq "BOSS" and $nicktype ne "OTHER" and $identified == 0) {
			$irc->yield( privmsg => $channel, "$nick: You need to be identified to execute this command." );

		} elsif ($cmdtype eq "BOSS" and $nicktype ne "OTHER" and $identified == 1) {
			if ( $args[1] eq "join" and defined $args[2] ) { ### JOIN
				if ( $args[2] =~ /^[^\#]/ ) { $args[2] = "\#$args[2]"; }
				$irc->yield( join => $args[2] );
			} elsif ( $args[1] eq "part" and defined $args[2] ) { ### PART
				if ( $args[2] =~ /^[^\#]/ ) { $args[2] = "\#$args[2]"; }
				$irc->yield( part => $args[2] );
			}

		} else {
			@msgs = functionalits (@args);
			if (defined $msgs[0]) {
				foreach $msg (@msgs) {
					if  ( $args[1] =~ /^log$/i and defined $args[2] and defined $args[3] ) {
						$irc->yield( privmsg => $nick, $msg );
					} else {
					 	$irc->yield( privmsg => $channel, "$nick: $msg" );
					}
				}
			}
		}
	$cmdtype = "";
	$nicktype = "";

	} elsif ($args[0] =~ /^[^($botnick)]/ and $text=~ /$botnick/){ # Talking about me
		$irc->yield(ctcp => $channel => "ACTION ¬¬ $nick");
	}
	return;
}

sub check_cmd {
	my $cmd = shift;

	foreach my $cmdmaster ( @cmdmasters ) {
		if ( $cmd eq $cmdmaster ) {
			return "MASTER";
		}
	}	
	foreach my $cmdboss ( @cmdbosses ) {
		if ( $cmd eq $cmdboss ) {
			return "BOSS";
		}
	}
	return "OTHER";
}

sub check_nick {
	my $nick = shift;

	if ( $nick eq $botmaster ) {
		return "MASTER";
	}

	foreach my $nickboss ( @botbosses ) {
		if ( $nick eq $nickboss ) {
			return "BOSS";
		}
	}
return "OTHER";
}
