/* stad-off.p
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
*/


/* stad-off.p
 * Модуль
     Коммунальные платежи
 * Назначение
     Загрузка платежей станций диагностик и таможенных платежей
 * Применение
     Применяется при загрузке оффлайн - платежей станций диагностик и таможенных платежей
  
 * Вызов
     
 * Меню
     п.3.2.10.7.5 Offline-импорт данных в Прагму

 * Автор
     pragma
 * Дата создания:
     28.05.03
 * Изменения
     11.07.03 kanat выгрузку в commonpl данных по лицевым счетам (поле counter) и дополнительной информации по платежам (info[2]).
     9/08/2006 u00568 Evgeniy - Проанализировав программу пришел к выводу~n ""Она устарела""
*/

message "Программа stad-off.p считается устаревшей, обратитесь в ДИТ!"  view-as alert-box title "".
return.

{global.i}
{get-dep.i}
{comm-txb.i}

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
def var fname as char initial "a:\\com.txt" no-undo.
def var ourbank as char no-undo.
def var seltxb as int no-undo.
def var uids as char init '' no-undo.

ourbank = comm-txb().
seltxb = comm-cod().

update
       "[  Станция диагностики  ]" skip
       vdate label "Укажите дату платежей" skip
       fname format "x(30)" label "Введите имя файла "
       with side-labels centered frame ff.
hide frame ff.

define temp-table tmpl like commonpl.


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
    run savelog( "stadlog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "stadlog", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.
    return.
end.

run savelog( "stadlog", 'Начало импорта offline базы : ' + fname).

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.



REPEAT on error undo, leave:
    CREATE tmpl.
    IMPORT delimiter "|" tmpl.type tmpl.sum tmpl.comsum tmpl.grp tmpl.dnum
           tmpl.uid tmpl.rnn tmpl.fio tmpl.adr tmpl.service tmpl.counter tmpl.info[1]
           NO-ERROR.

    tmpl.date = vdate.

    i = i + 1.

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog("stadlog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "stadlog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

   if substr(trim(tmpl.service),1,3) <> "TXB" or length(trim(tmpl.service)) <> 5 then do:
               put unformatted "Ошибка 10 в строке " string(i,">>9") " -  Не верный код банка (TXB) " skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.service.
   end.

   seltxb = integer(substr(trim(tmpl.service),4,2)).
   
   if not (can-find (first commonls where commonls.grp = tmpl.grp and commonls.txb = seltxb
           and commonls.visible = yes no-lock )) then
          do:
               put unformatted "Ошибка 4 в строке " string(i,">>9") " - Неизвестная группа: " tmpl.grp skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.grp.
          end.
    else if not (can-find (first commonls where commonls.grp = tmpl.grp
                 and commonls.txb = seltxb and commonls.type = tmpl.type and commonls.visible = yes no-lock)) then
             do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неизвестный тип документа: " tmpl.type skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.type.
          end.


   if tmpl.sum <= 0 then do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неверная сумма: " +
               string(tmpl.sum,"->>>,>>>,>>9.99") skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.sum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.sum.
   end.


/*
   if tmpl.comsum <= 0 then do:
               put unformatted "Ошибка 3 в строке " string(i,">>9") " - Неверная сумма комиссии: " +
               string(tmpl.comsum,"->>>,>>>,>>9.99") skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма комиссии: " + string(tmpl.comsum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.comsum.
   end.
*/



   find first ofc where ofc.ofc=tmpl.uid no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 6 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
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

   if length(trim(tmpl.rnn)) <> 12
   then do:
               put unformatted "Ошибка 7 в строке " string(i,">>9") " - Длина РНН не 12: " + tmpl.rnn skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.rnn.
   end.


   if trim(tmpl.fio) = '' then do:
               put unformatted "Ошибка 8 в строке " string(i,">>9") " -  Не заполнено ФИО " skip.
               run savelog( "stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.fio.
   end.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.
END.
INPUT CLOSE.
output close.

unix silent rm -f base.d.

run savelog( "stadlog", 'Окончание импорта offline базы : ' + fname).
run savelog( "stadlog", ' -- Итог offline базы: ' + fname).
run savelog( "stadlog", ' --          Платежей: ' + string(s-num,">>>>9")).
run savelog( "stadlog", ' --          на сумму: ' + string(summa,">>>,>>>,>>9.99")).
run savelog( "stadlog", ' --          комиссия: ' + string(comsumma,">>>,>>>,>>9.99")).
run savelog( "stadlog", ' --            Ошибок: ' + string(err,">>>>9")).

 run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "STAD Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).

unix silent value("rm -f " + fname).



if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "stadlog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").

 run menu-prt("errors.txt").
 return.
end.

logic = false.
 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего записей: " + trim(string(i,">>>>9")) + "  На сумму: " + trim(string(summa,">>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Платежи станции диагностики" UPDATE logic.
         case logic:
            when false then return.
         end.

for each tmpl where tmpl.sum=0:
  delete tmpl.
end.

docnum = 0.
for each tmpl no-lock:
    CREATE commonpl.
    docnum = docnum + 1.
    run cppl.
    if imperr then do:
        run savelog("stadlog", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
        disp 'Ошибка, записи в commonpl'.
        undo.
    end.
END.

procedure cppl.

 imperr = false.

 find first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and
                     commonls.txb = seltxb and commonls.visible = yes no-lock no-error.
 if avail commonls then
    assign
       commonpl.rnnbn = commonls.rnnbn
       commonpl.arp   = commonls.arp
       commonpl.comsum  = tmpl.comsum
       commonpl.grp     = commonls.grp
       commonpl.typegrp = commonls.typegrp
       commonpl.npl = commonls.npl
       commonpl.kb = integer(commonls.kbk)
       no-error.
    else imperr=true.

 update
 commonpl.rko     = get-dep(tmpl.uid, tmpl.date)
 commonpl.txb     = seltxb
 commonpl.date    = tmpl.date
 commonpl.uid     = tmpl.uid
 commonpl.type    = tmpl.type
 commonpl.service = tmpl.service
 commonpl.sum     = tmpl.sum
 commonpl.dnum    = tmpl.dnum
 commonpl.valid   = tmpl.valid
 commonpl.fio      = trim(tmpl.fio)
 commonpl.adr      = trim(tmpl.adr)
 commonpl.fioadr   = trim(tmpl.fio) + "," + trim(tmpl.adr)
 commonpl.rnn      = tmpl.rnn
 commonpl.credate  = today
 commonpl.z        = 1 /* количество ордеров */
 commonpl.cretime  = time
 commonpl.counter  = tmpl.counter
 commonpl.info[1]  = tmpl.info[1].
end.

run savelog( "stadlog", 'Завершение импорта базы в ПРАГМУ').
