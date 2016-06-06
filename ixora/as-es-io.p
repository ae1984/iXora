/* as-es-io.p
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

/* Оффлайновый импорт данных */
{get-dep.i}
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

/*def shared var g-today as date.*/
def var typeb as char format "x(1)".
def var tmpd  as char no-undo.
def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var docnum   as int init 0 no-undo.
def var temptype as int init 0 no-undo.
def var summa    as decimal init 0 no-undo.
def var imperr   as logical init false no-undo.
def var logic as logical init false no-undo.
def var fname as char initial 'a:\\' no-undo.
define buffer bcommpl for commonpl.

def var d as integer extent 9.

assign
     d[1] = 103
     d[2] = 104
     d[3] = 105
     d[4] = 106
     d[5] = 110
     d[6] = 12
     d[7] = 13
     d[8] = 14
     d[9] = 15.

/*vdate = g-today.*/

update 
       vdate label "Укажите дату платежей" skip
       fname format "x(30)" label "Введите имя файла " 
       with side-labels centered frame ff.
hide frame ff.

/*define temp-table tmpImp like commonpl.
*/

define temp-table tmpl 
  FIELD tDate as date format "99/99/99"
  FIELD tRK   LIKE commonpl.rko
  FIELD tUid  LIKE commonpl.uid
  FIELD tTDoc as integer 
  FIELD tVdoc LIKE commonpl.service
  FIELD tAcc  LIKE commonpl.accnt
  FIELD tFIO  LIKE commonpl.fio
  FIELD tAdr  LIKE commonpl.adr
  FIELD tCnt  LIKE commonpl.counter
  FIELD tAmt  LIKE commonpl.sum
  FIELD tP    LIKE commonpl.valid
  INDEX du tDate tAcc.

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

unix silent cat value(fname) | win2koi > base.d.
/* unix silent cp  base.d value("/tmp/as"+string(time)+".txt")*/

file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "as_energ", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz", "AstanaEnergyService OFF-Importer", "Ошибка", 
    "Не найден файл загрузки " + fname, "", "", ""). 
    run savelog( "as_energ", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.
    return.    
end.

run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "AstanaEnergy Offline Import " +
          string(today,"99.99.99"), "", "1", "", fname).

run savelog( "as_energ", 'Начало импорта offline базы : ' + fname).
unix silent value("rm -f " + fname).

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.

REPEAT on error undo, leave:
    CREATE tmpl.
    IMPORT DELIMITER "|" tmpl except tP tDate no-error.

    tmpl.tDate = vdate.

    i = i + 1.

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog("as_energ", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:         
             run savelog( "as_energ", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

    if (trim(tmpl.tvdoc) <> "C" and trim(tmpl.tvdoc) <> "A" ) then 
          do: 
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неизвестный тип документа: " tmpl.tvdoc skip.
               run savelog( "as_energ", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
          end.

   logic = false.
   do j=1 to 9:
    if tmpl.tTdoc = d[j] then logic = true.
   end.
   if not logic then do: 
               put unformatted "Ошибка 3 в строке " string(i,">>9") " - Неизвестный код услуги" skip.
               run savelog( "as_energ", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
          end.

   find first  as-es-ls where as-es-ls.accnt = string(tmpl.tAcc) no-lock no-error.
   if not avail as-es-ls then tmpl.tp = false.
                        else tmpl.tp = true.

   find first ofc where ofc.ofc=tmpl.tUid no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 4 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.tUid skip.
               run savelog( "as_energ", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
   end.

   tmpl.tRK = get-dep(tmpl.tuid, tmpl.tDate).
   find first ppoint where ppoint.depart = tmpl.tRK no-lock no-error.
   if not avail ppoint then do:
               put unformatted "Ошибка 5 в строке " string(i,">>9") " - Неизвестное СПФ: " + string(tmpl.tRK,">>9") skip.
               run savelog( "as_energ", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
   end.

   if tmpl.tAmt <= 0 then do:
               put unformatted "Ошибка 6 в строке " string(i,">>9") " - Неверная сумма: " + 
               string(tmpl.tAmt,"->>>,>>>,>>9.99") skip.
               run savelog( "as_energ", "Ошибка в строке " + string(i,">>9") + " - Неверная сумма: " + string(tmpl.tAmt,"->>>,>>>,>>9.99")).
               err = err + 1.
   end.
   s-num = s-num + 1.
   summa = summa + tmpl.tAmt.
   disp tmpl.
END.
INPUT CLOSE.
output close.

unix silent rm -f base.d.

run savelog( "as_energ", 'Окончание импорта offline базы : ' + fname).
run savelog( "as_energ", ' -- Итог offline базы: ' + fname).
run savelog( "as_energ", ' --          Платежей: ' + string(s-num,">>>>9")).
run savelog( "as_energ", ' --          на сумму: ' + string(summa,">>>,>>>,>>9.99")).
run savelog( "as_energ", ' --            Ошибок: ' + string(err,">>>>9")).

if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "as_energ", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz","TEXAKABANK <" + userid("bank") + "@elexnet.kz>", 
          "AstanaEnergy Offline Import Error" + string(today,"99.99.99"), "", "1","", "errors.txt").

 run menu-prt("errors.txt").
 return.
end.

logic = false.
 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего записей: " + trim(string(i,">>>>9")) + "  На сумму: " + trim(string(summa,">>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Платежи АстанаЭнергоСервис" UPDATE logic.
         case logic:
            when false then return.
         end.        

for each tmpl where tAmt=0:
  delete tmpl.
end.

for each tmpl no-lock: 
    CREATE commonpl.
    run cppl.
    if imperr then do:
        run savelog("as_energ", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
        disp 'Ошибка, записи в commonpl'.
        undo.
    end.
END.

procedure cppl.
 if tmpl.tTDoc > 100 then temptype = tmpl.tTDoc - 100.
                     else temptype = tmpl.tTDoc.

 imperr=false.
 find first commonls where commonls.grp = 2 and commonls.type = temptype and 
                     commonls.txb = seltxb no-lock no-error.
 if avail commonls then 
    assign
       commonpl.rnnbn = commonls.rnnbn
       commonpl.arp   = commonls.arp
       commonpl.npl   = commonls.npl
       commonpl.comsum  = commonls.comsum
       commonpl.grp     = commonls.grp
       commonpl.typegrp = commonls.typegrp
       no-error.
    else imperr=true.
 
 find last bcommpl where bcommpl.txb = seltxb and bcommpl.date = tmpl.tDate
                         use-index datenum no-lock no-error.
 if avail  bcommpl then docnum = bcommpl.dnum + 1.
                   else docnum = 1.

 update
 commonpl.txb     = seltxb
 commonpl.rko     = tmpl.tRK
 commonpl.date    = tmpl.tDate
 commonpl.uid     = tmpl.tUid
 commonpl.type    = temptype
 commonpl.service = trim(string(tmpl.tTDoc))
 commonpl.sum     = tmpl.tAmt
 commonpl.dnum    = docnum
 commonpl.valid   = tmpl.tP
 commonpl.counter = tmpl.tCnt 
 commonpl.accnt    = tmpl.tAcc
 commonpl.fio      = trim(tmpl.tfio)
 commonpl.adr      = trim(tmpl.tadr)
 commonpl.fioadr   = trim(tmpl.tfio) + "," + trim(tmpl.tadr)
 commonpl.credate  = today.
 commonpl.cretime  = time.
end.

run savelog( "as_energ", 'Завершение импорта базы в ПРАГМУ').
