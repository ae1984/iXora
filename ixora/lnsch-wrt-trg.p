TRIGGER PROCEDURE FOR Write OF lnsch OLD BUFFER oldb.
                                                           
def var uid as char.                                       

if connected ('bank') then assign uid = userid ('bank').   
                                                      
output to value ("/data/log/lnsch-write.log") append.

put unformatted 
    today " " string (time, "HH:MM:SS") " " uid " ".

export delimiter ";" oldb.

export delimiter ";" lnsch.

output close.       

