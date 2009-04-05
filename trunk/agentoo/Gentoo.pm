package Gentoo;

use strict;
use warnings;
use Cwd;
use POSIX qw(strftime);
use Talk;
use WWW::Pastebin::PastebinCom::Create;
use REST::Google::Search;
use LWP::UserAgent;
use URI;

BEGIN {
	use Exporter   ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

#	$VERSION     = 1.00;
	@ISA	 = qw(Exporter);
	@EXPORT      = qw(&functionalits);
#	%EXPORT_TAGS = ( );
#	@EXPORT_OK   = qw();
}
#our @EXPORT_OK;

END { }

sub functionalits {
	my (@args) = @_;

### Functionalits ###	
	if ( $args[1] =~ /^ping$/i ){ ### PING
		return "pong";
		
	} elsif ( $args[1] =~ /^help$/i and ! defined $args[2] ) { ### HELP
		return "$::botnick bot version $::botver. Commands available: help, log, google, doc, wiki, find, finddesc, info, finduse, fdescuse, infouse, ebuse, useeb, dep, rdep, pdep, bug, forum, join, part, addboss, delboss, shutdown, reload. For specific help use \"help command\".";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^log$/i ) { ### HELP LOG
		return "Usage: log channel string. Search for the last 5 lines with \"string\" in the \"channel\". You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^google$/i ) { ### HELP GOOGLE
		return "Usage: doc string. Search for a website with \"string\" in google. You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^doc$/i ) { ### HELP DOC
		return "Usage: doc string. Search for a gentoo document with \"string\". You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^wiki$/i ) { ### HELP WIKI
		return "Usage: wiki string. Search for a gentoo wiki with \"string\". You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^find$/i ) { ### HELP FIND
		return "Usage: find string. Search for an ebuild with \"string\". You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^finddesc$/i ) { ### HELP FINDDESC
		return "Usage: findesc string. Search for an ebuild with \"string\" description. You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^info$/i ) { ### HELP INFO
		return "Usage: info ebuild. Information about an ebuild.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^finduse$/i ) { ### HELP FINDUSE
		return "Usage: finduse string. Search for an USE with \"string\".";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^fdescuse$/i ) { ### HELP FDESCUSE
		return "Usage: fdescuse string. Search for an USE with \"string\" in description. You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^infouse$/i ) { ### HELP INFOUSE
		return "Usage: infouse USE. Information about an USE.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^ebuse$/i ) { ### HELP EBUSE
		return "Usage: ebuse USE. Search for an ebuild that use \"USE\".";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^useeb$/i ) { ### HELP USEEB
		return "Usage: useeb ebuild. Search for an USE that is used by \"ebuild\".";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^dep$/i ) { ### HELP DEP
		return "Usage: dep ebuild. List \"ebuild\" DEPEND (http://devmanual.gentoo.org/general-concepts/dependencies/).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^rdep$/i ) { ### HELP RDEP
		return "Usage: rdep ebuild. List \"ebuild\" RDEPEND (http://devmanual.gentoo.org/general-concepts/dependencies/).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^pdep$/i ) { ### HELP PDEP
		return "Usage: pdep ebuild. List \"ebuild\" PDEPEND (http://devmanual.gentoo.org/general-concepts/dependencies/).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^bug$/i ) { ### HELP BUG
		return "Usage: bug string. Search for the last 3 bugs with string. You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^forum$/i ) { ### HELP FORUM
		return "Usage: forum string. Search for the last 3 forums with string. You can inform more than one string.";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^join$/i ) { ### HELP JOIN
		return "Usage: join channel. Join bot on the \"channel\" \(only for bosses\).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^part$/i ) { ### HELP PART
		return "Usage: part channel. Part bot from the \"channel\" \(only for bosses\).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^addboss$/i ) { ### HELP ADDBOSS
		return "Usage: addboss nick. Add \"nick\" to the bot boss list \(only for master\).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^delboss$/i ) { ### HELP DELBOSS
		return "Usage: delboss nick. Del \"nick\" from the bot boss list \(only for master\).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^shutdown$/i ) { ### HELP SHUTDOWN
		return "Usage: shutdown. Disconnect the bot from the network \(only for master\).";
	} elsif ( $args[1] =~ /^help$/i and $args[2] =~ /^reload$/i ) { ### HELP RELOAD
		return "Usage: reload. Reload the source code \(only for master\).";
		
	} elsif ( $args[1] =~ /^find$/i and defined $args[2] ) { ### FIND
		return find_ebuilds( @args );
	} elsif ( $args[1] =~ /^finddesc$/i and defined $args[2] ) { ### FINDDESC
		return find_desc_ebuilds( @args );
	} elsif ( $args[1] =~ /^info$/i and defined $args[2] ) { ### INFO
		return info_ebuild( $args[2] );
	} elsif ( $args[1] =~ /^finduse$/i and defined $args[2] ) { ### FINDUSE
		return find_use( $args[2] );
	} elsif ( $args[1] =~ /^fdescuse$/i and defined $args[2] ) { ### FDESCUSE
		return find_desc_use( @args );
	} elsif ( $args[1] =~ /^infouse$/i and defined $args[2] ) { ### INFOUSE
		return info_use( $args[2] );
	} elsif ( $args[1] =~ /^ebuse$/i and defined $args[2] ) { ### EBUSE
		return ebuild_use( $args[2] );
	} elsif ( $args[1] =~ /^useeb$/i and defined $args[2] ) { ### USEEB
		return use_ebuild( $args[2] );
	} elsif ( $args[1] =~ /^(dep|rdep|pdep)$/i and defined $args[2] ) { ### DEPS
		return ebuild_deps( $args[1], $args[2] );
	} elsif ( $args[1] =~ /^bug$/i and defined $args[2] ) { ### BUG
		return bug( @args );
	} elsif ( $args[1] =~ /^forum$/i and defined $args[2] ) { ### FORUM
		return forum( @args );
	} elsif ( $args[1] =~ /^(google|doc|wiki)$/i and defined $args[2] ) { ### GOOGLE | DOC | WIKI
		return google( @args );
	} elsif ( $args[1] =~ /^log$/i and defined $args[2] and defined $args[3] ) { ### LOG
		return find_log( @args );
		
	} else {
		return talks( @args );
	}
}

sub find_ebuilds {
	my $ebuildstr = join(' ', @_[2 .. $#_]);
	my @eix = `eix -n $ebuildstr --format "<name>"`;
	my $line = "";
	my $ebuild = "";
	my $num_ebuilds = 0;

	foreach $line ( @eix ) {
		chomp ( $line );
		if ( $line =~ /^No matches found\.$/ ) {
			return "No ebuilds with \"$ebuildstr\".";
		} elsif ( $line =~ /^Found (\d*) matches\.$/ ) {
			$num_ebuilds = $1;
		} else {
			$num_ebuilds++;
			$ebuild = "$ebuild, $line";
		}
	}
	$ebuild  = substr $ebuild, 2;
	if ( length ( $ebuild . $ebuildstr ) > 420 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => "Found $num_ebuilds ebuilds with \"$ebuildstr\": $ebuild." ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much ebuilds \($num_ebuilds\) with \"$ebuildstr\". Please take a look on $paste.";
	} else {
		return "Found $num_ebuilds ebuilds with \"$ebuildstr\": $ebuild.";
	}
}

sub find_desc_ebuilds {
	my $ebuildstr = join(' ', @_[2 .. $#_]);
	my @eix = `eix -nS $ebuildstr --format "<name>"`;
	my $line = "";
	my $ebuild = "";
	my $num_ebuilds = 0;

	foreach $line ( @eix ) {
		chomp ( $line );
		if ( $line =~ /^No matches found\.$/ ) {
			return "No ebuilds with \"$ebuildstr\" description.";
		} elsif ( $line =~ /^Found (\d*) matches\.$/ ) {
			$num_ebuilds = $1;
		} else {
			$num_ebuilds++;
			$ebuild = "$ebuild, $line";
		}
	}
	$ebuild  = substr $ebuild, 2;
	if ( length ( $ebuild . $ebuildstr ) > 420 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => "Found $num_ebuilds ebuilds description with \"$ebuildstr\".: $ebuild." ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much ebuilds \($num_ebuilds\) with \"$ebuildstr\" description. Please take a look on $paste.";
	} else {
		return "Found $num_ebuilds ebuilds with \"$ebuildstr\" description: $ebuild.";
	}
}

sub info_ebuild {
	my $ebuildstr = shift;
	my $eb = `eix -ne $ebuildstr --format "<category>/<name>: [Versions]<availableversions>. [Homepage] <homepage>. [Description] <description>."`;
	$eb =~ s/\e\[0m//g;
	$eb =~ s/\n//g; 
	$eb =~ s/ +|\t+/ /g; 
	return $eb;
}

sub find_use {
	my $usestr = shift;
	my $usefile = "/usr/portage/profiles/use.desc";
	my $use = "";
	my $uses = "";
	my $num_uses = 0;

	open( USE, $usefile ) or die "Couldn't read $usefile: $!";
	while ( <USE> ) {
		( $use ) = ( $_ =~ /^(\S*)/ );
		if ( $use =~ /$usestr/ ) {
			$num_uses++;
			$uses = "$uses, $use";
		}
	}
	close USE;
	if ( $num_uses == 0 ){
		return "No USEs with \"$usestr\".";
	}
	$uses = substr $uses,2;
	if ( length ( $uses . $usestr ) > 420 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => "Found $num_uses USEs with \"$usestr\": $uses." ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much USEs \($num_uses\) with \"$usestr\". Please take a look on $paste.";
	} else {
		return "Found $num_uses USEs with \"$usestr\": $uses.";		
	}
}

sub find_desc_use {
	my $usedescstr = join(' ', @_[2 .. $#_]);
	my $usefile = "/usr/portage/profiles/use.desc";
	my $use = "";
	my $usedesc = "";
	my $uses = "";
	my $num_uses = 0;

	open( USE, $usefile ) or die "Couldn't read $usefile: $!";
	while ( <USE> ) {
		next if /^#|^$/;
		( $use, $usedesc ) = ( $_ =~ /^(\S*)\s\-\s(.*)$/ );
		if ( $usedesc =~ /$usedescstr/i ) {
			$num_uses++;
			$uses = "$uses, $use";
		}
	}
	close USE;
	if ( $num_uses == 0 ){
		return "No USEs with \"$usedescstr\" in description.";
	}
	$uses = substr $uses,2;
	if ( length ( $uses . $usedescstr ) > 420 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => "Found $num_uses USEs with \"$usedescstr\": $uses." ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much USEs \($num_uses\) with \"$usedescstr\" in description. Please take a look on $paste.";
	} else {
		return "Found $num_uses USEs with \"$usedescstr\" in description: $uses.";		
	}
}

sub info_use {
	my $usestr = shift;
	my $usefile = "/usr/portage/profiles/use.desc";
	my $use = "";
	my $usedesc = "";
	my $description = "";

	open( USE, $usefile ) or die "Couldn't read $usefile: $!";
	while ( <USE> ) {
		( $use, $usedesc ) = ( $_ =~ /^(\S*)\s\-\s(.*)$/ );
		if ( defined $use and $use =~ /^$usestr$/ ) {
			$description = $usedesc;
		}
	 }
	 close USE;

	if ( $description eq "" ){
		return "No USE \"$usestr\" found.";
	} else {
		return "Found \"$usestr\" description: $description.";		
	}
}

sub ebuild_use {
	my $usestr = shift;
	my @eix = `eix -eU $usestr --format "<name>"`;
	my $line = "";
	my $ebuild = "";
	my $num_ebuilds = 0;

	foreach $line ( @eix ) {
		chomp ( $line );
		if ( $line =~ /^No matches found\.$/ ) {
			return "No ebuilds with \"$usestr\" USE.";
		} elsif ( $line =~ /^Found (\d*) matches\.$/ ) {
			$num_ebuilds = $1;
		} else {
			$num_ebuilds++;
			$ebuild = "$ebuild, $line";
		}
	}
	$ebuild  = substr $ebuild, 2;
	if ( length ( $ebuild . $usestr ) > 420 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => "Found $num_ebuilds ebuilds with \"$usestr\" USE: $ebuild." ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much ebuilds \($num_ebuilds\) with \"$usestr\" USE. Please take a look on $paste.";
	} else {
		return "Found $num_ebuilds ebuilds with \"$usestr\" USE: $ebuild.";
	}
}

sub use_ebuild {
	my $ebuildstr = shift;
	my @equery = `equery -C -N u $ebuildstr -a 2>&1`;
	my $line = "";
	my @ebuilds = "";
	my @uses = "";
	my @num_uses = 0;
	my $num_ebuilds = 0;
	my @alluses = "";
	my $ok_results = "";

	foreach $line ( @equery ) {
		if ( $line =~ /^\!\!\! No matching packages found for/ ) {
			return "No USEs found with ebuild \"$ebuildstr\".";
		} elsif ( $line =~ /^\[ Found these USE variables for.*?\/(\S*)/ ) {
			$num_ebuilds++;
			$ebuilds[$num_ebuilds] = $1;
		} elsif ( $line =~ /^\s.\s.\s(\S*)\s/ ) {
			$num_uses[$num_ebuilds]++;
			$uses[$num_ebuilds][$num_uses[$num_ebuilds]] = $1;
		}
	}

	for my $x ( 1 .. $num_ebuilds ) {
		$alluses[$x] = "";
		for my $y ( 1 .. $num_uses[$x] ) {
			$alluses[$x] = "$alluses[$x], $uses[$x][$y]";
		}
		( $alluses[$x] ) = ( $alluses[$x] =~ /,\s(.*)/ );
		$ok_results = "$ok_results\[$ebuilds[$x]\]: $alluses[$x]. ";
	}
	( $ok_results ) = ( $ok_results =~ /(.*)\s/ );
	if ( length ( $ok_results ) > 440 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => $ok_results ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much USEs for \"$ebuildstr\". Please take a look on $paste.";
	} else {
		return $ok_results;
	}
}

sub ebuild_deps {
	my ( $deptype, $ebuildstr ) = ( @_[0 .. 1] );
	chomp( my $eb0 = `eix -e -n $ebuildstr --format "<category>/<name> <bestshort>"` );
	$eb0 =~ s/\e\[0m//g;
	if ( $eb0 =~ /No matches found\./ ) {
		return "There is no ebuild \"$ebuildstr\".";
	}
	$deptype =~ tr/a-z/A-Z/;
	$deptype = $deptype . "END";
	my $dir = getcwd;
	my ($eb, $ebversion) = split(/ /, $eb0);
	chomp( my $dep = `$dir/scripts/auxget $eb $deptype` );
	$dep =~ s/^\s*//g;

	if ( $dep =~ /^$deptype: $/ ) {
		return	"There is no $deptype for \"$ebuildstr\".";
	}
	my $depresults = "$eb-$ebversion $dep";
	if ( length ( $depresults ) > 440 ) {
		my $paste = WWW::Pastebin::PastebinCom::Create->new ( timeout => 5, );
		$paste->paste( text => $depresults ) or $paste = "\"http://pastebin.com is out!\"";
		return "Too much $deptype" . "s  for \"$ebuildstr\". Please take a look on $paste.";
	} else {
		return $depresults;
	}
}

sub google {
	my $googlestr = join(' ', @_[2 .. $#_]);
	my $q = "";
	
	if ( $_[1] eq "google" ){
		$q = "$googlestr";
	} elsif ( $_[1] eq "doc" ){
		$q = "$googlestr site:gentoo.org/doc";
	} elsif ( $_[1] eq "wiki" ){
		$q = "$googlestr site:gentoo-wiki.com";
	}

	REST::Google::Search->http_referer('http://www.agentoo.org');
	my $doc = REST::Google::Search->new(
		q => $q,
	);

	if ( $doc->responseStatus != 200 ) {
		return "Error: $doc->responseDetails";
	} else {
		my $data = $doc->responseData;
		my $cursor = $data->cursor;
		my @results = $data->results;
		if  (defined $results[0]{titleNoFormatting}) {
			return "Title: $results[0]{titleNoFormatting}. URL: $results[0]{unescapedUrl}.";
		} else {
			return "Your search $googlestr did not match any documents.";
		}
	}
}

sub find_log {
	my $logstr = join(' ', @_[3 .. $#_]);
	$_[2] =~ tr/A-Z/a-z/;
	my $date = strftime '%F', localtime;
	my $logfile = "$::logdir$_[2]/$date.log";
	my $line = "";
	my @lines = ();
	my @matchlogs = ();
	my $numlinelogs = 5;
	
	open( LOG, $logfile ) or return "There are no logs for $_[2] channel.";
	@lines = reverse <LOG>;	
	foreach $line (@lines) {
		last if $numlinelogs == -1;
		if ( $line =~ /$logstr/ ) {
			$line =~ s/\n//g;
			if ($numlinelogs < 5) {
				push @matchlogs, $line;
			}
			$numlinelogs--;
		}
	}
	close LOG;
	
	if (!defined $matchlogs[0]) {
		return "There are no matches for $logstr in $_[2].";
	} else {
		@matchlogs = reverse @matchlogs;	
		return @matchlogs;
	}
}

sub bug {
	my $bugstr = join('+', @_[2 .. $#_]);
	my $bugstrtest = join('', @_[2 .. $#_]);
	if ( length ( $bugstrtest ) <= 3 ) {
		return "Please make a bigger string search.";
	}   
	my $numbugs = 0;
	my @bugs;
	my $bug = "";
	my $tmphtml = '/tmp/gbugs.html';
	my $ua = LWP::UserAgent->new;
	my $url = 'http://bugs.gentoo.org/buglist.cgi?quicksearch=' . $bugstr;
	my $res = $ua->get( $url, ':content_file' => $tmphtml );

	open( TMP, $tmphtml ) or return "I had problems to get the bugs.";

	foreach my $line ( <TMP> ) {
		last if $numbugs == 3;
		if ( $line =~ /<a href\="show_bug.cgi\?id\=(.*)"/ ) {
			$bug = "[BUG]: http://bugs.gentoo.org/show_bug.cgi?id\=$1.";
		}
		if ( $line =~ /<td style\="white-space: nowrap">(UNCO|NEW|ASSI|REOP|RESO|VERI|CLOS)$/ ) {
			$bug = $bug . " [STATUS]: $1."; 
		}
		if ( $line =~ /^\s{4}<td >(.*)$/ ) {
			$bug = $bug . " [SUM]: $1.";
			push @bugs, $bug;
			$numbugs++;
		}
	}
	if (!defined $bugs[0]) {
		( $bugstr ) =~ s/\+/ /g;
		return "There are no bugs with $bugstr.";
	} else {
		return @bugs;
	}
}

sub forum {
	my $forumstr = join(' ', @_[2 .. $#_]);
	my $numforums = 0;
	my @forums;
	my $forum = "";
	my $tmphtml = '/tmp/gforums.html';
	my $url = URI->new( 'http://forums.gentoo.org/search.php' );
	$url->query_form(
		'search_keywords'    => $forumstr,
		'show_results'    => 'topics',
	);
	my $ua = LWP::UserAgent->new;
	my $res = $ua->get( $url, ':content_file' => $tmphtml );

	open( TMP, $tmphtml ) or return "I had problems to get the forums.";

	foreach my $line ( <TMP> ) {
		if ( $line =~ /You cannot make another search so soon after your last; please try again in a short while/ ) {
			return "You cannot make another search so soon after your last; please try again in a short while.";
		}
		last if $numforums == 3;
		if ( $line =~ /<td class="row2"><span class="topictitle"><a href="viewtopic-t-(.*)-highlight-.*" class="topictitle">(.*)<\/a><\/span><br \/><span class="gensmall">/ ) {
			$forum = "[TOPIC]: $2. [URL]: http://forums.gentoo.org/viewtopic-t-$1.html";
		}
		if ( $line =~ /<td class="row2" align="center" valign="middle"><span class="postdetails">(.*)<\/span><\/td>$/ ) {
			$forum = $forum . " [REPLIES]: $1."; 
		}
		if ( $line =~ /<td class="row1" align="center" valign="middle"><span class="postdetails">(.*)<\/span><\/td>$/ ) {
			$forum = $forum . " [VIEWS]: $1.";
			push @forums, $forum;
			$numforums++;
		}
	}
	if (!defined $forums[0]) {
		return "There are no forums with $forumstr.";
	} else {
		return @forums;
	}
}

1;
