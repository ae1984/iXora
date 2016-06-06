/* taxsofp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Загрузка платежей станций диагностик и таможенных платежей
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
        06/04/2005 kanat - Убрал лишний update по colord
        09/08/2006 u00568 Evgeniy - убрал один Find,
                                  + исправил ошибку comm.tax.comcode = "03" - зачем-то все коды комиссии модифицировались под одну гребенку
                                  + no-undo
                                  + transaction
        10/08/2006 u00568 Evgeniy - переделал transaction
        19/09/2006 u00568 Evgeniy - buffer-copy ... EXCEPT id to comm.tax.
         3/10/2006 u00568 Evgeniy - если платеж удален, то ошибок импорта он не правоцирует
*/
{global.i}
{get-dep.i}
{getfromrnn.i}

def input parameter v-date-init as date.
def input parameter v-handler as char.
def shared var v-kofc as char.


def var tmpd  as char no-undo.
def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var docnum   as int init 0 no-undo.
def var tran_flag   as int init 0 no-undo /*no-undo не стирать*/.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.

def var logic as logical init false no-undo.
def var fname as char initial "a:\\tax.txt" no-undo.
def var uids as char init '' no-undo.
/*def var v-created as int no-undo.*/

def var v-fname-ofc as char no-undo.

def var pathname as char init 'A:\\' no-undo.
def var s as char init '' no-undo.

def var v-minus-index as integer no-undo.
def var v-dot-index as integer no-undo.
def var v-razn-index as integer no-undo.

def var v-payment-count as integer no-undo.
def var v-payment-comsum as decimal no-undo.
def var v-payment-sum as decimal no-undo.

{comm-txb.i}
def var ourbank as char no-undo.
def var ourcode as integer no-undo.
ourbank = comm-txb().
ourcode = comm-cod().

pathname = v-handler.

pathname = caps(trim(pathname)).
pathname = replace ( pathname , '/', '\\' ).


if index(substr(pathname,length(pathname) ,1), '~\') <= 0 then
  pathname = pathname + '~\'.

input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
repeat:
       import unformatted s.
       if substr(s,1,3) = 'tax' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').

file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_taxlog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_taxlog", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.
    return.
end.

       vdate = date(substr(fname,4,2) + "/" + substr(fname,6,2) + "/" + substr(fname,8,2)).
       v-minus-index = index(fname,"-").
       v-dot-index = index(fname,".").

       v-razn-index = v-dot-index - v-minus-index.
       v-fname-ofc = substr(fname,v-minus-index + 1,v-razn-index - 1).

       /* v-kofc = v-fname-ofc. */ {importkofc.i}

unix silent cat value(fname) | tr '\054' '\056' > base.d.

define temp-table tmpl no-undo like comm.tax.

tmpd = string(day(today),"99") + string(month(today),"99") + substring(string(today,"999999"),5,2) .


run savelog( "ofp_taxlog", '------------------------------------------------------------------------------').
run savelog( "ofp_taxlog", 'Начало импорта offline базы (налоговые платежи): ' + fname).

/*
file-info:file-name = fname.
if file-info:file-type <> ? then do:
unix silent value("rsh `askhost` del " + pathname + fname).
end.
*/


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
  IMPORT delimiter "|" tmpl no-error.

  if CAPS(TRIM(tmpl.uid)) = "EPDADM" then tmpl.uid = v-kofc.

  i = i + 1.

   if tmpl.sum < 0 and tmpl.duid = ? then do:
               put unformatted "Ошибка 2 в строке " string(i,">>>9") " - Неверная сумма: " +
               string(tmpl.sum,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.sum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.sum.
   end.


   find first ofc where ofc.ofc = tmpl.uid no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 3 в строке " string(i,">>>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.

   if not can-do (uids, tmpl.uid) then do:
      if uids = '' then uids = tmpl.uid.
                   else uids = uids + "," + tmpl.uid.
   end.

   if is_it_jur_person_rnn(tmpl.rnn) then
     find first rnnu where rnnu.trn = tmpl.rnn no-lock no-error.
   else
     find first rnn where rnn.trn = tmpl.rnn no-lock no-error.
   if (not avail rnn) and (not avail rnnu) then tmpl.valid = false.
                                           else tmpl.valid = true.

   /*
   if not tmpl.valid then run savelog("taxlog", "Предупреждение: неизвестный РНН: " + string(tmpl.rnn)).
   */
     
   if tmpl.duid = ? and length(trim(tmpl.rnn)) <> 12
   then do:
               put unformatted "Ошибка 4 в строке " string(i,">>>9") " - Длина РНН не 12: " + tmpl.rnn skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn.
   end.

   if tmpl.duid = ? and length(trim(tmpl.rnn_nk)) <> 12
   then do:
               put unformatted "Ошибка 6 в строке " string(i,">>>9") " - Длина РНН НК не 12: " + tmpl.rnn_nk skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn_nk.
   end.

   if tmpl.duid = ? and not (can-find(first comm.taxnk where comm.taxnk.rnn = tmpl.rnn_nk and comm.taxnk.visible = yes no-lock))
   then do:
               put unformatted "Ошибка 6 в строке " string(i,">>>9") " - Неизвестный РНН НК: " + tmpl.rnn_nk skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.rnn_nk.
   end.

   if tmpl.duid = ? and tmpl.com <> yes and tmpl.com <> no then
   do:
               put unformatted "Ошибка 7 в строке " string(i,">>>9")
               " - Не правильный статус взятия комиссии: " + string(tmpl.com) skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.com.
   end.

   if tmpl.duid = ? and tmpl.comu <> yes and tmpl.comu <> no then
   do:
               put unformatted "Ошибка 8 в строке " string(i,">>>9")
               " - Не правильный статус клиента (Юр/Физ): " + string(tmpl.com) skip.
               run savelog( "ofp_taxlog", "Ошибка в строке " + string(i,">>>9")).
               err = err + 1.
               displ tmpl.comu.
   end.

END.

INPUT CLOSE.
output close.

if i = 0 then  return.

unix silent rm -f base.d.

if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>>9") format "x(50)" at 10.
 run savelog( "ofp_taxlog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "TAX Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
 run menu-prt("errors.txt").
 return.
end.


for each tmpl where tmpl.sum=0:
  delete tmpl.
end.

output to scrout.img.
put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.

   s-num = 0.
   summa = 0.
   comsumma = 0.

for each tmpl where tmpl.duid = ? no-lock break by tmpl.dnum.

   if first-of(tmpl.dnum) then
   s-num = s-num + 1.

   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.

end.


put unformatted ' -- ИТОГО: ' skip.
put unformatted 'Платежей:  ' + string(s-num,">>>>9") skip.
put unformatted 'на сумму:  ' + string(summa,">>>,>>>,>>>,>>9.99") skip.
put unformatted 'комиссия:  ' + string(comsumma,">>>,>>>,>>>,>>9.99") skip.
put unformatted 'Итого:  '    + string(comsumma + summa,">>>,>>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_taxlog", ' -- ИТОГО: ' + fname).
run savelog( "ofp_taxlog", 'Платежей: ' + string(s-num,">>>>>9")).
run savelog( "ofp_taxlog", 'на сумму: ' + string(summa,">>>,>>>,>>>,>>9.99")).
run savelog( "ofp_taxlog", 'комиссия: ' + string(comsumma,">>>,>>>,>>>,>>9.99")).
run savelog( "ofp_taxlog", 'Итого: ' + string(comsumma + summa,">>>,>>>,>>>,>>9.99")).
run savelog( "ofp_taxlog", 'Ошибок: ' + string(err,">>>>9")).

output close.


run menu-prt("scrout.img").


  if (comsumma + summa) = 0 then
  return.


logic = false.
 MESSAGE "Вы действительно хотите импортировать данные в Прагму ?~n" +
         "Всего квитанций: " + trim(string(s-num,">>>>>9")) + "  На сумму: " + trim(string(summa + comsumma,">>>,>>>,>>>,>>9.99"))
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Налоговые платежи" UPDATE logic.
         case logic:
            when false then return.
         end.


docnum = 0.
tran_flag = 0.
/*v-created = time.*/
m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    CREATE comm.tax.
    buffer-copy tmpl EXCEPT id to comm.tax.
    assign comm.tax.txb = ourcode.
    /*comm.tax.comcode = "03". */
  end.
  tran_flag = 1.
end. /*tran*/

if tran_flag = 0 then do:
  run savelog( "ofp_taxlog", 'Строка ' + string(docnum) + '. Ошибка, записи в tax.').
  OUTPUT TO errors.txt.
    put unformatted "ofp_taxlog "+ ' Строка ' + string(docnum) + '. Ошибка, записи в tax.'.
  output close.
  run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "TAX Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в tax ~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.
  /*
  MESSAGE "ok" VIEW-AS ALERT-BOX.
  return.
  */

     if (comsumma + summa) <> 0 then
       run tax2arp(v-date-init, v-kofc).


run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "TAX Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).



unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").


run savelog( "ofp_taxlog", 'Завершение импорта базы в АБПК PRAGMA TX').
run savelog( "ofp_taxlog", '------------------------------------------------------------------------------').

/*
message string(vdate) ' ' v-fname-ofc view-as alert-box title "Attention".
*/
