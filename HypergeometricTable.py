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





Hypergeometric tables in Python.  As noted above,
based on my old Perl code, which in turn was derived
in roughly equal proportion from ideas found in three
sources:

     1. An old version of the BMJ Statistics at Square
        One textbook, at
        https://www.bmj.com/about-bmj/resources-readers/publications

     2. The Two by Two Table tool from www.openepi.com

     3. Some old Java code, which was at
http://www.inference.phy.cam.ac.uk/mackay/java/pal-1.4.tar.gz/
        when I downloaded it some years ago.  That URL does not
        work now.  Two snapshots of that tarball
        can be found by searching https://archive.org/web/
        for the above URL.  Once you've downloaded and unpacked
        the tarball, it's src/pal/statistics/FisherExact.java





Note that unlike Perl, Python always needs to see function
declarations before calls.  So my Perl habit of sticking all
my sub{...} stuff at the end won't work here.
'''




with fileinput.input() as stdin:
    for line in stdin:
       line = line.rstrip('\r\n')
       # line is a string object; using its rstrip method to
       # remove its newline(s).  Using both \r and \n so it
       # will work with all platforms
       print("Input line: ", line)
       import re
       p=re.compile(r'[^0-9]*([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)')
       #                  A              B             C              D
       # Intended to be VERY forgiving: take the first four things that look
       # like integers, ignoring all else.
       s = p.search(line)
       if s:
           a = int(s.group(1))
           b = int(s.group(2))
           c = int(s.group(3))
           d = int(s.group(4))
           # OK, now we have our input values
           # so make the basic table
           print(     "\n",
                      a  , "\t", b  , "\t",  a+b     , "\n",
                      c  , "\t", d  , "\t",  c+d     ,  "\n",
                      a+c, "\t", b+d, "\t",  a+b+c+d , "\n")
       else:
           print('ignoring input:',
                  line)
   



