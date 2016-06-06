/* jcomplaint.p
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
def var v-date as date no-undo. 
def var v-dat1 as date no-undo. 
def var v-dat2 as date no-undo. 
def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-compldesc as char no-undo. 
def var v-actions as char no-undo.
def var v-result as char no-undo.
def var i as integer no-undo. 
def var v-accl as logi no-undo.
def var v-sel as integer.

define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jcomplaint like jcomplaint.
def stream vcrpt.
/*ввод параметров*/
form 
  skip(1)
  v-dat1 label "Дата записи жалобы с " format "99/99/9999" 
  validate (v-dat1 <= g-today or v-dat1 = ?, " Дата не может быть больше " + string (g-today))
  v-dat2 label " по " format "99/99/9999"
  validate (v-dat2 <= g-today or v-dat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jcomplaint"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-dat1 v-dat2 v-acc2 with frame f-par.

if trim(v-acc2) <> " " then v-accl = no. else v-accl = yes.


if  v-dat1 <> ? and v-dat2 <> ? then do:
  for each jcomplaint where (jcomplaint.date >= v-dat1 or jcomplaint.date <= v-dat2) and (v-accl or jcomplaint.acc = v-acc2) no-lock use-index dtacc:
    create t-jcomplaint.
    buffer-copy jcomplaint to t-jcomplaint.
  end.
end.

if trim(v-acc2) <> " " and  (v-dat1 = ? or v-dat2 = ?) then do: 
  for each jcomplaint where jcomplaint.acc = v-acc2 no-lock use-index acc:
    create t-jcomplaint.
    buffer-copy jcomplaint to t-jcomplaint.
  end.
end.

if ((v-dat1 = ? or v-dat2 = ?) and trim(v-acc2) = " ") then do:
 for each jcomplaint no-lock use-index dtacc:
    create t-jcomplaint.
    buffer-copy jcomplaint to t-jcomplaint.
 end.
end.


define query qt for t-jcomplaint.
define buffer b-jcomplaint for t-jcomplaint.

define browse bt query qt
       displ t-jcomplaint.date label "Дата записи жалобы" format "99/99/9999"
             t-jcomplaint.clname label "Клиент" format "x(40)"
             t-jcomplaint.acc label "Лиц.счет" format "x(12)"
             t-jcomplaint.compldesc label "Суть жалобы" format "x(30)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title " Журнал учета притензий ".

form 
 v-date label "Дата записи жалобы" format "99/99/9999" skip
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-compldesc label "Суть жалобы" format "x(40)" skip
 v-actions label "Принятые меры" format "x(40)" skip
 v-result label "Результат" format "x(40)" 
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jcomplaint where b-jcomplaint.acc = t-jcomplaint.acc no-lock no-error.
    if avail b-jcomplaint then do:
         assign 
             v-date = b-jcomplaint.date
             v-clname = b-jcomplaint.clname
             v-acc = b-jcomplaint.acc
             v-compldesc = b-jcomplaint.compldesc
             v-actions = b-jcomplaint.actions
             v-result = b-jcomplaint.result.
         
         on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
         end.             
             
        update v-date v-clname v-acc v-compldesc v-actions v-result with frame fedit.
        
        find current b-jcomplaint exclusive-lock.
         assign 
             b-jcomplaint.date = v-date 
             b-jcomplaint.clname = v-clname
             b-jcomplaint.acc = v-acc
             b-jcomplaint.compldesc = v-compldesc
             b-jcomplaint.actions = v-actions
             b-jcomplaint.result = v-result.
        find current b-jcomplaint no-lock.
    end.
    open query qt for each t-jcomplaint use-index dtacc no-lock.
    find first t-jcomplaint use-index dtacc no-lock no-error.
    if avail t-jcomplaint then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jcomplaint.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jcomplaint).
    open query qt for each t-jcomplaint where use-index dtacc no-lock.
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
 find first t-jcomplaint use-index dtacc no-lock no-error.
 if avail t-jcomplaint then do:
     for each t-jcomplaint no-lock use-index dtacc:
      find first jcomplaint where jcomplaint.acc = t-jcomplaint.acc exclusive-lock no-error.
      if not avail jcomplaint then create jcomplaint. 
      buffer-copy t-jcomplaint to jcomplaint.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jcomplaint use-index dtacc no-lock no-error.
if avail t-jcomplaint then do:
 output stream vcrpt to "jcomplaint.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал учета претензий  клиентов и мерах по их устранению"
    }
    
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал учета претензий  клиентов и мерах по их устранению</FONT></P>" skip.
    
    if v-dat1 <> ? and v-dat2 <> ? then do:
     if v-dat1 <> v-dat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата записи жалобы c " + string(v-dat1, '99/99/9999') + " по "  + string(v-dat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата записи жалобы " + string(v-dat1, '99/99/9999') skip.           
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
         "<TD>Дата<BR>записи<BR>жалобы</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>Суть жалобы</TD>" skip
         "<TD>Меры,<BR>принятые<BR>по устранению</TD>" skip
         "<TD>Резльтат<BR>принятых<BR>мер</TD>" skip
         "</TR>" skip.
    
    i = 0.
     for each t-jcomplaint use-index dtacc no-lock:
     i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<td>" i "</td>" skip
      "<td>" t-jcomplaint.date "</td>" skip
      "<TD>" t-jcomplaint.clname "</TD>" skip
      "<TD> &nbsp;" t-jcomplaint.acc "</TD>" skip
      "<TD>" t-jcomplaint.compldesc "</TD>" skip
      "<TD>" t-jcomplaint.actions "</TD>" skip
      "<TD>" t-jcomplaint.result "</TD>" skip
      "</TR>" skip.
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jcomplaint.xls excel").
  unix silent rm -f jcomplaint.xls.
end.  
end.

open query qt for each t-jcomplaint use-index dtacc no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
