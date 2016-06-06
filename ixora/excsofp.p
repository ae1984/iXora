/* excsofp.p
 * MODULE
        Импорт обменных операций Offline PragmaTX
 * DESCRIPTION
        Загрузка обменных операций
 * RUN
      
 * CALLER
        excsofp.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        02/01/04 kanat
 * CHANGES
        02/20/2004 kanat - добавил отправку сообщений по почте после импорта данных с носителей в АБПК Pragma
        28/04/2004 kanat - добавил входные параметры по дате и типу носителя для загрузки данных.
        25/05/2004 kanat - Добавил удаление всех текстовых файлов после их загрузок в систему
        28/05/2004 kanat - Добавил отправку писем после зачисления операций
        28/10/2004 kanat - Добавил удаление текстовых файлов после их загрузок в систему - только обменные операции
        08/11/2004 kanat - Раскомеентировал копирование файлов на сервер
        05/04/2005 kanat - Добавил удаление файлов выдачи в подотчет
        07/07/2005 sasco - Добавил обработку epdadm через v-kofc и importkofc.i
        12/09/2005 kanat Добавил условие по удаленныи квитанциям
        31/08/2006 u00568 Evgeniy + no-undo + transaction + EXCEPT id + как везде
        10/10/2006 u00568 Evgeniy - добавил ошибку "Неизвестная валюта"
*/


{global.i}
{get-dep.i}
{comm-txb.i}
{msg-box.i}
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
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
def var imperr   as logical init false no-undo.
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
def var v-symbol as char no-undo.
def var tran_flag   as int init 0 no-undo /*no-undo не стирать*/.



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
       if substr(s,1,3) = 'exc' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_exclog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "STAD Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_exclog", 'Окончание импорта.').
    disp  "Не найден файл загрузки " + fname.
    return.
end.

unix silent cat value(fname) | tr '\054' '\056' > base.d.


       vdate = date(substr(fname,4,2) + "/" + substr(fname,6,2) + "/" + substr(fname,8,2)).
       v-minus-index = index(fname,"-").
       v-dot-index = index(fname,".").

       v-razn-index = v-dot-index - v-minus-index.
       v-fname-ofc = substr(fname,v-minus-index + 1,v-razn-index - 1).

       /* v-kofc = v-fname-ofc. */
       {importkofc.i}

run savelog( "ofp_exclog", '------------------------------------------------------------------------------').
run savelog( "ofp_exclog", 'Начало импорта offline базы : ' + fname).

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
        run savelog("ofp_exclog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_exclog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

    i = i + 1.

   /*if not (can-find (first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and commonls.txb = seltxb
           and commonls.visible = no no-lock )) then
          do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неизвестная группа: " tmpl.grp skip.
               run savelog( "ofp_exclog", "Ошибка 1 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.grp.
          end.
    else
    if not (can-find (first commonls where commonls.grp = tmpl.grp
                 and commonls.txb = seltxb and commonls.type = tmpl.type and commonls.visible = no no-lock)) then
          do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неизвестный тип документа: " tmpl.type skip.
               run savelog( "ofp_exclog", "Ошибка 2 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.type.
          end.
*/

   find first ofc where ofc.ofc = tmpl.uid and ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 4 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_exclog", "Ошибка 4 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.


   if not can-find(first crc where crc.crc = tmpl.typegrp no-lock) then do:
               put unformatted "Ошибка 5 в строке " string(i,">>9") " - Неизвестная Валюта: " + string(tmpl.typegrp) skip.
               run savelog( "ofp_exclog", "Ошибка 5 в строке " + string(i,">>9") + " - Неизвестная Валюта " + string(tmpl.typegrp)).
               err = err + 1.
               displ ("Ошибка 5 в строке " + string(i,">>9") + " - Неизвестная Валюта: "  + string(tmpl.typegrp) ).
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
 run savelog( "ofp_exclog", 'Импорт offline базы невозможен: ' + fname).
/*
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
*/

 run menu-prt("errors.txt").
 return.
end.


for each tmpl where tmpl.sum = 0:
  delete tmpl.
end.


output to scrout.img.
put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.

   s-num = 0.
   summa = 0.
   comsumma = 0.


/* Обменные операции - покупка валюты */

for each tmpl where tmpl.deluid = ? and tmpl.type = 1 no-lock break by tmpl.type by tmpl.typegrp.

if first-of(tmpl.type) then do:
find first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and commonls.typegrp = tmpl.typegrp no-lock no-error.
if avail commonls then do:
put unformatted ' Обменные операции (покупка валюты)' skip.
run savelog( "ofp_exclog", ' Обменные операции (покупка валюты)').
end.
end.


if first-of(tmpl.typegrp) then do:
find first crc where crc.crc = tmpl.typegrp no-lock no-error.
if avail crc then do:
put unformatted ' Обменные операции (покупка валюты). Валюта - ' + crc.code + " - " + crc.des skip.
run savelog( "ofp_exclog", ' Обменные операции (покупка валюты) Валюта - ' + crc.code  + " - " + crc.des).
end.
end.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.


if last-of(tmpl.typegrp) then do:
put unformatted ' Количество операций:  ' + string(s-num,">>>>9") skip.
put unformatted ' Сумма:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_exclog", 'Операций: ' + string(s-num,">>>>>9")).
run savelog( "ofp_exclog", 'на сумму: ' + string(summa,">>>,>>>,>>9.99")).

    v-payment-count = v-payment-count + s-num.
    v-payment-comsum = v-payment-comsum + comsumma.
    v-payment-sum = v-payment-sum + summa.

   s-num = 0.
   summa = 0.
   comsumma = 0.
end.
end.

   s-num = 0.
   summa = 0.
   comsumma = 0.

   v-payment-count = 0.
   v-payment-sum = 0.
   v-payment-comsum = 0.

/* Обменные операции - продажа валюты */


for each tmpl where tmpl.deluid = ? and tmpl.type = 2 no-lock break by tmpl.type by tmpl.typegrp.

if first-of(tmpl.type) then do:
find first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and commonls.typegrp = tmpl.typegrp no-lock no-error.
if avail commonls then do:
put unformatted ' Обменные операции (продажа валюты)' skip.
run savelog( "ofp_exclog", ' Обменные операции (продажа валюты)').
end.
end.


if first-of(tmpl.typegrp) then do:
find first crc where crc.crc = tmpl.typegrp no-lock no-error.
if avail crc then do:
put unformatted ' Обменные операции (продажа валюты). Валюта - ' + crc.code + " - " + crc.des skip.
run savelog( "ofp_exclog", ' Обменные операции (продажа валюты) Валюта - ' + crc.code + " - " + crc.des).
end.
end.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.


if last-of(tmpl.typegrp) then do:
put unformatted ' Количество операций:  ' + string(s-num,">>>>9") skip.
put unformatted ' Сумма:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_exclog", 'Операций: ' + string(s-num,">>>>>9")).
run savelog( "ofp_exclog", 'на сумму: ' + string(summa,">>>,>>>,>>9.99")).

    v-payment-count = v-payment-count + s-num.
    v-payment-comsum = v-payment-comsum + comsumma.
    v-payment-sum = v-payment-sum + summa.

   s-num = 0.
   summa = 0.
   comsumma = 0.
end.
end.



for each tmpl where tmpl.deluid = ? and tmpl.type = 3 no-lock break by tmpl.type by tmpl.typegrp.

if first-of(tmpl.type) then do:
find first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and commonls.typegrp = tmpl.typegrp no-lock no-error.
if avail commonls then do:
put unformatted ' Обменные операции (покупка неплатежной валюты)' skip.
run savelog( "ofp_exclog", ' Обменные операции (покупка неплатежной валюты)').
end.
end.


if first-of(tmpl.typegrp) then do:
find first crc where crc.crc = tmpl.typegrp no-lock no-error.
if avail crc then do:
put unformatted ' Обменные операции (покупка неплатежной валюты). Валюта - ' + crc.code + " - " + crc.des skip.
run savelog( "ofp_exclog", ' Обменные операции (покупка неплатежной валюты) Валюта - ' + crc.code + " - " + crc.des).
end.
end.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.


if last-of(tmpl.typegrp) then do:
put unformatted ' Количество операций:  ' + string(s-num,">>>>9") skip.
put unformatted ' Сумма:  ' + string(summa,">>>,>>>,>>9.99") skip.
put unformatted ' -------------------------------------------- ' skip.

run savelog( "ofp_exclog", 'Операций: ' + string(s-num,">>>>>9")).
run savelog( "ofp_exclog", 'на сумму: ' + string(summa,">>>,>>>,>>9.99")).

    v-payment-count = v-payment-count + s-num.
    v-payment-comsum = v-payment-comsum + comsumma.
    v-payment-sum = v-payment-sum + summa.

   s-num = 0.
   summa = 0.
   comsumma = 0.
end.
end.



output close.

 run menu-prt("scrout.img").


if not yes-no("Обменные операции", "Импортировать данные по обменным операциям в Прагму ?~n") then
  return.

docnum = 0.
tran_flag = 0.
m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    CREATE commonpl.
    imperr = false.
    buffer-copy tmpl EXCEPT id to comm.commonpl.
    update
      commonpl.rko     = get-dep(tmpl.uid, tmpl.date)
      commonpl.txb     = seltxb.
  end.
  tran_flag = 1.
end. /*tran*/
if tran_flag = 0 then do:
  run savelog( "ofp_exclog", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
  OUTPUT TO errors.txt.
   put unformatted "excsofp.p -Обменные операции- " + ' Строка ' + string(docnum) + '. Ошибка, записи в commonpl.'.
  output close.
  run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в commonpl -Обменные операции-~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.


run exc2arp(v-date-init, v-kofc).  /* Процедура зачисления обменных операций с кассы в ... */
run xcm2arp(v-date-init, v-kofc).  /* Процедура зачисления комиссии за неплатежную валюту ... */

run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "EXCHANGE Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).

    if weekday(today) = 5 or weekday(today) = 6 then do:
      run SHOW-MSG-BOX ("Очистка загруженных текстовых файлов").
      if not yes-no("Внимание", "Произвести очистку файлов?") then do:
        pathname = caps(trim(pathname)).
        pathname = replace ( pathname , '/', '\\' ).
        unix silent value("rsh `askhost` del " + pathname + "exc*.txt").
        unix silent value("rsh `askhost` del " + pathname + "giv*.txt").
      end.
      run HIDE-MSG-BOX.
    end.


unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").


run savelog( "ofp_exclog", 'Завершение импорта и зачисления данных в АБПК PRAGMA TX').
run savelog( "ofp_exclog", '------------------------------------------------------------------------------').
