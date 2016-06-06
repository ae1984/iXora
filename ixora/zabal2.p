def  shared var v-pass as char.

for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
    connect value("-S " + comm.txb.service + " -db " + comm.txb.path + " -ld txb -H " + comm.txb.host + " -U " + comm.txb.login + " -P " + comm.txb.password). 
   run zabaldat.p (comm.txb.bank).
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".



