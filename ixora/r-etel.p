/* r-etel.p
 * MODULE
        Бухгалтерская отчетность
 * DESCRIPTION
        Отчет ЕКНП - телеграмма из csv-файла
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        01/05/2011 marinav
 * BASES
        BANK COMM
 * CHANGES
        25/07/2011 madiyar - запрос дат, закрывающая скобка
*/

def new shared var v-dtb as date.
def new shared var v-dte as date.

def shared var g-today as date.

v-dte = date(month(g-today),1,year(g-today)) - 1.
v-dtb = date(month(v-dte),1,year(v-dte)).

update v-dtb format "99/99/9999"
       v-dte format "99/99/9999" skip
       with centered row 13 title "Период" frame frdt.

def temp-table t-eknp
    field sr as char
    field wu as char
    field pr as char
    field sbank as char format "x(12)"
    field rbank as char format "x(12)"
    field s_locat as char
    field s_secek as char
    field cnt1 as char format "x(2)"
    field r_locat as char
    field r_secek as char
    field cnt2 as char format "x(2)"
    field knp as char format "999"
    field crccode as char format "x(3)" label "Вал"
    field sumkzt as deci format "zzz,zzz,zzz,zz9.99-"
    field ptype as char.


define var t-file as char format "x(100)" no-undo.

        input from "222.csv".
        REPEAT on error undo, leave:
           do transaction:
               import unformatted t-file no-error.
               create t-eknp.
               assign t-eknp.sr = entry(1,t-file,";")
                      t-eknp.wu = entry(2,t-file,";")
                      t-eknp.pr = entry(3,t-file,";")
                      t-eknp.sbank = trim(entry(4,t-file,";"))
                      t-eknp.rbank = trim(entry(5,t-file,";"))
                      t-eknp.s_locat = entry(6,t-file,";")
                      t-eknp.s_secek = entry(7,t-file,";")
                      t-eknp.cnt1 = entry(8,t-file,";")
                      t-eknp.r_locat = entry(9,t-file,";")
                      t-eknp.r_secek = entry(10,t-file,";")
                      t-eknp.cnt2 = entry(11,t-file,";")
                      t-eknp.knp = entry(12,t-file,";")
                      t-eknp.crccode = entry(13,t-file,";")
                      t-eknp.sumkzt = deci(entry(14,t-file,";"))
                      t-eknp.ptype = entry(15,t-file,";").

           end.
        end.
        input close.

def var v-msgnum as integer init 0.
find sysc where sysc.sysc = "eknpnm" no-lock no-error.
if avail sysc then v-msgnum = sysc.inval.
v-msgnum = v-msgnum + 1.

define var sum as decimal.

define stream mt998.
output stream mt998 to "temp.exp".

do transaction:
  find sysc where sysc.sysc = "eknpnm" exclusive-lock no-error.
  sysc.inval = v-msgnum.
  release sysc.
end.

put stream mt998 unformatted "\{1:F01K054700000000000000000\}" skip.
put stream mt998 unformatted "\{2:O998SSTAT0000000U3003\}" skip.
put stream mt998 unformatted "\{4:" skip.
put stream mt998 unformatted ":20:MKB" + trim(string(v-msgnum, ">>>>>>>>9")) skip.
put stream mt998 unformatted ":12:800" skip.
put stream mt998 unformatted ":77E:" skip.

put stream mt998 unformatted "/ACCOUNT/NBRKKZKX/KZ98125KZT1001300600" skip.  /*+ */

find bank.sysc where bank.sysc.sysc = "CHIEF" no-lock no-error.
if avail bank.sysc then put stream mt998 unformatted "/CHIEF/" + sysc.chval skip.

find sysc where sysc.sysc = "MAINBK" no-lock no-error.
if avail sysc then put stream mt998 unformatted "/MAINBK/" + sysc.chval skip.

session:date-format = "ymd".
put stream mt998 unformatted "/PERIOD/" + string(v-dtb,"999999") + "/" + string(v-dte,"999999") skip.
session:date-format = "dmy".

put stream mt998 unformatted "/SOURCE/02" skip.
put stream mt998 unformatted "/CLIENT/NBRKKZKX/KZ98125KZT1001300600" skip.


for each t-eknp break
                      by t-eknp.sr      by t-eknp.wu      by t-eknp.pr     by t-eknp.sbank by t-eknp.rbank
                      by t-eknp.s_locat by t-eknp.s_secek by t-eknp.cnt1
                      by t-eknp.r_locat by t-eknp.r_secek by t-eknp.cnt2
                      by t-eknp.knp     by t-eknp.crccode  by t-eknp.ptype :

   ACCUMULATE t-eknp.sumkzt (SUB-TOTAL SUB-COUNT
                      by t-eknp.sr      by t-eknp.wu      by t-eknp.pr     by t-eknp.sbank by t-eknp.rbank
                      by t-eknp.s_locat by t-eknp.s_secek by t-eknp.cnt1
                      by t-eknp.r_locat by t-eknp.r_secek by t-eknp.cnt2
                      by t-eknp.knp     by t-eknp.crccode  by t-eknp.ptype ).

   if last-of (t-eknp.ptype) then do:
      sum = ACCUM SUB-TOTAL by t-eknp.ptype t-eknp.sumkzt.
         put stream mt998 unformatted
           "/INFO/" t-eknp.sr
           "/" t-eknp.wu
           "/" t-eknp.pr
           "/" trim(t-eknp.sbank)
           "//" trim(t-eknp.rbank)
           "//" t-eknp.s_locat
           "/" t-eknp.s_secek
           "/" t-eknp.cnt1
           "/" t-eknp.r_locat
           "/" t-eknp.r_secek
           "/" t-eknp.cnt2
           "/" t-eknp.knp
           "/" ACCUM SUB-COUNT by t-eknp.ptype t-eknp.sumkzt
           "/" trim(replace(string(sum,"->>>>>>>>>>9.99"),".",","))
           "/" caps(t-eknp.crccode)
           "/" t-eknp.ptype   skip.
   end.
end.

put stream mt998 unformatted "-\}" skip.

output stream mt998 close.

