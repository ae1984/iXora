TRIGGER PROCEDURE FOR Write OF pkanketa OLD BUFFER oldb.   
                                                           
def var uid as char.                                       
                                                           
if oldb.sts = pkanketa.sts then return.                    
                                                           
if connected ('bank') then assign uid = userid ('bank').   
else if connected ('txb') then assign uid = userid ('txb').
else uid = userid ('comm').                                
                                                           
output to value ('/data/log/pkanketa-sts-wrt.log') append. 
                                                           
put unformatted                                            
    today " " string (time, "HH:MM:SS") " " uid " "   
    pkanketa.bank " "                                 
    "Credtype = " pkanketa.credtype " "               
    "Ln = " string (pkanketa.ln) " "                  
    "Old status = " oldb.sts " "                      
    "New status = " pkanketa.sts
    skip.
                                                      
output close.                                         
                                                      
