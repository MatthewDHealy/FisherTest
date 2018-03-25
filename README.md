# FisherTest

Simple Perl script that computes the Fisher Exact or Hypergeometric Test.  Nothing
in its code is Perl-specific; it should be straightforward translating this into
any language that supports what are called hash tables in Perl and some
other languages call dictionaries.

There are a few wrinkles.  First, I compute logs of factorials instead of
factorials, because factorials become large very quickly.  Then to compute the
probabilities I modified the textbook formulas to add and subtract logs instead
of multiplying and dividing the large factorials.

The second wrinkle is that my LnFactorial function uses a hash to keep track of
previously-computed values, which makes it very efficient, able to handle tables
of very large size.

A third wrinkle is that I compute the mid-P variant of the Fisher Exact Test,
which many textbooks recommend.

I also compute the Z-value, the Z-value that has the same P-value, and their
ratio.  These calculations allow one to assess how accurate an approximate
P-value computed using the normal distribution would be.  I put this part in
because I was curious about the accuracy or otherwise of the normal approximation.
