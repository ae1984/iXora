/* eknp_fil.i
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        Отчет по ЕКНП
        нахождение ЕКНП по входящим платежам на филиалы
 * RUN
        run eknpdat.p (remtrz.remtrz, output s_locat, output s_secek, output r_locat, output r_secek, output knp$, output v-country).
 * CALLER
        eknp_dat.i
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8.12.9.7.xxx
 * AUTHOR
        07.06.2004 nadejda
 * CHANGES
        10/10/05 nataly ускорила процесс поиска remtrz
*/


def input parameter p-remtrz like txb.remtrz.remtrz.
def input parameter p-acc like txb.remtrz.racc.
def input parameter p-amt like txb.remtrz.amt.
def output parameter s_locat as char.
def output parameter s_secek as char.
def output parameter r_locat as char.
def output parameter r_secek as char.
def output parameter knp$ as char.
def output parameter v-country as char.
def buffer b-remtrz for txb.remtrz.
def var yes-no as logical init 'no'.
def var v-remtrz like txb.remtrz.remtrz.

for each txb.remtrz where remtrz.racc = p-acc and remtrz.amt = p-amt no-lock.
if txb.remtrz.sqn matches "*" + p-remtrz + "*"  then do: yes-no = true.  v-remtrz = txb.remtrz.remtrz. end. 
end.        

if yes-no = no then  return.
find txb.remtrz where  remtrz.remtrz = v-remtrz no-lock no-error.

find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "eknp" no-lock no-error.
if available txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
    s_locat = substr(txb.sub-cod.rcode, 1, 1).
    s_secek = substr(txb.sub-cod.rcode, 2, 1).
    r_locat = substr(txb.sub-cod.rcode, 4, 1).
    r_secek = substr(txb.sub-cod.rcode, 5, 1).
    knp$ = substr(txb.sub-cod.rcode, 7, 3).
end.

find txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "iso3166" no-lock no-error.
if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then do: 
    v-country = txb.sub-cod.ccode.
end.

