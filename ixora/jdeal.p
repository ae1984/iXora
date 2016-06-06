/* jdeal.p
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
def input parameter p-dealsts as integer.
def input parameter p-title as char.

def var v-rid as rowid.
def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-dealnum as char no-undo.
def var v-dealnum2 as char no-undo.
def var v-dealdate as date no-undo. 
def var v-dealdat1 as date no-undo. 
def var v-dealdat2 as date no-undo. 
def var v-onum as char no-undo.
def var v-onum2 as char no-undo.
def var v-odate as date no-undo. 
def var v-odat1 as date no-undo. 
def var v-odat2 as date no-undo. 
def var v-dealtype as char no-undo.
def var v-type as char no-undo.
def var v-NID as char no-undo.
def var v-ammount as integer no-undo.
def var v-price as deci no-undo.
def var v-dealsumm as deci no-undo.
def var v-contragent as char no-undo.
def var v-ddate as date no-undo.
def var v-dealdesc as char no-undo. 
def var v-dealsts as integer no-undo.
def var i as integer no-undo.

def var v-accl as logi no-undo.
def var v-dealnuml as logi no-undo.
def var v-dealdatel as logi no-undo. 
def var v-onuml as logi no-undo.
def var v-odatel as logi no-undo. 
def var v-sel as integer.
define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jdeal like jdeal.
def stream vcrpt.

/*ввод параметров*/

form 
  skip(1)
  v-dealnum2 label "# сделки" format "x(10)" help "F2 - список номеров сделок" skip 
  v-dealdat1 label "Дата сделки c " format "99/99/9999"
  validate (v-dealdat1 <= g-today or v-dealdat1 = ?, " Дата не может быть больше " + string (g-today))
  v-dealdat2 label " по " format "99/99/9999" 
  validate (v-dealdat2 <= g-today  or v-dealdat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-onum2 label "# заказа" format "x(10)" help "F2 - список номеров заказов" skip
  v-odat1 label "Дата заказа с " format "99/99/9999"
  validate (v-odat1 <= g-today or v-odat1 = ?, " Дата не может быть больше " + string (g-today))
  v-odat2 label " по " format "99/99/9999" 
  validate (v-odat2 <= g-today or v-odat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов"
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-dealnum2 in frame f-par do:
 {jsprav.i
  &table = "jdeal"
  &field = "dealnum"
  &flname = "'ВЫБЕРИТЕ НОМЕР СДЕЛКИ'"}
  if v-sel <> 0 then v-dealnum2 = entry(v-sel,v-list,'|').
  display v-dealnum2 with frame f-par.
end.

on help of v-onum2 in frame f-par do:
 {jsprav.i
  &table = "jdeal"
  &field = "onum"
  &flname = "'ВЫБЕРИТЕ НОМЕР ЗАКАЗА'"}
  if v-sel <> 0 then v-onum2 = entry(v-sel,v-list,'|').
  display v-onum2 with frame f-par.
end.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jdeal"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update  v-dealnum2 v-dealdat1 v-dealdat2 v-onum2 v-odat1 v-odat2 v-acc2 with frame f-par.

if v-dealdat1 <> ? and v-dealdat2 <> ? then v-dealdatel = no. else v-dealdatel = yes.
if trim(v-onum2) <> " " then v-onuml = no. else v-onuml = yes.
if v-odat1 <> ? and v-odat2 <> ? then v-odatel = no. else v-odatel = yes.
if trim(v-acc2) <> " " then v-accl = no. else v-accl = yes.



if trim(v-dealnum2) <> " " then do:
 for each jdeal where jdeal.dealnum = v-dealnum2 and (v-dealdatel or (jdeal.dealdate >= v-dealdat1 and jdeal.dealdate <= v-dealdat2)) and (v-onuml or jdeal.onum = v-onum2) 
  and (v-odatel or (jdeal.odate >= v-odat1 and jdeal.odate <= v-odat2)) and (v-accl or jdeal.acc = v-acc2) no-lock use-index main:
  if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.
end.

if trim(v-dealnum2) = " " and v-dealdat1 <> ? and v-dealdat2 <> ? then do:
 for each jdeal where (jdeal.dealdate >= v-dealdat1 and jdeal.dealdate <= v-dealdat2) and (v-onuml or jdeal.onum = v-onum2) 
  and (v-odatel or (jdeal.odate >= v-odat1 and jdeal.odate <= v-odat2)) and (v-accl or jdeal.acc = v-acc2) no-lock use-index dealdt:
  if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.
end.


if trim(v-dealnum2) = " " and (v-dealdat1 = ? or v-dealdat2 = ?) and trim(v-onum2) <> " " then do:
 for each jdeal where jdeal.onum = v-onum2 and (v-odatel or (jdeal.odate >= v-odat1 and jdeal.odate <= v-odat2)) and (v-accl or jdeal.acc = v-acc2) no-lock use-index onum:
 if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.

end.

if trim(v-dealnum2) = " " and (v-dealdat1 = ? or v-dealdat2 = ?) and trim(v-onum2) = " " and v-odat1 <> ? and v-odat2 <> ? then do:
 for each jdeal where (jdeal.odate >= v-odat1 and jdeal.odate <= v-odat2) and (v-accl or jdeal.acc = v-acc2) no-lock use-index odate:
 if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.

end.

if trim(v-dealnum2) = " " and (v-dealdat1 = ? or v-dealdat2 = ?) and trim(v-onum2) = " " and (v-odat1 = ? or v-odat2 = ?) and trim(v-acc2) <> " " then do:
 for each jdeal where jdeal.acc = v-acc2 no-lock use-index acc:
 if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.

end.

if trim(v-dealnum2) = " " and (v-dealdat1 = ? or v-dealdat2 = ?) and trim(v-onum2) = " " and (v-odat1 = ? or v-odat2 = ?) and trim(v-acc2) = " " then do:
  for each jdeal no-lock use-index dealdt:
  if jdeal.dealsts <> p-dealsts then next.
  create t-jdeal.
  buffer-copy jdeal to t-jdeal.
 end.
end.

define query qt for t-jdeal.
define buffer b-jdeal for t-jdeal.

define browse bt query qt
       displ t-jdeal.dealnum label "# сделки" format "x(10)"
             t-jdeal.dealtype label "Вид сделки" format "x(10)"
             t-jdeal.dealdate label "Дата сделки" format "99/99/9999"
             t-jdeal.clname label "Клиент" format "x(40)"
             t-jdeal.acc label "Лиц.счет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title p-title.

form
  v-clname label "Клиент" format "x(40)" skip
  v-acc label "Лиц.счет" format "x(12)" skip
  v-dealnum label "# сделки" format "x(10)" skip
  v-dealdate label "Дата сделки" format "99/99/9999" skip
  v-onum label "# заказа" format "x(10)" skip
  v-odate label "Дата заказа" format "99/99/9999" skip
  v-dealtype label "Вид сделки" format "x(20)" skip
  v-type label "Вид ценной бумаги" format "x(20)" skip
  v-NID label "НИН" format "x(20)" skip
  v-ammount label "Кол-во ценных бумаг" format ">>>>>>>>9" skip
  v-price label "Цена одной ценной бумаги" format ">>>>>>>>9.99" skip
  v-dealsumm label "Сумма сделки" format ">>>>>>>>9.99" skip
  v-contragent label "Контрагент" format "x(40)" skip
  v-ddate label "Дата исполнения/неисполнения" format "99/99/9999" skip
  v-dealdesc label "Причина неисполнения" format "x(20)" skip
  v-dealsts label "Статус сделки" format "9" help "0 - заключена  1 - исполнена  2 - не исполнена" validate(index("012",v-dealsts) > 0,'Неверный статус сделки!')
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.

on "return" of bt in frame ft do:
    find first b-jdeal where b-jdeal.acc = t-jdeal.acc no-lock no-error.
    if avail b-jdeal then do:
         assign 
              v-clname = b-jdeal.clname
              v-acc = b-jdeal.acc
              v-dealnum = b-jdeal.dealnum
              v-dealdate = b-jdeal.dealdate
              v-onum = b-jdeal.onum
              v-odate = b-jdeal.odate
              v-dealtype = b-jdeal.dealtype
              v-type = b-jdeal.type
              v-NID = b-jdeal.NID
              v-ammount = b-jdeal.ammount
              v-price = b-jdeal.price
              v-dealsumm = b-jdeal.dealsumm
              v-contragent = b-jdeal.contragent
              v-ddate = b-jdeal.ddate
              v-dealdesc = b-jdeal.dealdesc
              v-dealsts = b-jdeal.dealsts.
        
         on help of v-dealsts in frame fedit do:
             v-sel = 0.
             run sel2("ВЫБЕРИТЕ СТАТУС СДЕЛКИ","0 заключена|1 исполнена|2 не исполнена", output v-sel).
             if v-sel <> 0 then v-dealsts = integer(entry(1,entry(v-sel,"0 заключена|1 исполнена|2 не исполнена",'|'),' ')). 
             displ v-dealsts with frame fedit.
         end.
        
         on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
         end.       

        display v-onum v-odate v-dealtype v-type v-NID v-ammount v-price 
               v-dealsumm v-contragent v-ddate v-dealdesc v-dealsts with frame fedit.
        
        update v-clname v-acc v-dealnum v-dealdate with frame fedit.
        
        display v-onum v-odate v-dealtype v-type v-NID v-ammount v-price 
               v-dealsumm v-contragent v-ddate v-dealdesc v-dealsts with frame fedit.
        
        update v-onum with frame fedit.
         find first jorder where jorder.onum = v-onum no-lock no-error.
         if not avail jorder then do:
          message "Клиентский заказ с номером " v-onum "не найден!" view-as alert-box.
          return.
         end.
         update v-odate v-dealtype v-type v-NID v-ammount v-price 
               v-dealsumm v-contragent v-ddate with frame fedit.
        if p-dealsts = 0 or p-dealsts = 2 then update v-dealdesc with frame fedit.
        if p-dealsts = 0 then do:
          update v-dealsts with frame fedit.
          if v-dealsts <> 0 then do:
            find first jdeal where jdeal.acc = v-acc exclusive-lock no-error.
            if not avail jdeal then create jdeal.
            assign
              jdeal.clname = v-clname
              jdeal.acc = v-acc
              jdeal.dealnum = v-dealnum
              jdeal.dealdate = v-dealdate
              jdeal.onum = v-onum
              jdeal.odate = v-odate
              jdeal.dealtype = v-dealtype
              jdeal.type = v-type
              jdeal.NID = v-NID
              jdeal.ammount = v-ammount
              jdeal.price = v-price
              jdeal.dealsumm = v-dealsumm
              jdeal.contragent = v-contragent
              jdeal.ddate = v-ddate
              jdeal.dealdesc = v-dealdesc
              jdeal.dealsts = v-dealsts.     
          end.
        end.  
        find current b-jdeal exclusive-lock.
         assign 
              b-jdeal.clname = v-clname
              b-jdeal.acc = v-acc
              b-jdeal.dealnum = v-dealnum
              b-jdeal.dealdate = v-dealdate
              b-jdeal.onum = v-onum
              b-jdeal.odate = v-odate
              b-jdeal.dealtype = v-dealtype
              b-jdeal.type = v-type
              b-jdeal.NID = v-NID
              b-jdeal.ammount = v-ammount
              b-jdeal.price = v-price
              b-jdeal.dealsumm = v-dealsumm
              b-jdeal.contragent = v-contragent
              b-jdeal.ddate = v-ddate
              b-jdeal.dealdesc = v-dealdesc
              b-jdeal.dealsts = v-dealsts.    
        find current b-jdeal no-lock.
    end.
    
    open query qt for each t-jdeal where t-jdeal.dealsts = p-dealsts no-lock.
    
    find first  t-jdeal where t-jdeal.dealsts = p-dealsts no-lock no-error.
    if avail t-jdeal then  bt:refresh().
    
end.   

if p-dealsts = 0 then do:
    on "insert-mode" of bt in frame ft do:
        create t-jdeal.
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = rowid(t-jdeal).
        open query qt for each t-jdeal where t-jdeal.dealsts = p-dealsts no-lock.
        reposition qt to rowid v-rid no-error .
        bt:refresh().
        apply "return" to bt in frame ft.
    end.
end.

on "END-ERROR" of frame ft do: 
   message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
   hide all.
   run journal.
end.

on choose of bsave in frame ft do:
for each t-jdeal no-lock use-index main:
 if t-jdeal.dealsts = 1 and p-dealsts = 0 then do:
   create joperation.
   assign 
      joperation.clname = t-jdeal.clname
      joperation.acc = t-jdeal.acc
      joperation.type = t-jdeal.type
      joperation.NID = t-jdeal.NID 
      joperation.ammount = t-jdeal.ammount.
 end.
end. 

 for each t-jdeal where t-jdeal.dealsts <> p-dealsts.
   delete  t-jdeal.
 end.
 find first t-jdeal use-index main no-lock no-error.
 if avail t-jdeal then do:
    for each t-jdeal no-lock use-index main:
      find first jdeal where jdeal.acc = t-jdeal.acc exclusive-lock no-error.
      if not avail jdeal then create jdeal. 
      buffer-copy t-jdeal to jdeal.
    end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jdeal where t-jdeal.dealsts = p-dealsts  no-lock no-error.
if avail t-jdeal then do:
 output stream vcrpt to "jdeal.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = p-title
    }
    
   find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
        p-title +  "</FONT></P>" skip.
    
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
    
    if trim(v-dealnum2) <> " " then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ сделки " + v-dealnum2 + " " skip.
    end.
    
    if v-dealdat1 <> ? and v-dealdat2 <> ? then do:
      if v-dealdat1 <> v-dealdat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата заключения сделки c " + string(v-dealdat1, '99/99/9999') + " по "  + string(v-dealdat2, '99/99/9999') skip.           
      end.    
      else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата заключения сделки " + string(v-dealdat1, '99/99/9999') skip.           
            
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
         "<TD>№ к/з</TD>" skip
         "<TD>Дата<BR>принятия к/з</TD>" skip
         "<TD>Дата<BR>закдючения<BR>сделки</TD>" skip
         "<TD>№ сделки</TD>" skip
         "<TD>Вид сделки</TD>" skip
         "<TD>Наименование<BR>и Нин ценной<BR>бумаги</TD>" skip
         "<TD>Кол-во<BR>ценных бумаг</TD>" skip
         "<TD>Цена одной<BR>ценной бумаги</TD>" skip
         "<TD>Сумма<BR>сделки</TD>" skip.
         if p-dealsts = 0 then put stream vcrpt unformatted   
         "<TD>Наименование<BR>котрагента</TD>" skip.
         if p-dealsts = 1 then put stream vcrpt unformatted   
         "<TD>Дата<BR>исполнения<BR>обязательств</TD>" skip.
         if p-dealsts = 2 then put stream vcrpt unformatted   
         "<TD>Дата<BR>неисполнения<BR>обязательств</TD>" skip
         "<TD>Причина<BR>неисполнения<BR>обязательств</TD>" skip
         "</TR>" skip.
    i = 0.
    
    for each t-jdeal where t-jdeal.dealsts = p-dealsts  no-lock:
    i = i + 1.
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jdeal.clname "</TD>" skip
      "<TD> &nbsp;" t-jdeal.acc "</TD>" skip
      "<TD>" t-jdeal.onum "</TD>" skip
      "<TD>" t-jdeal.odate "</TD>" skip
      "<TD>" t-jdeal.dealdate "</TD>" skip
      "<TD>" t-jdeal.dealnum "</TD>" skip
      "<TD>" t-jdeal.dealtype "</TD>" skip
      "<TD>" t-jdeal.type "&nbsp;" t-jdeal.NID "</TD>" skip
      "<TD>" t-jdeal.ammount "</TD>" skip
      "<TD>" t-jdeal.price "</TD>" skip
      "<TD>" t-jdeal.dealsumm "</TD>" skip.
      if p-dealsts = 0 then put stream vcrpt unformatted 
      "<TD>" t-jdeal.contragent "</TD>" skip.
      put stream vcrpt unformatted 
      "<TD>" t-jdeal.ddate "</TD>" skip.
      if p-dealsts = 2 then put stream vcrpt unformatted 
      "<TD>" t-jdeal.dealdesc "</TD>" skip.
      put stream vcrpt unformatted 
      "</TR>" skip.
      
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jdeal.xls excel").
  unix silent rm -f jdeal.xls.
end.  
end.

open query qt for each t-jdeal where t-jdeal.dealsts = p-dealsts  no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.




