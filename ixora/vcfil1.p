/* vcfil1.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM TXB             
 * AUTHOR
      30.05.2008 galina     
 * CHANGES
*/

def input parameter p-codfr as char.


find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if txb.sysc.chval = "TXB00" then return.

for each txb.codfr where txb.codfr.codfr = p-codfr exclusive-lock:
  delete txb.codfr.
end.

for each bank.codfr where bank.codfr.codfr = p-codfr  no-lock:
 do transaction on error undo, retry:
  create txb.codfr.
  buffer-copy bank.codfr to txb.codfr.
end.
end.