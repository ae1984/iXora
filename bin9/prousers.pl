#!/usr/bin/perl
# by Sasco - list of all live Progres sessions on all databases

# check count of arguments
if ($#ARGV == -1) { print "List of Progres sessions\nMissing arguments!\n\t0,a,A = all users\n\t1,e,E = existing PTS\n\t2,n,N = non-existing PTS\n\th,H = help\n"; exit;}

# check 1st argument for validity
if ($ARGV[0] =~ m/[^012aAeEnNhH]/)
{
   print "Incorrect argument!\n";
   print "Enter 0,a,A = all users\n      1,e,E = existing PTS\n      2,n,N = non-existing PTS\n      h,H  = help\n"; 
   exit;
}

# get progres sessions without PTS number (i.e. pts = ?)
$data_n = `ps -eaf | grep '?' | grep '_progres' | grep -v grep | awk '
     BEGIN { WASDB = 0; }
     {
       printf ("%s ", \$1); printf ("%s ", \$2);
       if (substr(\$8, 1, 1) == "?") { printf ("%s ", \$8); } else { printf ("%s ", \$9); }
       WASDB = 0;
       for (i=1; i<NF; i++) { if (\$i == "-db") { WASDB = 1; printf ("%s", \$(i+1)); } }
       if (WASDB == 0) { if (substr(\$8, 1, 1) == "?") { printf ("%s ", \$11); printf ("%s ", \$13); } else { printf ("%s ", \$12); printf ("%s ", \$14); } }
       print "";
     }'`;

# get progres sessions with PTS number
$data_e = `ps -eaf | grep -v '?' | grep '_progres' | grep -v grep |
          awk ' {printf ("%s ", \$1); printf ("%s ", \$2);
          if (substr(\$8, 1, 3) == "pts") {printf ("%s ", \$8);
          printf ("%s", \$11)} else {printf ("%s ", \$9);
          printf ("%s", \$12);}; print ""; } '` ;

if ($ARGV[0] =~ m/[0aA]/)
{
   print $data_n;
   print $data_e;
}

if ($ARGV[0] =~ m/[1eE]/)
{
   print $data_e;
}

if ($ARGV[0] =~ m/[2nN]/)
{
   print $data_n;
}

if ($ARGV[0] =~ m/[hH]/)
{
   print "Enter 0,a,A = all users\n      1,e,E = existing PTS\n      2,n,N = non-existing PTS\n      h,H  = help\n"; 
}

