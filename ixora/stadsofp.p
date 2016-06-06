/* stadsofp.p
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
        20/09/2004 kanat - убрал проверки по сумме и добавил возможность загрузки информации по авторизации в системе
        30/09/2004 kanat - Добавил дополнительные условия по 13 группе для авторизаций в системе
        10/05/06 sasco - исправление неправильных АРП счетов в загружаемом файле
        12/05/06 sasco - сделал проверку на группу 0 при проверке на наличие типа документа
        09/08/2006 u00568 Evgeniy - + no-undo + transaction
        10/08/2006 u00568 Evgeniy - переделал transaction
        23/08/2006 u00568 Evgeniy - появились платежи алматытелекома которые не должны быть приняты в офлайне. по этому вопросу меняем их на импорте пока не переделаем офлайн
        31/08/2006 u00568 Evgeniy - buffer-copy ... EXCEPT id to comm.commonpl.  + yes-no
*/


{global.i}
{get-dep.i}
{comm-txb.i}
{yes-no.i}

def input parameter v-date-init as date.
def input parameter v-handler as char.
def shared var v-kofc as char.

def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var seltxb as int init 0 no-undo.
def var docnum   as int init 0 no-undo.
def var tran_flag   as int init 0 no-undo /*no-undo не стирать*/.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
def var fname as char no-undo.
def var ourbank as char no-undo.
def var uids as char init '' no-undo.
def var v-fioadr as char no-undo.
def temp-table tmpl like commonpl.
def var pathname as char init 'A:\\' no-undo.
def var s as char init '' no-undo.

def var v-fname-ofc as char no-undo.

def var v-minus-index as integer no-undo.
def var v-dot-index as integer no-undo.
def var v-razn-index as integer no-undo.

def var v-payment-count as integer no-undo.
def var v-payment-comsum as decimal no-undo.
def var v-payment-sum as decimal no-undo.

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
       if substr(s,1,3) = 'com' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_stadlog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_stadlog", 'Окончание импорта.').
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

run savelog( "ofp_stadlog", '------------------------------------------------------------------------------').
run savelog( "ofp_stadlog", 'Начало импорта offline базы : ' + fname).

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

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog("ofp_stadlog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_stadlog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

    i = i + 1.

   if not (can-find (first commonls where commonls.grp = tmpl.grp and commonls.txb = seltxb no-lock )) then
          do:
               put unformatted "Ошибка 4 в строке " string(i,">>9") " - Неизвестная группа: " tmpl.grp skip.
               run savelog( "ofp_stadlog", "Ошибка 4 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.grp.
          end.
    else if tmpl.grp <> 13 and not (can-find (first commonls where commonls.grp = tmpl.grp and
                                   commonls.txb = seltxb and commonls.type = tmpl.type and commonls.visible no-lock)) then
             do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неизвестный тип документа: " tmpl.type skip.
               run savelog( "ofp_stadlog", "Ошибка 1 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.type.
          end.

   find first ofc where ofc.ofc = tmpl.uid and ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 6 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_stadlog", "Ошибка 6 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.

   if not can-do (uids, tmpl.uid) then do:
      if uids = '' then uids = tmpl.uid.
                   else uids = uids + "," + tmpl.uid.
   end.


END.

INPUT CLOSE.
output close.

unix silent rm -f base.d.


for each tmpl where tmpl.sum = 0 and tmpl.grp <> 13:
  delete tmpl.
end.

/* 10/05/06 sasco - исправление неправильных АРП счетов в загружаемом файле */
for each tmpl where tmpl.deluid = ? and tmpl.grp <> 13:
    find first commonls where commonls.txb = seltxb and
                              commonls.grp  = tmpl.grp  and
                              commonls.type = tmpl.type and
                              commonls.visible = yes no-lock no-error.
    if avail commonls then if tmpl.arp <> commonls.arp then tmpl.arp = commonls.arp.
end.

if err > 0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "ofp_stadlog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").

 run menu-prt("errors.txt").
 return.
end.

output to scrout.img.
put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.

   s-num = 0.
   summa = 0.
   comsumma = 0.


for each tmpl where tmpl.deluid = ? and tmpl.grp <> 13 no-lock break by tmpl.arp.
if first-of(tmpl.arp) then do:

find first commonls where commonls.txb = seltxb and
                          commonls.arp  = tmpl.arp  and
                          commonls.grp  = tmpl.grp  and
                          commonls.type = tmpl.type and
                          commonls.visible = yes no-lock no-error.
if avail commonls then
put unformatted ' -- ' + commonls.bn + ' счет ARP: ' + commonls.arp skip.
run savelog( "ofp_stadlog", ' --- ' + commonls.bn + '  Счет ARP: ' + commonls.arp).
end.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.


if last-of(tmpl.arp) then do:
put unformatted ' Количество платежей:  ' + string(s-num,">>>>9") skip.
put unformatted ' Сумма:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' Комиссия:  ' + string(comsumma,">>>,>>>,>>9.99") skip.
put unformatted ' Итого:  ' + string(comsumma + summa,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_stadlog", 'Платежей: ' + string(s-num,">>>>>9")).
run savelog( "ofp_stadlog", 'на сумму: ' + string(summa,">>>,>>>,>>9.99")).
run savelog( "ofp_stadlog", 'комиссия: ' + string(comsumma,">>>,>>>,>>9.99")).
run savelog( "ofp_stadlog", 'Итого: ' + string(comsumma + summa,">>>,>>>,>>9.99")).

    v-payment-count = v-payment-count + s-num.
    v-payment-comsum = v-payment-comsum + comsumma.
    v-payment-sum = v-payment-sum + summa.

   s-num = 0.
   summa = 0.
   comsumma = 0.

end.
end.

put unformatted ' -- ИТОГО: ' skip.
put unformatted 'Платежей: ' + string(v-payment-count,">>>>>>9") skip.
put unformatted 'на сумму: ' + string(v-payment-sum,">>>,>>>,>>9.99") skip.
put unformatted 'комиссия: ' + string(v-payment-comsum,">>>,>>>,>>9.99") skip.
put unformatted 'Итого: ' + string(v-payment-comsum + v-payment-sum,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.


run savelog( "ofp_stadlog", ' -- ИТОГО: ' + fname).
run savelog( "ofp_stadlog", 'Платежей: ' + string(v-payment-count,">>>>>9")).
run savelog( "ofp_stadlog", 'на сумму: ' + string(v-payment-sum,">>>,>>>,>>9.99")).
run savelog( "ofp_stadlog", 'комиссия: ' + string(v-payment-comsum,">>>,>>>,>>9.99")).
run savelog( "ofp_stadlog", 'Итого: '    + string(v-payment-comsum + v-payment-sum,">>>,>>>,>>9.99")).
run savelog( "ofp_stadlog", 'Ошибок: ' + string(err,">>>>9")).


output close.


 run menu-prt("scrout.img").


/* Авторизации в системе кассиров РКО */
m1:
do transaction:
  for each tmpl where tmpl.grp = 13 no-lock ON error UNDO m1:
    CREATE commonpl.
    buffer-copy tmpl EXCEPT id to comm.commonpl.
    update
      commonpl.rko     = get-dep(tmpl.uid, tmpl.date)
      commonpl.txb     = seltxb.
  end.
end. /*tran*/

 if (v-payment-comsum + v-payment-sum) = 0 then
 return.

if not yes-no("Платежи станции диагностики", "Вы действительно хотите импортировать данные в Прагму ?~n" + "Всего записей: " + trim(string(v-payment-count,">>>>9")) + "  На сумму: " + trim(string(v-payment-sum + v-payment-comsum,">>>,>>>,>>9.99"))) then
  return.


docnum = 0.
tran_flag = 0.
m2:
do transaction:
  for each tmpl where tmpl.grp <> 13 no-lock ON error UNDO m2:
    docnum = tmpl.dnum.
    CREATE commonpl.
    buffer-copy tmpl EXCEPT id to comm.commonpl.
    update
      commonpl.rko     = get-dep(tmpl.uid, tmpl.date)
      commonpl.txb     = seltxb.
    if commonpl.arp = '003904589' and commonpl.type = 2 and commonpl.grp = 3 then do:
      commonpl.arp = '000904184'.
      commonpl.type = 1.
    end.
  end.
  tran_flag = 1.
end. /*tran*/

if tran_flag = 0 then do:
  run savelog( "ofp_stadlog", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
  OUTPUT TO errors.txt.
  put unformatted "ofp_stadlog " + ' Строка ' + string(docnum) + '. Ошибка, записи в commonpl.'.
  output close.
  run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в commonpl ~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.
  /*
  MESSAGE "ok" VIEW-AS ALERT-BOX.
  return.
  */

 run stad2arp(v-date-init, v-kofc).

 run mob2arp(v-date-init, v-kofc).



run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "STAD Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).




unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").



run savelog( "ofp_stadlog", 'Завершение импорта базы в АБПК PRAGMA TX').
run savelog( "ofp_stadlog", '------------------------------------------------------------------------------').
