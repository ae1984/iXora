/* findaaa1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        05/05/2011 evseev - поиск счета
 * BASES
        BANK COMM TXB
 * CHANGES
        05.10.2012 evseev - ТЗ-797
        13.03.2013 evseev - tz-1633
*/
def input parameter i-aaa like txb.aaa.aaa no-undo.
def output parameter  o-isfindaaa as logical no-undo.
def output parameter  o-sta like txb.aaa.sta no-undo.
def output parameter o-bin as char no-undo.
def output parameter o-cifname as char no-undo.
def output parameter o-lgr as char no-undo.

{chbin_txb.i}
o-isfindaaa = false.
find first txb.aaa where txb.aaa.aaa = i-aaa no-lock no-error.
if avail txb.aaa then do:
  find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
  if avail txb.cif then do:
     if v-bin then  o-bin = txb.cif.bin. else  o-bin = txb.cif.jss.
     o-cifname = txb.cif.prefix + " " + txb.cif.name.
  end. else do:
     o-bin = "".
     o-cifname = "".
  end.
  o-sta = txb.aaa.sta.
  o-lgr = txb.aaa.lgr.
  o-isfindaaa = true.
end.