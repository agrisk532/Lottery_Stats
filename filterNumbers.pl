use Algorithm::Combinatorics qw(combinations);
use List::Util qw(sum max);
use Text::Table;

### CHOOSE GAME ###

### EUROJACKPOT

#=begin
my $selected_numbers_count = 5;
my $myChosenNumbers = "1 14 15 21 23 27 33 36 38 42";
# range of sums (including these values)
my $sumLowerBound = 95;
my $sumUpperBound = 160;
#AC limits
my $ACLowerBound = 5;
# how many odd numbers (even_numbers = 5 - odd_numbers), not used
#my $odd_numbers = 2;
#=cut

### VIKINGLOTTO

=begin
my $selected_numbers_count = 6;
my $myChosenNumbers = "4 11 20 29 36 45";
# range of sums (including these values)
my $sumLowerBound = 113;
my $sumUpperBound = 181;
# AC limits
my $ACLowerBound = 1;
# how many odd numbers (even_numbers = 6 - odd_numbers), not used
#my $odd_numbers = 3;
=cut

### 5NO35

=begin
my $selected_numbers_count = 5;
my $myChosenNumbers = "1 4 14 16 21 24 27 29 34";
# range of sums (including these values)
my $sumLowerBound = 68;
my $sumUpperBound = 112;
# AC limits
my $ACLowerBound = 4;
# how many odd numbers (even_numbers = 5 - odd_numbers), not used
#my $odd_numbers = 2;
=cut

### Do not change below this line ###


my @data = split /[\s,]+/, $myChosenNumbers;
print "Numbers to choose from : " . join ',', @data; print "\n";
#print "Odd numbers = $odd_numbers\n";
print "Possible combinations and sums\n\n";
my $ac = filter(\@data);

sub filter
{
	my $tb_ = Text::Table->new("Numbers"," ","Sum  ","AC", "Valid");
	my @data = @{$_[0]};
	my $iter = combinations(\@data, $selected_numbers_count);
	my %count;
	while (my $c = $iter->next) {
		$s = sum(@$c);
		$odd_count = 0;
		$high_number_count = 0;
		$ac = getAC(\@$c);
		if($s >= $sumLowerBound and $s <= $sumUpperBound) {
			foreach (@$c)
			{
				if ($_ & 1)
				{
					$odd_count++;
				}
				if($_ > 17)
				{
					$high_number_count++;
				}
			}

#			if($odd_count == $odd_numbers and $ac >= $ACLowerBound)
#			{
				if(($ac >= $ACLowerBound) and ($odd_count == 2 or $odd_count == 3) and ($high_number_count == 2 or $high_number_count == 3))
				{
					$tb_->add(join (" ", @$c), "  ", $s,  $ac, " valid");
#					print join (" ", @$c) , "   $s " , getAC(\@$c) , "\n";
					$count{$s}++;
				}
#			}
		}
	}
	print $tb_;
	print "Number of occurences of the sum:\n";
	print "$_ $count{$_}\n" for (keys %count);
	
	my $highest = max values %count;
	print ("highest sum = $highest\n");
	print ("Here they are:\n");
	
	my @keys = grep { $count{$_} eq $highest } keys %count;
	
	my $tb1_ = Text::Table->new("Numbers"," ","Sum  ","AC");
	$iter = combinations(\@data, $selected_numbers_count);
	
	print "keys = @keys\n";
	
	foreach (@keys)
	{
		$k = $_;
		while (my $c = $iter->next)
		{
			$s = sum(@$c);
			$ac = getAC(\@$c);
			if($s == $k and $ac >= $ACLowerBound)
			{
				$tb1_->add(join (" ", @$c), "  ", $s,  $ac);
			}
		}
		$iter = combinations(\@data, $selected_numbers_count);
	}
	print $tb1_;
}
 
 sub getAC
{
	my @in = @{$_[0]};

	my @sum = 0;
	my %seen = ();
	my @uniq = ();
	my @arr = ();
	my $size = scalar @in;
	for(my $i=0; $i<$size; $i++)
	{
		for(my $j = $i+1; $j<$size; $j++)
		{
			my $v = $in[$j] - $in[$i];
			# print "diff = $v\n";
			push @arr, $v;
		}
	}

	foreach my $item (@arr)
	{
	    push(@uniq, $item) unless $seen{$item}++;
	}

	my $ac = scalar @uniq - ($size - 1);
	return $ac;
}