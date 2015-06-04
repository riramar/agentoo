package Talk;

use strict;
use warnings;
use POSIX qw(strftime);

BEGIN {
	use Exporter   ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

#	$VERSION     = 1.00;
	@ISA	 = qw(Exporter);
	@EXPORT      = qw(&talks);
#	%EXPORT_TAGS = ( );
#	@EXPORT_OK   = qw();
}
#our @EXPORT_OK;

END { }

sub talks {
	my (@args) = @_;

### Talks ###
	if ( $args[1] =~ /^(hi|hello|oi|ae|oie|eae|blz|fmz|falae|certo|ola)$/i ) { ### HI
		return random_hi();
	} elsif ( $args[1] =~ /^(bye|see\syou|tchau|xau|falo[uw]|fui|vazei)$/i ) { ### BYE
		return random_bye();		
	} elsif ( defined $args[2] and "$args[1] $args[2]" =~ /^(bom|boa)\s(dia|tarde|noite)$/i ) { ### BOM/BOA DIA/TARDE/NOITE
		return bdtn($1, $2);

	} else {
		return random_msg();
	}
}

sub random_msg {
	my @msg = (
		"hã?",
		"desculpa, sou um bot e não sei do que você está falando",
		"posso ajudar em algo?",
		"dinovo...",
		"mais uma vez...",
		"você ainda não notou?",
		"hein?",
		"da pra parar?",
	);
    return $msg[ rand scalar @msg ];
}

sub random_hi {
	my @hi = ("hi", "hello", "oi", "ae", "oie", "eae", "blz", "fmz", "falae", "certo", "ola");
    return $hi[ rand scalar @hi ];
}

sub random_bye {
	my @bye = ("bye", "see you", "tchau", "xau", "falou", "falow");
    return $bye[ rand scalar @bye ];
}

sub bdtn {
	my ( $b, $dtn ) = ( @_[0 .. 1] );
	my $hour = strftime "%H", localtime;

	if ( $hour >= 6 and $hour <= 11) {
		return "bom dia";
	} elsif ( $hour >= 12 and $hour <= 17 ) {
		return "boa tarde";
	} elsif ( $hour >= 18 and $hour <= 23 ) {
		return "boa noite";
	} else {
		return "Vai durmir! Isso são horas?";
	}
}

1;
