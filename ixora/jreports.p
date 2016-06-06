/* jreports.p
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

def var v-rdate as date no-undo. 
def var v-clname as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-reptype as char no-undo.
def var v-reptype2 as char no-undo.
def var v-sendmethod  as char no-undo.
def var i as integer no-undo. 
def var v-rdat1 as date no-undo. 
def var v-rdat2 as date no-undo. 

def var v-sel as integer no-undo.
def var v-rep as char no-undo.
def var v-rdatel as logi no-undo. 
def var v-reptypel as logi no-undo.
def var v-repname as char.

define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jreports like jreports.
def stream vcrpt.

/*ввод параметров*/
form 
  skip(1)
  v-acc2 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов" skip
  v-reptype2 label "Вид отчета" format "x(3)" help "F2 - виды отчетов" skip
  v-rdat1 label "Дата выдачи отчета c " format "99/99/9999" 
  validate (v-rdat1 <= g-today or v-rdat1  = ?, " Дата не может быть больше " + string (g-today))
  v-rdat2 label " по " format "99/99/9999" 
  validate (v-rdat2 <= g-today or v-rdat2  = ?, " Дата не может быть больше " + string (g-today)) skip
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-acc2 in frame f-par do:
 {jsprav.i
  &table = "jreports"
  &field = "acc"
  &flname = "'ВЫБЕРИТЕ ЛИЦ.СЧЕТ'"}
  if v-sel <> 0 then v-acc2 = entry(v-sel,v-list,'|').
  display v-acc2 with frame f-par.
end.

on help of v-reptype2 in frame f-par do:
if v-rep = " " then do:
 for each codfr where codfr.codfr = "reptype" and codfr.code <> "msc" no-lock:
   if v-rep <> "" then v-rep = v-rep + " |".
   v-rep = v-rep + codfr.code + " " + codfr.name[1].
 end.
end.
    v-sel = 0.
    run sel2 (" ВЫБЕРИТЕ ОТЧЕТ ", v-rep, output v-sel).
    /*message "ky-ky1 " v-sel view-as alert-box.*/
    if v-sel <> 0 then v-reptype2 = trim(entry(1,(entry(v-sel,v-rep, '|')),' ')).
    /*message "ky-ky " v-reptype view-as alert-box.*/
    display v-reptype2 with frame f-par.
end.

on "END-ERROR" of frame f-par do: 
   hide all.
   run journal.
end.

update v-acc2 v-reptype2 v-rdat1 v-rdat2 with frame f-par.


if v-rdat1 <> ? and v-rdat2 <> ? then v-rdatel = no. else v-rdatel = yes.  
if trim(v-reptype2) <> " " then v-reptypel = no. else v-reptypel = yes.

if trim(v-acc2) <> " " then do: 
  for each jreports where jreports.acc = v-acc2 and (v-rdatel or (jreports.rdate >= v-rdat1 and jreports.rdate <= v-rdat2)) and (v-reptypel or jreports.reptype = v-reptype2) no-lock use-index main:
    create t-jreports.
    buffer-copy jreports to t-jreports.
  end.
end.  

if trim(v-reptype2) <> " " and trim(v-acc2) = " " then do: 
  for each jreports where jreports.reptype= v-reptype2 no-lock use-index reptype:
    create t-jreports.
    buffer-copy jreports to t-jreports.
  end.
end.

if v-rdat1 <> ? and v-rdat2 <> ? and trim(v-acc2) = " " and trim(v-reptype2) = " " then do:
  for each jreports where (jreports.rdate >= v-rdat1 and jreports.rdate <= v-rdat2) no-lock use-index rdt:
    create t-jreports.
    buffer-copy jreports to t-jreports.
  end.
end.

if (trim(v-acc2) = " " and (v-rdat1 = ? or v-rdat2 = ?) and trim(v-reptype2) = " ") then do:
 for each jreports no-lock use-index rdt:
    create t-jreports.
    buffer-copy jreports to t-jreports.
 end.
end.
/**/

define query qt for t-jreports.
define buffer b-jreports for t-jreports.

define browse bt query qt
       displ t-jreports.clname label "Клиент" format "x(40)" 
             t-jreports.acc label "Лиц.счет" format "x(12)"
             t-jreports.rdate label "Дата выдачи отчета" format "99/99/9999" 
             t-jreports.reptype label "Вид отчета" format "x(3)" 
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsave " " brep
 with width 110 row 3 overlay no-label title "Журнал выдачи отчетов".

form 
 v-rdate label "Дата выдачи отчета" format "99/99/9999" skip
 v-clname label "Клиент" format "x(40)" skip
 v-acc label "Лиц.счет" format "x(12)" skip
 v-reptype label "Вид отчета" format "x(3)" validate(can-find(codfr where codfr.codfr = "reptype" and codfr.code = v-reptype),'Неверный вид отчета') 
 help "F2 - справочник отчетов" skip
 v-sendmethod label "Способ отправки" format "x(40)" skip
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.

on help of v-reptype in frame fedit do:
if v-rep = " " then do:
 for each codfr where codfr.codfr = "reptype" and codfr.code <> "msc" no-lock:
   if v-rep <> "" then v-rep = v-rep + " |".
   v-rep = v-rep + codfr.code + " " + codfr.name[1].
 end.
end. 
    v-sel = 0.
    run sel2 (" ВЫБЕРИТЕ ОТЧЕТ ", v-rep, output v-sel).
    if v-sel <> 0 then v-reptype = trim(entry(1,(entry(v-sel,v-rep, '|')),' ')).
    display v-reptype with frame fedit.
end.

on "return" of bt in frame ft do:

    find first b-jreports where b-jreports.acc = t-jreports.acc no-lock no-error.
    if avail t-jreports then do:
         assign 
             v-rdate = b-jreports.rdate
             v-clname = b-jreports.clname
             v-acc = b-jreports.acc
             v-reptype = b-jreports.reptype
             v-sendmethod = b-jreports.sendmethod.
             
        on "END-ERROR" of frame fedit do: 
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return. 
        end.                
        
        update v-rdate v-clname v-acc v-reptype v-sendmethod with frame fedit.
        /*display v-reptype with frame f-par.*/
        
        find current b-jreports exclusive-lock.
         assign 
             b-jreports.rdate = v-rdate
             b-jreports.clname = v-clname
             b-jreports.acc = v-acc
             b-jreports.reptype = v-reptype
             b-jreports.sendmethod = v-sendmethod.
       find current b-jreports no-lock.
    end.
    open query qt for each t-jreports use-index rdt no-lock.
    find first t-jreports no-lock no-error.
    if avail t-jreports then bt:refresh().
    
end. 

on "insert-mode" of bt in frame ft do:
    create t-jreports.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jreports).
    open query qt for each t-jreports use-index rdt no-lock.
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
 find first t-jreports use-index rdt no-lock no-error.
 if avail t-jreports then do:
     for each t-jreports no-lock use-index rdt:
      find first jreports where jreports.acc = t-jreports.acc exclusive-lock no-error.
      if not avail jreports then create jreports. 
      buffer-copy t-jreports to jreports.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

on choose of brep in frame ft do:
find first t-jreports use-index rdt no-lock no-error.
if avail t-jreports then do:
 output stream vcrpt to "jreports.xls".
 
    {html-title.i 
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал выдачи отчетов"
    }
    
    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал выдачи отчетов</FONT></P>" skip.
    
    if v-rdat1 <> ? and v-rdat2 <> ? then do:
     if v-rdat1 <> v-rdat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата выдачи отчета c " + string(v-rdat1, '99/99/9999') + " по "  + string(v-rdat2, '99/99/9999') skip.           
     end.    
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата выдачи отчета " + string(v-rdat1, '99/99/9999') skip.           
     end.
    end.  
    if trim(v-acc2) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета " + v-acc2 skip.         
    end.
    if trim(v-reptype2) <> " " then do:
     find codfr where codfr.codfr = "reptype" and codfr.code = trim(v-reptype2) no-lock.
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Наименование отчета: " + codfr.name[1] skip.         
    end.  
    i = 0.

      put stream vcrpt unformatted
      
      "<TR valign=""top"">" skip 
      "<TD>№ п/п</TD>" skip
      "<TD>Дата выдачи<BR>отчета</TD>" skip
      "<TD>Ф.И.О.<BR>наименование клиента</TD>" skip
      "<TD>№ лицевого<BR>счета</TD>" skip     
      "<TD>Наименование<BR>отчета</TD>" skip
      "<TD>Способ отправки отчета</TD>" 
      "</TR>" skip.

    
     for each t-jreports use-index rdt no-lock:
      i = i + 1.
      find codfr where codfr.codfr = "reptype" and codfr.code = trim(t-jreports.reptype) no-lock.
      v-repname = codfr.name[1].
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>" t-jreports.rdate "</TD>" skip
      "<TD>" t-jreports.clname "</TD>" skip
      "<TD> &nbsp;" t-jreports.acc "</TD>" skip     
      "<TD>" v-repname "</TD>" skip
      "<TD>" t-jreports.sendmethod "</TD>" 
      "</TR>" skip.
    end.
  put stream vcrpt unformatted
  "</TABLE>" skip. 
  {html-end.i}
  
  output stream vcrpt close.
  unix silent value("cptwin jreports.xls excel").
  unix silent rm -f jreports.xls.
end.  
end.
open query qt for each t-jreports use-index rdt no-lock.
enable bt bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
