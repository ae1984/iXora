/* comm-fel.i
 * MODULE
        Коммунальные платежи (отправка коммунальных платежей)
 * DESCRIPTION
        Формирование списка организаций для отправки по организациям (без Алсеко, ИВЦ, АПК, Прочие платежи)
 * RUN
        
 * CALLER
        comm-cif.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        07/04/2005 kanat
 * CHANGES
        06.07.2007 id00004 исключил ИВЦ
*/

define temp-table tcommLS like commonLS
    field pix as integer.

def var i as integer.
def new shared var selprc  as decimal format "9.9999".
def new shared var selcom  as decimal format ">>>9.99".
def new shared var selbn   as char.
def new shared var selarp  as char format "x(9)" init "".
def new shared var selgrp  as integer.

def var s-sel   as char.
s-sel = ''. 
seltxb = comm-cod().
i = 1.

for each commonls where commonls.arp <> "" and commonls.visible = yes and commonls.txb = seltxb and 
                  commonls.arp <> "000904786" /* Алсеко */ and 
                /*  commonls.arp <> "000904883" /* ИВЦ */ and */
                  commonls.arp <> "002904878" /* АПК */ and
                  commonls.arp <> "001076668" /* Прочие */ no-lock use-index type break by commonls.arp by commonls.iik:
    if first-of(commonls.arp) then do:
     create tcommls.
     buffer-copy commonls to tcommLS.
     tcommLS.pix = i.
     i = i + 1. 
     s-sel = s-sel + tcommls.bn + '|'.
   end.
end.

s-sel = substring(s-sel,1, length(s-sel) - 1). 
/* обрезаем последний символ "|" */

run sel('Укажите организацию',s-sel).

find first tcommLS where tcommLS.pix = integer(return-value) no-lock no-error.
if avail tcommLS then do:
                    selarp = string(integer(tcommLS.arp),"999999999").
                    selprc = tcommLS.comprc.
                    selcom = tcommLS.comsum.
                    selbn  = trim(tcommLS.bn). 
                    selgrp = tcommLS.grp.    
                 end.
                 else do:
                   MESSAGE "Не найден АРП счет"
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                   TITLE "Проблема: Выбор АРП-счета" .
                   return.
                  end.
