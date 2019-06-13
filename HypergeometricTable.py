#!/usr/bin/python3
import fileinput


'''

REMOVE THIS BIT WHEN DONE
As I start building this, first I merely echo the input and
then I start incorporating more features.  Basically I wanna
get something that works as a filter ASAP, then incrementally
add stuff to it.



REMOVE THIS BIT WHEN DONE


Input format is just A, B, C, and D as whitespace separated
values on STDIN, interpreted as cell counts from a simple
two-by-two contingency table as below:

     A    B    A+B
     C    D    C+D
    A+C  B+D   A+B+C+D

Output format is intended to facilitate both reading by a human
and parsing by another program as part of a pipeline.

This is based on my working Perl version, for which I made two
key optimizations.  First, because factorials get very big very
quickly, I compute LOGS of factorials instead of factorials.
Second, to save on lots of redundant computations that would
otherwise occur, I keep a cache of all such values up to the
highest value computed so far.  The formulas for Fisher Exact
Test are based on some old Java code, as described later in
this docstrinc


Hypergeometric tables in Python.  Based on my old Perl code,
which in turn is PARTLY based on some old Java code.  That code
was in a file called FisherExact.java which was found within
a tarball at
http://www.inference.phy.cam.ac.uk/mackay/java/pal-1.4.tar.gz/
Note that the above URL is not working.  As of 13 June 2019,
it can be obtained by searching the Wayback Machine at
https://archive.org/web/ for that URL.  As of 13 June 2019,
the Wayback Machine had two snapshots of the tarball, which
it captured on 3 January 2006 and again on 15 April 2016.

That Java code was part of a package written by the "PAL
Development Core Team," who were at Auckland, Oxford, and NCSU
when they wrote it.  The code says (c) 1999-2001 and that it
may be distributed under the GNU LGPL; it doesn't specify a
version of the LGPL.



'''




