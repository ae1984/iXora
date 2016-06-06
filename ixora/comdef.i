/* comdef.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Определение кода комиссии, проставляемого по умолчанию во внешних валютных платежах 
        комиссии различаются по валюте платежа и по статусу ЮЛ/ФЛ
 * RUN
        
 * CALLER
        psroup.p, IBHtrz_ps.p, 3-svch.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-1, 5-2-8 ...
 * AUTHOR
        24.09.2003 nadejda
 * CHANGES
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/

def var v-clnsts as char.
v-clnsts = "0".
find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = {&cif} no-lock no-error.
if avail sub-cod and sub-cod.ccode <> "msc" then v-clnsts = sub-cod.ccode.

case remtrz.fcrc :
  when 4 then do:
    if v-clnsts = "0" then remtrz.svccgr = 218.
                      else remtrz.svccgr = if ourbank = "TXB00" then 209 else 217.
  end.
  when 11 then do:
    if v-clnsts = "0" then remtrz.svccgr = /* if ourbank = "TXB01" then 219 else */ 205.
                      else remtrz.svccgr = 209.
  end.
  otherwise do:
    if v-clnsts = "0" then remtrz.svccgr = 205.
                      else remtrz.svccgr = 209.
  end.
end case.

