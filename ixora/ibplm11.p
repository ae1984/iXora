/* chk_pbkey.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Проверка ЭЦП
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-1
 * BASES
        BANK COMM IB
 * AUTHOR
        16/12/2005 tsoy 
 * CHANGES
*/                                                 

def new shared var v-rmz like remtrz.remtrz.

form skip v-rmz with frame rmzor side-label row 3  centered .

find sysc where sysc.sysc = "IBHOST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do :

 message " Нет IBHOST записи в sysc файле ! ".
 return.

end.

if not connected("ib") then 
  connect value(sysc.chval) no-error .

if not connected("ib") 
then do:
 message  " INTERNET HOST не отвечает ." .
 return .
end.

update v-rmz label "Платеж" validate (can-find (remtrz where remtrz.remtrz = v-rmz),
     "Платеж не найден !" ) with frame rmzor .

find remtrz where remtrz.remtrz = v-rmz no-error.
if remtrz.source <> "IBH"  then do:
    message  " не платеж интернет INTERNET." .
    return.
end.

run chk_pbkey. 

