#!/usr/bin/perl -w

use strict;    # fun with whitespace
use open qw(:std :utf8);
use Text::Table;
use Array::Utils qw(:all);
use List::Util qw/max min sum/;
use Spreadsheet::Read qw(ReadData);


$|=1;                        # un buffer

# pirms 272136,24.05.2017,12 28 29 42 46 48 + 8 ir citi html tokeni (https://www.latloto.lv/lv/arhivs/viking-lotto/4)
# 280236,10.01.2018, 2 9 19 28 33 43 + 4  nav video, tatad ar siem tokeniem netiek apstradats

#### HOWTO RUN ############################################################################################################
# Use Internet Download Manager to get all arhive result files (3) from https://www.latloto.lv/lv/arhivs/viking-lotto/1-3
# Save all files in folder "C:\Users\agrisk\Documents\Loto\Perl\RezultatuArhivs\Vikinglotto"
# edit $izlozu_skaits - cik izlozes apstradat. Taam jaabuut ieksaa nolasiitajos .htm failos
# run from cmd prompt "C:\Users\agrisk\Documents\Loto\Perl\Vikinglotto.pl"
#
#### EDIT PARAMETERS HERE #################################################################################################
my $skaitli_diapazons = 48;   		# 48, kopejais bumbinu skaits
my $skaitli_skaits = 6;				# 6, izveleto bumbinu skaits
my $papildskaitli_diapazons = 8;    # 8, papildskaitlu diapazons
my $papildsk_skaits = 1;			# 1, papildskaitlu skaits
my $izlozu_skaits = 50;			# cik pedejas izlozes apstradat
my $izlozu_sakums = 0;				# ar kuru izlozi sakt apstradat datus. Ja visas, tad $izlozu_sakums = 0. Ja no otras, tad $izlozu_sakums = 1.
my $print_papildskaitli = 0;		# 0 - druka tikai pamatskaitlus, 1 - druka tikai papildskaitlus, 2 - druka abus
my $print_dots = 0;					# 0 - do not print dots in the DRAWINGS SINCE HIT CHART, 1 - print
my $print_lines = 0; 				# 0 - do not print vertical lines in the DRAWINGS SINCE HIT CHART, 1 - print

my $avg_sum = 147;  # average sum
my $lps = 113;  # lowest probable sum
my $hps = 181;  # highest probable sum
my $ls = 50;  # lowest sum (mod %10 must be zero)
my $hs = 200; # highest sum (mod %10 must be zero)
#################################################################################################################

my $skaitli_visi = $skaitli_skaits + $papildsk_skaits + 1;
my $getnumbers = 0;
my @row=();
my @ieteicamie_skaitli=();

open FILE, ">v.txt";
select FILE; # print will use FILE instead of STDOUT

my $datestring = localtime();
print "Script run on $datestring\n\n";


########### parse html files with drawing results


my @array_partial = ();
my $book = ReadData ('../RezultatuArhivs/Vikinglotto/viking.xls');
my @rows = Spreadsheet::Read::rows($book->[1]);
foreach my $i ($izlozu_sakums+1 .. $izlozu_skaits)
{
	last unless defined $rows[$i];
	my @r = ();
	my $str = $rows[$i][2];
	$str =~ tr/ //ds;
	push @r, ($rows[$i][0], $rows[$i][1], split /[,|\+]/, $str);
	push @array_partial, \@r;
}



##### find games out and deltas

my @array_games_out = ();
my @array_deltas = ();	# differences between numbers in a drawing
my $row_ = 0;
foreach my $r (@array_partial)
{
	my $col_deltas = 0;
	my $col = 0;
	my $prev_deltas = 0;
	foreach my $c (@$r[2..$skaitli_skaits+1])
	{
		if($col_deltas == 0)
		{
			$array_deltas[$row_][$col_deltas] = $c;
		}
		else
		{
			$array_deltas[$row_][$col_deltas] = $c - $prev_deltas;
		}
		$prev_deltas = $c;
		$col_deltas++;

		my $row2 = 0;
		my @arr2 = @array_partial[$row_+1..$#array_partial];
		my $found = 0;
		foreach my $r3 (@arr2)
		{
			#print join(",",@$r3),"\n";
			if(grep(/^$c$/, @{$r3}[2..$skaitli_skaits+1]))
			{
				#print "c = $c, row2 = $row2, row_ = $row_, col = $col\n";
				$array_games_out[$row_][$col++] = $row2;
				$found = 1;
				last;
			}
			$row2++;
		}
		if($found == 0)
		{
			$array_games_out[$row_][$col++] = ".";
		}
	}
	$row_++;
}

print "\nAnalysed ", scalar @array_partial, " lottery drawing results\n";
print "Analysis started at drawing ", $array_partial[0][0],"\n";

print "\n\n**************************** TIPS ON NUMBER SELECTION ******************************************\n";
print "Avoid combinations that have been drawn before\n";
print "Avoid betting consecutive numbers\n";
print "Avoid betting one number group (single, teens, 20s,...)\n";
print "Avoid combination 1-2-3-4-5-6\n";
print "Avoid pattern betting on slips (lines, diagonals, etc.)\n";
print "Avoid number multiples (5-10-15-20-...)\n";
print "Avoid all same last digits (3-13-23-33-...)\n";
print "Avoid low number combinations (calendar numbers: birthdays, anniversaries,...). If not, include a couple of high numbers\n";
print "Play balanced game (most probable sum)\n\n";
print "**************************** TIPS ON GROUP SELECTION ******************************************\n";
print "Even mix of odd and even numbers\n";
print "Even mix of high and low numbers\n";
print "Play adjacent numbers, average is 1.4 per game\n";
print "Study number groups\n";
print "Study games skipped\n\n";

#########################  GAMES OUT VIEW OF HISTORY


print "\nSHORT TERM TREND (5-10 games)\n\n";
print "Look for bias. If something is MUCH HIGHER or MUCH LOWER than average for 3-5 games, play opposite\n";
print "EVEN/ODD, HI/LO - look for double digit bias\n";
print "Look in the SUM TRACKING CHART for most probable sums\n";


print "\n\n******************** GAMES OUT VIEW OF HISTORY, SUMS, HI/LO, EVEN/ODD ********************\n";
print "******************** Drawing average sum: $avg_sum ********************\n\n";
print "One of the most useful charts. When shows clear pattern, can be used exclusively without any other chart to play just HOT NUMBERS\n";
print "When you see 3-4 drawings in a row with LOW SUM_GAMES_OUT and AVG_GAMES_OUT, play more Long Shot numbers\n";
print "When you see 3-4 drawings in a row with HIGH SUM_GAMES_OUT and AVG_GAMES_OUT, play all HOT numbers (numbers out less than 10 games)\n";
print "Deltas are differences between numbers in the same drawing\n\n";

my $drawings1 = 5;
my $drawings2 = 10;

my $tb_ = Text::Table->new("DRAW RESULTS","GAMES OUT  ","DELTAS","L10","SUM_GAMES_OUT", "AVG_GAMES_OUT", "SUM_DRAWING",
							 "HI/LO $drawings1", "HI/LO $drawings2", "EVEN/ODD $drawings1", "EVEN/ODD $drawings2", "DOUBLE HITS", "ADJACENT PREVIOUS HITS", "DOUBLE+ADJACENT PREV", "ADJACENT PAIRS CURRENT");
my $q = 0;
my $l10_avg = 0;
my $sum_avg = 0;
my $l10_avg_5 = 0;
my $sum_drawing_5 = 0;
my $l10_avg_10 = 0;
my $sum_drawing_10 = 0;
my $sum_drawing_20 = 0;
my $sum_drawing_50 = 0;

for my $r ( @array_partial )
{
	my $arr = $array_games_out[$q];
	my $arr_deltas = $array_deltas[$q];
	my $l10 = 0;
	my $sum = 0;
	my $doublehits = 0;
	my $adjacentprevhits = 0;
	my $adjacentcurrenthits = 0;

	for ( @$arr )
	{
		if($_ ne ".")
		{
			$l10++ if $_ < 10;
			$sum += $_;
		}
	}
		my $sum_drawing = 0;
		$sum_drawing += $_ for @$r[2..$skaitli_skaits+1];

		my @drawings_arr1 = ();
		my @drawings_arr2 = ();
		push @drawings_arr1, @$r[2..$skaitli_skaits+1];
		push @drawings_arr2, @$r[2..$skaitli_skaits+1];
		for(my $a = 1; $a < $drawings1; $a++)
		{
			my $i = $q + $a;
			last if($i > $#array_partial);
			push @drawings_arr1, @{$array_partial[$i]}[2..$skaitli_skaits+1];
		}
		for(my $a = 1; $a < $drawings2; $a++)
		{
			my $i = $q + $a;
			last if($i > $#array_partial);
			push @drawings_arr2, @{$array_partial[$i]}[2..$skaitli_skaits+1];
		}

		my ($hilo1, $evenodd1) = hilo_evenodd($drawings1, \@drawings_arr1);
		my ($hilo2, $evenodd2) = hilo_evenodd($drawings2, \@drawings_arr2);

		foreach my $n ( @$r[2..$skaitli_skaits+1] )
		{
			last if($q+1 > $#array_partial);
			if(grep(/^$n$/, @{$array_partial[$q+1]}[2..$skaitli_skaits+1]))
			{
				$doublehits++;
			}
			my $np1 = ($n+1 > $skaitli_diapazons) ? 1 : $n+1;
			my $nm1 = ($n-1 == 0) ? $skaitli_diapazons : $n-1;
			if(grep(/^$np1$/, @{$array_partial[$q+1]}[2..$skaitli_skaits+1]) || grep(/^$nm1$/, @{$array_partial[$q+1]}[2..$skaitli_skaits+1]))
			{
				$adjacentprevhits++;
			}
			if(grep(/^$np1$/, @$r[2..$skaitli_skaits+1]) || grep(/^$nm1$/, @$r[2..$skaitli_skaits+1]))
			{
				$adjacentcurrenthits++;
			}
		}

		$tb_->add("$q " . join(",",@$r), join(",",@$arr), join(",",@$arr_deltas), $l10, $sum, (sprintf "%.1f", $sum/6), $sum_drawing, $hilo1, $hilo2, $evenodd1, $evenodd2, $doublehits, $adjacentprevhits, $doublehits + $adjacentprevhits, $adjacentcurrenthits/2);
		$l10_avg += $l10;
		$sum_avg += $sum;
		$l10_avg_5 += $l10 if ($q < 5);
		$sum_drawing_5 += $sum_drawing if ($q < 5);
		$l10_avg_10 += $l10 if ($q < 10);
		$sum_drawing_10 += $sum_drawing if ($q < 10);
		$sum_drawing_20 += $sum_drawing if ($q < 20);
		$sum_drawing_50 += $sum_drawing if ($q < 50);
		$q++;
}

$l10_avg /= scalar @array_partial;	# last lines are not filled
$sum_avg /= scalar @array_partial;
$l10_avg_5 /= 5;
$l10_avg_10 /= 10;
$sum_drawing_5 /= 5;
$sum_drawing_10 /= 10;
$sum_drawing_20 /= 20;
$sum_drawing_50 /= 50;
$tb_->add("", "", "AVERAGE:", (sprintf "%.1f", $l10_avg), (sprintf "%.1f", $sum_avg), (sprintf "%.1f", $sum_avg/6), $avg_sum);
# print " " x $c2 . (sprintf "%.1f", $l10_avg) . " " x 1 . (sprintf "%.1f", $sum_avg) . " " x 11 . (sprintf "%.1f", $sum_avg/6) . " " x 10 . "$avg_sum\n";
my $str0 = " " x (($tb_->colrange(2))[0]) . "AVERAGE:";
my $stra = " " x (($tb_->colrange(3))[0] - length($str0)) . (sprintf "%.1f", $l10_avg);
my $strb = " " x (($tb_->colrange(4))[0] - length($str0) - length($stra)) . (sprintf "%.1f", $sum_avg);
my $strc = " " x (($tb_->colrange(5))[0] - length($str0) - length($stra) - length($strb)) . (sprintf "%.1f", $sum_avg/6);
my $strd = " " x (($tb_->colrange(6))[0] - length($str0) - length($stra) - length($strb) - length($strc)) . "$avg_sum\n";

my $stra_ = " " x (($tb_->colrange(3))[0] - length($str0)) . (sprintf "L10_5: %.1f", $l10_avg_5);
my $strd_ = " " x (($tb_->colrange(6))[0] - length($str0) - length($stra) - length($strb) - length($strc)) . "SUM_DRAWING_5: $sum_drawing_5\n";
print $str0 . $stra_ . " " x (length($strb) + length($strc) - 10) . $strd_ ;

$stra_ = " " x (($tb_->colrange(3))[0] - length($str0)) . (sprintf "L10_10: %.1f", $l10_avg_10);
$strd_ = " " x (($tb_->colrange(6))[0] - length($str0) - length($stra) - length($strb) - length($strc)) . "SUM_DRAWING_10(20)(50): $sum_drawing_10" . " ($sum_drawing_20)" . " ($sum_drawing_50)\n";
print $str0 . $stra_ . " " x (length($strb) + length($strc) - 10) . $strd_ . "\n";

print $str0 . $stra . $strb . $strc . $strd;
print $tb_;


#############  PRINT NUMBER OF DIFFERENT DELTAS

print "\n\n******************** NUMBER OF DIFFERENT DELTAS\n\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]) . "\n\n";
my $tb_deltas = Text::Table->new("DELTA","OCCURENCES");
my @arr_deltas_summary = ();
$arr_deltas_summary[0] = 0;
for(my $n = 1; $n <= $skaitli_diapazons; $n++)
{
	$arr_deltas_summary[$n] = 0;
	foreach my $r (@array_deltas)
	{
		if(grep(/^$n$/, @$r) and @$r[0] != $n) # ignore the first number since it is not delta
		{
			$arr_deltas_summary[$n]++;
		}
	}
	$tb_deltas->add($n, $arr_deltas_summary[$n]);
}
print $tb_deltas;



################# DRAWINGS SINCE HIT CHART


print "\n\nMEDIUM TERM TREND (50-60 games)";
print "\n\n******************** DRAWINGS SINCE HIT CHART (The most valuable, accurate, reliable chart. LOOK FOR PATTERNS.)\n";
print "******************** PERCENTAGE SYSTEM (for HOT NUMBERS only).********************\n\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $percentage_system_drawings = 10;  # 10 drawings cheked
my @arr_tmp = @array_partial[0..($percentage_system_drawings - 1)];
my @a = ();
# percentage system
for(my $i=1;$i<$skaitli_diapazons+1;$i++)
{
	my $row = 0;
	my $hit5 = 0;
	my $hit10 = 0;
	foreach my $r (@arr_tmp)
	{
		foreach my $r2 (@$r[2..$skaitli_skaits+1])
		{
			if($i == $r2)
			{
				# print "$i: $r2; ";
				if($row < 5)
				{
						$hit5 = 1;
				}
				elsif($row < 10)
				{
						$hit10 = 1;
				}
				else
				{}
			}
		}
		$row++;
	}
	if(($hit5 == 1) && ($hit10 == 1))
	{
		push @a, " v";
	}
	else
	{
		push @a, "";
	}
}

# drawings since hit
my @n = ();
foreach my $r (1..$skaitli_diapazons)
{
	push @n, sprintf("%2s", $r);
}

print "----- MAIN NUMBERS -----\n\n";
my $tb_1 = Text::Table->new("", "Percentage", "System ->", @a);
$print_papildskaitli = 0;
plotDrawResults($tb_1);

print "----- ADDITIONAL NUMBERS -----\n\n";
my $tb_2 = Text::Table->new("", "Percentage", "System ->", @a);
$print_papildskaitli = 1;
plotDrawResults($tb_2);

###############  NUMBER GROUPS BIAS TRACKER


my $number_of_drawings = 10; # ... last drawings analyzed
my $group_size = 5; # gruped by 5,6,7,8,9,10
print "\n\nSHORT TERM TREND (5-10 games)";
print "\n\n******************** NUMBER GROUPS BIAS TRACKER ********************\n\n";
print "Look for groups of 4 or more games without a winner\n";
print "\nAnalyzed $number_of_drawings last drawings\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
print "GROUPS BY $group_size\n\n";
my $tbg = Text::Table->new("GROUPS", 1..$number_of_drawings, "AVG");	# ten last drawings
my ($arraysize, @arr_groups) = getgroups($number_of_drawings, $group_size);
for(my $j = 0; $j<$arraysize; $j++)
{
	$tbg->load($arr_groups[$j]);
}
print $tbg;

$group_size = 10; # gruped by 5,6,7,8,9,10
print "\nAnalyzed $number_of_drawings last drawings\n";
print "GROUPS BY $group_size\n\n";
$tbg = Text::Table->new("GROUPS", 1..$number_of_drawings, "AVG");	# ten last drawings
($arraysize, @arr_groups) = getgroups($number_of_drawings, $group_size);
for(my $j = 0; $j<$arraysize; $j++)
{
	$tbg->load($arr_groups[$j]);
}
print $tbg;



######### SKIPS DUE BIAS TRACKER CHARTS


print "\n\nSHORT TERM TREND (5-10 games)";
print "\n\n******************** SKIPS DUE BIAS TRACKER CHARTS (Second most important chart) ********************\n";
print "\nSkips at the top are the most due.\n";
my $drawings_checked = 5;
print "\nANALYZED $drawings_checked games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb2 = Text::Table->new("Games out","In last 5","Lottery numbers");
my @arr3 = gamesout($drawings_checked);
foreach my $r (@arr3)
{
	$tb2->add($r->[0],$r->[1],$r->[2]);
}
print $tb2;

$drawings_checked = 10;
print "\nANALYZED $drawings_checked games\n";
$tb2 = Text::Table->new("Games out","In last 10","Lottery numbers");
@arr3 = gamesout($drawings_checked);
foreach my $r (@arr3)
{
	$tb2->add($r->[0],$r->[1],$r->[2]);
}
print $tb2;


############ LAST DIGIT BIAS CHART


$drawings_checked = 5;
print "\n\nSHORT TERM TREND (5-10 games)";
print "\n\n******************** LAST DIGIT BIAS CHART ********************\n\n";
print "Only if strong on other charts\n\n";
print "ANALYZED $drawings_checked games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb_d = Text::Table->new("Last digit","In last 5","Numbers");
@arr3 = lastdigitbias($drawings_checked);
foreach my $r (@arr3)
{
	$tb_d->add($r->[0],$r->[1],$r->[2]);
}
print $tb_d;

$drawings_checked = 10;
print "\nANALYZED $drawings_checked games\n";
$tb_d = Text::Table->new("Last digit","In last 10","Numbers");
@arr3 = lastdigitbias($drawings_checked);
foreach my $r (@arr3)
{
	$tb_d->add($r->[0],$r->[1],$r->[2]);
}
print $tb_d;



########### DRAWINGS BETWEEN HITS CHARTS



print "\n\nMEDIUM TERM TREND (50-60 games)";
print "\n\n******************** DRAWINGS BETWEEN HITS CHARTS ********************\n";
print "\nTo find a pattern easier\n";
print "\nANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
print "                <<-- OLDEST HITS, MOST RECENT HITS -->>\n";
my $cols_with_numbers = 21;  # columns with numbers
my $tb_dbh = Text::Table->new("##", (" ")x($cols_with_numbers+1), "OUT", "##", "HITS");
my ($arraysize_dbh, @arr_dbh) = drawingsbetweenhits($skaitli_diapazons, $cols_with_numbers);
for(my $j = 0; $j<$arraysize_dbh; $j++)
{
	$tb_dbh->load($arr_dbh[$j]);
}
print $tb_dbh;



############# DIAGONAL DRAWINGS BETWEEN HITS CHARTS



print "\n\n******************** DIAGONAL DRAWINGS BETWEEN HITS CHARTS ********************\n\n";
print "To find a pattern easier.\n0 hits at the beginning means - if chosen, the number will be adjacent to the previous draw.\n";
print "ANALYZED $skaitli_diapazons games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb_dc = Text::Table->new("##", "HITS DOWN LEFT", "HITS DOWN RIGHT");
my ($arraysize_dc, @arrdc) = diagonal($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_dc; $j++)
{
	$tb_dc->load($arrdc[$j]);
}
print $tb_dc;



########### MULTIPLE HIT PATTERN CHART WITH DOUBLE HIT RATIO


print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** MULTIPLE HIT PATTERN CHART WITH DOUBLE HIT RATIO ********************\n\n";
print "More than 50% of drawings have at least one number hit from the previous game.\n";
print "Double hit ratios LOWER than average are the best to play for a repeat hit.\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
print  ' ' x 3 . "MULTIPLE HITS, TIMES\n";
my @atm = ();
for(my $i=1; $i<8; $i++)
{
	push @atm, sprintf("%1d", $i);
}
my $tb_mh = Text::Table->new("##", @atm, "DOUBLE HIT RATIO");
my ($arraysize_mh, @arrmh) = multiplehit($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_mh; $j++)
{
	$tb_mh->load($arrmh[$j]);
}
print $tb_mh;



### SKIP AND HIT CHART (Skips between hits)



print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** SKIP AND HIT CHART (Skips between hits) ********************\n\n";
print "Shows the number of times each Lotto number has had a hit after loosing a specific number of games.\n";
print "Search for a pattern where the number of hits INCREASES in direction from left to right.\n";
print "The further to right the better. Compare to average value in the last row.\n\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb_sh = Text::Table->new("##","OUT ",(1..40),"Beyond 40 (to be fixed)");
my ($arraysize_, @arrsh) = skipandhit();
for(my $j = 0; $j < $arraysize_; $j++)
{
	$tb_sh->load($arrsh[$j]);
}
print $tb_sh;



########### COMPANION NUMBER CHART



print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** COMPANION NUMBER CHART ********************\n\n";
print "Shows how many times each lotto number has hit with every other Lotto numbern\n";
print "Play the numbers that hit together most often. Eliminate the numbers that rarely hit together, unless strong in other charts.\n\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
@atm = ();
for(my $i=1; $i<=$skaitli_diapazons; $i++)
{
	push @atm, sprintf("%1d", $i);
}
my $tb_cn = Text::Table->new("##", @atm);
my ($arraysize_cn, @arrcn) = companion($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_cn; $j++)
{
	$tb_cn->load($arrcn[$j]);
}
print $tb_cn;


############ TRAILING NUMBERS CHART


print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** TRAILING NUMBERS CHART ********************\n\n";
print "Shows which numbers followed (trailed) last winners most often.\n";
print "Play the numbers that most often follow one or more of the last game's winning numbers.\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
@atm = @{$array_partial[0]}[2..$skaitli_skaits+1];
my $tb_tn = Text::Table->new("##", @atm, "Total");
my ($arraysize_tn, @arrtn) = trailingnumbers($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_tn; $j++)
{
	$tb_tn->load($arrtn[$j]);
}
print $tb_tn;


######### ADJACENT HIT CHART


print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** ADJACENT HIT CHART ********************\n\n";
print "Shows which of the numbers on either side of the last games winning numbers are most likely to come up as winners in the next drawing\n";
print "If it's TIMES or % is higher than average, play it. If it is lower, do not play it.\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb_a = Text::Table->new("##", "ADJ.HITS","TOTAL HITS","%","##","TIMES","%","##","TIMES","%","TOTAL","%");
my ($arraysize_adj, @arradj) = adjacent($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_adj; $j++)
{
	$tb_a->load($arradj[$j]);
}
print $tb_a;


######### QUICK STATS CHART


print "\n\nLONG TERM TREND (all games)";
print "\n\n******************** QUICK STATS CHART ********************\n\n";
print "Pick LONG SHOT numbers with HIGHEST Out/Avg.Ratio.\n";
print "Hotter numbers has Hit Ratio above 100%. The lower the percent below 100, the colder the number\n";
print "ANALYZED ALL games\n";
print "Last draw results: " . (join ",", @{$array_partial[0]}[2..$skaitli_visi]);
print "\n\n";
my $tb_qs = Text::Table->new("##", "Games Out","Out/Avg.Ratio","Longest skip","Last skip","Avg.Skips","Median Skips","Expected Hits","Total Hits","Hit Ratio %");
my ($arraysize_qs, @arrqs) = quickstats($skaitli_diapazons);
for(my $j = 0; $j < $arraysize_qs; $j++)
{
	$tb_qs->load($arrqs[$j]);
}
print $tb_qs;


############ SUM TRACKING CHART

open FILE1, ">v_sum_tracking.txt";
select FILE1; # print will use FILE instead of STDOUT
print "\n\nSHORT TERM TREND (5-10 games)";
print "\n\n******************** SUM TRACKING CHART ********************\n\n";

my $row_prefix = "DRAW     SUM    ";
my $cols = $row_prefix . join " "x7, map sprintf("%03d", 10 * $_), $ls/10 .. $hs/10+1;
my $ls_column = length($row_prefix) + 2 + $ls%10;  # middle (2nd digit) of 3 digit number
my $lps_column = $ls_column + $lps - $ls;
my $avg_column = $lps_column + $avg_sum - $lps;
my $hps_column = $avg_column + $hps - $avg_sum;
my $hs_column = $hps_column + $hs - $hps;
#print "$ls_column, $lps_column, $avg_column, $hps_column, $hs_column\n";


my $format  = "format FILE1 = \n"
          . " "x($ls_column - 2) . sprintf("%03d", $ls)
          . " "x($lps - $ls - 3) . sprintf("%03d", $lps)
          . " "x($avg_sum - $lps - 3) . sprintf("%03d", $avg_sum)
          . " "x($hps - $avg_sum - 3) . sprintf("%03d", $hps) . "\n"
          ." "x($lps_column - 2) . "LPS"
          . " "x($avg_sum - $lps - 3) . "AVG"
          . " "x($hps - $avg_sum - 3) . "HPS" . "\n"
          . "$cols\n.\n";
eval $format;
#print $format . "\n", "-"x100,"\n";
write (FILE1);

my $sum_ = 0;
for(my $row__ = 0; $row__ < $#array_partial; $row__++)
{
	$sum_ = 0;
	$sum_ += $_ for @{$array_partial[$row__]}[2..$skaitli_skaits+1];
	if($sum_ <= $avg_sum)
	{
		my $format1  = "format FORMAT1 = \n"
							. "@#####   @##    " . " "x($sum_-$ls + 1) . "#"x($avg_sum - $sum_ + 1) ."\n"
							. '$array_partial[$row__][0], $sum_'
							. "\n.\n";
		eval $format1;
		$~ = "FORMAT1";
	}
	else
	{
		my $format2  = "format FORMAT2 = \n"
							. "@#####   @##    " . " "x($avg_sum - $ls + 1) . "#"x($sum_ - $avg_sum + 1) ."\n"
		          . '$array_partial[$row__][0], $sum_'
							. "\n.\n";
		eval $format2;
		$~ = "FORMAT2";
	}

  write (FILE1);
}

#---------- SUBs ---------------

sub drawingsbetweenhits
{
	my $range = $_[0]; # lottery numbers
	my $cols_with_numbers = $_[1]; # how many columns to print, excluding the OUT column
	my @arr = ();

	my $col_out = $cols_with_numbers + 2; # the OUT column
	my $col_number = $col_out + 1; # the lottery nuymber column
	my $col_hits = $col_number + 1; # the hits column

	my $hits_avg = 0;
	for(my $row = 0; $row < $range; $row++)	# lottery numbers
	{
		my $r1 = $row + 1;
		$arr[$row][0] = $r1;
		$arr[$row][1] = "-";
		$arr[$row][$col_number] = $r1 ;	# lottery number
		my $games_out = 0;
		my $hits = 0;
		my $col = $col_out;
		for(my $row2 = 0; $row2 <= $#array_partial; $row2++)
		{
				my @arr_tmp = @{$array_partial[$row2]}[2..$skaitli_skaits+1];
				if(grep(/^$r1$/, @arr_tmp)) # hit
				{
					if($col > 1)
					{
						$arr[$row][$col] = $games_out;
						$games_out = 0;
						$col--;
					}
					$hits++;
				}
				else
				{
					$games_out++;
				}
		}
		$arr[$row][$col_hits] = $hits;
		$hits_avg += $hits;
	}

	$hits_avg /= $range;
	$arr[$range][$col_number] = "AVG";
	$arr[$range][$col_hits] = sprintf("%.1f", $hits_avg);
	return ($#arr + 1, @arr);
}



# analyzes a set of drawings for HI/LO and EVEN/ODD
sub hilo_evenodd
{
	my $drawings = $_[0];  # number of drawings
	my @ar = @{$_[1]};

	my $hi = 0;
	my $lo = 0;
	my $hilo = "";
	my $even = 0;
	my $odd = 0;
	my $evenodd = "";

	foreach my $i_ (@ar)
	{
		$hi++ if $i_ > $skaitli_diapazons/2;
		$lo++ if $i_ <= $skaitli_diapazons/2;
		$even++ if $i_%2 == 0;
		$odd++ if $i_%2 != 0;
	}
	if($hi > $lo)
	{
		$hilo = sprintf("HI$drawings+ = %d", $hi - $lo);
	}
	else
	{
		$hilo = sprintf("LO$drawings+ = %d", $lo - $hi);
	}
	if($even > $odd)
	{
		$evenodd = sprintf("EVEN$drawings+ = %d", $even - $odd);
	}
	else
	{
		$evenodd = sprintf("ODD$drawings+ = %d", $odd - $even);
	}
	return ($hilo, $evenodd);
}


sub gamesout
{
	my $drawings = $_[0];
	my @arr_tmp = @array_games_out[0..($drawings - 1)];	# Input data. Results of last 5 games checked. Increase this later to 6..10
	my @arr2 = ();
	my @arr_tot = ();
	for(my $i=0; $i<6; $i++)	# 0..5 games out checked
	{
		$arr2[$i][0] = $i;
		$arr2[$i][1] = 0;
		my @minus= ();
		foreach my $r (@arr_tmp)
		{
			foreach my $r2 (@$r)
			{
				if($i == $r2)
				{
					$arr2[$i][1]++;
				}
			}
		}
		my $arr_p = $array_partial[$i];
		my @a = @$arr_p[2..$skaitli_skaits+1];

		@minus = array_minus( @a, @arr_tot );
		push @arr_tot, @minus;
		# print "Minus = ", join(",",@minus),"\n";
		# print "arr_tot = ", join(",",@arr_tot),"\n\n";
		$arr2[$i][2] = join(",",@minus);
	}
	my @arr3 = sort { $a->[1] <=> $b->[1] } @arr2;
	$arr3[6][0] = "Not listed";
	$arr3[6][1] = "# above";
	my @ta = ();
	for(my $i = 0; $i<6; $i++)
	{
		my @a = split /,/, $arr3[$i][2];
		# print @a; print "\n";
		push @ta, @a;
	}
	my @ab = (1..$skaitli_diapazons);
	$arr3[6][2] = join ",", array_diff(@ab, @ta);
	return @arr3;
}


sub lastdigitbias
{
	my $drawings = $_[0];
	my @arr_tmp = @array_partial[0..($drawings - 1)];	# last 5 games checked. Increase this later to 6..10
	my @arr2 = ();
	for(my $i=0; $i<10; $i++)	# last digits
	{
		my @a = ();
		$arr2[$i][0] = $i;
		$arr2[$i][1] = 0;

		foreach my $r (@arr_tmp)
		{
			foreach my $r2 (@$r[2..$skaitli_skaits+1])
			{
				$r2 =~ /(\d)$/;
				if($i == $1)
				{
					$arr2[$1][1]++;
					push @a, $r2;
				}
			}
		}
		$arr2[$i][2] = join (",",@a);
	}
	my @arr3 = sort { $a->[1] <=> $b->[1] } @arr2;
	return @arr3;
}



sub getgroups
{
	my $number_of_drawings = $_[0];
	my $groupsize = $_[1];

	my @implemented = (5,6,7,8,9,10);
	my @arr_tmp = @array_partial[0..($number_of_drawings - 1)];
	my @arr = ();
	my @arr_min = ();
	my @arr_max = ();
	for(my $i = 0; $i < ($number_of_drawings + 2); $i++)
	{
			push @arr, [(0)x($number_of_drawings + 2)];
	}
	my $array_size = 15 - $groupsize;
	if($groupsize == 10)
	{
		$array_size = 6;
	}
	if(!(grep(/^$groupsize$/, @implemented)))
	{
		print "ERROR: Group size $group_size not impemented\n";
	}


	for(my $i = 0; $i < $array_size; $i++)
	{
		$arr_min[$i] = $i * $groupsize + 1;
		$arr_max [$i] = $arr_min[$i] + $groupsize - 1;
		if($i == 0)
		{
			$arr_min[$i] = 1;
			if($groupsize == 10)
			{
				$arr_max [$i] = 9;
			}
		}
		$arr[$i][0] = sprintf("%02d-%02d", $arr_min[$i], $arr_max[$i]);

		my $k = 1;
		my $sum = 0;
		foreach my $r (@arr_tmp)
		{
			foreach my $r2 (@$r[2..$skaitli_skaits+1])
			{
				if($r2 >= $arr_min[$i] && $r2 <= $arr_max[$i])
				{
					$arr[$i][$k]++;
					$sum++;
				}
		  }
			$k++;
		}
		$arr[$i][$number_of_drawings + 1] = $sum/$number_of_drawings;
	}
	return ( scalar $array_size, @arr);
}


sub skipandhit
{
	my $cols_max = 42; # number of columns
	my @arr =();
	ROWS: for(my $row = 0; $row < $skaitli_diapazons; $row++)
	{
		$arr[$row][0] = sprintf("%2d", $row + 1);
		COLS: for(my $col = 1; $col < $cols_max; $col++)
		{
			my $games_out = 0;
			$arr[$row][$col] = 0;
			my $realhit = 0;  # to exclude case when there is no hit before the skip (the very first hit)
			GAMES: foreach my $r (@array_partial)
			{
				foreach my $k (@$r[2..$skaitli_skaits+1])
				{
					if(($col == 1) and ($row + 1) == $k)  # current games out
					{
						$arr[$row][$col] = $games_out;
						next COLS;
					}
					elsif($row + 1 == $k) # hit
					{
						if($games_out == ($col - 1))
						{
							# if($row == 0 and $col == 2)
							# {
							# 	my $o1 = $o+32;
							# 	print "$o1, $games_out\n";
							# }
							if($realhit == 1)
							{
								$arr[$row][$col]++;
								$games_out = 0;
								next GAMES;
							}
						}
						$games_out = 0;
						$realhit = 1;
						next GAMES;
					}
					else
					{}
				}

				$games_out++;
				# $o++;
			}
		}
	}

	$arr[$skaitli_diapazons][$_] = 0 for(0..$cols_max-1);
	for(my $col = 1; $col < $cols_max; $col++)
	{
		for(my $row = 0; $row < $skaitli_diapazons; $row++)
		{
			$arr[$skaitli_diapazons][$col] += $arr[$row][$col];
		}
		$arr[$skaitli_diapazons][$col] = sprintf("%.0f", $arr[$skaitli_diapazons][$col]/$skaitli_diapazons);
	}
	$arr[$skaitli_diapazons][0] = "AVG";
	return (1+$#arr, @arr);
}


sub multiplehit
{
	my $numbers = $_[0];
	my @arr = ();
	for(my $row = 0; $row < $numbers; $row++)
	{
		$arr[$row][$_] = 0 for(0..9);
		$arr[$row][0] = $row + 1;
		my $hits = 0;
		my $prev = "u"; # "u", "h", "s" (unknow - next draw result, hit, skip)
		my $first = 1; # to deal with the next draw, before the first.
		foreach my $r (@array_partial)
		{
			my $hit = 0;
			foreach my $k (@$r[2..$skaitli_skaits+1])	# check if hit
			{
				if(($row + 1) == $k)
				{
					$hit = 1;
					last;
				}
			}
			if($hit == 1) # hit
			{
				$hits++;
				$prev = "h";
				next;
			}
			else # skip
			{
				if($prev eq "h")
				{
					if($first == 0)
					{
						$arr[$row][$hits]++;
						# if($row == 0)
						# {
						# 	print "$hits, ";
						# }
						$hits = 0;
					}
				}
				$prev = "s";
				$first = 0;
			}
		}
		my $sum = 0;
		$sum += $_ for @{$arr[$row]}[2..$skaitli_skaits+2];
		# print "Sum = $sum, Row = $row\n";
		$arr[$row][8] = ($sum != 0) ? sprintf("%.1f",$arr[$row][1] / $sum) : 0;
	}

	$arr[$numbers][$_] = 0 for(0..9);
	for(my $col = 1; $col < 9; $col++)
	{
		for(my $row = 0; $row < $numbers; $row++)
		{
			$arr[$numbers][$col] += $arr[$row][$col];
		}
		$arr[$numbers][$col] = sprintf("%.1f", $arr[$numbers][$col]/$numbers);
	}
	$arr[$numbers][0] = "AVG";
	return ($#arr + 1, @arr);
}


sub companion
{
	my $range = $_[0]; # number range (1-35)
	my @arr = ();
	# initialize
	for(my $row = 0; $row < $range; $row++)
	{
		for(my $col = 0; $col <= $range; $col++)
		{
			if($col == 0)
			{
				$arr[$row][0] = $row + 1;
				next;
			}
			if($col <= $row)
			{
				$arr[$row][$col] = 0;
			}
			elsif($col == ($row + 1))
			{
				# $arr[$row][$row+1] = "X";
				$arr[$row][$row+1] = ".";
			}
			else
			{
				$arr[$row][$col] = ".";
			}
		}
	}
	# calculate
	for(my $row = 0; $row < $range; $row++)
	{
		my $r1 = $row + 1;
		foreach my $r (@array_partial)
		{
			if(grep( /^$r1$/, @{$r}[2..$skaitli_skaits+1]))
			{
				foreach my $k (@$r[2..$skaitli_skaits+1])	# check if hit
				{
					next if($r1 == $k);
					$arr[$row][$k]++ if($r1 > $k);
					# $arr[$k-1][$r1]++ if($r1 < $k);
				}
			}
		}
	}
	return ($#arr + 1, @arr);
}



sub trailingnumbers
{
	my $range = $_[0]; # range (35)
	my @lastresults = @{$array_partial[0]}[2..$skaitli_skaits+1];
	my @arr = ();
	my $sum = 0;
	my $avg_sum = 0;
	for(my $row = 0; $row < $range; $row++)
	{
		$arr[$row][0] = $row + 1;
		$arr[$row][$skaitli_skaits + 1] = 0;

		for(my $i=0; $i<$skaitli_skaits; $i++)  # last hit numbers
		{
			$arr[$row][$i+1] = 0;
			my $lastnumber = $lastresults[$i];
			for(my $r = 0; $r < $#array_partial; $r++)
			{
				foreach my $k (@{$array_partial[$r]}[2..$skaitli_skaits+1])
				{
					if($k == $lastnumber)
					{
						my @arr2 = @{$array_partial[$r+1]}[2..$skaitli_skaits+1];
						my $r1 = $row + 1;
						if(grep(/^$r1$/, @arr2))
						{
							$arr[$row][$i+1]++;
						}
					}
				}
			}
		}
		$sum = 0;
		$sum += $_ for (@{$arr[$row]}[1..$skaitli_skaits]);
		$arr[$row][$skaitli_skaits + 1] = $sum;
		$avg_sum += $sum;
	}
	my @arr_d = sort { $b->[$skaitli_skaits + 1] <=> $a->[$skaitli_skaits + 1] } @arr;
	$arr_d[$range][$skaitli_skaits] = "AVG";
	$arr_d[$range][$skaitli_skaits + 1] = sprintf("%.1f",$avg_sum / $range);
	return ($#arr_d + 1, @arr_d);
}


sub adjacent
{
	my $range = $_[0]; # range (35)
	my @arr = ();
	for(my $n = 1; $n <= $range; $n++)
	{
		my $hits = hits($n, \@array_partial);
		my @adj = ( ($n==1) ? $skaitli_diapazons : $n - 1 ,  ($n==$skaitli_diapazons) ? 1 : $n + 1 );
		my $adj_hits_low  = adjacenthits($n, $adj[0], \@array_partial);
		my $adj_hits_high = adjacenthits($n, $adj[1], \@array_partial);
		$arr[$n-1][0] = $n;
		$arr[$n-1][1] = $adj_hits_low + $adj_hits_high;
		$arr[$n-1][2] = $hits;
		$arr[$n-1][3] = ($arr[$n-1][2] > 0) ? sprintf("%.1f", $arr[$n-1][1]/$arr[$n-1][2]*100) : 0;
		$arr[$n-1][4] = $adj[0];
		$arr[$n-1][5] = adjacenthits($adj[0], $n, \@array_partial);
		$arr[$n-1][6] = "";
		$arr[$n-1][7] = $adj[1];
		$arr[$n-1][8] = adjacenthits($adj[1], $n, \@array_partial);
		$arr[$n-1][9] = "";
		$arr[$n-1][10] = $arr[$n-1][5] + $arr[$n-1][8];
		$arr[$n-1][11] = "";
	}
	for(my $n = 1; $n <= $range; $n++)
	{
		my @adj = ( ($n==1) ? $skaitli_diapazons : $n - 1 ,  ($n==$skaitli_diapazons) ? 1 : $n + 1 );
		$arr[$n-1][6] = ($arr[$adj[0]-1][2] > 0) ? sprintf("%.1f", $arr[$n-1][5] / $arr[$adj[0]-1][2] * 100) : 0;
		$arr[$n-1][9] = ($arr[$adj[1]-1][2] > 0) ? sprintf("%.1f", $arr[$n-1][8] / $arr[$adj[1]-1][2] * 100) : 0;
		$arr[$n-1][11] = sprintf("%.1f" ,$arr[$n-1][6] + $arr[$n-1][9]);
	}
	$arr[$range][0] = "AVG" ;
	my $sum = 0;
	for(my $col = 1; $col < 12; $col++)
	{
		for(my $row = 0; $row < $range; $row++)
		{
			$arr[$range][$col] += $arr[$row][$col];
		}
		$arr[$range][$col] /= $skaitli_diapazons;
		if (grep{$_ eq $col} 3,6,9,11)
		{
			$arr[$range][$col] = sprintf("%.2f%%", $arr[$range][$col]);
		}
		else
		{
			$arr[$range][$col] = sprintf("%.2f", $arr[$range][$col]);
		}
	}
	return ($#arr + 1, @arr);
}


# find number of hits in array
sub hits
{
	my $n = $_[0];
	my $h = 0;
	foreach my $r (@{$_[1]})
	{
		if(grep(/^$n$/, @{$r}[2..$skaitli_skaits+1]))
		{
			$h++;
		}
	}
	return $h;
}

sub adjacenthits
{
	my $n = $_[0]; # number
	my $adjhitsto = $_[1]; # how many times $n is adjacent to this
	my $h = 0;
	my $row = 0;
	my @arr = @{$_[2]};
	foreach my $r (@arr)
	{
		if(grep(/^$adjhitsto$/, @$r[2..$skaitli_skaits+1]))
		{
			if(grep(/^$n$/, @{$arr[$row+1]}[2..$skaitli_skaits+1]))
			{
				$h++;
			}
		}
		$row++;
		last if $row == $#arr;
	}
	return $h;
}


sub quickstats
{
		my $range = $_[0]; # range
		my @arr = ();
		my $sumhits = 0;
		for(my $n = 1; $n <= $range; $n++)
		{
			my ($hits, @skips) = skips($n); # array with all skip lengths
			#print "n = $n, hits = $hits, skips = ", join ",", @skips, "\n";
			$arr[$n-1][0] = $n;	# number
			$arr[$n-1][1] = $skips[0]; # games out
			$arr[$n-1][3] = max(@skips); # longest skip
			$arr[$n-1][4] = $skips[1]; # last skip
			$arr[$n-1][5] = (scalar @skips > 0) ? sprintf("%.1f", sum(@skips)/scalar @skips) : 0; # average skips
			$arr[$n-1][6] = 0;	# median skips
			$arr[$n-1][7] = 0;  # expected hits
 			$arr[$n-1][8] = $hits;  # total hits
 			$arr[$n-1][9] = 0;  # hit ratio
 			$arr[$n-1][2] = ($arr[$n-1][5] > 0) ? sprintf("%.1f",$skips[0]/$arr[$n-1][5]) : 0; # games out/avg
 			$sumhits += $hits;
		}
		my $expectedhits = sprintf("%.1f", $sumhits/$range);
		foreach my $r (@arr)
		{
			@{$r}[7] = $expectedhits;
			@{$r}[9] = sprintf("%.1f%%", @{$r}[8]/$expectedhits*100);
		}
		return ($#arr + 1, @arr);
}


sub skips
{
	my $number = $_[0]; # number
	my @arr = ();
	my $hits = 0; # total number of hits
	my $games_out = 0; # between hits
	my $prev = "u"; # s - skip, h - hit, u - unknown
	foreach my $row (@array_partial)
	{
		if(grep(/^$number$/, @{$row}[2..$skaitli_skaits+1]))	# hit
		{
			$hits++;
			if($prev eq "s" or $prev eq "u")
			{
				push @arr, $games_out;
				$games_out = 0;
				$prev = "h";
			}
			elsif($prev eq "h")
			{
				$prev = "h";
			}
			else
			{}
		}
		else  # skip
		{
			$prev = "s";
			if($prev eq "u")
			{
				$games_out++;
				next;
			}
			elsif($prev eq "s")
			{
				$games_out++;
			}
			elsif($prev eq "h")
			{
				$games_out = 1;
			}
		}
	}
	return ($hits, @arr);
}


sub diagonal
{
	my $range = $_[0]; # range
	my @arr = ();
	for(my $n = 1; $n <= $range; $n++) # numbers
	{
		my @row = ();
		my @hits = ();
		push @row, $n;
		for(my $h = 0; $h < $range; $h++)	# drawings on left side
		{
			my $nmh = $n - $h - 1;
			last if $nmh == 0;
			if(grep(/^$nmh$/, @{$array_partial[$h]}[2..$skaitli_skaits+1]))
			{
				push @hits, $h;
			}
		}
		my @hits2 = ();
		for(my $i = 0; $i <= $#hits; $i++)
		{
			if($i==0)
			{
				push @hits2, $hits[$i];
			}
			else
			{
				push @hits2, $hits[$i] - $hits[$i-1] - 1;
			}
		}
		push @row, join ",", @hits2;


		@hits = ();
		for(my $h = 0; $h < $range; $h++)	# drawings on right side
		{
			my $nmh = $n + $h + 1;
			last if $nmh > $skaitli_diapazons;
			if(grep(/^$nmh$/, @{$array_partial[$h]}[2..$skaitli_skaits+1]))
			{
				push @hits, $h;
			}
		}
		@hits2 = ();
		for(my $i = 0; $i <= $#hits; $i++)
		{
			if($i==0)
			{
				push @hits2, $hits[$i];
			}
			else
			{
				push @hits2, $hits[$i] - $hits[$i-1] - 1;
			}
		}
		push @row, join ",", @hits2;
		push @arr, \@row;
	}
	return (scalar @arr, @arr);
}

sub plotDrawResults
{
	my $tb = $_[0];
	$tb->add("N","Drawing","Date", @n);
	my $row=0;
	my @col=(0)x$skaitli_diapazons;
	foreach my $r (@array_partial)
	{
		my @a_=(); # for table row
		push @a_, $row;
		push @a_, $r->[0];
		push @a_, $r->[1];
		for(my $i=1;$i<$skaitli_diapazons+1;$i++)
		{
			my $elem="";
			if(grep(/^$i$/, @{$r}[2..$skaitli_skaits+1]))
			{
				if ($print_papildskaitli == 0 or $print_papildskaitli == 2)
				{
					$elem .= " X" ;
					$col[$i-1] = 1;
				}
			}
			if(grep(/^$i$/, (@{$r}[8..8])))
			{
				if ($print_papildskaitli == 1)
				{
					$elem .= " X";
					$col[$i-1] = 1;
				}
				if($print_papildskaitli == 2)
				{
					$elem .= "o";
				}
			}
			if($elem eq "")
			{
				if($col[$i-1] == 0)
				{
					$elem = ($print_lines == 1) ? "|" : " ";
				}
				else
				{
	            	$elem = ($print_dots == 1) ? "." : " ";
				}
			}
			push @a_, $elem;
		}
		$tb->add(@a_);
		$row++;
	}

	print $tb;
	print "\n\n";
}
