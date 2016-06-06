/* jorder.p
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
def var v-onum as char no-undo.
def var v-onum2 as char no-undo.
def var v-odate as date no-undo. 
def var v-odat1 as date no-undo. 
def var v-odat2 as date no-undo. 
def var v-cname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-otype as char no-undo.
def var v-dealtype as char no-undo.
def var v-type as char no-undo.
def var v-NID as char no-undo.
def var v-ammount as integer no-undo.
def var v-dealsumm as deci no-undo.
def var v-olastdate as date no-undo.
def var v-osts as char no-undo.
def var v-osts2 as char no-undo.
def var v-ostsch as char no-undo.
def var v-ostsdesc as char no-undo. 
def var i as integer no-undo.
def var v-sel as integer.
def var v-odatel as logi no-undo.
def var v-accl as logi no-undo.

define button bsort label "Доп.фильтр".
define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jorder like jorder.
def stream vcrpt.

/*ввод параметров*/
form 
  skip(1)
  v-onum2 label "# заказа" format "x(10)" help "F2 - список номеров заказов" skip
  v-odat1 format "99/99/9999" label "Дата заказа c" 
  validate (v-odat1 <= g-today or v-odat1 = ?, " Дата не может быть больше " + string (g-today))
  v-odat2 label " по " format "99/99/9999" 
  validate (v-odat2 <= g-today or v-odat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов" skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

 on help of v-onum2 in frame f-par do:
    {jsprav.i
     &table = "jorder"
     &field = "onum"
     &flname = "'ВЫБЕРИТЕ НОМЕР ЗАКАЗА'"}
     if v-sel <> 0 then v-onum2 = entry(v-sel,v-list,'|').
     display v-onum2 with frame f-par.
 end.
 on help of v-acc2 in frame f-par do:
    {jsprav.i
     &table = "jorder"
     &field = "acc"
     &flname = "'ВЫБЕРИТЕ НОМЕР ЛИЦ.СЧЕТА'"}
     if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
     display v-acc2 with frame f-par.
 end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-onum2 v-odat1 v-odat2 v-acc2 with frame f-par.

if v-odat1 <> ? and v-odat2 <> ? then v-odatel = no. else v-odatel = yes.  
if trim(v-acc2) <> " " then v-accl = no. else v-accl = yes.

if trim(v-onum2) <> " " then do: 
  for each jorder where jorder.onum = v-onum2 and (v-odatel or (jorder.odate >= v-odat1 and jorder.odate <= v-odat2)) and (v-accl or jorder.acc = v-acc2) no-lock use-index main:
    create t-jorder.
    buffer-copy jorder to t-jorder.
  end.
end.  

if v-odat1 <> ? and v-odat2 <> ? and trim(v-onum2) = " " then do:
  for each jorder where (jorder.odate >= v-odat1 and jorder.odate <= v-odat2) and (v-accl or jorder.acc = v-acc2) no-lock use-index odate:
    create t-jorder.
    buffer-copy jorder to t-jorder.
  end.
end.

if trim(v-acc2) <> " " and  (v-odat1 = ? or v-odat2 = ?) and trim(v-onum2) = " " then do: 
  for each jorder where jorder.acc = v-acc2 no-lock use-index acc:
    create t-jorder.
    buffer-copy jorder to t-jorder.
  end.
end.

if (trim(v-onum2) = " " and (v-odat1 = ? or v-odat2 = ?) and trim(v-acc2) = " ") then do:
 for each jorder no-lock use-index odate:
    create t-jorder.
    buffer-copy jorder to t-jorder.
 end.
end.
/**/

define query qt for t-jorder.
define buffer b-jorder for t-jorder.

define browse bt query qt
       displ t-jorder.onum label "# заказа" format "x(10)"
             t-jorder.odate label "Дата заказа" format "99/99/9999"
             t-jorder.cname label "Клиент" format "x(40)"
             t-jorder.acc label "Лиц.счет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsort " " bsave " " brep
 with width 110 row 3 overlay no-label title " Журнал регистрации клиентских заказов ".

form 
 v-onum label "# заказа" format "x(10)" skip
 v-odate label "Дата заказа" format "99/99/9999" skip
 v-cname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-otype label "Вид заказа" format "x(20)" skip
 v-dealtype label "Вид сделки" format "x(20)" skip
 v-type label "Вид ценной бумаги" format "x(20)" skip
 v-NID label "НИН" format "x(20)" skip
 v-ammount label "Кол-во ценных бумаг" format ">>>>>>>>9" skip
 v-dealsumm label "Сумма сделки" format ">>>>>>>>9.99" skip
 v-olastdate label "Срок действия заказа" format "99/99/9999" skip
 v-osts label "Испонен/не исполен" format "9" help "1 - исполнен; 2 - не исполнен" validate(index('12',v-osts) > 0,'Неверный статус заказа!') skip
 v-ostsdesc label "Прична неисполнения" format "x(20)" skip
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jorder where b-jorder.acc = t-jorder.acc no-lock no-error.
    if avail b-jorder then do:
         assign 
             v-onum = b-jorder.onum
             v-odate = b-jorder.odate
             v-cname = b-jorder.cname
             v-acc = b-jorder.acc 
             v-otype = b-jorder.otype
             v-dealtype = b-jorder.dealtype
             v-type = b-jorder.type 
             v-NID = b-jorder.NID 
             v-ammount = b-jorder.ammount
             v-dealsumm = b-jorder.dealsumm
             v-olastdate = b-jorder.olastdate
             v-osts = string(b-jorder.osts)
             v-ostsdesc = b-jorder.ostsdesc.
             
        on help of v-osts in frame fedit do:
           run sel2("ВЫБЕРИТЕ СТАТУС ЗАКАЗА","1 - исполнен|2 - не исполнен", output v-sel).
           if v-sel <> 0 then v-osts = entry(1,entry(v-sel,"1 - исполнен|2 - не исполнен",'|'),' '). 
           displ v-osts with frame fedit.
        end.
        
        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.                            

        update v-onum v-odate v-cname v-acc v-otype v-dealtype v-type v-NID v-ammount v-dealsumm v-olastdate v-osts with frame fedit.
        if v-osts = "2" then update v-ostsdesc with frame fedit.
        find current b-jorder exclusive-lock.
         assign 
             b-jorder.onum = v-onum
             b-jorder.odate = v-odate
             b-jorder.cname = v-cname
             b-jorder.acc = v-acc
             b-jorder.otype = v-otype
             b-jorder.dealtype = v-dealtype
             b-jorder.type = v-type
             b-jorder.NID = v-NID
             b-jorder.ammount = v-ammount
             b-jorder.dealsumm = v-dealsumm
             b-jorder.olastdate = v-olastdate
             b-jorder.osts = integer(v-osts)
             b-jorder.ostsdesc = v-ostsdesc.    
        find current b-jorder no-lock.
    end.
    open query qt for each t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock.
    find first t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock no-error.
    if avail t-jorder then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jorder.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jorder).
    open query qt for each t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock.
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
 find first t-jorder  use-index odate no-lock no-error.
 if avail t-jorder then do:
     for each t-jorder no-lock use-index odate:
      find first jorder where jorder.acc = t-jorder.acc exclusive-lock no-error.
      if not avail jorder then create jorder. 
      buffer-copy t-jorder to jorder.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of bsort in frame ft do:
 displ v-osts2 label " Исполнен/не исполнен" format "9" help "1 - исполнен; 2 - не исполнен" validate(index('12',v-osts2) > 0,'Неверный статус заказа!')
 with width 50 overlay side-label title "СТАТУС ЗАКАЗА" row 10 column 10 frame fr2.
 
  on help of v-osts2 in frame fr2 do:
     run sel2("ВЫБЕРИТЕ СТАТУС ЗАКАЗА","1 - исполнен|2 - не исполнен", output v-sel).
     if v-sel <> 0 then v-osts2 = entry(1,entry(v-sel,"1 - исполнен|2 - не исполнен",'|'),' '). 
     displ v-osts2 with frame fr2.
  end.
 
 update v-osts2 with frame fr2.
 hide frame fr2.
 open query qt for each t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock.
end.

on choose of brep in frame ft do:
find first t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock no-error.
if avail t-jorder then do:
 output stream vcrpt to "jorder.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал регистрации принятых клиентских заказов и их исполнения (неисполнения)"
    }
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал регистрации принятых клиентских заказов и их исполнения (неисполнения)</FONT></P>" skip.
    
    if trim(v-onum2) <> " " then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ заказа " + v-onum2 + " " skip.
    end.
    
    if v-odat1 <> ? and v-odat2 <> ? then do:
     if v-odat1 <> v-odat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата заказа c " + string(v-odat1, '99/99/9999') + " по "  + string(v-odat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата заказа " + string(v-odat1, '99/99/9999') skip.           
            
     end.
    end.  
    if trim(v-acc2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета " + v-acc2 skip.         
    end.
    if trim(v-osts2) <> " " then do:
     put stream vcrpt unformatted
     "</P><P align = ""center"">" skip
         "Статус заказа: ".       
     case v-osts2:
       when "1" then put stream vcrpt unformatted "Исполнен" skip.
       when "2" then put stream vcrpt unformatted "Не исполнен" skip.
     end. 
    end.
    put stream vcrpt unformatted   
       "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD>№ п/п</TD>" skip
         "<TD>№ к/з</TD>" skip
         "<TD>Дата<BR>принятия к/з</TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>Тип заказа</TD>" skip
         "<TD>Вид операции</TD>" skip
         "<TD>Наименование<BR>и Нин ценной<BR>бумаги</TD>" skip
         "<TD>Кол-во<BR>ценных бумаг</TD>" skip
         "<TD>Сумма<BR>сделки</TD>" skip
         "<TD>Срок<BR>действия</TD>" skip
         "<TD>Отметка об<BR>исполнении</TD>" skip
         "<TD>Причины<BR>неисполнения</TD>" skip
         "</TR>" skip.
    i = 0.
    for each t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock:
    i = i + 1.
      if t-jorder.osts = 2 then v-ostsch = "не исполнен".
      else v-ostsch = "не исполнен".
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jorder.onum "</TD>" skip
      "<TD>" t-jorder.odate "</TD>" skip
      "<TD> &nbsp;" t-jorder.acc "</TD>" skip
      "<TD>" t-jorder.cname "</TD>" skip
      "<TD>" t-jorder.otype "</TD>" skip
      "<TD>" t-jorder.dealtype "</TD>" skip
      "<TD>" t-jorder.type "&nbsp" t-jorder.NID "</TD>" skip
      "<TD>" t-jorder.ammount "</TD>" skip
      "<TD>" t-jorder.dealsumm "</TD>" skip
      "<TD>" t-jorder.olastdate "</TD>" skip
      "<TD>" v-ostsch  "</TD>" skip
      "<TD>" t-jorder.ostsdesc "</TD>" skip
      "</TR>" skip.
      
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jorder.xls excel").
  unix silent rm -f jorder.xls.
end.
end.

open query qt for each t-jorder where (trim(v-osts2) = " " or t-jorder.osts = integer(v-osts2)) no-lock.
enable bt bsort bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
