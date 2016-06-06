/* atvsofp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Загрузка платежей АЛМА TV
 * RUN
      
 * CALLER
        import.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        27/10/2003 kanat
 * CHANGES
        09/12/2003 kanat при импорте проверка на сумму осуществляется только на неудаленные квитанции
        12/12/2003 kanat добавил новую шаренную переменную v-kofc - логин загружаемого кассира
        01/13/2004 kanat убрал проверку по суммам долга абонентов и поставил ее на суммы фактической оплаты (summ -> summfk)
        10/02/2004 kanat убрал проверку на суммы = 0 (они все равно удаляются из временной таблицы)
        23/04/2004 kanat добавил вывод комиссии при выдаче результатов импорта на экран
        06/05/2004 sasco присваивание v-kofc или смена логина кассира epdadm через importkofc.i
                         в отчет пишется v-kofc вместо v-fname-ofc
        25/05/2004 kanat - Добавил удаление всех текстовых файлов после их загрузок в систему
        28/05/2004 kanat - Добавил отправку писем после зачисления операций
        02/06/2004 kanat - Убрал удаление всех текстовых файлов после их загрузок в систему
        11/08/2006 u00568 Evgeniy + no-undo
                                  + transaction
         3/10/2006 u00568 Evgeniy - buffer-copy ... EXCEPT id
         6/10/2006 u00568 Evgeniy - офлайн принимает платежи с кривой кодировкой, поэтому при импорте русскоязычные поля должны сохраниться
         9/10/2006 u00568 Evgeniy - оказывается они ещё и дату не правельную загрузили
        19/10/2006 u00568 Evgeniy - если создается запись, то копируется вся инфа.

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
def var imperr   as logical init false no-undo.
def var logic as logical init false no-undo.
def var fname as char no-undo.
def var ourbank as char no-undo.
def var seltxb as int no-undo.
def var uids as char init '' no-undo.
def var v-fioadr as char no-undo.
def temp-table tmpl like almatv.
def var pathname as char init 'A:\\' no-undo.
def var s as char init '' no-undo.

def var v-fname-ofc as char no-undo.
def var v-minus-index as integer no-undo.
def var v-dot-index as integer no-undo.
def var v-razn-index as integer no-undo.

def shared var v-atv-jh as integer.

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
       if substr(s,1,3) = 'atv' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_atvlog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_atvlog", 'Окончание импорта.').
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

run savelog( "ofp_atvlog", '------------------------------------------------------------------------------').
run savelog( "ofp_atvlog", 'Начало импорта offline базы : ' + fname).


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

    i = i + 1.

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog( "ofp_atvlog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_atvlog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

   if tmpl.summfk < 0 and tmpl.deluid = ? then do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неверная сумма: " +
               string(tmpl.summfk,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_atvlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.summfk,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.summfk.
   end.

   find first ofc where ofc.ofc = tmpl.uid and ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_atvlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.


   if tmpl.dtfk = ? then do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неверная дата: " +
               string(tmpl.dtfk,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_atvlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.dtfk,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.dtfk.
   end.


   if not can-do (uids, tmpl.uid) then do:
      if uids = '' then uids = tmpl.uid.
                   else uids = uids + "," + tmpl.uid.
   end.

END.

INPUT CLOSE.
output close.


unix silent rm -f base.d.


if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "ofp_atvlog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "ALMA TV Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").

 run menu-prt("errors.txt").
 return.
end.


for each tmpl where tmpl.summfk = 0:
  delete tmpl.
end.

for each tmpl where tmpl.deluid = ? no-lock.
   s-num = s-num + 1.
   summa = summa + tmpl.summfk.
   comsumma = comsumma + tmpl.cursfk.
end.


output to scrout.img.

put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.

put unformatted ' -- ИТОГО: ' skip.
put unformatted ' Платежей:  ' + string(s-num,">>>>9") skip.
put unformatted ' На сумму:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' Комиссия:  ' + string(comsumma,">>>,>>>,>>9.99") skip.
put unformatted ' Всего   :  ' + string(summa + comsumma,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_atvlog", ' -- ИТОГО: ' + fname).
run savelog( "ofp_atvlog", 'Платежей: ' + string(s-num,">>>>>9")).
run savelog( "ofp_atvlog", 'На сумму: ' + string(summa,">>>,>>>,>>9.99")).
run savelog( "ofp_atvlog", 'Комиссия: ' + string(comsumma,">>>,>>>,>>9.99")).
run savelog( "ofp_atvlog", 'Всего   : ' + string(summa + comsumma,">>>,>>>,>>9.99")).
run savelog( "ofp_atvlog", 'Ошибок: ' + string(err,">>>>9")).

output close.


 run menu-prt("scrout.img").

logic = false.

 if summa = 0 then
 return.

 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего записей: " + trim(string(s-num,">>>>9")) + "  На общую сумму: " + trim(string(summa + comsumma,">>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Платежи АЛМА TV" UPDATE logic.
         case logic:
            when false then return.
         end.

docnum = 0.
tran_flag = 0.

m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    find first almatv where almatv.ndoc = tmpl.ndoc
                        and almatv.accnt = tmpl.accnt
                        /*and almatv.dt = tmpl.dt*/
                        and almatv.summ = tmpl.summ
                        and almatv.summfk = 0
                        and almatv.dtfk = ?
                        and almatv.state = 0
                      exclusive-lock no-error.
    if not avail almatv then do:
      create almatv.
      buffer-copy tmpl EXCEPT id to comm.almatv.
    end. else
      buffer-copy tmpl EXCEPT id Address f io to comm.almatv.
    release almatv.
  END.
  tran_flag = 1.
end. /*tran*/

if tran_flag = 0 then do:
  disp 'Ошибка, записи в almatv'.
  run savelog( "ofp_atvlog", 'Строка ' + string(docnum) + '. Ошибка, записи в almatv.').
  OUTPUT TO errors.txt.
    put unformatted "ofp_atvlog "+ ' Строка ' + string(docnum) + '. Ошибка, записи в almatv.'.
  output close.
  run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "almatv Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в almatv ~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.
  /*MESSAGE "ok" VIEW-AS ALERT-BOX.
  return.*/



    if summa <> 0 then
    run atv2arp(v-date-init, v-kofc, output v-atv-jh).


run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "ALMA TV Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).



unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").


run savelog( "ofp_atvlog", 'Завершение импорта базы в АБПК PRAGMA TX').
run savelog( "ofp_atvlog", '------------------------------------------------------------------------------').
