#!/usr/bin/perl -w

# Sometimes my Fisher Exact Test code blows up
# which causes problems.  Being too lazy to put in all kinds of error-checking
# logic, I am gonna fix this by wrapping it in an eval block...




# Simple-minded brute-force hypergeometric distribution
# calculator, based on the java code found in:
# http://www.inference.phy.cam.ac.uk/mackay/java/pal-1.4.tar.gz/
#
# The formulas required are given in numerous textbooks and
# websites, but the formats most commonly used are not very
# convenient for calculation purposes.  Among the few textbooks
# giving the formulas in a convenient format -- one quite close
# to the one used here -- is the British Medical Journal's text
# "Statistics at Square One" which is available online at
# http://www.bmj.com/statsbk/ and discusses the Fisher Exact Test at
# http://www.bmj.com/statsbk/9.dtl
#
# Computes ONE-TAILED p-values for the Fisher Exact Test,
# which is the MINIMUM of either:
#        1. The p-value for the same or a stronger association
#      OR=
#        2. The p-value for the same or the reverse association
#
# To validate this, I am comparing randomly-chosen cases against:
#
#     1. The HYPGEOMDIST function in GNUMERIC 1.6.2
#     2. The SISA web calculator at
#        http://home.clara.net/sisa/fisher.htm
#
# Various sources differ slightly on how to define the two-tailed
# version of the Fisher Exact Test; the BMJ text suggests using
# the simplest method of simply doubling the one-tailed P-value.
# I've not bothered to code this up since it can easily be done
# by hand!
#
# Also, various sources differ on whether to use the conventional
# or mid-P version of the Fisher Exact Test; according the the BMJ
# textbook and other sources the conventional version is somewhat
# conservative whereas the mid-P version is less so.  For simplicity
# and for compatibility with many Fisher Exact Test calculators
# available online, I have chosen to stick with the conventional
# version of the Fisher Exact Test.


use strict;


# Read the four numbers and emit the complete table with marginal
# totals and the P-value:
my $now = time();
my $num_sets = 0;

while (<>)
   {
       my ($a, $b , $c, $d) = split (' ' , $_);
       print "\n\n====================\n\n";
       print "\n\nInput:\t$a\t$b\t$c\t$d\n";


eval {
         # try
       my $a_b = $a + $b;
       my $c_d = $c + $d;
       my $a_c = $a + $c;
       my $b_d = $b + $d;
       my $total = $a + $b + $c + $d;
       my $p1 = $a/$a_b;
       my $p2 = $c/$c_d;
       my $deltap = abs($p1 - $p2);
       print "P1:$p1\tP2:$p2\tDeltap:$deltap\n";
       my $p  = $a_c / $total;
       print "overall p:$p\n";
       my $sd = sqrt($p * (1-$p) * (1/$a_b + 1/$c_d));
       my $z  = abs($p1 - $p2) / $sd;
       print "Z-score:$z\n\n";
       print "\n$a\t$b\t$a_b\n$c\t$d\t$c_d\n".
       "$a_c\t$b_d\t$total\n";
       my $FisherProb = ProbCumTable($a, $b , $c, $d);
       my $zp = abs(ltqnorm($FisherProb));
       my $z95 = abs(ltqnorm(0.95));

       my $z_ratio = $z / $zp;
       my $deltap95 = $deltap * ($z95 / $zp);

       my $elapsed_time = time() - $now;
       $num_sets++;
       print "$num_sets in $elapsed_time\n\n";

       print "Deltap:$deltap\tProjectedDeltap95:$deltap95\n\n";


       print "Traditional Fisher Exact test:$FisherProb\n" .
       "z:$z\nzp:$zp\nratio:$z_ratio\n$p1\t$p2\t$p\n\n";

       my $p_this_table = ProbOneTable($a , $b , $c , $d);
       print "This one table p:$p_this_table\n";

       my $mid_p = $FisherProb - $p_this_table/2;
       print "Mid-p:$mid_p\tTwo-tailed Mid-p:" . 2 * $mid_p . "\n\n";

       print "InputWas:\t$a\t$b\t$c\t$d\n";
       1;
       } or do {
               #catch
       print "Mid-p:ERROR\tTwo-tailed Mid-p:ERROR\n";
       print "InputWas:\t$a\t$b\t$c\t$d\tWhich generated an error\n";
       }

   }


  {
      # Wrap curlies around my functions for scoping...

# Define the LnFactorial utility function...
#
# We add logs instead of multipying in order to avoid
# overflow -- with IEEE doubles the factorial function
# will overflow at N around 170.
#
# We use an array as a cache for speed, so we don't
# compute the same value over and over again; also we
# take advantage of Perl's automatic resizing to grow
# this array as needed.

  {
        my @cache;

        sub LnFactorial {
            my $n = shift;
            $cache[0] = 0;
            $cache[1] = 0;
            return $cache[$n] if defined $cache[$n];
            return undef if $n < 0;
            for (my $i = scalar(@cache) ; $i <= $n ; $i++)
               {
                   $cache[$i] = $cache[$i-1] + log($i);
               }

            return $cache[$n];
        }
    }

sub ProbOneTable {

    # Compute the probability of getting this exact table
    # using the hypergeometric distribution

    my ($a , $b , $c, $d) = @_;
    my $n =$a+$b+$c+$d;
    my $LnNumerator =
                       LnFactorial($a+$b)+
                       LnFactorial($c+$d)+
                       LnFactorial($a+$c)+
                       LnFactorial($b+$d);

    my $LnDenominator =
                       LnFactorial($a) +
                       LnFactorial($b) +
                       LnFactorial($c) +
                       LnFactorial($d) +
                       LnFactorial($n);

    my $LnP = $LnNumerator - $LnDenominator;
    return exp($LnP);

  }

sub ProbCumTable {

    # Compute the cumulative probability by adding up individual
    # probabilities

    my ($a, $b, $c, $d) = @_;

    my $min;

    my $n=$a+$b+$c+$d;

    my $p=0;
    $p+= ProbOneTable($a, $b, $c, $d);
    if(($a*$d)>=($b*$c))
      {$min=($c<$b)?$c:$b;
      for(my $i=0; $i<$min; $i++)
        {$p+=ProbOneTable(++$a, --$b, --$c, ++$d);}
      }
    if(($a*$d)<($b*$c))
      {$min=($a<$d)?$a:$d;
      for(my $i=0; $i<$min; $i++)
        {$p+=ProbOneTable(--$a, ++$b, ++$c, --$d);}
      }
    return $p;
  }

}

sub ltqnorm  {
    #
    # Lower tail quantile for standard normal distribution function.
    #
    # This function returns an approximation of the inverse cumulative
    # standard normal distribution function.  I.e., given P, it returns
    # an approximation to the X satisfying P = Pr{Z <= X} where Z is a
    # random variable from the standard normal distribution.
    #
    # The algorithm uses a minimax approximation by rational functions
    # and the result has a relative error whose absolute value is less
    # than 1.15e-9.
    #
    # Author:      Peter J. Acklam
    # Time-stamp:  2000-07-19 18:26:14
    # E-mail:      pjacklam@online.no
    # WWW URL:     http://home.online.no/~pjacklam

    my $p = shift;
    die "input argument must be in (0,1)\n" unless 0 < $p && $p < 1;

    # Coefficients in rational approximations.
    my @a = (-3.969683028665376e+01,  2.209460984245205e+02,
             -2.759285104469687e+02,  1.383577518672690e+02,
             -3.066479806614716e+01,  2.506628277459239e+00);
    my @b = (-5.447609879822406e+01,  1.615858368580409e+02,
             -1.556989798598866e+02,  6.680131188771972e+01,
             -1.328068155288572e+01 );
    my @c = (-7.784894002430293e-03, -3.223964580411365e-01,
             -2.400758277161838e+00, -2.549732539343734e+00,
              4.374664141464968e+00,  2.938163982698783e+00);
    my @d = ( 7.784695709041462e-03,  3.224671290700398e-01,
              2.445134137142996e+00,  3.754408661907416e+00);

    # Define break-points.
    my $plow  = 0.02425;
    my $phigh = 1 - $plow;

    # Rational approximation for lower region:
    if ( $p < $plow ) {
       my $q  = sqrt(-2*log($p));
       return ((((($c[0]*$q+$c[1])*$q+$c[2])*$q+$c[3])*$q+$c[4])*$q+$c[5]) /
               (((($d[0]*$q+$d[1])*$q+$d[2])*$q+$d[3])*$q+1);
    }

    # Rational approximation for upper region:
    if ( $phigh < $p ) {
       my $q  = sqrt(-2*log(1-$p));
       return -((((($c[0]*$q+$c[1])*$q+$c[2])*$q+$c[3])*$q+$c[4])*$q+$c[5]) /
                (((($d[0]*$q+$d[1])*$q+$d[2])*$q+$d[3])*$q+1);
    }

    # Rational approximation for central region:
    my $q = $p - 0.5;
    my $r = $q*$q;
    return ((((($a[0]*$r+$a[1])*$r+$a[2])*$r+$a[3])*$r+$a[4])*$r+$a[5])*$q /
           ((((($b[0]*$r+$b[1])*$r+$b[2])*$r+$b[3])*$r+$b[4])*$r+1);
}
