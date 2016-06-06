/* joperation.p
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

{global.i}
def var v-rid as rowid.

def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-operdate as date no-undo. 
def var v-operdat1 as date no-undo. 
def var v-operdat2 as date no-undo. 
def var v-opertype as char no-undo.
def var v-type as char no-undo.
def var v-NID as char no-undo.
def var v-ammount as integer no-undo.
def var v-operdesc as char no-undo. 
def var v-accl as logi no-undo.
def var i as integer no-undo.
def var v-sel as integer.

define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-joperation like joperation.
def stream vcrpt.
/*ввод параметров*/
form 
  skip(1)
  v-operdat1 label "Дата операции с " format "99/99/9999"
  validate (v-operdat1 <= g-today or v-operdat1 = ?, " Дата не может быть больше " + string (g-today))
  v-operdat2 label " по " format "99/99/9999" 
  validate (v-operdat2 <= g-today or v-operdat2 = ?, " Дата не может быть больше " + string (g-today)) 
  help "F2 - список лиц.счетов" skip
  v-acc2 label "Лиц.счет" format "x(12)"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "joperation"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-operdat1 v-operdat2 v-acc2 with frame f-par.

if trim(v-acc2) <> " " then v-accl = no. else v-accl = yes.


if v-operdat1 <> ? and v-operdat2 <> ? then do:
  for each joperation where (joperation.operdate >= v-operdat1 and joperation.operdate <= v-operdat2) and (v-accl or joperation.acc = v-acc2) no-lock use-index operdt:
    create t-joperation.
    buffer-copy joperation to t-joperation.
  end.
end.

if trim(v-acc2) <> " " and  (v-operdat1 = ? or v-operdat2 = ?) then do: 
  for each joperation where joperation.acc = v-acc2 no-lock use-index acc:
    create t-joperation.
    buffer-copy joperation to t-joperation.
  end.
end.

if (v-operdate = ? and trim(v-acc2) = " ") then do:
 for each joperation no-lock use-index operdt:
    create t-joperation.
    buffer-copy joperation to t-joperation.
 end.
end.
/**/

define query qt for t-joperation.
define buffer b-joperation for t-joperation.

define browse bt query qt
       displ t-joperation.operdate label "Дата операции" format "99/99/9999"
             t-joperation.opertype label "Вид операции" format "x(20)"
             t-joperation.clname label "Клиент" format "x(40)"
             t-joperation.acc label "Лиц.счет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title " Журнал регистрации операций по лиц.счетам ".

form 
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-operdate label "Дата сделки" format "99/99/9999" skip
 v-opertype label "Вид сделки" format "x(20)" skip
 v-type label "Вид ценной бумаги" format "x(20)" skip
 v-NID label "НИН" format "x(20)" skip
 v-ammount label "Кол-во ценных бумаг" format ">>>>>>>>9" skip
 v-operdesc label "Основание операции" format "x(20)" 
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-joperation where b-joperation.acc = t-joperation.acc no-lock no-error.
    if avail b-joperation then do:
         assign 
             v-clname = b-joperation.clname
             v-acc = b-joperation.acc
             v-operdate = b-joperation.operdate
             v-opertype = b-joperation.opertype
             v-type = b-joperation.type
             v-NID = b-joperation.NID
             v-ammount = b-joperation.ammount
             v-operdesc = b-joperation.operdesc.

        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.  
        
        update v-clname v-acc v-operdate v-opertype v-type v-NID v-ammount v-operdesc with frame fedit.
        
        find current b-joperation exclusive-lock.
         assign 
             b-joperation.clname = v-clname
             b-joperation.acc = v-acc
             b-joperation.operdate = v-operdate
             b-joperation.opertype = v-opertype
             b-joperation.type = v-type 
             b-joperation.NID = v-NID
             b-joperation.ammount = v-ammount
             b-joperation.operdesc = v-operdesc.
        find current b-joperation no-lock.
    end.
    open query qt for each t-joperation use-index operdt no-lock.
    find first t-joperation use-index operdt no-lock no-error.
    if avail t-joperation then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-joperation.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-joperation).
    open query qt for each t-joperation where use-index operdt no-lock.
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
 find first t-joperation use-index operdt no-lock no-error.
 if avail t-joperation then do:
     for each t-joperation no-lock use-index operdt:
      find first joperation where joperation.acc = t-joperation.acc exclusive-lock no-error.
      if not avail joperation then create joperation. 
      buffer-copy t-joperation to joperation.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-joperation use-index operdt no-lock no-error.
if avail t-joperation then do:
 output stream vcrpt to "joperation.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал регистрации операций по лицевым счетам"
    }
    
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал регистрации операций по лицевым счетам</FONT></P>" skip.
    
    if v-operdat1 <> ? and v-operdat2 <> ? then do:
     if v-operdat1 <> v-operdat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата операции c " + string(v-operdat1, '99/99/9999') + " по "  + string(v-operdat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата операции " + string(v-operdat1, '99/99/9999') skip.           
            
     end.
    end.  
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
         "<TD>Дата<BR>проведения<BR>операции</TD>" skip
         "<TD>Вид операции</TD>" skip
         "<TD>Наименование<BR>и Нин ценной<BR>бумаги</TD>" skip
         "<TD>Кол-во<BR>ценных бумаг</TD>" skip
         "<TD>Основание<BR>операции</TD>" skip
         "</TR>" skip.
    i = 0.
    
    for each t-joperation use-index operdt no-lock:
    i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-joperation.clname "</TD>" skip
      "<TD> &nbsp;" t-joperation.acc "</TD>" skip
      "<TD>" t-joperation.operdate "</TD>" skip
      "<TD>" t-joperation.opertype "</TD>" skip
      "<TD>" t-joperation.type "&nbsp;" t-joperation.NID "</TD>" skip
      "<TD>" t-joperation.ammount "</TD>" skip
      "<TD>" t-joperation.operdesc "</TD>" skip
      "</TR>" skip.
      
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin joperation.xls excel").
  unix silent rm -f joperation.xls.
end.  
end.

open query qt for each t-joperation use-index operdt no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
