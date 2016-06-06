/* dubl-com.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Дубликаты коммунальных платежей
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        11.12.2003 sasco
 * CHANGES
        13.12.2003 sasco оптимизировал поиск для известного РНН
        20.04.2004 dpuchkov добавил возможность просмотра документа
        26.04.2004 dpuchkov добавил сообщения для платежей 
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        30.03.2005 kanat - Дубликаты могут делать только сотрудники ЦО
        14.11.2005 saltanat - Внесла возможность выгрузки в Ексель
*/

{yes-no.i}
{comm-txb.i}
{get-dep.i}

def stream v-out.
output stream v-out to dubl-com.html.

define shared variable g-today as date.
define shared variable g-ofc as character.

define variable seltxb as integer.
define new shared variable selgrp as integer.

seltxb = comm-cod().

define variable grpname as character format "x(40)".

define variable v-date1 as date.
define variable v-date2 as date.
define variable v-dnum as integer.
define variable v-rnn as character.
define variable v-sum1 as decimal.
define variable v-sum2 as decimal.
define variable v-fio as character.
define variable v-accnt like commonpl.accnt.
define variable v-counter like commonpl.counter.
define variable v-fioadr like commonpl.fioadr.

def new shared var rnnValid   as logical initial false.
def new shared var doctype as int format ">9".
def new shared var docfio  as char format "x(30)".
def new shared var docadr  as char format "x(50)".
def new shared var docfioadr  as char format "x(80)".
def new shared var docbik  as integer format "999999999".
def new shared var dociik  as integer format "999999999".
def new shared var dockbk  as char format "x(6)".
def new shared var docbn   as char format "x(35)".
def new shared var docbank  as char.
def new shared var dockbe   as char format "x(2)".
def new shared var dockod   as char format "x(2)".
def new shared var docrnn   as char format "x(12)".
def new shared var docrnnnk as char format "x(12)".
def new shared var docrnnbn as char format "x(12)".
def new shared var docnpl   as char format "x(120)".
def new shared var docnum   as integer format ">>>>>>>9".
def new shared var docgrp   as integer.
def new shared var doctgrp  as integer.
def new shared var docarp   as char    format "x(10)".
def new shared var docsum      as decimal format ">>,>>>,>>9.99".
def new shared var doccomsum   as decimal format ">,>>9.99".
def new shared var docprc   as integer  format "9.9999". 
def new shared var bsdate   as date.
def new shared var esdate   as date.
def new  shared var docnumber as char.
def new shared var dockts as char init "".


define variable vd as date.
define variable vcount as integer.

define temp-table tmp like commonpl 
                  field rid as rowid.

/* ------------------------------------------ */
vcount = 0.

define variable s-grp as character.
define variable v-departs as integer.

v-departs = get-dep(g-ofc, g-today).
if seltxb = 0 and v-departs <> 1 then do:
message "Данный режим работы временно недоступен" view-as alert-box title "Внимание".
return.
end.


find first tarif2 where tarif2.num  = "1" and tarif2.kod = "10" 
                    and tarif2.stat = "r" no-lock no-error.
if not avail tarif2 or (avail tarif2 and not (can-find (gl where gl.gl = tarif2.kont no-lock))) then
do: 
    message "Не могу найти счет комисии по 110 тарифу!" view-as alert-box title "".
    return.
end.

/*
define frame getcode s-grp label "КОД ПЛАТЕЖЕЙ (F2 - выбор)" 
             with row 3 centered overlay side-labels.

on HELP of s-grp in frame getcode do:
    run uni_help1 ("comtype", "*").
end.

update s-grp with frame getcode.
hide frame s-grp.

if s-grp <> ? and s-grp <> '' then selgrp = integer (s-grp).
else do:
     message "Ошибка выбора!" view-as alert-box title ''.
     return.
end.

find first commonls where commonls.txb = seltxb and commonls.visible and 
                    commonls.grp = selgrp no-lock no-error.
if not available commonls then do:
     message "Ошибка выбора!" view-as alert-box title ''.
     return.
end.

*/

s-grp = "1".
/* selgrp = 1. */

find codfr where codfr.codfr = "comtype" and codfr.code = s-grp no-lock no-error.
grpname = codfr.name [1].


/* ------------------------------------------ */

v-date1 = g-today.
v-date2 = g-today.
v-sum1 = 0.00.
v-sum2 = 999999999.99.
v-dnum = ?.
v-rnn = ''.
v-fio = ''.
v-accnt = ?.
v-fioadr = ''.
v-counter = 0.

define frame getcom
       grpname label "Платеж" view-as text skip(1)
       v-date1 label "Дата с..." 
       v-date2 label "Дата по..." 
       v-dnum label "Номер док." format "zzzzzz9"
       v-rnn label "РНН" format "x(12)"
       v-fio label "Часть ФИО" format "x(35)"
       v-accnt label "Лицевой счет"
       v-fioadr label "Счет-извещение" format "x(20)"
       v-counter label "Телефон/Счетчик" 
       v-sum1 label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99"
       v-sum2 label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99"
       with row 2 side-labels 1 column centered overlay.

define query qt for tmp.

define browse bt query qt
       displ tmp.date column-label "Дата"
             tmp.dnum column-label "НомДок" format "zzzzzz9"
             tmp.rnn column-label "РНН" format "x(12)"
             tmp.fio column-label "ФИО" format "x(20)"
             tmp.sum column-label "Сумма" format ">>>>>>>>9.99"
       with row 1 centered 15 down title "Выберите платеж".

define frame ft bt help "F2 - печать дубликата, ENTER - просмотр платежа, F6 - Excel".

on "HELP" of bt do:
   if not available tmp then leave.
   if vcount = 0 then do:
     MESSAGE "Внимание! не одного платежа не найдено" VIEW-AS
        ALERT-BOX QUESTION BUTTONS OK.
     leave.
   end.

   if not yes-no ("", "Распечатать дубликат квитанции?") then leave.
   run stadkvit1 (STRING(tmp.rid)).
     MESSAGE "Внимание! Сейчас будет делаться проводка" VIEW-AS
           ALERT-BOX QUESTION BUTTONS OK.
   run dubltrx (tarif2.ost, tarif2.kont, "За выдачу дубликата квитанции").

end.


on "return" of browse bt do:
   if not available tmp then leave.
   run stadin (today, false, tmp.rid).
end.

on "put" of browse bt do:
   if not available tmp then leave.
   run to_excel.
end.

 
 
/* ------------------------------------------ */

update grpname 
       v-date1
       v-date2
       v-dnum 
       v-rnn 
       v-fio
       v-accnt
       v-fioadr
       v-counter
       v-sum1
       v-sum2
       with frame getcom.
hide frame getcom.

/*
do vd = v-date1 to v-date2:
displ vd label "Ждите..." with row 5 centered frame waitfr. pause 0.
*/

displ "Ждите..." with row 5 centered frame waitfr. pause 0.

if v-rnn = '' then
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date1 and 
                        commonpl.date <= v-date2 and 
                        commonpl.deluid = ? and 
                        commonpl.grp = 1 /*selgrp*/ and
                        commonpl.joudoc <> ? 
                        no-lock:

    if (v-fio = '' or (v-fio <> '' and commonpl.fio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or commonpl.dnum = v-dnum) and
       (v-accnt = ? or v-accnt = 0 or commonpl.accnt = v-accnt) and
       (v-fioadr = ? or v-fioadr = '' or commonpl.fioadr = v-fioadr) and
       (commonpl.sum >= v-sum1 and commonpl.sum <= v-sum2) then do:

       create tmp.
       buffer-copy commonpl to tmp.
       tmp.rid = rowid (commonpl).
vcount = vcount + 1.
    end.

end. /* each commonpl */
else
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date1 and 
                        commonpl.date <= v-date2 and 
                        commonpl.rnn = v-rnn and 
                        commonpl.deluid = ? and 
                        commonpl.grp =  1 /*selgrp*/ and
                        commonpl.joudoc <> ? 
                        no-lock:

    if (v-fio = '' or (v-fio <> '' and commonpl.fio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or commonpl.dnum = v-dnum) and
       (v-accnt = ? or v-accnt = 0 or commonpl.accnt = v-accnt) and
       (v-fioadr = ? or v-fioadr = '' or commonpl.fioadr = v-fioadr) and
       (commonpl.sum >= v-sum1 and commonpl.sum <= v-sum2) then do:

       create tmp.
       buffer-copy commonpl to tmp.
       tmp.rid = rowid (commonpl).
vcount = vcount + 1.
    end.

end. /* each commonpl */
/*
end. 
*/

hide frame waitfr. pause 0.

open query qt for each tmp.
enable all with frame ft.
wait-for window-close of current-window focus browse bt.
hide all.
pause 0.


procedure to_excel.

output to dubl-com.txt.

put stream v-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h3>Дубликаты станции диагностики (коммунальные)</h3>" skip. 
put stream v-out unformatted  "<br> С " v-date1 "&nbsp;&nbsp;ПО " v-date2 skip. 


put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip. 

put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                             "<td>Дата</td>"
                             "<td>НомДок</td>"
                             "<td>РНН</td>"
                             "<td>ФИО</td>"
                             "<td>Сумма</td>"
                             "</tr>"
                             skip.

for each tmp :
    put stream v-out unformatted "<tr>"
                      "<td>" string(tmp.date,"99/99/9999")  "</td>"
                      "<td>" tmp.dnum  "</td>"
                      "<td>'" tmp.rnn  "</td>"
                      "<td>" tmp.fio  "</td>"
                      "<td>"  replace(string(tmp.sum,"->>>>>>>>>>>9.99"),'.',',') "</td>"
                      "</tr>"
                      skip.
end.
output close.
output stream v-out close.
unix silent value("cptwin dubl-com.html excel").
end procedure.
