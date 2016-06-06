/* jcontract.p
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

def var v-cnum as char no-undo.
def var v-cnum1 as char no-undo.
def var v-cdat1 as date no-undo.
def var v-cdat2 as date no-undo.
def var v-cdate as date no-undo.
def var v-clname as char no-undo.
def var v-accnum as char no-undo.
def var v-accnum1 as char no-undo.
def var v-subacc as char no-undo.
def var v-subacc1 as char no-undo.
def var v-macc as char no-undo.
def var v-accbdt as date no-undo.
def var v-accedt as date no-undo.
def var v-csts as char no-undo.
def var v-csts1 as char no-undo.
def var v-cstsch as char no-undo.
def var v-sel as integer.
def var v-cdatel as logi no-undo.
def var v-accnuml as logi no-undo.
def var v-subaccl as logi no-undo.

define button bsort label "Доп.фильтр".
define button bsave label "Сохранить".
define button brep label "Отчет".

def temp-table t-jcontract like jcontract.
def stream vcrpt.

/*ввод параметров*/

form
  skip(1)
  v-cnum1 label "# договора" format "x(10)" help "F2 - список номеров договоров" skip
  v-cdat1 format "99/99/9999" label "Дата договора с "
  validate (v-cdat1 <= g-today or v-cdat1 = ?, " Дата не может быть больше " + string (g-today))
  v-cdat2 format "99/99/9999" label " по "
  validate (v-cdat2 <= g-today or v-cdat2 = ?, " Дата не может быть больше " + string (g-today)) skip
  v-subacc1 label "Субсчет" format "x(12)" help "F2 - номера субсчетов" skip
  skip (1)
with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par.

on help of v-cnum1 in frame f-par do:
 {jsprav.i
  &table = "jcontract"
  &field = "cnum"
  &flname = "'ВЫБЕРИТЕ НОМЕР ДОГОВОРА'"}
  if v-sel <> 0 then v-cnum1 = entry(v-sel,v-list,'|').
  display v-cnum1 with frame f-par.
end.

on help of v-subacc1 in frame f-par do:
 {jsprav.i
  &table = "jcontract"
  &field = "subacc"
  &flname = "'ВЫБЕРИТЕ НОМЕР СУБСЧЕТА'"}
  if v-sel <> 0 then v-subacc1 = entry(v-sel,v-list,'|').
  display v-subacc1 with frame f-par.
end.

on "END-ERROR" of frame f-par do:
   hide all.
   run journal.
end.

update v-cnum1  v-cdat1 v-cdat2 v-subacc1 with frame f-par.

if v-cdat1 <> ? and v-cdat2 <> ?  then v-cdatel = no. else v-cdatel = yes.
if trim(v-subacc1) <> " " then v-subaccl = no. else v-subaccl = yes.

if trim(v-cnum1) <> " " then do:
  for each jcontract where jcontract.cnum = v-cnum1 and (v-cdatel or (jcontract.cdate >= v-cdat1 and jcontract.cdate <= v-cdat2)) and (v-subaccl or jcontract.subacc = v-subacc1) no-lock use-index submain:
    create t-jcontract.
    buffer-copy jcontract to t-jcontract.
  end.
end.

if v-cdat1 <> ? and v-cdat2 <> ? and trim(v-cnum1) = " " then do:
  for each jcontract where (jcontract.cdate >= v-cdat1 and jcontract.cdate <= v-cdat2) and (v-subaccl or jcontract.subacc = v-subacc1) no-lock use-index cdtsubacc:
    create t-jcontract.
    buffer-copy jcontract to t-jcontract.
  end.
end.

if trim(v-subacc1) <> " " and  (v-cdat1 = ? or v-cdat2 = ?) and trim(v-cnum1) = " " then do:
  for each jcontract where jcontract.subacc = v-subacc1 no-lock use-index subaccdt:
    create t-jcontract.
    buffer-copy jcontract to t-jcontract.
  end.
end.

if (trim(v-cnum1) = " " and (v-cdat1 = ? or v-cdat2 = ?) and trim(v-subacc1) = " ") then do:
    form
      skip(1)
      v-cnum1 label "# договора" format "x(10)" help "F2 - список номеров договоров" skip
      v-cdat1 format "99/99/9999" label "Дата договора с "
      validate (v-cdat1 <= g-today or v-cdat1 = ?, " Дата не может быть больше " + string (g-today))
      v-cdat2 format "99/99/9999" label " по "
      validate (v-cdat2 <= g-today or v-cdat2 = ?, " Дата не может быть больше " + string (g-today)) skip
      v-accnum1 label "Лиц.счет" format "x(12)" help "F2 - список лиц.счетов" skip
      skip (1)
    with centered side-label row 5 title "ПАРАМЕТРЫ" frame f-par1.

    on help of v-cnum1 in frame f-par1 do:
    {jsprav.i
     &table = "jcontract"
     &field = "cnum"
     &flname = "'ВЫБЕРИТЕ НОМЕР ДОГОВОРА'"}
     if v-sel <> 0 then v-cnum1 = entry(v-sel,v-list,'|').
     display v-cnum1 with frame f-par1.
    end.

    on help of v-accnum1 in frame f-par1 do:
    {jsprav.i
     &table = "jcontract"
     &field = "accnum"
     &flname = "'ВЫБЕРИТЕ НОМЕР ЛИЦ.СЧЕТА'"}
     if v-sel <> 0 then v-accnum1 = entry(v-sel,v-list,'|').
     display v-accnum1 with frame f-par1.
    end.

    update v-cnum1 v-cdat1 v-cdat2 v-accnum1 with frame f-par1.

    if v-cdat1 <> ? and v-cdat2 <> ? then v-cdatel = no. else v-cdatel = yes.
    if trim(v-accnum1) <> " " then v-accnuml = no. else v-accnuml = yes.

    if trim(v-cnum1) <> " " then do:
      for each jcontract where jcontract.cnum = v-cnum1 and (v-cdatel or (jcontract.cdate >= v-cdat1 and jcontract.cdate <= v-cdat2)) and (v-accnuml or jcontract.accnum = v-accnum1) no-lock use-index main:
        create t-jcontract.
        buffer-copy jcontract to t-jcontract.
      end.
    end.

    if v-cdat1 <> ? and v-cdat2 <> ? and trim(v-cnum1) = " " then do:
      for each jcontract where (jcontract.cdate >= v-cdat1 and jcontract.cdate <= v-cdat2) and (v-accnuml or jcontract.accnum = v-accnum1) no-lock use-index cdtacc:
        create t-jcontract.
        buffer-copy jcontract to t-jcontract.
      end.
    end.

    if trim(v-accnum1) <> " " and trim(v-cnum1) = " " and (v-cdat1 = ? or v-cdat2 = ?)  then do:
      for each jcontract where jcontract.accnum = v-accnum1 no-lock use-index accdt:
        create t-jcontract.
        buffer-copy jcontract to t-jcontract.
      end.
    end.

    if (trim(v-cnum1) = " " and (v-cdat1 = ? or v-cdat2 = ?)  and trim(v-accnum1) = " ") then do:
     for each jcontract no-lock use-index cnumdate:
        create t-jcontract.
        buffer-copy jcontract to t-jcontract.
      end.
    end.
end.
/**/

define query qt for t-jcontract.
define buffer b-jcontract for t-jcontract.

define browse bt query qt
       displ t-jcontract.cnum label "# договора" format "x(10)"
             t-jcontract.cdate label "Дата договора" format "99/99/9999"
             t-jcontract.clname label "Клиент" format "x(40)"
             t-jcontract.subacc label "Субсчет" format "x(12)"
             with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " bsort " " bsave " " brep
 with width 110 row 3 overlay no-label title " Журнал договоров брокерских услуг ".

form
 v-cnum label "# договора" format "x(10)" skip
 v-cdate label "Дата договора" format "99/99/9999" skip
 v-clname label "Клиент" format "x(40)" skip
 v-accnum label "Лиц.счет" format "x(12)" skip
 v-accbdt label "Дата открытия ЛС" format "99/99/9999" skip
 v-accedt label "Дата закрытия ЛС" format "99/99/9999" skip
 v-subacc label "Субсчет" format "x(12)" skip
 v-macc label "Счет для расчетов" format "x(12)" skip
 v-csts label "Статус" format "x(1)" help "A - активен|C - расторгнут" validate(index("AC",v-csts) > 0,'Неверный статус договора!')
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.


on "return" of bt in frame ft do:

    find first b-jcontract where b-jcontract.accnum = t-jcontract.accnum no-lock no-error.
    if avail b-jcontract then do:
         assign
          v-cnum = b-jcontract.cnum
          v-cdate = b-jcontract.cdate
          v-clname = b-jcontract.clname
          v-accnum = b-jcontract.accnum
          v-subacc = b-jcontract.subacc
          v-macc = b-jcontract.macc
          v-accbdt = b-jcontract.accbdt
          v-accedt = b-jcontract.accedt
          v-csts = b-jcontract.csts.

         on help of v-csts in frame fedit do:
            v-sel = 0.
            run sel2("ВЫБЕРИТЕ СТАТУС КОНТРАКТА","A - активен|C - расторгнут", output v-sel).
            if v-sel <> 0 then v-csts = entry(1,entry(v-sel,"A - активен|C - расторгнут",'|'),' ').
            displ v-csts with frame fedit.
         end.

         on "END-ERROR" of frame fedit do:
           message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
           return.
         end.

         update  v-cnum v-cdate v-clname v-accnum v-accbdt v-accedt v-subacc v-macc v-csts  with frame fedit.
         find current b-jcontract exclusive-lock.
          assign
            b-jcontract.cnum = v-cnum
            b-jcontract.cdate = v-cdate
            b-jcontract.clname = v-clname
            b-jcontract.accnum = v-accnum
            b-jcontract.subacc = v-subacc
            b-jcontract.macc = v-macc
            b-jcontract.accbdt = v-accbdt
            b-jcontract.accedt = v-accedt
            b-jcontract.csts = v-csts.

        find current b-jcontract no-lock.
    end.
    open query qt for each t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock.
    find first t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock no-error.
    if avail t-jcontract then  bt:refresh().
end.

on "insert-mode" of bt in frame ft do:
    create t-jcontract.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-jcontract).
    open query qt for each t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

/*on "delete-line" of bt in frame ft do:
    choice = no.
    message "Удалить запись?"
              view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice then do:
        find first b-jcontract where b-jcontract.cnum = t-jcontract.cnum exclusive-lock.
        delete b-jcontract.
        open query qt for each t-jcontract where (trim(v-csts) = " " or t-jcontract.csts = v-csts) no-lock.
        bt:refresh().
    end.
end.*/

on choose of bsave in frame ft do:
 find first t-jcontract use-index cnumdate no-lock no-error.
 if avail t-jcontract then do:
     for each t-jcontract no-lock use-index cnumdate:
      find first jcontract where jcontract.cnum = t-jcontract.accnum exclusive-lock no-error.
      if not avail jcontract then create jcontract.
      buffer-copy t-jcontract to jcontract.
     end.
     message " Данные сохранены " view-as alert-box information.
 end.
 else message " Данные для сохранения отсутсвуют " view-as alert-box information.
end.

on choose of bsort in frame ft do:
 displ v-csts1 label " Статус" format "x(1)" help "A - активен; C - расторгнут" validate(index("AC",v-csts1) > 0,'Неверный статус договора!')
 with width 20 overlay side-label title "СТАТУС КОНРАКТА" row 10 column 10 frame fr2.

  on help of v-csts1 in frame fr2 do:
   v-sel = 0.
   run sel2("ВЫБЕРИТЕ СТАТУС КОНТРАКТА","A - активен|C - расторгнут", output v-sel).
   if v-sel <> 0 then v-csts1 = entry(1,entry(v-sel,"A - активен|C - расторгнут",'|'),' ').
   displ v-csts1 with frame fr2.
 end.

 update v-csts1 with frame fr2.
 hide frame fr2.

 open query qt for each t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock.
end.

on "END-ERROR" of frame ft do:
   message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
   hide all.
   run journal.
end.

on choose of brep in frame ft do:
find first t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock no-error.
if avail t-jcontract then do:
 output stream vcrpt to "jcontract.xls".

    {html-title.i
     &stream = " stream vcrpt "
     &size-add = "xx-"
     &title = "Журнал заключенных Договоров об оказании брокерских услуг"
    }

    find first cmp no-lock no-error.
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<FONT size=""2"" face=""Arial Cyr""><P align = ""left"">" skip
       "<U>"  cmp.name "</U>" skip
       "<P align = ""center""><FONT size=""3"" face=""Arial Cyr"">" skip
       "Журнал заключенных Договоров об оказании брокерских услуг</FONT></P>" skip.

    if trim(v-cnum1) <> " " then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ заказа " + v-cnum1 + " " skip.
    end.

    if v-cdat1 <> ? and v-cdat2 <> ? then do:
     if v-cdat1 <> v-cdat2 then do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата договора c " + string(v-cdat1, '99/99/9999') + " по "  + string(v-cdat2, '99/99/9999') skip.
     end.
     else do:
        put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "Дата договора " + string(v-cdat1, '99/99/9999') skip.

     end.
    end.
    if trim(v-accnum1) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ лицевого счета: " + v-accnum1 skip.
    end.
    if trim(v-subacc1) <> " " then do:
     put stream vcrpt unformatted
          "</P><P align = ""center"">" skip
         "№ субсчета: " + v-subacc1 skip.
    end.
    if v-csts1 <> " " then do:
      put stream vcrpt unformatted
      "</P><P align = ""center"">" skip
         "Статус договора: ".
     case v-csts1:
      when "A" then put stream vcrpt unformatted "Активен" skip.
      when "C" then put stream vcrpt unformatted "Расторгнут" skip.


     end.
    end.

    put stream vcrpt unformatted
       "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD>№ договора</TD>" skip
         "<TD>Дата<BR>договора</TD>" skip
         "<TD>Ф.И.О.<BR>наименование клиента </TD>" skip
         "<TD>Дата открытия<BR>лиц.счета</TD>" skip
         "<TD>№ лицевого<BR>счета</TD>" skip
         "<TD>№ субсчета</TD>" skip
         "<TD>№ счета<BR>денежных расчетов</TD>" skip
         "<TD>Дата закрытия<BR>лиц.счета</TD>" skip
         "<TD>Статус<BR>договора</TD>" skip
         "</TR>" skip.

    for each t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock:
      if t-jcontract.csts = "A" then  v-cstsch = "Активен".
      if t-jcontract.csts = "C" then  v-cstsch = "Расторгнут".
      put stream vcrpt unformatted
      "<TR valign=""top"">" skip
      "<TD>" t-jcontract.cnum "</TD>" skip
      "<TD>" t-jcontract.cdate "</TD>" skip
      "<TD>" t-jcontract.clname "</TD>" skip
      "<TD>" t-jcontract.accbdt "</TD>" skip
      "<TD> &nbsp;" t-jcontract.accnum "</TD>" skip
      "<TD> &nbsp;" t-jcontract.subacc "</TD>" skip
      "<TD>" t-jcontract.macc "</TD>" skip
      "<TD>" t-jcontract.accedt "</TD>" skip
      "<TD>" v-cstsch "</TD>" skip
      "</TR>" skip.

    end.
  put stream vcrpt unformatted
  "</TABLE>" skip.
  {html-end.i}

  output stream vcrpt close.
  unix silent value("cptwin jcontract.xls excel").
  unix silent rm -f jcontract.xls.
end.
end.

open query qt for each t-jcontract where (trim(v-csts1) = " " or t-jcontract.csts = v-csts1) no-lock.
enable bt bsort bsave brep with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.
