#!/usr/bin/perl -X

use Authen::Radius;
  
     $r = new Authen::Radius(Host => '192.168.1.32', Secret => '123');
     print $r->check_pwd($ARGV[0], $ARGV[1], '192.168.1.132'), "\n";

   

                
                        