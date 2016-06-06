/* jcommand.p
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
def var v-comnum as char no-undo.
def var v-comnum2 as char no-undo.
def var v-comdate as date no-undo. 
def var v-comdat1 as date no-undo. 
def var v-comdat2 as date no-undo. 
def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-opertype as char no-undo.
def var v-operparam as char no-undo.
def var v-comsts as char no-undo.
def var v-comsts2 as char no-undo.
def var v-comstsch as char no-undo.
def var v-comstsdesc as char no-undo. 
def var i as integer no-undo. 
def var v-sel as integer.
def var v-comdatel as logi no-undo.
def var v-accl as logi no-undo.

define button bsort label "Доп.фильтр".
define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jcommand like jcommand.
def stream vcrpt.
/*ввод параметров*/
form 
  skip(1)
  v-comnum2 label "# приказа" format "x(10)" help "F2 - список номеров приказов" skip
  v-comdat1 label "Дата приказа с" format "99/99/9999"
  validate (v-comdat1 <= g-today or v-comdat1 = ?, " Дата не может быть больше " + string (g-today))
  v-comdat2 label " по " format "99/99/9999" 
  validate (v-comdat2 <= g-today or v-comdat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов"  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

 on help of v-comnum2 in frame f-par do:
    {jsprav.i
     &table = "jcommand"
     &field = "comnum"
     &flname = "'ВЫБЕРИТЕ НОМЕР ПРИКАЗА'"}
     if v-sel <> 0 then v-comnum2 = entry(v-sel,v-list,'|').
     display v-comnum2 with frame f-par.
 end.
    
 on help of v-acc2 in frame f-par do:
    {jsprav.i
     &table = "jcommand"
     &field = "acc"
     &flname = "'ВЫБЕРИТЕ НОМЕР ЛИЦ.СЧЕТА'"}
     if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
     display v-acc2 with frame f-par.
 end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-comnum2 v-comdat1 v-comdat2 v-acc2 with frame f-par.


if v-comdat1 <> ? and v-comdat2 <> ? then v-comdatel = no. else v-comdatel = yes.  
if trim(v-acc2) <> " " then v-accl = no. else v-accl = yes.

if trim(v-comnum2) <> " " then do: 
  for each jcommand where jcommand.comnum = v-comnum2 and (v-comdatel or (jcommand.comdate >= v-comdat1 and jcommand.comdate <= v-comdat2)) and (v-accl or jcommand.acc = v-acc2) no-lock use-index main:
    create t-jcommand.
    buffer-copy jcommand to t-jcommand.
  end.
end.  

if v-comdat1 <> ? and v-comdat2 <> ? and trim(v-comnum2) = " " then do:
  for each jcommand where (jcommand.comdate >= v-comdat1 and jcommand.comdate <= v-comdat2) and (v-accl or jcommand.acc = v-acc2) no-lock use-index comdate:
    create t-jcommand.
    buffer-copy jcommand to t-jcommand.
  end.
end.

if trim(v-acc2) <> " " and (v-comdat1 = ? or v-comdat2 = ?) and trim(v-comnum2) = " " then do: 
  for each jcommand where jcommand.acc = v-acc2 no-lock use-index acc:
    create t-jcommand.
    buffer-copy jcommand to t-jcommand.
  end.
end.

if (trim(v-comnum2) = " " and (v-comdat1 = ? or v-comdat2 = ?) and trim(v-acc2) = " ") then do:
 for each jcommand no-lock use-index comdate:
    create t-jcommand.
    buffer-copy jcommand to t-jcommand.
 end.
end.
/**/

define query qt for t-jcommand.
define buffer b-jcommand for t-jcommand.

define browse bt query qt
       displ t-jcommand.comnum  label "# приказа" format "x(10)" 
             t-jcommand.comdate label "Дата приказа" format "99/99/9999" 
             t-jcommand.clname label "Клиент" format "x(40)" 
             t-jcommand.acc label "Лиц.счет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsort " " bsave " " brep
 with width 110 row 3 overlay no-label title "Журнал регистрации клиентских приказов".

form 
 v-comnum label "# заказа" format "x(10)" skip
 v-comdate label "Дата заказа" format "99/99/9999" skip
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-opertype label "Вид операции" format "x(20)" skip
 v-operparam label "Осн. парам. провед/ия операции" format "x(40)" skip
 v-comsts label "Испонен/не исполен" format "9" validate(index("1,2",v-comsts) > 0, "Неверный статус заказа!") help "1 - исполнен; 2 - не исполнен" skip
 v-comstsdesc label "Прична неисполнения" format "x(20)" skip
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:
  
    find first b-jcommand where b-jcommand.acc = t-jcommand.acc no-lock no-error.
    if avail b-jcommand then do:
         assign 
             v-comnum = b-jcommand.comnum
             v-comdate = b-jcommand.comdate
             v-clname = b-jcommand.clname
             v-acc = b-jcommand.acc 
             v-opertype = b-jcommand.opertype
             v-operparam = b-jcommand.operparam
             v-comsts = string(b-jcommand.comsts)
             v-comstsdesc = b-jcommand.comstsdesc.
             
         on help of v-comsts in frame fedit do:
           v-sel = 0.
           run sel2("ВЫБЕРИТЕ СТАТУС ПРИКАЗА","1 - исполнен|2 - не исполнен", output v-sel).
           if v-sel <> 0 then v-comsts = entry(1,entry(v-sel,"1 - исполнен|2 - не исполнен",'|'),' '). 
           displ v-comsts with frame fedit.
         end.
        
         on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
         end.
        
        update v-comnum v-comdate v-clname v-acc v-opertype v-operparam v-comsts with frame fedit.       
        
        if v-comsts = "2" then update v-comstsdesc with frame fedit.
        find current b-jcommand exclusive-lock.
         assign 
             b-jcommand.comnum = v-comnum
             b-jcommand.comdate = v-comdate
             b-jcommand.clname = v-clname
             b-jcommand.acc = v-acc 
             b-jcommand.opertype = v-opertype
             b-jcommand.operparam = v-operparam
             b-jcommand.comsts = integer(v-comsts)
             b-jcommand.comstsdesc = v-comstsdesc.
        find current b-jcommand no-lock.
    end.
    open query qt for each t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock.
    find first t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock no-error.
    if avail t-jcommand then bt:refresh().

end. 

on "insert-mode" of bt in frame ft do:
    create t-jcommand.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jcommand).
    open query qt for each t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

on choose of bsave in frame ft do:
find first t-jcommand use-index comdate no-lock no-error.
if avail t-jcommand then do:
     for each t-jcommand no-lock use-index comdate:
      find first jcommand where jcommand.acc = t-jcommand.acc exclusive-lock no-error.
      if not avail jcommand then create jcommand. 
      buffer-copy t-jcommand to jcommand.
     end.
     message " Данные сохранены " view-as alert-box information.
end.     
else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on "END-ERROR" of frame ft do: 
   message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
   hide all.
   run journal.
end.

on choose of bsort in frame ft do:
 displ v-comsts2 label " Исполнен/не исполнен" format "9" validate(index("1,2",v-comsts2) > 0, "Неверный статус заказа!") help "1 - исполнен; 2 - не исполнен"
 with width 50 overlay side-label title "СТАТУС ПРИКАЗА" row 10 column 10 frame fr2.
 
 on help of v-comsts2 in frame fr2 do:
   run sel2("ВЫБЕРИТЕ СТАТУС ПРИКАЗА","1 - исполнен|2 - не исполнен", output v-sel).
   if v-sel <> 0 then v-comsts2 = entry(1,entry(v-sel,"1 - исполнен|2 - не исполнен",'|'),' '). 
   displ v-comsts2 with frame fr2.
 end.
 
 update v-comsts2 with frame fr2.
 hide frame fr2.
 
 open query qt for each t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock.
end.

on choose of brep in frame ft do:
find first t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock no-error.
if avail t-jcommand then do:
 output stream vcrpt to "jcommand.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал регистрации клиентских приказов и их исполнения (неисполнения)"
    }
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журналрегистрации клиентских приказов и их исполнения (неисполнения)</FONT></P>" skip.
    
    if trim(v-comnum2) <> " " then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ приказа " + v-comnum2 + " " skip.
    end.
    
    if v-comdat1 <> ? and v-comdat2 <> ? then do:
     if v-comdat1 <> v-comdat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата приказа c " + string(v-comdat1, '99/99/9999') + " по "  + string(v-comdat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата приказа " + string(v-comdat1, '99/99/9999') skip.           
            
     end.
    end.  
    if trim(v-acc2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета " + v-acc2 skip.         
    end.
    if trim(v-comsts2) <> " " then do:
     put stream vcrpt unformatted
     "</P><P align = ""center"">" skip
         "Статус приказа: ".       
     case v-comsts2:
       when "1" then put stream vcrpt unformatted "Исполнен" skip.
       when "2" then put stream vcrpt unformatted "Не исполнен" skip.
     end. 
    end.
    put stream vcrpt unformatted   
       "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD>№ п/п</TD>" skip
         "<TD>№ к/п</TD>" skip
         "<TD>Дата<BR>принятия к/п</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>Вид операции</TD>" skip
         "<TD>Осноные<BR>параметры<BR>проведения<BR>операции</TD>" skip
         "<TD>Отметка об<BR>исполнении</TD>" skip
         "<TD>Причины<BR>неисполнения</TD>" skip
         "</TR>" skip.
    i = 0.
    for each t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock:
      i = i + 1.
      if t-jcommand.comsts = 2 then v-comstsch = "не исполнен".
      else v-comstsch = "не исполнен".
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jcommand.comnum "</TD>" skip
      "<TD>" t-jcommand.comdate "</TD>" skip
      "<TD>" t-jcommand.clname "</TD>" skip
      "<TD> &nbsp;" t-jcommand.acc "</TD>" skip
      "<TD>" t-jcommand.opertype "</TD>" skip
      "<TD>" t-jcommand.operparam "</TD>" skip
      "<TD>" v-comstsch  "</TD>" skip      
      "<TD>" t-jcommand.comstsdesc "</TD>" skip
      "</TR>" skip.
      
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jcommand.xls excel").
  unix silent rm -f jcommand.xls.
end.  
end.


open query qt for each t-jcommand where (trim(v-comsts2) = " " or t-jcommand.comsts = integer(v-comsts2)) no-lock.
enable bt bsort bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
