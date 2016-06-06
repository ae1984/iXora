/* jmoney.p
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
def var v-operdesc as char no-undo. 
def var v-bbal as deci no-undo.
def var v-ebal as deci no-undo.
def var v-crturn as deci no-undo.
def var v-dturn as deci no-undo.
def var i as integer no-undo. 
def var v-accl as logi no-undo.
def var v-sel as integer.

define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jmoney like jmoney.
def stream vcrpt.

/*ввод параметров*/
form 
  skip(1)
  v-operdat1 label "Дата операции с " format "99/99/9999"
  validate (v-operdat1 <= g-today or v-operdat1 = ?, " Дата не может быть больше " + string (g-today))
  v-operdat2 label " по " format "99/99/9999" 
  validate (v-operdat2 <= g-today or v-operdat1 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jmoney"
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
  for each jmoney where (jmoney.operdate >= v-operdate and jmoney.operdate <= v-operdat2) and (v-accl or jmoney.acc = v-acc2) no-lock use-index operdt:
    create t-jmoney.
    buffer-copy jmoney to t-jmoney.
  end.
end.

if trim(v-acc2) <> " " and  (v-operdat1 = ? or v-operdat2 = ?) then do: 
  for each jmoney where jmoney.acc = v-acc2 no-lock use-index acc:
    create t-jmoney.
    buffer-copy jmoney to t-jmoney.
  end.
end.

if ((v-operdat1 = ? or v-operdat2 = ?) and trim(v-acc2) = " ") then do:
 for each jmoney no-lock use-index operdt:
    create t-jmoney.
    buffer-copy jmoney to t-jmoney.
 end.
end.
/**/

define query qt for t-jmoney.
define buffer b-jmoney for t-jmoney.

define browse bt query qt
       displ t-jmoney.operdate label "Дата операции" format "99/99/9999"
             t-jmoney.clname label "Клиент" format "x(40)"
             t-jmoney.acc label "Лиц.счет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title " Журнал регистрации операций по лиц.счетам ".

form 
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-operdate label "Дата сделки" format "99/99/9999" skip
 v-operdesc label "Основание операции" format "x(20)" skip
 v-bbal label "Остаток на начало дня" format ">>>>>>>>9.99" skip
 v-crturn label "Обороты по кредиту" format ">>>>>>>>9.99" skip
 v-dturn label "Обороты по дебету" format ">>>>>>>>9.99" skip
 v-ebal label "Остаток на конец дня" format ">>>>>>>>9.99"
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jmoney where b-jmoney.acc = t-jmoney.acc no-lock no-error.
    if avail b-jmoney then do:
         assign 
             v-clname = b-jmoney.clname
             v-acc = b-jmoney.acc
             v-operdate = b-jmoney.operdate
             v-operdesc = b-jmoney.operdesc
             v-bbal = b-jmoney.bbal 
             v-crturn = b-jmoney.crturn
             v-dturn = b-jmoney.dturn 
             v-ebal = b-jmoney.ebal. 
             
             
        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.                          
             
        update v-clname v-acc v-operdate v-operdesc v-bbal v-crturn v-dturn v-ebal with frame fedit.
        
        find current b-jmoney exclusive-lock.
         assign 
             b-jmoney.clname = v-clname
             b-jmoney.acc = v-acc
             b-jmoney.operdate = v-operdate
             b-jmoney.operdesc = v-operdesc
             b-jmoney.bbal  = v-bbal
             b-jmoney.crturn = v-crturn
             b-jmoney.dturn  = v-dturn
             b-jmoney.ebal = v-ebal.
        find current b-jmoney no-lock.
    end.
    open query qt for each t-jmoney use-index operdt no-lock.
    find first t-jmoney use-index operdt no-lock no-error.
    if avail t-jmoney then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jmoney.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jmoney).
    open query qt for each t-jmoney where use-index operdt no-lock.
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
 find first t-jmoney use-index operdt no-lock no-error.
 if avail t-jmoney then do:
     for each t-jmoney no-lock use-index operdt:
       find first jmoney where jmoney.acc = t-jmoney.acc exclusive-lock no-error.
      if not avail jmoney then create jmoney. 
      buffer-copy t-jmoney to jmoney.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jmoney use-index operdt no-lock no-error.
if avail t-jmoney then do:
 output stream vcrpt to "jmoney.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал учета денег и изменения их количества"
    }
    
   find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал учета денег и изменения их количества</FONT></P>" skip.
    
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
         "<TD>Основание<BR>операции</TD>" skip
         "<TD>Остаток<BR>на начало<BR>дня</TD>" skip
         "<TD>Обороты<BR>по дебету<BR>счета</TD>" skip
         "<TD>Обороты<BR>по кредиту<BR>счета</TD>" skip
         "<TD>Остаток<BR>на конец<BR>дня</TD>" skip
         "</TR>" skip.
    i = 0.
    
    for each t-jmoney use-index operdt no-lock:
    i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jmoney.clname "</TD>" skip
      "<TD> &nbsp;" t-jmoney.acc "</TD>" skip
      "<TD>" t-jmoney.operdate "</TD>" skip
      "<TD>" t-jmoney.operdesc "</TD>" skip
      "<TD>" t-jmoney.bbal "</TD>" skip
      "<TD>" t-jmoney.crturn "</TD>" skip
      "<TD>" t-jmoney.dturn "</TD>" skip
      "<TD>" t-jmoney.ebal "</TD>" skip
      "</TR>" skip.
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jmoney.xls excel").
  unix silent rm -f jmoney.xls.
end.  
end.

open query qt for each t-jmoney use-index operdt no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
