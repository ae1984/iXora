/* jsecurities.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        30/09/2008 galina
 * BASES
        BANK COMM
 * CHANGES
*/

def var v-rid as rowid.

def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-dealtype as char no-undo.
def var v-type as char no-undo.
def var v-NID as char no-undo.
def var v-inbal as deci.
def var v-cracc as char no-undo.
def var v-dacc as char no-undo.
def var v-outbal as deci no-undo.
def var i as integer no-undo. 
def var v-sel as integer.

define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jsecurities like jsecurities.
def stream vcrpt.
/*ввод параметров*/
form 
  skip(1)
   v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jsecurities"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-acc2 with frame f-par.

for each jsecurities where (trim(v-acc2) = " " or jsecurities.acc = v-acc2) no-lock use-index acc:
  create t-jsecurities.
  buffer-copy jsecurities to t-jsecurities.
end.


define query qt for t-jsecurities.
define buffer b-jsecurities for t-jsecurities.

define browse bt query qt
       displ t-jsecurities.dealtype label "Вид операции/сделки" format "x(20)"
             t-jsecurities.clname label "Клиент" format "x(40)"
             t-jsecurities.acc label "Лиц.счет" format "x(12)" 
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title "Журнал учета движения цен.бумаг".
form 
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-dealtype label "Вид операции/сделки"  format "x(20)" skip
 v-type label "Вид ценной бумаги" format "x(20)" skip
 v-NID label "НИН" format "x(20)" skip
 v-inbal label "Входящий остаток цен.бумаг" format ">>>>>>>>9.99" skip
 v-dacc label "Дебетовый счет" format "x(12)" skip
 v-cracc label "Кредитовый счет" format "x(12)" skip
 v-outbal label "Исходящий остаток цен.бумаг" format ">>>>>>>>9.99"
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jsecurities where b-jsecurities.acc = t-jsecurities.acc no-lock no-error.
    if avail b-jsecurities then do:
         assign 
             v-clname = b-jsecurities.clname 
             v-acc = b-jsecurities.acc
             v-dealtype = b-jsecurities.dealtype
             v-type = b-jsecurities.type
             v-NID = b-jsecurities.NID
             v-inbal = b-jsecurities.inbal
             v-dacc = b-jsecurities.dacc
             v-cracc = b-jsecurities.cracc
             v-outbal = b-jsecurities.outbal.
        
        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.              
             
        update v-clname v-acc v-dealtype v-type v-NID v-inbal v-dacc v-cracc v-outbal with frame fedit.
        
        find current b-jsecurities exclusive-lock.
         assign 
             b-jsecurities.clname = v-clname 
             b-jsecurities.acc = v-acc
             b-jsecurities.dealtype = v-dealtype
             b-jsecurities.type = v-type
             b-jsecurities.NID = v-NID
             b-jsecurities.inbal = v-inbal
             b-jsecurities.dacc = v-dacc
             b-jsecurities.cracc = v-cracc
             b-jsecurities.outbal = v-outbal.
        find current b-jsecurities no-lock.
    end.
        
    open query qt for each t-jsecurities use-index acc no-lock.
    find first t-jsecurities use-index acc no-lock no-error.
    if avail t-jsecurities then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jsecurities.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jsecurities).
    open query qt for each t-jsecurities where use-index acc no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

on "END-ERROR" of frame ft do: 
   message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
   hide all.
   run journal.
end.

on choose of bsave in frame ft do:
 find first t-jsecurities use-index acc no-lock no-error.
 if avail t-jsecurities then do:
     for each t-jsecurities no-lock use-index acc:
      find first jsecurities where jsecurities.acc = t-jsecurities.acc exclusive-lock no-error.
      if not avail jsecurities then create jsecurities. 
      buffer-copy t-jsecurities to jsecurities.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jsecurities use-index acc no-lock no-error.
if avail t-jsecurities then do:
 output stream vcrpt to "jsecurities.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал учета движения ценных бумаг"
    }
    
   find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал учета движения ценных бумаг</FONT></P>" skip.
    
    if trim(v-acc2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета " + v-acc2 skip.         
    end.
    put stream vcrpt unformatted   
       "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD>№ п/п</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>Вид операции<BR> или сделки</TD>" skip
         "<TD>Наименование<BR>и Нин ценной<BR>бумаги</TD>" skip
         "<TD>Входящий<BR>остаток<BR>ценных бумаг</TD>" skip
         "<TD>Дебетовый<BR>счет</TD>" skip
         "<TD>Кредитовый<BR>счет</TD>" skip
         "<TD>Исходящий<BR>остаток<BR>ценных бумаг</TD>" skip
         "</TR>" skip.
    i = 0.
    
    for each t-jsecurities use-index acc no-lock:
    i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jsecurities.clname "</TD>" skip
      "<TD> &nbsp;" t-jsecurities.acc "</TD>" skip
      "<TD>" t-jsecurities.dealtype "</TD>" skip
      "<TD>" t-jsecurities.type "&nbsp;" t-jsecurities.NID "</TD>" skip
      "<TD>" t-jsecurities.inbal "</TD>" skip
      "<TD>" t-jsecurities.dacc "</TD>" skip
      "<TD>" t-jsecurities.cracc "</TD>" skip
      "<TD>" t-jsecurities.outbal "</TD>" skip      
      "</TR>" skip.
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jsecurities.xls excel").
  unix silent rm -r jsecurities.xls.
end.  
end.

open query qt for each t-jsecurities use-index acc no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
