use strict;
use utf8;
use Encode;
use Getopt::Std;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $punctuations = q#-!"'(),./:;?[]_{}|¡«»¿‘’‚‛“”„‟‥…‹›‼、。〈〉《》「」『』【】〔〕〖〗〘〙〚〛〞〟｡｢｣､･！（），－．／：；・？［＼］＿｛｜｝#;

# コマンドライン引数
my %opt;
getopts('f:g:p' => \%opt);
my $freq = 1; $freq = $opt{'f'} if exists $opt{'f'};
my $gmin = 3;
my $gmax = 3;
($gmin, $gmax) = split /,/, $opt{'g'} if exists $opt{'g'};

my %ngsm;
my @names;
for my $input_file (@ARGV) {
	open F, "<:utf8", $input_file or die "Can't open $input_file:";
	my $input_file = decode('utf-8', $input_file);
	print STDERR $input_file, "\n";
	my ($name) = ($input_file =~ /^([^.]+)/);
	push @names, $name;	
	my $text = join '', <F>;
	$text =~ s/\x0D\x0A|\x0D|\x0A//g;
	$text =~ s/\&M(\d\d\d\d\d\d);/chr(0xEFFFF+$1)/ge;
    $text =~ s/[\s　]//g;
    $text =~ s#[\Q$punctuations\E]##g;
	#print STDERR $text;
    
    my $len = length($text);
    for (my $i = 0; $i < $len - $gmin + 1; $i++) {
    	for my $j ($gmin..$gmax) {
    		next if ($i + $j) > $len;
    		$ngsm{substr($text, $i, $j)}{$name}++;
    	}
    }
}

for my $k (sort keys %ngsm) {
	my $index = $k;
	$index =~ s/([\x{F0000}-\x{10FFFF}])/sprintf("&M%06d;", ord($1)-0xEFFFF)/ge;
	print $index, "\t(";
	for my $n (@names) {
		$ngsm{$k}{$n} = 0 unless exists $ngsm{$k}{$n};
		print ' ', $n, ':',  $ngsm{$k}{$n};
	}
	print " )\n";
}

