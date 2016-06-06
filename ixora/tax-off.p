/* tax-off.p
 * MODULE
        Название Программного Модуля
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        9/08/2006 u00568 Evgeniy - Проанализировав программу пришел к выводу~n ""Она устарела""
*/

/* Оффлайновый импорт данных */
/* ДЛЯ НАЛОГОВЫХ */
/* 11.02.2003 sasco - обработка новых параметров
   (дополнительно, резиденство, недоимка, штраф, пеня) */

message "Программа tax-off.p считается устаревшей, обратитесь в ДИТ!"  view-as alert-box title "".
return.

{global.i}
{get-dep.i}

def var tmpd  as char no-undo.
def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var docnum   as int init 0 no-undo.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
def var imperr   as logical init false no-undo.
def var logic as logical init false no-undo.
def var fname as char initial "a:\\tax.txt" no-undo.
def var uids as char init '' no-undo.
def var v-created as int.

{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

update
       "[  Налоговые платежи  ]" skip
       vdate label "Укажите дату платежей" skip
       fname format "x(30)" label "Введите имя файла "
       with side-labels centered frame ff.
hide frame ff.

define temp-table tmpl like comm.tax.


tmpd = string(day(today),"99") + string(month(today),"99") + substring(string(today,"999999"),5,2) .

fname = replace(fname, '\\', '\\\\').

unix silent echo -n \\# > getfile.sh.
unix silent echo '/bin/sh' >> getfile.sh.
unix silent echo -n "rcp " ' ' >> getfile.sh.
unix silent echo -n '\\' >> getfile.sh.
unix silent value("askhost | awk '\{  printf " + '"%s"' + " , $0 }'
>> getfile.sh").
unix silent echo -n ':' >> getfile.sh.
unix silent echo -n value('"' + "'" + '"') >> getfile.sh.
unix silent echo -n value(fname) >> getfile.sh.
unix silent echo -n value('"' + "'" + '"') >> getfile.sh.
unix silent echo -n '\\' >> getfile.sh.
unix silent echo -n './' >> getfile.sh.
unix silent echo -n  >> getfile.sh.
unix silent chmod +x getfile.sh.
unix silent getfile.sh.
unix silent echo y | rm getfile.sh.

fname = trim(substring(fname, r-index(fname, "\\") + 1)).

if search("./" + fname) = ? then do:
    MESSAGE "Невозможно обработать файл: " + fname + "."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE " Проблема: ".
    return.
end.

/* unix silent cat value(fname) | win2koi > base.d. */

 unix silent cat value(fname) | tr '\054' '\056' > base.d.

/* unix silent cp  base.d value("/tmp/as"+string(time)+".txt")*/

file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "taxlog", 'Не найден файл загрузки ' + fname).

/*    run mail("municipal" + ourbank + "@elexnet.kz",
             "TAX Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname,
              "", "", "").  */
    
    run savelog( "taxlog", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.

    return.
end.

run savelog( "taxlog", 'Начало импорта offline базы : ' + fname).

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.


def var v-adr as char.
def var v-fio as char.
def var dr as char.
def var d1 as decimal.
def var d3 as decimal.
def var d4 as decimal.

REPEAT on error undo, leave:
   CREATE tmpl.
   IMPORT delimiter "|" tmpl.dnum tmpl.decval[2] tmpl.uid tmpl.rnn tmpl.kb
   tmpl.rnn_nk tmpl.com tmpl.comu
   tmpl.comsum tmpl.chval[1] v-adr
   tmpl.info dr d1 d3 d4.

   if dr = "0" then tmpl.resid = yes.
               else tmpl.resid = no.

   if d1 <> ? then tmpl.decval[1] = d1.
   if d3 <> ? then tmpl.decval[3] = d3.
   if d4 <> ? then tmpl.decval[4] = d4.

   tmpl.date = vdate.

   i = i + 1.

   if tmpl.info = ? then tmpl.info = "".
   if tmpl.resid <> yes and tmpl.resid <> no then tmpl.resid = yes.


   tmpl.sum = tmpl.decval[1] + tmpl.decval[2] + tmpl.decval[3] + tmpl.decval[4] + tmpl.decval[5].
  
  if tmpl.sum  <= 0 then do:
               put unformatted "Ошибка 2 в строке " string(i,">>>9") " - Неверная сумма: " +
               string(tmpl.sum,"->>>,>>>,>>9.99") skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.sum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.sum.
   end.


   find first ofc where ofc.ofc = tmpl.uid no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 3 в строке " string(i,">>>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.

   if not can-do (uids, tmpl.uid) then do:
      if uids = '' then uids = tmpl.uid.
                   else uids = uids + "," + tmpl.uid.
   end.


   find first rnn where rnn.trn = tmpl.rnn no-lock no-error.
   find first rnnu where rnnu.trn = tmpl.rnn no-lock no-error.
   if (not avail rnn) and (not avail rnnu) then tmpl.valid = false.
                                           else tmpl.valid = true.

   /*
   if not tmpl.valid then run savelog("taxlog", "Предупреждение: неизвестный РНН: " + string(tmpl.rnn)).
   */
     
   if length(trim(tmpl.rnn)) <> 12
   then do:
               put unformatted "Ошибка 4 в строке " string(i,">>>9") " - Длина РНН не 12: " + tmpl.rnn skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn.
   end.

   if length(trim(tmpl.rnn_nk)) <> 12
   then do:
               put unformatted "Ошибка 6 в строке " string(i,">>>9") " - Длина РНН НК не 12: " + tmpl.rnn_nk skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn_nk.
   end.

   if not (can-find(first comm.taxnk where comm.taxnk.rnn = tmpl.rnn_nk and comm.taxnk.visible = yes no-lock))
   then do:
               put unformatted "Ошибка 6 в строке " string(i,">>>9") " - Неизвестный РНН НК: " + tmpl.rnn_nk skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn_nk.
   end.

   if tmpl.com <> yes and tmpl.com <> no then
   do:
               put unformatted "Ошибка 7 в строке " string(i,">>>9")
               " - Не правильный статус взятия комиссии: " + string(tmpl.com) skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.com.
   end.

   if tmpl.comu <> yes and tmpl.comu <> no then
   do:
               put unformatted "Ошибка 8 в строке " string(i,">>>9")
               " - Не правильный статус клиента (Юр/Физ): " + string(tmpl.com) skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.comu.
   end.

   if tmpl.comsum <= 0 then do:
               put unformatted "Ошибка 9 в строке " string(i,">>>9") " - Неверная сумма комиссии: " +
               string(tmpl.comsum,"->>>,>>>,>>9.99") skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9") +
                            " - Неверная сумма комиссии: " + string(tmpl.comsum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.comsum.
   end.


   v-fio = tmpl.chval[1].


   if trim(v-fio) = '' then do:
               put unformatted "Ошибка 10 в строке " string(i,">>>9") " -  Не заполнено ФИО " skip.
               run savelog( "taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ v-fio.
   end.


   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.
END.
INPUT CLOSE.
output close.

unix silent rm -f base.d.

run savelog( "taxlog", 'Окончание импорта offline базы : ' + fname).
run savelog( "taxlog", ' -- Итог offline базы: ' + fname).
run savelog( "taxlog", ' --          Платежей: ' + string(s-num,">>>>>9")).
run savelog( "taxlog", ' --          на сумму: ' + string(summa,">>>,>>>,>>9.99")).
run savelog( "taxlog", ' --          комиссия: ' + string(comsumma,">>>,>>>,>>9.99")).
run savelog( "taxlog", ' --            Ошибок: ' + string(err,">>>>>9")).



/* run mail("municipal" + ourbank + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "TAX Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname). */
unix silent value("rm -f " + fname).


/* сообщение об ошибках */
if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>>9") format "x(50)" at 10.
 run savelog( "taxlog", 'Импорт offline базы невозможен: ' + fname).
/* run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "TAX Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt"). */

 run menu-prt("errors.txt").
 return.
end.

logic = false.
 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего записей: " + trim(string(i,">>>>>9")) + "  На сумму: " + trim(string(summa,">>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Налоговые платежи" UPDATE logic.
         case logic:
            when false then return.
         end.

for each tmpl where tmpl.sum=0:
  delete tmpl.
end.

docnum = 0.
v-created = time.
for each tmpl no-lock:
    docnum = docnum + 1.
    CREATE comm.tax.
    run cppl.
    if imperr then do:
        run savelog("taxlog", 'Строка ' + string(docnum) + '. Ошибка, записи в tax.').
        disp 'Ошибка, записи в tax'.
        undo.
    end.
END.

procedure cppl.
 imperr=false.
 buffer-copy tmpl to comm.tax.
 assign comm.tax.txb = ourcode
  comm.tax.date = vdate
        comm.tax.comcode = "03"
        comm.tax.created = v-created
        comm.tax.colord = 1.
end.

run savelog( "taxlog", 'Завершение импорта базы в ПРАГМУ').
