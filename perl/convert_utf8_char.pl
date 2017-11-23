#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my %entity_table = _make_entity_table();

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub escape_data {
    my $self  = shift;
    my @values = @_;

    for my $value (@values) {
        $value =~ s/(['",])/\\$1/g;
    }
    if (wantarray()) {
        return @values;
    }
    else {
        return join '', @values;
    }

    return;

}

sub trim {
    my $self   = shift;
    my @values = @_;
    for my $value (@values) {
        $value =~ s{ [\s　]+ \z }{}xms;
        $value =~ s{ [\t\r\n]   }{}xmsg;
    }
    if (wantarray()) {
        return @values;
    }
    else {
        return join '', @values;
    }
}


sub escape_entity {
    my $self = shift;
    my $str  = shift;
    return '' if !(defined $str);

    $str =~ s{;}{}xmsg;

    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/"/&quot;/g;
    $str =~ s/'/&#39;/g;

    return $str;
}

sub convert_utf8_char {
    my $self   = shift;
    my $input  = shift;
    my $output = q{};

    return $output unless $input;

    my $length = length $input;

    #positionのリセット
    pos $input = 0;

    CONV:
    while (pos $input < $length){
        #参照が見つかったら変換 (&omul; &#246; などにマッチ)
        if ($input =~ m{ \G ( & \#? [a-zA-Z0-9]{3,8}? ; ) }gcxms) {
            if (exists $entity_table{$1}) {
                my $name = $entity_table{$1};
                my $code = charnames::vianame($name);
                $output .= ($code) ? chr($code) : $1;
            }
            else {
                $output .= $1;
            }
        }
        #次のアンパサンドが出現するまでスキップ
        elsif ($input =~ m{ \G (&? [^&]*) }gcxms) {
            $output  .= $1;
        }
        #ここには来ない(はず)
        else {
            #文字列を１つ進める(念のため無限ループ回避)
            pos $input += 1;
        }
    }

    return $output;
}

sub _make_entity_table {
    my %hash;
    my @chg_chars = @{_chg_char_data()};
    for my $line (@chg_chars) {
        my ($uni_name, $entity, $code) = split /\t/, $line;
        $hash{$entity} = $hash{$code}  = $uni_name;
    }

    return %hash;
}

    # Unicode の文字名は perl5/??/unicore/ 以下に実際のデータ群がある
sub _chg_char_data {
    my $chg_char = qq|NO-BREAK SPACE	&#160;	&nbsp;
INVERTED EXCLAMATION MARK	&#161;	&iexcl;
CENT SIGN	&#162;	&cent;
POUND SIGN	&#163;	&pound;
CURRENCY SIGN	&#164;	&curren;
YEN SIGN	&#165;	&yen;
BROKEN BAR	&#166;	&brvbar;
SECTION SIGN	&#167;	&sect;
DIAERESIS	&#168;	&uml;
COPYRIGHT SIGN	&#169;	&copy;
FEMININE ORDINAL INDICATOR	&#170;	&ordf;
LEFT-POINTING DOUBLE ANGLE QUOTATION MARK	&#171;	&laquo;
NOT SIGN	&#172;	&not;
SOFT HYPHEN	&#173;	&shy;
REGISTERED SIGN	&#174;	&reg;
MACRON	&#175;	&macr;
DEGREE SIGN	&#176;	&deg;
PLUS-MINUS SIGN	&#177;	&plusmn;
SUPERSCRIPT TWO	&#178;	&sup2;
SUPERSCRIPT THREE	&#179;	&sup3;
ACUTE ACCENT	&#180;	&acute;
MICRO SIGN	&#181;	&micro;
PILCROW SIGN	&#182;	&para;
MIDDLE DOT	&#183;	&middot;
CEDILLA	&#184;	&cedil;
SUPERSCRIPT ONE	&#185;	&sup1;
MASCULINE ORDINAL INDICATOR	&#186;	&ordm;
RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK	&#187;	&raquo;
VULGAR FRACTION ONE QUARTER	&#188;	&frac14;
VULGAR FRACTION ONE HALF	&#189;	&frac12;
VULGAR FRACTION THREE QUARTERS	&#190;	&frac34;
INVERTED QUESTION MARK	&#191;	&iquest;
LATIN CAPITAL LETTER A WITH GRAVE	&#192;	&Agrave;
LATIN CAPITAL LETTER A WITH ACUTE	&#193;	&Aacute;
LATIN CAPITAL LETTER A WITH CIRCUMFLEX	&#194;	&Acirc;
LATIN CAPITAL LETTER A WITH TILDE	&#195;	&Atilde;
LATIN CAPITAL LETTER A WITH DIAERESIS	&#196;	&Auml;
LATIN CAPITAL LETTER A WITH RING ABOVE	&#197;	&Aring;
LATIN CAPITAL LETTER AE	&#198;	&AElig;
LATIN CAPITAL LETTER C WITH CEDILLA	&#199;	&Ccedil;
LATIN CAPITAL LETTER E WITH GRAVE	&#200;	&Egrave;
LATIN CAPITAL LETTER E WITH ACUTE	&#201;	&Eacute;
LATIN CAPITAL LETTER E WITH CIRCUMFLEX	&#202;	&Ecirc;
LATIN CAPITAL LETTER E WITH DIAERESIS	&#203;	&Euml;
LATIN CAPITAL LETTER I WITH GRAVE	&#204;	&Igrave;
LATIN CAPITAL LETTER I WITH ACUTE	&#205;	&Iacute;
LATIN CAPITAL LETTER I WITH CIRCUMFLEX	&#206;	&Icirc;
LATIN CAPITAL LETTER I WITH DIAERESIS	&#207;	&Iuml;
LATIN CAPITAL LETTER ETH	&#208;	&ETH;
LATIN CAPITAL LETTER N WITH TILDE	&#209;	&Ntilde;
LATIN CAPITAL LETTER O WITH GRAVE	&#210;	&Ograve;
LATIN CAPITAL LETTER O WITH ACUTE	&#211;	&Oacute;
LATIN CAPITAL LETTER O WITH CIRCUMFLEX	&#212;	&Ocirc;
LATIN CAPITAL LETTER O WITH TILDE	&#213;	&Otilde;
LATIN CAPITAL LETTER O WITH DIAERESIS	&#214;	&Ouml;
MULTIPLICATION SIGN	&#215;	&times;
LATIN CAPITAL LETTER O WITH STROKE	&#216;	&Oslash;
LATIN CAPITAL LETTER U WITH GRAVE	&#217;	&Ugrave;
LATIN CAPITAL LETTER U WITH ACUTE	&#218;	&Uacute;
LATIN CAPITAL LETTER U WITH CIRCUMFLEX	&#219;	&Ucirc;
LATIN CAPITAL LETTER U WITH DIAERESIS	&#220;	&Uuml;
LATIN CAPITAL LETTER Y WITH ACUTE	&#221;	&Yacute;
LATIN CAPITAL LETTER THORN	&#222;	&THORN;
LATIN SMALL LETTER SHARP S	&#223;	&szlig;
LATIN SMALL LETTER A WITH GRAVE	&#224;	&agrave;
LATIN SMALL LETTER A WITH ACUTE	&#225;	&aacute;
LATIN SMALL LETTER A WITH CIRCUMFLEX	&#226;	&acirc;
LATIN SMALL LETTER A WITH TILDE	&#227;	&atilde;
LATIN SMALL LETTER A WITH DIAERESIS	&#228;	&auml;
LATIN SMALL LETTER A WITH RING ABOVE	&#229;	&aring;
LATIN SMALL LETTER AE	&#230;	&aelig;
LATIN SMALL LETTER C WITH CEDILLA	&#231;	&ccedil;
LATIN SMALL LETTER E WITH GRAVE	&#232;	&egrave;
LATIN SMALL LETTER E WITH ACUTE	&#233;	&eacute;
LATIN SMALL LETTER E WITH CIRCUMFLEX	&#234;	&ecirc;
LATIN SMALL LETTER E WITH DIAERESIS	&#235;	&euml;
LATIN SMALL LETTER I WITH GRAVE	&#236;	&igrave;
LATIN SMALL LETTER I WITH ACUTE	&#237;	&iacute;
LATIN SMALL LETTER I WITH CIRCUMFLEX	&#238;	&icirc;
LATIN SMALL LETTER I WITH DIAERESIS	&#239;	&iuml;
LATIN SMALL LETTER ETH	&#240;	&eth;
LATIN SMALL LETTER N WITH TILDE	&#241;	&ntilde;
LATIN SMALL LETTER O WITH GRAVE	&#242;	&ograve;
LATIN SMALL LETTER O WITH ACUTE	&#243;	&oacute;
LATIN SMALL LETTER O WITH CIRCUMFLEX	&#244;	&ocirc;
LATIN SMALL LETTER O WITH TILDE	&#245;	&otilde;
LATIN SMALL LETTER O WITH DIAERESIS	&#246;	&ouml;
DIVISION SIGN	&#247;	&divide;
LATIN SMALL LETTER O WITH STROKE	&#248;	&oslash;
LATIN SMALL LETTER U WITH GRAVE	&#249;	&ugrave;
LATIN SMALL LETTER U WITH ACUTE	&#250;	&uacute;
LATIN SMALL LETTER U WITH CIRCUMFLEX	&#251;	&ucirc;
LATIN SMALL LETTER U WITH DIAERESIS	&#252;	&uuml;
LATIN SMALL LETTER Y WITH ACUTE	&#253;	&yacute;
LATIN SMALL LETTER THORN	&#254;	&thorn;
LATIN SMALL LETTER Y WITH DIAERESIS	&#255;	&yuml;
LATIN CAPITAL LIGATURE OE	&#338;	&OElig;
LATIN SMALL LIGATURE OE	&#339;	&oelig;
LATIN CAPITAL LETTER S WITH CARON	&#352;	&Scaron;
LATIN SMALL LETTER S WITH CARON	&#353;	&scaron;
LLATIN CAPITAL LETTER Y WITH DIAERESIS	&#376;	&Yuml;
MODIFIER LETTER CIRCUMFLEX ACCENT	&#710;	&circ;
SMALL TILDE	&#732;	&tilde;
LATIN SMALL F WITH HOOK	&#402;	&fnof;
GREEK CAPITAL LETTER ALPHA	&#913;	&Alpha;
GREEK CAPITAL LETTER BETA	&#914;	&Beta;
GREEK CAPITAL LETTER GAMMA	&#915;	&Gamma;
GREEK CAPITAL LETTER DELTA	&#916;	&Delta;
GREEK CAPITAL LETTER EPSILON	&#917;	&Epsilon;
GREEK CAPITAL LETTER ZETA	&#918;	&Zeta;
GREEK CAPITAL LETTER ETA	&#919;	&Eta;
GREEK CAPITAL LETTER THETA	&#920;	&Theta;
GREEK CAPITAL LETTER IOTA	&#921;	&Iota;
GREEK CAPITAL LETTER KAPPA	&#922;	&Kappa;
GREEK CAPITAL LETTER LAMBDA	&#923;	&Lambda;
GREEK CAPITAL LETTER MU	&#924;	&Mu;
GREEK CAPITAL LETTER NU	&#925;	&Nu;
GREEK CAPITAL LETTER XI	&#926;	&Xi;
GREEK CAPITAL LETTER OMICRON	&#927;	&Omicron;
GREEK CAPITAL LETTER PI	&#928;	&Pi;
GREEK CAPITAL LETTER RHO	&#929;	&Rho;
GREEK CAPITAL LETTER SIGMA	&#931;	&Sigma;
GREEK CAPITAL LETTER KAPPA	&#932;	&Tau;
GREEK CAPITAL LETTER UPSILON	&#933;	&Upsilon;
GREEK CAPITAL LETTER PHI	&#934;	&Phi;
GREEK CAPITAL LETTER CHI	&#935;	&Chi;
GREEK CAPITAL LETTER PSI	&#936;	&Psi;
GREEK CAPITAL LETTER OMEGA	&#937;	&Omega;
GREEK SMALL LETTER ALPHA	&#945;	&alpha;
GREEK SMALL LETTER BETA	&#946;	&beta;
GREEK SMALL LETTER GAMMA	&#947;	&gamma;
GREEK SMALL LETTER DELTA	&#948;	&delta;
GREEK SMALL LETTER EPSILON	&#949;	&epsilon;
GREEK SMALL LETTER ZETA	&#950;	&zeta;
GREEK SMALL LETTER ETA	&#951;	&eta;
GREEK SMALL LETTER THETA	&#952;	&theta;
GREEK SMALL LETTER IOTA	&#953;	&iota;
GREEK SMALL LETTER KAPPA	&#954;	&kappa;
GREEK SMALL LETTER LAMBDA	&#955;	&lambda;
GREEK SMALL LETTER MU	&#956;	&mu;
GREEK SMALL LETTER NU	&#957;	&nu;
GREEK SMALL LETTER XI	&#958;	&xi;
GREEK SMALL LETTER OMICRON	&#959;	&omicron;
GREEK SMALL LETTER PI	&#960;	&pi;
GREEK SMALL LETTER RHO	&#961;	&rho;
GREEK SMALL LETTER FINAL SIGMA	&#962;	&sigmaf;
GREEK SMALL LETTER SIGMA	&#963;	&sigma;
GREEK SMALL LETTER KAPPA	&#964;	&tau;
GREEK SMALL LETTER UPSILON	&#965;	&upsilon;
GREEK SMALL LETTER PHI	&#966;	&phi;
GREEK SMALL LETTER CHI	&#967;	&chi;
GREEK SMALL LETTER PSI	&#968;	&psi;
GREEK SMALL LETTER OMEGA	&#969;	&omega;
GREEK SMALL LETTER THETA SYMBOL	&#977;	&thetasym;
GREEK UPSILON WITH HOOK SYMBOL	&#978;	&upsih;
GREEK PI SYMBOL	&#982;	&piv;|;

    my @chg_chars = split "\n", $chg_char;
    return \@chg_chars;

}

1;
