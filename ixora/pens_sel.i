/* import.p
 * MODULE
        Пенсионные платежи (соц. отчисления)
 * DESCRIPTION
        Пенсионные платежи 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        01/14/2005 kanat
 * CHANGES
*/

/* Нужно заранее определить var seltxb as integer */

define temp-table tcommLS like commonLS
    field pix as integer.

def var i as integer.
def new shared var selprc  as decimal format "9.9999".
def new shared var selcom  as decimal format ">>>9.99".
def new shared var selbn   as char.
def new shared var selarp  as char format "x(9)".
def new shared var seltown as char.

def var s-sel   as char.
s-sel = ''. 
seltown = comm-txb().
seltxb = comm-cod().
i = 1.

for each commonls where commonls.txb = seltxb and commonls.visible = no and
                        commonls.grp = selgrp no-lock use-index type break by commonls.arp:
    IF FIRST-OF(commonls.arp) THEN do:
     create tcommls.
     buffer-copy commonls to tcommLS.
     tcommLS.pix = i.
     i = i + 1. 
     s-sel = s-sel + tcommls.bn + '|'.
   end.
end.

s-sel = substring(s-sel,1, length(s-sel) - 1). /* обрезаем последний символ "|" */

run sel('Укажите организацию',s-sel).

find first tcommLS where tcommLS.pix = integer(return-value) no-lock no-error.
if avail tcommLS then do:
                    selarp = string(integer(tcommLS.arp),"999999999").
                    selprc = tcommLS.comprc.
                    selcom = tcommLS.comsum.
                    selbn  = trim(tcommLS.bn). 
/*                    selgrp = tcommLS.grp.    */
                 end.
                 else do:
                   MESSAGE "Не найден или не выбран АРП счет"
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                   TITLE "" .
                   return.
                  end. 

selarp = string(integer(selarp),"999999999").


