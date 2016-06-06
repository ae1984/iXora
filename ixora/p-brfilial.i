/* p-brfilial.i
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Запуск отчетов по текущему филиалу или в ЦО - выбор консолидированный/филиалы
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        01.04.2004 nadejda
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        31/10/2006 madiyar - отчеты формируются в разрезе по программам
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        05/03/2008 madiyar - разбранчевка Банк-МКО, убрал сообщения
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
*/

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
find txb where txb.consolid and txb.bank = sysc.chval no-lock no-error.

if not txb.is_branch then do:
  {sel-filial.i}
end.
else do:
  v-select = txb.txb + 2.
end.

if v-select = 1 then do:

   def var fname as char.
   def var fname1 as char.
   def var quar as inte.

   if month(datums + 1) <= 12 then quar = 4.
   if month(datums + 1) <= 9 then quar = 3.
   if month(datums + 1) <= 6 then quar = 2.
   if month(datums + 1) <= 3 then quar = 1.

   fname  = "/data/reports/push/port-" + string(year(datums + 1)) + "-" + string(month(datums + 1)) + "-" + string(quar) + "-" + string(day(datums + 1)) + "-rep" + string(v-reptype,"9") + ".html".
   fname1 = "/data/reports/push/port-" + string(year(datums + 1)) + "-" + string(month(datums + 1)) + "-" + string(quar) + "-" + string(day(datums + 1)) + "-r-rep" + string(v-reptype,"9") + ".html".

   /*
   message fname "~n" fname1 view-as alert-box.
   */

   FILE-INFO:FILE-NAME = fname.
   IF FILE-INFO:FILE-TYPE = ?
     THEN run p_cicle.
     ELSE do:
         unix silent value ("cptwin " + fname  + " excel").
         unix silent value ("cptwin " + fname1 + " excel").
     end.

end.
else run p_cicle.


procedure p_cicle.

      for each txb where txb.consolid and
               (if v-select = 1 then true else txb.txb = v-select - 2) no-lock:
          if connected ("txb") then disconnect "txb".
          connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + txb.login + " -P " + txb.password).
          run {&proc}.
      end.

      if connected ("txb")  then disconnect "txb".

end.


