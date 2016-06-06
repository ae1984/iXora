/* dubl-tax.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Дубликаты налоговых платежей
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
define variable selgrp as integer.

seltxb = comm-cod().

define variable grpname as character format "x(40)".

define variable v-date1 as date.
define variable v-date2 as date.
define variable v-sum1 as decimal.
define variable v-sum2 as decimal.
define variable v-dnum as integer.
define variable v-rnn as character.
define variable v-fio as character.
define variable v-kb as integer.

define variable rnnfio as character.

define variable vd as date.

define variable vcount as integer.

define temp-table tmp like tax 
                  field rid as rowid.

define variable v-departs as integer.
v-departs = get-dep(g-ofc, g-today).
if seltxb = 0 and v-departs <> 1 then do:
message "Данный режим работы временно недоступен" view-as alert-box title "Внимание".
return.
end.

vcount = 0.
for each tmp:
   vcount = vcount + 1.
end.
/* ------------------------------------------ */

grpname = "Налоговые платежи".

find first tarif2 where tarif2.num  = "1" and tarif2.kod = "10" 
                    and tarif2.stat = "r" no-lock no-error.
if not avail tarif2 or (avail tarif2 and not (can-find (gl where gl.gl = tarif2.kont no-lock))) then
do: 
    message "Не могу найти счет комисии по 110 тарифу!" view-as alert-box title "".
    return.
end.

/* ------------------------------------------ */

v-date1 = g-today.
v-date2 = g-today.
v-sum1 = 0.00.
v-sum2 = 999999999.99.
v-dnum = ?.
v-rnn = ''.
v-fio = ''.
v-kb = ?.

define frame getcom
       grpname label "Платеж" view-as text skip(1)
       v-date1 label "Дата с..." 
       v-date2 label "Дата по..." 
       v-dnum label "Номер док." format "zzzzzz9"
       v-rnn label "РНН" format "x(12)"
       v-fio label "Часть ФИО" format "x(35)"
       v-kb label "Код бюджета" format "zzzzz9"
       v-sum1 label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99"
       v-sum2 label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99"
       with row 2 side-labels 1 column centered overlay.

define query qt for tmp.

define browse bt query qt
       displ tmp.date column-label "Дата"
             tmp.dnum column-label "НомДок" format "zzzzzz9"
             tmp.rnn column-label "РНН" format "x(12)"
             tmp.chval[1] column-label "ФИО" format "x(20)"
             tmp.kb column-label "КБК" format "999999"
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
      run taxkvit1 (STRING(tmp.rid)).
      MESSAGE "Внимание! Сейчас будет делаться проводка" VIEW-AS
          ALERT-BOX QUESTION BUTTONS OK.
      run dubltrx (tarif2.ost, tarif2.kont, "За выдачу дубликата квитанции").
end.

on "return" of browse bt do:
   if not available tmp then leave.
   run taxin (today, false, tmp.rid, false).
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
       v-kb
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
for each tax where tax.txb = seltxb and 
                   tax.date >= v-date1 and 
                   tax.date <= v-date2 and 
                   tax.duid = ? and
                   tax.taxdoc <> ?   
                   no-lock:

    rnnfio = TRIM (tax.chval[1]).

    if rnnfio = '' then do:
       find rnn where rnn.trn = tax.rnn no-lock no-error.
       if available rnn then do:
          rnnfio = CAPS (TRIM(TRIM(rnn.lname) + " " + TRIM(rnn.fname) + " " + TRIM(rnn.mname))).
       end.
       else do:
               find rnnu where rnnu.trn = tax.rnn no-lock no-error.
               if available rnnu then do:
                  rnnfio = CAPS (TRIM(TRIM(rnnu.fil) + " " + TRIM(rnnu.busname))).
               end.
       end.
    end.

    if (v-fio = '' or (v-fio <> '' and rnnfio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or tax.dnum = v-dnum) and
       (v-kb = ? or v-kb = 0 or tax.kb = v-kb) and
       (tax.sum >= v-sum1 and tax.sum <= v-sum2) then do:

       create tmp.
       buffer-copy tax to tmp.
       tmp.rid = rowid (tax).
       tmp.chval[1] = rnnfio.
 vcount = vcount + 1.
    end.

end. /* each tax */
else
for each tax where tax.txb = seltxb and 
                   tax.date >= v-date1 and 
                   tax.date <= v-date2 and 
                   tax.duid = ? and
                   tax.rnn = v-rnn and
                   tax.taxdoc <> ?   

                   no-lock use-index rnn:

    rnnfio = TRIM (tax.chval[1]).

    if rnnfio = '' then do:
       find rnn where rnn.trn = tax.rnn no-lock no-error.
       if available rnn then do:
          rnnfio = CAPS (TRIM(TRIM(rnn.lname) + " " + TRIM(rnn.fname) + " " + TRIM(rnn.mname))).
       end.
       else do:
               find rnnu where rnnu.trn = tax.rnn no-lock no-error.
               if available rnnu then do:
                  rnnfio = CAPS (TRIM(TRIM(rnnu.fil) + " " + TRIM(rnnu.busname))).
               end.
       end.
    end.

    if (v-fio = '' or (v-fio <> '' and rnnfio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or tax.dnum = v-dnum) and
       (v-kb = ? or v-kb = 0 or tax.kb = v-kb) and
       (tax.sum >= v-sum1 and tax.sum <= v-sum2) then do:

       create tmp.
       buffer-copy tax to tmp.
       tmp.rid = rowid (tax).
       tmp.chval[1] = rnnfio.
 vcount = vcount + 1.
    end.

end. /* each tax */
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
                             "<td>КБК</td>"
                             "<td>Сумма</td>"
                             "</tr>"
                             skip.

for each tmp :
    put stream v-out unformatted "<tr>"
                      "<td>" string(tmp.date,"99/99/9999")  "</td>"
                      "<td>" tmp.dnum  "</td>"
                      "<td>'" string(tmp.rnn,"x(12)") "</td>"
                      "<td>" tmp.chval[1]  "</td>"
                      "<td>" string(tmp.kb,"999999")  "</td>"
                      "<td>"  replace(string(tmp.sum,"->>>>>>>>>>>9.99"),'.',',') "</td>"
                      "</tr>"
                      skip.
end.

output close.
output stream v-out close.
unix silent value("cptwin dubl-com.html excel").
end procedure.
