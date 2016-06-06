/* pensofp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Загрузка пенсионных платежей
 * RUN
      
 * CALLER
        import.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        27/10/03 kanat
 * CHANGES
        09/12/2003 kanat при импорте проверка на сумму осуществляется только на неудаленные квитанции
        12/12/2003 kanat добавил новую шаренную переменную v-kofc - логин загружаемого кассира
        10/02/2004 kanat убрал проверку на суммы = 0 (они все равно удаляются из временной таблицы)
        06/05/2004 sasco присваивание v-kofc или смена логина кассира epdadm через importkofc.i
        25/05/2004 kanat - Добавил удаление всех текстовых файлов после их загрузок в систему
        28/05/2004 kanat - Добавил отправку писем после зачисления операций
        02/06/2004 kanat - Убрал удаление всех текстовых файлов после их загрузок в систему
        09/08/2006 u00568 Evgeniy + no-undo
                                  + transaction
        10/08/2006 u00568 Evgeniy переделал transaction

*/

{global.i}
{get-dep.i}
{comm-txb.i}

def input parameter v-date-init as date.
def input parameter v-handler as char.
def shared var v-kofc as char.


def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var docnum   as int init 0 no-undo.
def var tran_flag  as int init 0 no-undo.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
/*def var imperr   as logical init false no-undo.*/
def var logic as logical init false no-undo.
def var fname as char no-undo.
def var ourbank as char no-undo.
def var seltxb as int no-undo.
def var uids as char init '' no-undo.
def var v-fioadr as char no-undo.
def temp-table tmpl  no-undo like p_f_payment.
def var pathname as char init 'A:\\' no-undo.
def var s as char init '' no-undo.

def var v-fname-ofc as char no-undo.

def var v-minus-index as integer no-undo.
def var v-dot-index as integer no-undo.
def var v-razn-index as integer no-undo.

def var v-payment-count as integer no-undo.
def var v-payment-comsum as decimal no-undo.
def var v-payment-sum as decimal no-undo.

def shared var v-pen-jh as integer.

ourbank = comm-txb().
seltxb = comm-cod().

pathname = v-handler.

pathname = caps(trim(pathname)).
pathname = replace ( pathname , '/', '\\' ).


if index(substr(pathname,length(pathname) ,1), '~\') <= 0
   then pathname = pathname + '~\'.
input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
repeat:
       import unformatted s.
       if substr(s,1,3) = 'pen' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_penslog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_penslog", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.
    return.
end.

unix silent cat value(fname) | tr '\054' '\056' > base.d.


       vdate = date(substr(fname,4,2) + "/" + substr(fname,6,2) + "/" + substr(fname,8,2)).
       v-minus-index = index(fname,"-").
       v-dot-index = index(fname,".").

       v-razn-index = v-dot-index - v-minus-index.
       v-fname-ofc = substr(fname,v-minus-index + 1,v-razn-index - 1).

       /* v-kofc = v-fname-ofc. */ {importkofc.i}

run savelog( "ofp_penslog", '------------------------------------------------------------------------------').
run savelog( "ofp_penslog", 'Начало импорта offline базы : ' + fname).

/*
file-info:file-name = fname.
if file-info:file-type <> ? then do:
unix silent value("rsh `askhost` del " + pathname + fname).
end.
*/


INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.



REPEAT on error undo, leave:
    CREATE tmpl.
    IMPORT delimiter "|" tmpl no-error.

    if CAPS(TRIM(tmpl.uid)) = "EPDADM" then tmpl.uid = v-kofc.

    tmpl.date = vdate.

    i = i + 1.

    put unformatted tmpl.dnum tmpl.date tmpl.amt tmpl.deldate tmpl.deluid tmpl.delwhy skip.

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog( "ofp_penslog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_penslog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

   if tmpl.rnn = "" then do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " -  Отсутствует РНН плательщика " skip.
               run savelog( "ofp_penslog", "Ошибка 1 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.rnn.
   end.



   if tmpl.amt < 0 and tmpl.deluid = ? then do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неверная сумма: " +
               string(tmpl.amt,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_penslog", "Ошибка 2 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.amt,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.amt.
   end.


/*
   if tmpl.name = "" then do:
               put unformatted "Ошибка 3 в строке " string(i,">>9") " - Наименование плательщика отсутствует: " +
               string(tmpl.amt,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_penslog", "Ошибка 3 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.name,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.name.
   end.
*/


   if tmpl.cod = 0 then do:
               put unformatted "Ошибка 4 в строке " string(i,">>9") " - Отсутствует код платежа: " +
               string(tmpl.cod,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_penslog", "Ошибка 4 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.cod,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.cod.
   end.


   if tmpl.dnum = 0 then do:
               put unformatted "Ошибка 5 в строке " string(i,">>9") " - Отсутсвует номер квитанции: " +
               string(tmpl.dnum,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_penslog", "Ошибка 5 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.dnum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.dnum.
   end.

   if tmpl.qty <= 0 then do:
               put unformatted "Ошибка 7 в строке " string(i,">>9") " - Неверное количество плательщиков: " +
               string(tmpl.qty,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_penslog", "Ошибка 7 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.qty,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.qty.
   end.


   if length(trim(tmpl.rnn)) <> 12
   then do:
               put unformatted "Ошибка 9 в строке " string(i,">>>9") " - Длина РНН плательщика не 12: " + tmpl.rnn skip.
               run savelog( "ofp_penslog", "Ошибка 9 в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn.
   end.




   /* обработка только тех платежей у которых есть РНН ПФ, и которые не прочие */
   if tmpl.cod <> 400 or trim (tmpl.distr) <> '' then do:
   if tmpl.distr = "" then do:
               put unformatted "Ошибка 9 в строке " string(i,">>9") " -  Отсутствует РНН пенсионного фонда " skip.
               run savelog( userid("bank") + "_penslog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.distr.
   end.


 
      if length(trim(tmpl.distr)) <> 12
      then do:
               put unformatted "Ошибка 10 в строке " string(i,">>>9") " - Длина РНН пенсионного фонда не 12: " + tmpl.distr skip.
               run savelog(  userid("bank") + "_penslog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.distr.
      end.

/*
      find first p_f_list where p_f_list.rnn = tmpl.distr no-lock no-error.
      if not avail p_f_list then do:
               put unformatted "Ошибка 11 в строке " string(i,">>9") " - Неизвестный пенсионный фонд: " + tmpl.uid skip.
               run savelog( userid("bank") + "_stadlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.distr.
      end.
*/
   end.
   else tmpl.distr = '000000000000'.



   find first ofc where ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 12 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_penslog", "Ошибка 12 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.


END.

INPUT CLOSE.
output close.


unix silent rm -f base.d.


for each tmpl where tmpl.amt = 0.
    delete tmpl.
end.


if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "ofp_penslog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "PENSION Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
 run menu-prt("errors.txt").
 return.
end.

   s-num = 0.

for each tmpl where tmpl.deluid = ? no-lock.
   s-num = s-num + 1.
   summa = summa + tmpl.amt.
   comsumma = comsumma + tmpl.comiss.
end.



output to scrout.img.

put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.

put unformatted ' -- ИТОГО: ' skip.
put unformatted ' Платежей:  ' + string(s-num,">>>>9") skip.
put unformatted ' на сумму:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' комиссия:  ' + string(comsumma,">>>,>>>,>>9.99") skip.
put unformatted ' Итого:  '    + string(comsumma + summa,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_penslog", ' -- ИТОГО: ' + fname).
run savelog( "ofp_penslog", 'Платежей: '  + string(s-num,">>>>>9")).
run savelog( "ofp_penslog", 'на сумму: '  + string(summa,">>>,>>>,>>9.99")).
run savelog( "ofp_penslog", 'комиссия: '  + string(comsumma,">>>,>>>,>>9.99")).
run savelog( "ofp_penslog", 'Итого: '     + string(comsumma + summa,">>>,>>>,>>9.99")).
run savelog( "ofp_penslog", 'Ошибок: '    + string(err,">>>>9")).

output close.


run menu-prt("scrout.img").


 if (comsumma + summa) = 0 then
 return.


logic = false.
 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего записей: " + trim(string(s-num,">>>>9")) + "  На сумму: " + trim(string(summa + comsumma,">>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Пенсионные и прочие платежи" UPDATE logic.
         case logic:
            when false then return.
         end.


for each tmpl where tmpl.amt = 0:
  delete tmpl.
end.


docnum = 0.
tran_flag = 0.

m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    CREATE p_f_payment.
    buffer-copy tmpl to comm.p_f_payment.
    p_f_payment.txb = seltxb.
  END.
  tran_flag = 1.
end. /*tran*/


if tran_flag = 0 then do:
  run savelog( "ofp_penslog", 'Строка ' + string(docnum) + '. Ошибка, записи в p_f_payment.').
  OUTPUT TO errors.txt.
    put unformatted "ofp_penslog "+ ' Строка ' + string(docnum) + '. Ошибка, записи в p_f_payment.'.
  output close.
  run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "TAX Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в p_f_payment ~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.
  /*MESSAGE "ok" VIEW-AS ALERT-BOX.
  return.*/


if (summa + comsumma) <> 0 then
run pen2arp(v-date-init, v-kofc, output v-pen-jh).



run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "PENSION Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).




unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").


run savelog( "ofp_penslog", 'Завершение импорта базы в АБПК PRAGMA TX').
run savelog( "ofp_penslog", '------------------------------------------------------------------------------').
