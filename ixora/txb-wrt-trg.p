/* txb-wrt-trg.p
 * MODULE

 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        31.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES

*/
TRIGGER PROCEDURE FOR Write OF txb OLD BUFFER oldb.

def var uid as char.

input through value("whoami").
repeat:
  import unformatted uid.
end.

output to value ("/data/log/txb-write.log") append.

put unformatted
    today " " string (time, "HH:MM:SS") " " uid " ".

export delimiter ";" oldb.

export delimiter ";" txb.

output close.

