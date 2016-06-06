/* possofp.p
 * MODULE
        Offline PragmaTX
 * DESCRIPTION
        Выдачи наличных через POS (импорт информации с внешних носителей)
 * RUN
      
 * CALLER
        import.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        27/05/05 kanat
 * CHANGES
        11/08/2006 u00568 Evgeniy + no-undo + transaction
        05/09/2006 u00568 Evgeniy - buffer-copy ... EXCEPT id to comm.commonpl.  + yes-no
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
def var docnum   as int init 0 no-undo.
def var tran_flag  as int init 0 no-undo.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
def var imperr   as logical init false no-undo.
/*def var logic as logical init false no-undo.*/
def var fname as char no-undo.
def var ourbank as char no-undo.
def var seltxb as int no-undo.
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
       if substr(s,1,3) = 'pos' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_poslog", 'Не найден файл загрузки ' + fname).
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "POS Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
    run savelog( "ofp_poslog", 'Окончание импорта.').
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

run savelog( "ofp_poslog", '------------------------------------------------------------------------------').
run savelog( "ofp_poslog", 'Начало импорта платежей (POS-terminal) : ' + fname).

/*
file-info:file-name = fname.
if file-info:file-type <> ? then do:
unix silent value("rsh `askhost` del " + pathname + fname).
end.
*/


INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.


repeat on error undo, leave:
    CREATE tmpl.
    IMPORT delimiter "|" tmpl no-error.

    if CAPS(TRIM(tmpl.uid)) = "EPDADM" then tmpl.uid = v-kofc.

    tmpl.date = vdate.

    i = i + 1.

    IF ERROR-STATUS:ERROR then do:
        err = err + 1.
        run savelog( "ofp_poslog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_poslog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

   if tmpl.sum <= 0 and tmpl.deluid = ? then do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неверная сумма: " +
               string(tmpl.sum,"->>>,>>>,>>9.99") skip.
               run savelog( "ofp_poslog", "Ошибка 1 в строке " + string(i,">>9") +
                            " - Неверная сумма: " + string(tmpl.sum,"->>>,>>>,>>9.99")).
               err = err + 1.
               displ tmpl.sum.
   end.

   find first ofc where ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_poslog", "Ошибка 2 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.uid.
   end.
end.

INPUT CLOSE.
output close.


unix silent rm -f base.d.


for each tmpl where tmpl.sum = 0.
    delete tmpl.
end.


if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "ofp_poslog", 'Импорт offline базы невозможен: ' + fname).
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "POS-terminal Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
 run menu-prt("errors.txt").
 return.
end.

   s-num = 0.



output to scrout.img.
put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip(1).

put unformatted "Список операций выдач наличных через POS-terminal" skip(1).

put unformatted "Номер     " " Сумма         " " Комиссия      " " Валюта "   skip.
put unformatted fill("-",50) skip.


for each tmpl where tmpl.deluid = ? no-lock.

   s-num = s-num + 1.
   summa = summa + tmpl.sum.
   comsumma = comsumma + tmpl.comsum.

find first crc where crc.crc = tmpl.typegrp no-lock no-error.
if avail crc then
put unformatted string(tmpl.dnum) format "x(10)" " " string(tmpl.sum) format "x(15)" " " string(tmpl.comsum) format "x(15)" " "
                crc.code  skip.

run savelog( "ofp_poslog", 'Операций: '  + string(s-num,">>>>>9")).
end.

put unformatted fill("-",50) skip.
output close.

run menu-prt("scrout.img").

 if (comsumma + summa) = 0 then
   return.

if not yes-no("POS-terminal", "Вы действительно хотите импортировать данные в Прагму ?~n" + "Всего операций выдач наличных: " + trim(string(s-num,">>>>>>>>>9"))) then
  return.

for each tmpl where tmpl.sum = 0:
  delete tmpl.
end.

docnum = 0.
tran_flag = 0.

m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    CREATE commonpl.
    buffer-copy tmpl EXCEPT id to commonpl.
    update
      commonpl.txb  =  seltxb.
  end.
  tran_flag = 1.
end. /*tran*/

if tran_flag = 0 then do:
  disp 'Ошибка, записи в commonpl - обратитесь в ДИТ'.
  run savelog( "ofp_poslog", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
  OUTPUT TO errors.txt.
    put unformatted "possofp.p  ofp_poslog "+ ' Строка ' + string(docnum) + '. Ошибка, записи в commonpl.'.
  output close.
  run mail("municipal" + ourbank + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "possofp.p commonpl Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в commonpl в possofp.p ~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
  return.
end.
  /*MESSAGE "ok" VIEW-AS ALERT-BOX.
  return.*/




if (summa + comsumma) <> 0 then
run pos2arp(v-date-init, v-kofc).

run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "POS-terminal Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).




unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").

run savelog( "ofp_poslog", 'Завершение импорта платежей в АБПК PRAGMA TX').
run savelog( "ofp_poslog", '------------------------------------------------------------------------------').
