/* jprofit.p
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
def var v-type as char no-undo.
def var v-NID as char no-undo.
def var v-NID2 as char no-undo.
def var v-ammount as integer no-undo.
def var v-date as date no-undo. 
def var v-dat1 as date no-undo. 
def var v-dat2 as date no-undo. 
def var v-summ as deci no-undo.
def var v-profitprop as char no-undo.
def var i as integer no-undo. 
def var v-accl as logi no-undo.
def var v-datel as logi no-undo. 
def var v-NIDl as logi no-undo.
def var v-sel as integer.
define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jprofit like jprofit.
def stream vcrpt.

/*ввод параметров*/
form 
  skip(1)
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов" skip
  v-dat1 label "Дата поступления доходов c " format "99/99/9999" 
  validate (v-dat1 <= g-today or v-dat1 = ?, " Дата не может быть больше " + string (g-today))
  v-dat2 label " по " format "99/99/9999" 
  validate (v-dat2 <= g-today or v-dat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-NID2 label "НИН" format "x(10)" help "F2 - список НИН"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jprofit"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on help of v-NID2 in frame f-par do:
 {jsprav.i
  &table = "jprofit"
  &field = "NID"
  &flname = "'ВЫБЕРИТЕ НИН'"}
  if v-sel <> 0 then v-NID2 = entry(v-sel,v-list,'|').
  display v-NID2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-acc2 v-dat1 v-dat2 v-NID2 with frame f-par.


if v-dat1 <> ? and v-dat2 <> ? then v-datel = no. else v-datel = yes.  
if trim(v-NID2) <> " " then v-NIDl = no. else v-NIDl = yes.

if trim(v-acc2) <> " " then do: 
  for each jprofit where jprofit.acc = v-acc2 and (v-datel or (jprofit.date >= v-dat1 and jprofit.date <= v-dat2)) and (v-NIDl or jprofit.NID = v-NID2) no-lock use-index main:
    create t-jprofit.
    buffer-copy jprofit to t-jprofit.
  end.
end.  

if v-dat1 <> ? and v-dat2 <> ? and trim(v-acc2) = " " then do:
  for each jprofit where (jprofit.date >= v-dat1 and jprofit.date <= v-dat2) and (v-NIDl or jprofit.NID = v-NID2) no-lock use-index dateNID:
    create t-jprofit.
    buffer-copy jprofit to t-jprofit.
  end.
end.

if trim(v-NID2) <> " " and (v-dat1 = ? or v-dat2 = ?) and trim(v-acc2) = " " then do: 
  for each jprofit where jprofit.NID = v-NID2 no-lock use-index NID:
    create t-jprofit.
    buffer-copy jprofit to t-jprofit.
  end.
end.

if (trim(v-acc2) = " " and (v-dat1 = ? or v-dat2 = ?) and trim(v-NID2) = " ") then do:
 for each jprofit no-lock use-index dateNID:
    create t-jprofit.
    buffer-copy jprofit to t-jprofit.
 end.
end.
/**/

define query qt for t-jprofit.
define buffer b-jprofit for t-jprofit.

define browse bt query qt
       displ t-jprofit.clname label "Клиент" format "x(40)" 
             t-jprofit.acc label "Лиц.счет" format "x(12)"
             t-jprofit.date label "Дата поступления доходов" format "99/99/9999" 
             t-jprofit.NID label "НИН" format "x(10)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title "Журнал учета доходов".

form 
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-type label "Вид операции" format "x(20)" skip
 v-NID label "НИН" format "x(10)" skip
 v-ammount label "Количество цен.бумаг" format ">>>>>>>>9" skip
 v-date label "Дата поступления доходов" format "99/99/9999" skip
 v-summ label "Сумма доходов" format ">>>>>>>>9.99" skip
 v-profitprop label "Реквизиты" format "x(40)"
 with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jprofit where b-jprofit.acc = t-jprofit.acc no-lock no-error.
    if avail b-jprofit then do:
         assign 
             v-clname = b-jprofit.clname
             v-acc = b-jprofit.acc
             v-type = b-jprofit.type
             v-NID = b-jprofit.NID
             v-ammount = b-jprofit.ammount
             v-date = b-jprofit.date
             v-summ = b-jprofit.summ
             v-profitprop = b-jprofit.profitprop.
        
        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.     
        
        update v-clname v-acc v-type v-NID v-ammount v-date v-summ v-profitprop with frame fedit.
        
        find current b-jprofit exclusive-lock.
         assign 
             b-jprofit.clname = v-clname
             b-jprofit.acc = v-acc
             b-jprofit.type = v-type
             b-jprofit.NID = v-NID
             b-jprofit.ammount =v-ammount
             b-jprofit.date = v-date
             b-jprofit.summ = v-summ
             b-jprofit.profitprop = v-profitprop.
       find current b-jprofit no-lock.
    end.
    open query qt for each t-jprofit  use-index dateNID no-lock.
    find first t-jprofit no-lock no-error.
    if avail t-jprofit then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jprofit.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jprofit).
    open query qt for each t-jprofit  use-index dateNID no-lock.
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
 find first t-jprofit use-index dateNID no-lock no-error.
 if avail t-jprofit then do:
     for each t-jprofit no-lock use-index dateNID:
      find first jprofit where jprofit.acc = t-jprofit.acc exclusive-lock no-error.
      if not avail jprofit then create jprofit. 
      buffer-copy t-jprofit to jprofit.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jprofit  use-index dateNID no-lock no-error.
if avail t-jprofit then do:
 output stream vcrpt to "jprofit.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал учета поступлений и распределения доходов по ценным бумагам"
    }
    
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал учета поступлений и распределения доходов по ценным бумагам</FONT></P>" skip.
    
    if v-dat1 <> ? and v-dat2 <> ? then do:
     if v-dat1 <> v-dat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата поступления доходов c " + string(v-dat1, '99/99/9999') + " по "  + string(v-dat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата поступления доходов " + string(v-dat1, '99/99/9999') skip.           
     end.
    end.  
    if trim(v-acc2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета " + v-acc2 skip.         
    end.
    
    if trim(v-NID2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "НИН ценной бумаги: " + v-NID2 skip.         
    end.
    put stream vcrpt unformatted   
       "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD>№ п/п</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>Наименование<BR>и Нин ценной<BR>бумаги</TD>" skip
         "<TD>Кол-во<BR>ценных бумаг</TD>" skip
         "<TD>Дата<BR>поступления<BR>доходов</TD>" skip
         "<TD>Сумма<BR>полученных<BR>доходов</TD>" skip
         "<TD>Реквизиты</TD>" skip
         "</TR>" skip.
    i = 0.
    
     for each t-jprofit  use-index dateNID no-lock:
     i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jprofit.clname "</TD>" skip
      "<TD> &nbsp;" t-jprofit.acc "</TD>" skip
      "<TD>" t-jprofit.type "&nbsp;" t-jprofit.NID "</TD>" skip
      "<TD>" t-jprofit.ammount "</TD>" skip
      "<TD>" t-jprofit.date "</TD>" skip
      "<TD>" t-jprofit.summ "</TD>" skip
      "<TD>" t-jprofit.profitprop "</TD>" skip
      "</TR>" skip.
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jprofit.xls excel").
  unix silent rm -r jprofit.xls.
end.  
end.

open query qt for each t-jprofit  use-index dateNID no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
