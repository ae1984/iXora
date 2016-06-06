/* kdhist.i
 * MODULE
        Электронное Кредитное 
 * DESCRIPTION
        кредиты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 КредИст - 
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


if s-kdcif = '' then return.

find {2} where  {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") 
     no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


def var v-cod as char.
define var type_ln as char.
define var v-descr as char format "x(25)".
define var amoun as deci.
define var v-crc as inte.
define var v-obinfo as char.
define var v-info as char.
define var prem as deci.
define var dat as date format '99/99/9999'.
define var dat1 as date format '99/99/9999' init '01/01/1000'.
define var dat2 as date format '99/99/9999'.
define var dat_str as char extent 3.
define var ost as deci.
define var sum_mes as deci.


define frame fr skip(1)
       type_ln  label "Банк. продукт    " validate (type_ln <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = type_ln no-lock), " Неверный код ! Выберите из справочника") v-descr no-label skip
       amoun    format ">>>,>>>,>>9.99" label "Одобренный лимит " skip
       v-crc    label "Валюта           " validate (can-find (crc where crc.crc = v-crc no-lock), " Неверный код ! Выберите из справочника") skip
       prem     label "Ставка %%        " skip
       dat      label "Дата возникн обяз" skip
       dat1     label "Погашен по факту " skip
       dat2     label "Погашен по догов " skip
       ost      format ">>>,>>>,>>9.99" label "Текущий остаток  " skip
       sum_mes  format ">>>,>>>,>>9.99" label "Взнос по обяз-ву " skip
       v-obinfo label "Обеспечение      " VIEW-AS EDITOR SIZE 50 by 2 skip
       v-info   label "Доп информация   " VIEW-AS EDITOR SIZE 50 by 2 skip(1)
       {1}.whn label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ИНФОРМАЦИЯ О КРЕДИТНОЙ ИСТОРИИ ".

on help of type_ln in frame fr do: 
  v-cod = type_ln.
  run uni_book ("kdfintyp", "*", output v-cod).  
  type_ln = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
    displ type_ln v-descr with frame fr.
end.

define var v-sel as char.

on help of {1}.res in frame kdaffil3 do: 
  run sel ("Выбор :", 
           " 1. Положительная | 2. Отрицательная | 3. Нет истории | 4. Нет информации ").
  v-sel = return-value.
  case v-sel:
    when "1" then {1}.res = "Положительная".
    when "2" then {1}.res = "Отрицательная".
    when "3" then {1}.res = "Нет истории".
    when "4" then {1}.res = "Нет информации".
  end case.
  displ {1}.res with frame kdaffil3.
end.


define variable s_rowid as rowid.

{jabrw.i 
&start     = " "
&head      = "{1}"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "{5}"
&framename = "kdaffil3"
&where     = "  {1}.kdcif = s-kdcif and {3} and {1}.code = '03' "

&addcon    = "(s-ourbank = {2}.bank)"
&deletecon = "(s-ourbank = {2}.bank)"
&precreate = " "
&postadd   = "  {1}.bank = s-ourbank. {1}.code = '03'. {1}.kdcif = s-kdcif.  {1}.who = g-ofc. {1}.whn = g-today. {3}.
      update {1}.name {1}.res with frame kdaffil3 .
      message 'F1 - Сохранить,   F4 - Выход без сохранения'.
      assign type_ln = '' v-descr = '' amoun = 0 v-crc = 1 prem = 0 dat = ? dat1 = 01/01/1000 dat2 = ? ost = 0 sum_mes = 0 v-obinfo = '' v-info = ''. 
      displ type_ln  v-descr amoun v-crc prem dat dat1 dat2 ost sum_mes v-obinfo v-info {1}.who {1}.whn with frame fr.
      update type_ln amoun v-crc prem dat dat1 dat2 ost sum_mes v-obinfo with frame fr.
      update v-info with frame fr.
      if dat <> ? then dat_str[1] = string(dat). else dat_str[1] = '?'.
                   if dat1 <> ? then dat_str[2] = string(dat1). else dat_str[2] = '?'.
                   if dat2 <> ? then dat_str[3] = string(dat2). else dat_str[3] = '?'.
      {1}.info[1] = type_ln + '|' + v-descr  + '|' + string(amoun)  + '|' + string(v-crc) + '|' + string(prem)  + '|' + dat_str[1]  + '|' +
        dat_str[2] + '|' + dat_str[3] + '|' + string(ost) + '|' + string(sum_mes) + '|' + v-obinfo + '|' + v-info. "
                 
&prechoose = "message 'F4-Выход,   INS-Вставка.'."

&postdisplay = " "

&display   = "{1}.name {1}.res" 

&highlight = " {1}.name {1}.res"


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
  then do transaction on endkey undo, leave:
    if s-ourbank = {2}.bank then do:
       update {1}.name {1}.res with frame kdaffil3.
       message 'F1 - Сохранить,   F4 - Выход без сохранения'.
    end.
    assign type_ln = entry(1,{1}.info[1],'|')     v-descr = entry(2,{1}.info[1],'|')
      amoun = deci(entry(3,{1}.info[1],'|')) v-crc = deci(entry(4,{1}.info[1],'|'))
      prem = deci(entry(5,{1}.info[1],'|'))  dat = date(entry(6,{1}.info[1],'|'))
      dat1 = date(entry(7,{1}.info[1],'|'))  dat2 = date(entry(8,{1}.info[1],'|'))
      ost = deci(entry(9,{1}.info[1],'|'))   sum_mes = deci(entry(10,{1}.info[1],'|'))
      v-obinfo = entry(11,{1}.info[1],'|')   v-info = entry(12,{1}.info[1],'|').
    displ type_ln v-descr amoun v-crc prem dat dat1 dat2 ost sum_mes v-obinfo v-info {1}.who {1}.whn with frame fr.
    if s-ourbank = {2}.bank then do:
      update type_ln amoun v-crc prem dat dat1 dat2 ost sum_mes v-obinfo with frame fr.
      update v-info with frame fr.
      if dat <> ? then dat_str[1] = string(dat). else dat_str[1] = '?'.
      if dat1 <> ? then dat_str[2] = string(dat1). else dat_str[2] = '?'.
      if dat2 <> ? then dat_str[3] = string(dat2). else dat_str[3] = '?'.
      {1}.info[1] = type_ln + '|' + v-descr  + '|' + string(amoun)  + '|' + string(v-crc) + '|' + string(prem) + '|' +
          dat_str[1] + '|' + dat_str[2] + '|' + dat_str[3] + '|' + string(ost) + '|' + string(sum_mes) + '|' + v-obinfo + '|' + v-info.
          {1}.who = g-ofc. {1}.whn = g-today.
    end.
    else pause.
    hide frame fr no-pause.
  end. "  
                              
&end = "hide frame kdaffil3.  
         hide frame fr."      
}
hide message.        1