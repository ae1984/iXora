TRIGGER PROCEDURE FOR Write OF lnsci OLD BUFFER oldb.
                                                           
def var uid as char.                                       

if connected ('bank') then assign uid = userid ('bank').   
                                                      
output to value ("/data/log/lnsci-write.log") append.

put unformatted 
    today " " string (time, "HH:MM:SS") " " uid " ".

export delimiter ";" oldb.

export delimiter ";" lnsci.

output close.       

