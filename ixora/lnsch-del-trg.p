TRIGGER PROCEDURE FOR Delete OF lnsch.
                                                           
def var uid as char.                                       

if connected ('bank') then assign uid = userid ('bank').   
                                                      
output to value ("/data/log/lnsch-delete.log") append.

put unformatted 
    today " " string (time, "HH:MM:SS") " " uid " " .

export lnsch.

output close.       

