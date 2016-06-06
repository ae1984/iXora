TRIGGER PROCEDURE FOR Delete OF lnsci.
                                                           
def var uid as char.                                       

if connected ('bank') then assign uid = userid ('bank').   
                                                      
output to value ("/data/log/lnsci-delete.log") append.

put unformatted 
    today " " string (time, "HH:MM:SS") " " uid " ".

export delimiter ";" lnsci.

output close.       

