#my $draw_results = "4 18 20 23 39";
my $draw_results = "3 11 12 19 35";
my @data = split /[\s,]+/, $draw_results;
print join ',', @data; print "\n";
my $ac = getAC(\@data);
my $sum = getSum(\@data);
print "AC: $ac\n";
print "Sum: $sum\n";


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

sub getSum
{
	my @in = @{$_[0]};

	my $sum = 0;
	my $size = scalar @in;
	for(my $i=0; $i<$size; $i++)
	{
		$sum += $in[$i];
	}
	return $sum;
}
