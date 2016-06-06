/* dubsofp.p
 * MODULE
        Импорт выдач дубликатов квитанций
 * DESCRIPTION
        Импорт выдач дубликатов квитанций
 * RUN
      
 * CALLER
        nmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        15/10/04 kanat
 * CHANGES
        18/10/04 kanat - обработка {importkofc.i}
        31/08/2006 u00568 Evgeniy + no-undo + transaction + EXCEPT id + как везде
*/


{global.i}
{get-dep.i}
{comm-txb.i}
{yes-no.i}

def input parameter v-date-init as date.
def input parameter v-handler as char.

def var v-kofc as char no-undo.

def var vdate as date no-undo.
def var i as int init 0 no-undo.
def var s-num as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var seltxb as int init 0.
def var docnum   as int init 0 no-undo.
def var summa    as decimal init 0 no-undo.
def var comsumma as decimal init 0 no-undo.
def var fname as char no-undo.
def var ourbank as char no-undo.
def var uids as char init '' no-undo.
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
       if substr(s,1,3) = 'dub' and substr(s,4,6) = replace(string(v-date-init),"/","") then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').


file-info:file-name = fname.
if file-info:file-type = ? then do:
    run savelog( "ofp_dublog", 'Не найден файл загрузки ' + fname).
/*
    run mail("municipal" + comm-txb() + "@elexnet.kz",
             "NEDOST Offline ERROR", "Ошибка", "Не найден файл загрузки " + fname, "", "", "").
*/
    run savelog( "ofp_dublog", 'Окончание импорта.').
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

run savelog( "ofp_dublog", '------------------------------------------------------------------------------').
run savelog( "ofp_dublog", 'Начало импорта offline базы : ' + fname).


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
        run savelog("ofp_dublog", 'Ошибка импорта Offline в строке ' + string(i) + '. Ошибка импорта.').
        put unformatted "Ошибка 1 в строке " string(i,">>9") skip.

        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:
             run savelog( "ofp_dublog", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
             put unformatted chr(9) + ERROR-STATUS:GET-MESSAGE(j) skip.
        END.
        undo.
    end.

    i = i + 1.

   if not (can-find (first commonls where commonls.grp = tmpl.grp and commonls.type = tmpl.type and commonls.txb = seltxb
           and commonls.visible = no no-lock )) then
          do:
               put unformatted "Ошибка 1 в строке " string(i,">>9") " - Неизвестная группа: " tmpl.grp skip.
               run savelog( "ofp_dublog", "Ошибка 1 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.grp.
          end.
    else if not (can-find (first commonls where commonls.grp = tmpl.grp
                 and commonls.txb = seltxb and commonls.type = tmpl.type and commonls.visible = no no-lock)) then
          do:
               put unformatted "Ошибка 2 в строке " string(i,">>9") " - Неизвестный тип документа: " tmpl.type skip.
               run savelog( "ofp_dublog", "Ошибка 2 в строке " + string(i,">>9")).
               err = err + 1.
               displ tmpl.type.
          end.

   find first ofc where ofc.ofc = tmpl.uid and ofc.ofc = trim(v-kofc) no-lock no-error.
   if not avail ofc then do:
               put unformatted "Ошибка 3 в строке " string(i,">>9") " - Неизвестный Офицер: " + tmpl.uid skip.
               run savelog( "ofp_dublog", "Ошибка 3 в строке " + string(i,">>9")).
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


if err>0 then do:
 disp "Импорт невозможен. Всего ошибок: " + string(err,">>>>9") format "x(50)" at 10.
 run savelog( "ofp_dublog", 'Импорт offline базы невозможен: ' + fname).
/*
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "STAD Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
*/

 run menu-prt("errors.txt").
 return.
end.


for each tmpl where tmpl.comsum = 0:
  delete tmpl.
end.


output to dubolf.img.
put unformatted 'Дата: ' + string(v-date-init) skip.
put unformatted 'Кассир: ' + v-kofc skip.


/* Погашение недостач кассира */
for each tmpl where tmpl.deluid = ? and tmpl.grp = 14 no-lock break by tmpl.dnum.
        v-payment-count = v-payment-count + 1.
        v-payment-comsum = v-payment-comsum + tmpl.comsum.
end.

  put unformatted 'Количество дубликатов: ' + string(v-payment-count,">>>>>>>9") skip.
  put unformatted 'На сумму: ' + string(v-payment-comsum,">>>,>>>,>>9.99") skip.
        put unformatted "------------------------------------------" skip.

output close.

run menu-prt("dubolf.img").

if not yes-no("Выдача дубликатов квитанций", "Импортировать данные по дубликатам кассира в Прагму ?~n") then
  return.

docnum = 0.
tran_flag = 0.
m1:
do transaction:
  for each tmpl no-lock ON error UNDO m1:
    docnum = docnum + 1.
    CREATE commonpl.
    buffer-copy tmpl EXCEPT id to comm.commonpl.
    update
      commonpl.rko     = get-dep(tmpl.uid, tmpl.date)
      commonpl.txb     = seltxb.
  end.
  tran_flag = 1.
end. /*tran*/
if tran_flag = 0 then do:
  run savelog( "ofp_dublog", 'Строка ' + string(docnum) + '. Ошибка, записи в commonpl.').
  OUTPUT TO errors.txt.
  put unformatted "ofp_dublog в dubsofp.p" + ' Строка ' + string(docnum) + '. Ошибка, записи в commonpl.'.
  output close.
  run mail("municipal" + comm-txb() + "@elexnet.kz",
           "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
           "dub Offline ERROR" + string(today,"99.99.99") + " (" + uids + ")", "", "1","", "errors.txt").
  MESSAGE "Ошибка, записи в commonpl в dubsofp.p~n Строка " + string(docnum) VIEW-AS ALERT-BOX.
end.

run dub22arp(v-date-init, v-kofc).

run mail("municipal" + comm-txb() + "@elexnet.kz",
         "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "DUBL Offline Import (" + uids + ") " +
         string(today,"99.99.99") + " for " + string(vdate,"99.99.99"), "", "1", "", fname).


unix silent value("rm -f " + fname + ".Z").
unix silent value("compress " + fname).
unix silent value("mv " + fname + ".Z " + trim(OS-GETENV("DBDIR")) + "/import/offpl").
unix silent value("rm -f " + fname + ".txt").
unix silent value("rm -f " + fname + ".Z").


run savelog( "ofp_dublog", 'Завершение импорта и зачисления погашений недостач в АБПК PRAGMA TX').
run savelog( "ofp_dublog", '------------------------------------------------------------------------------').
