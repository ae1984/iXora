/* kddeb.i
 * MODULE
        ЭКД 
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        Внесение баланса по активу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
        27/04/2006 madiyar - балансовые данные - для обычных кредитов
        11.08.06   marinav - оптимизация
    05/09/06   marinav - добавление индексов
 */


if s-kdcif = '' then return.

find {2} where  {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var v-sel as char.

  run sel ("Выбор :", 
           " 1. Расшифровка дебиторской задолженности | 2. Комментарии к дебиторской задолженности | 3. Выход").
  v-sel = return-value.

  case v-sel:     
    when "1" then    run s-deb .
    when "2" then    run s-komdeb .
    when "3" then return.
  end case.


procedure s-deb.

   define var v-dat as date.
   define var stitle as char.

   form stitle format 'x(50)' at 5 skip (1)
    "Дата" at 10 v-dat skip  
    with centered row 0 no-label frame f-cif1.

   v-dat = g-today.
   stitle = 'Дебиторская задолженность к балансу на дату :'.
    display stitle with frame f-cif1.
    update v-dat with frame f-cif1.

define frame fry {1}.info[1] no-label VIEW-AS EDITOR SIZE 65 by 5 skip
                with overlay width 70 side-labels column 7 row 10 title "Основание".

define variable s_rowid as rowid.
define var sum as deci.
define var sumb as deci.
define var w-lon as deci extent 27.
define var i as inte.

 i = 1.
 for each bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = v-dat  use-index cif-rdt no-lock:
     if bal_cif.nom begins 'a' and bal_cif.rem[1] = '01' then do:
        w-lon[i] = bal_cif.amount.
        i = i + 1.
     end.
 end.
 sumb = w-lon[16] + w-lon[17] + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21].


{jabrw.i 
&start     = " "
&head      = "{1}"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "{5}"
&framename = "kdaffil13"
&where     = " {1}.kdcif = s-kdcif and {3} and {1}.code = '13' and {1}.dat = v-dat "

&addcon    = "(s-ourbank = {2}.bank)"
&deletecon = "(s-ourbank = {2}.bank)"
&precreate = " "
&postadd   = "    {3}. {1}.bank = s-ourbank. {1}.code = '13'. {1}.kdcif = s-kdcif. {1}.kdlon = s-kdlon.  {1}.who = g-ofc. {1}.whn = g-today. {1}.dat = v-dat.
                  update {1}.name {1}.amount {1}.datres[1] {1}.datres[2] with frame kdaffil13 .
                  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                  update {1}.info[1] with frame fry. hide frame fry no-pause."
                 
&prechoose = "s_rowid = rowid({1}). sum = 0. for each {1} where {1}.bank = s-ourbank and {1}.code = '13' and {1}.kdcif = s-kdcif and {3} and {1}.dat = v-dat. 
              sum = sum + {1}.amount. end. find {1} where rowid({1}) = s_rowid no-lock no-error.
              put screen row 23 ' Итого дебит. задолженность  ' .
              if sum = sumb then put screen row 23 column 35 string(sum) + ' тг.'.
                            else put screen color messages row 23 column 35 string(sum) + ' тг.'.
              put screen row 23 column 50 '   В балансе  ' + string(sumb) + ' тг.'.  "

&postdisplay = " "

&display   = " {1}.name {1}.amount {1}.datres[1] {1}.datres[2] " 

&highlight = " {1}.name {1}.amount {1}.datres[1] {1}.datres[2] "

&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                        if s-ourbank = {2}.bank then do:
                            update {1}.name {1}.amount {1}.datres[1] {1}.datres[2] with frame kdaffil13.
                            message 'F1 - Сохранить,   F4 - Выход без сохранения'. 
                            update {1}.info[1] with frame fry.
                            {1}.who = g-ofc. {1}.whn = g-today.
                        end.
                        else do: displ {1}.info[1] with frame fry. pause. end.
                        hide frame fry no-pause.
                      end. "  
                              
&end = "hide frame kdaffil13.  
         hide frame fry.  put screen row 23 ''. "      
}
hide message.

end.

procedure s-komdeb.

   define var v-dat as date.
   define var stitle as char.
   define var s-info as char.
   define var s-tit as char format "x(50)".
   
   define frame fr skip(1) space(30) s-tit no-label skip(1)
       s-info  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ДЕБИТОРСКАЯ ЗАДОЛЖЕННОСТЬ " .

   form stitle format 'x(50)' at 5 skip (1)
    "Дата" at 10 v-dat skip  
    with centered row 0 no-label frame f-cif1.

   v-dat = g-today.
   stitle = 'Комментарии к дебиторской задолженности на дату :'.
    display stitle with frame f-cif1.
    update v-dat with frame f-cif1.

  find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '13' and ({1}.bank = s-ourbank or s-ourbank = "TXB00") and {1}.dat = v-dat no-lock no-error.
  if not avail {1} then do:
    if (s-ourbank = {2}.bank) then do:
        create {1}. 
        {3}. {1}.bank = s-ourbank. {1}.code = '13'. {1}.dat = v-dat. 
        {1}.kdcif = s-kdcif. {1}.who = g-ofc. {1}.whn = g-today.
        find current {1} no-lock no-error.
    end.
    else do:
      message skip "Запрашиваемые данные не были введены" skip(1) view-as alert-box buttons ok title " Нет данных ! ".
      return.
    end.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.

  s-tit = 'Комментарии'.
  s-info = {1}.info[2].
  displ s-tit s-info {1}.whn {1}.who with frame fr.
  if (s-ourbank = {2}.bank) then do:
    update s-info with frame fr.
    find current {1} exclusive-lock. 
    {1}.info[2] = s-info.
    find current {1} no-lock.
  end.
  else pause.

end.
