/* comm-sel.i
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Формирование списка организаций для зачислений на ARP и отравки платежей по организациям
 * RUN
        
 * CALLER
        comm-arp.p
 * SCRIPT
        
 * INHERIT
        sel.p
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09/08/03 kanat - при формировании буферной таблицы группировка идет по группе и номеру счета, раньше было по номеру ARP
        22/10/03 sasco - добавил no-lock no-error в поиск tcommLS
        20/07/04 kanat - группировку получателей сделал по ARP - счетам и лицевым счетам.


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

for each commonls where commonls.arp <> "" and commonls.visible = yes and commonls.txb = seltxb
                  no-lock use-index type break by commonls.arp by commonls.iik:
    IF FIRST-OF(commonls.arp) THEN do:
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
