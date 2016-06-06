/* kdaccoun.i
 * MODULE
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        Расчет остатков и оборотов
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
    05/09/06   marinav - добавление индексов
*/

if s-kdcif = '' then return.

find {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

    if not avail {2} then do:
      message skip " Клиент N" s-kdcif "не найден !" skip(1)
        view-as alert-box buttons ok title " ОШИБКА ! ".
      return.
    end.

if s-kdlon ne '' then do:
     find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  
    if not avail kdlon then do:
      message skip " Клиент N" s-kdlon "не найден !" skip(1)
        view-as alert-box buttons ok title " ОШИБКА ! ".
      return.
    end.
end.
    
define var v-list as char init '1,2,4,11'.   /*'KZT,USD,RUB,EUR'.*/
define var v-crc as char format 'x(15)' extent 5.
define var v-crc1 as char format 'x(15)' extent 5.
define var v-sum as decimal format '-zzz,zzz,zzz,zz9.99' extent 5.
define var v-sums as decimal format '-zzz,zzz,zzz,zz9.99' extent 5.
define var v-sum1 as decimal format '-zzz,zzz,zzz,zz9.99' extent 5.
define var i as inte.
define var j as inte.
define var k as inte.
define var d1 as date.
define var d2 as date.
define var d3 as date.
define buffer b-crchis for crchis.
def var v-sel as char.


define variable s_rowid as rowid.

find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '09'
                  and ({1}.bank = s-ourbank or s-ourbank = "TXB00")  and {1}.name matches '*TEXAKABANK*' no-lock no-error.

if avail {1} then do:
  run sel2 ("Выбор :", " 1. Просмотреть сохраненные данные | 2. Расчитать данные по TEXAKABANK заново ", output v-sel).
  if v-sel = "2" then do:
     find current {1} exclusive-lock no-error. 
     delete {1}.
     find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '09' and 
                           ({1}.bank = s-ourbank or s-ourbank = "TXB00") and {1}.name matches '*TEXAKABANK*' no-lock no-error. 
  end.
  else if v-sel <> "1" then leave.
end.

if not avail {1} then do:
 if s-ourbank = {2}.bank then do:
   d1 = date(1,1,year(g-today)).
   d2 = g-today.
   update d1 label ' Дата начала периода ' format '99/99/9999' validate(d1 <= g-today, " Некорректная дата! ") skip
          d2 label ' Дата конца периода  ' format '99/99/9999' validate(d2 <= g-today and d2 >= d1, " Некорректная дата! ") skip
          with side-label row 5 centered frame dat .

   repeat i = 1 to num-entries(v-list): 
        v-sum[i] = 0. v-sums[i] =0.
   end.
   create {1}.
   assign {1}.bank = s-ourbank
          {1}.code = '09'
          {1}.kdcif = s-kdcif
          
          {1}.who = g-ofc
          {1}.whn = g-today
          {1}.name = "TEXAKABANK" /*U00121 ЭТО НАЗВАНИЕ МОЖНО (НУЖНО) ВЗЯТЬ ИЗ ТАБЛИЦЫ CMP (П.П. 9-1-1-1)*/
          {1}.dat = d1.
          {3}.
          {1}.datres[1] = d2.
  find current {1} no-lock no-error. 
  display " Идет расчет оборотов по счетам !"  with row 5 frame ww centered.

  repeat i = 1 to num-entries(v-list):
   find last crchis where crchis.crc = inte(entry(i,v-list)) and crchis.regdt <= d2 no-lock no-error.
   if avail crchis then do:
     v-crc[i] = crchis.code.
     
     for each aaa where aaa.cif = s-kdcif and aaa.crc = crchis.crc no-lock:
       if aaa.lgr begins '5' then next.
       for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and jl.jdt >= d1 and jl.jdt <= d2 no-lock.
         if not (jl.crc = crchis.crc and jl.lev = 1) then next.
         accumulate jl.cam (TOTAL).
       end.
       v-sum[i] = v-sum[i] + accum total jl.cam. /* полный кредитовый оборот */
     end.
     
     for each lon where lon.cif = s-kdcif and lon.crc = crchis.crc no-lock:
        for each lnscg where lnscg.lng = lon.lon and lnscg.stdat >= d1 and lnscg.stdat <= d2 no-lock:
           if lnscg.jh > 0 then v-sums[i] = v-sums[i] + lnscg.paid. /* дебетовый оборот по ссудным счетам */
        end.
     end.
     
     v-sums[i] = v-sum[i] - v-sums[i].
     
    /* for each lgr where lgr.led eq "CDA" or lgr.led eq "TDA" no-lock, each */
       for each aaa where aaa.cif = s-kdcif and aaa.crc = crchis.crc no-lock.
         if d2 = g-today then v-sum1[i] = v-sum1[i] + aaa.cbal.
         else do:
           find last aab where aab.aaa = aaa.aaa and aab.fdt <= d2 no-lock no-error.
           if avail aab then v-sum1[i] = v-sum1[i] + aab.bal.
         end.
       end.
   end.
   find current {1} exclusive-lock no-error. 
   if {1}.info[1] = '' 
     then {1}.info[1] = v-crc[i]  + ',' + string(v-sum[i] / ((d2 - d1) / 30)).
     else {1}.info[1] = {1}.info[1] + ',' + v-crc[i] + ',' + string(v-sum[i] / ((d2 - d1) / 30)).
                         
   if {1}.info[2] = ''
     then {1}.info[2] = v-crc[i] + ',' + string(v-sum1[i] ).
     else {1}.info[2] = {1}.info[2] + ',' + v-crc[i] + ',' + string(v-sum1[i]).
   
   if {1}.info[3] = ''
     then {1}.info[3] = v-crc[i] + ',' + string(v-sums[i] / ((d2 - d1) / 30)).
     else {1}.info[3] = {1}.info[3] + ',' + v-crc[i] + ',' + string(v-sums[i] / ((d2 - d1) / 30)).
   find current {1} no-lock no-error. 
  
  end.
 end. /* if s-ourbank = kdlon.bank */
 else do:
   message " Данные не были введены " view-as alert-box buttons ok title " Нет данных! ".
   return.
 end.
end.
d1 = {1}.dat.
d2 = {1}.datres[1].
d3 = {1}.datres[1].
define frame fr
       "        Валюта                          Сумма" skip(1)
       'ОБОРОТЫ ПО СЧЕТАМ С ' d1 no-label ' ПО ' d2  no-label skip
       'Полный среднемес. об.' colon 20 'Чистый среднемес. об. ' colon 44 skip
       'Текущим  ' v-crc[1] format "X(12)" no-label v-sum[1] no-label '  ' v-sums[1] no-label skip
       '         ' v-crc[2] format "X(12)" no-label v-sum[2] no-label '  ' v-sums[2] no-label skip
       '         ' v-crc[3] format "X(12)" no-label v-sum[3] no-label '  ' v-sums[3] no-label skip
       '         ' v-crc[4] format "X(12)" no-label v-sum[4] no-label '  ' v-sums[4] no-label skip(1)
       'ОСТАТКИ НА СЧЕТАХ ЗА ' d3 no-label skip
       '         ' v-crc1[1] format "X(12)" no-label v-sum1[1] no-label skip
       '         ' v-crc1[2] format "X(12)" no-label v-sum1[2] no-label skip
       '         ' v-crc1[3] format "X(12)" no-label v-sum1[3] no-label skip
       '         ' v-crc1[4] format "X(12)" no-label v-sum1[4] no-label skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 58 side-labels centered row 4 title " СЧЕТА ЗАЕМЩИКА ".

 pause 0.


{jabrw.i 
&start     = " "

&head      = "{1}"

&headkey   = "code"

&index     = "cifnomc"

&formname  = "{5}"

&framename = "kdaffil9"

&where     = " {1}.kdcif = s-kdcif and {3} and {1}.code = '09' "

&addcon    = "(s-ourbank = {2}.bank)"

&deletecon = "(s-ourbank = {2}.bank)"

&precreate = " "

&postadd   = " {1}.bank = s-ourbank. {1}.code = '09'. {1}.kdcif = s-kdcif. {3}.  {1}.who = g-ofc. {1}.whn = g-today. {1}.dat = d1.
 update {1}.name with frame kdaffil9.
 repeat i = 1 to num-entries(v-list): find crc where crc.crc = inte(entry(i,v-list)) no-lock no-error.  
 if avail crc then do:  v-crc[i] = crc.code. v-crc1[i] = v-crc[i]. v-sum[i] = 0. v-sum1[i] = 0. v-sums[i] = 0. end. end.
 message 'F1-Принять, F4-Отменить'.
 do k = 1 to 4: displ v-crc[k] v-sum[k] v-crc1[k] v-sum1[k] v-sums[k] with frame fr. end.
 displ {1}.whn {1}.who  d1 d2 d3 with frame fr.
 if not ({1}.name matches '*TEXAKABANK*') then do: update d1 d2 with frame fr. d3 = d2. display d3 with frame fr. end.
 update v-sum[1] v-sum[2] v-sum[3] v-sum[4] v-sum1[1] v-sum1[2] v-sum1[3] v-sum1[4] with frame fr.
 /*if {1}.name matches '*TEXAKABANK*' then*/ update v-sums[1] v-sums[2] v-sums[3] v-sums[4] with frame fr.
 {1}.dat = d1. {1}.rdt = d2. {1}.info[1] = ''.
 repeat i = 1 to num-entries(v-list):
  if {1}.info[1] = '' then {1}.info[1] = v-crc[i] + ',' + string(v-sum[i]). else {1}.info[1] = {1}.info[1] + ',' + v-crc[i] + ',' + string(v-sum[i]).
  if {1}.info[2] = '' then {1}.info[2] = v-crc[i] + ',' + string(v-sum1[i]). else {1}.info[2] = {1}.info[2] + ',' + v-crc[i] + ',' + string(v-sum1[i]).
  if {1}.info[3] = '' then {1}.info[3] = v-crc[i] + ',' + string(v-sums[i]). else {1}.info[3] = {1}.info[3] + ',' + v-crc[i] + ',' + string(v-sums[i]). end. "

&prechoose = "message 'F4-Выход, INS-Вставка.'."

&postdisplay = " "

&display   = "{1}.name "

&highlight = " {1}.name "

&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction on endkey undo, leave:
 if s-ourbank = {2}.bank then do: update {1}.name with frame kdaffil9. message 'F1-Принять, F4-Отменить'. end.
 if not ({1}.name matches '*TEXAKABANK*') then do: if {1}.dat <> ? then d1 = {1}.dat. if {1}.rdt <> ? then d2 = {1}.rdt. end.
 repeat i = 1 to num-entries({1}.info[1]) by 2: j = (i + 1) / 2. v-crc[j] = entry(i , {1}.info[1]). v-crc1[j] = v-crc[j].
  v-sum[j] = deci(entry(i + 1,{1}.info[1])). v-sum1[j] = deci(entry(i + 1,{1}.info[2])). v-sums[j] = deci(entry(i + 1,{1}.info[3])). end.
 do k = 1 to 4: displ v-crc[k] v-sum[k] v-crc1[k] v-sum1[k] v-sums[k] with frame fr. end.
 displ {1}.whn {1}.who  d1 d2 d3 with frame fr.  if s-ourbank = {2}.bank then do: if not ({1}.name matches '*TEXAKABANK*') then do: update d1 d2 with frame fr. d3 = d2. display d3 with frame fr. end.
  update v-sum[1] v-sum[2] v-sum[3] v-sum[4] v-sum1[1] v-sum1[2] v-sum1[3] v-sum1[4]  with frame fr scrollable.
  update v-sums[1] v-sums[2] v-sums[3] v-sums[4] with frame fr. {1}.dat = d1. {1}.rdt = d2. {1}.info[1] = '' . {1}.info[2] = ''. {1}.info[3] = ''.
  repeat i = 1 to num-entries(v-list): if {1}.info[1] = '' then {1}.info[1] = v-crc[i]  + ',' + string(v-sum[i]). else {1}.info[1] = {1}.info[1] + ',' + v-crc[i] + ',' + string(v-sum[i]). 
   if {1}.info[2] = '' then {1}.info[2] = v-crc[i] + ',' + string(v-sum1[i]). else {1}.info[2] = {1}.info[2] + ',' + v-crc[i] + ',' + string(v-sum1[i]).
   if {1}.info[3] = '' then {1}.info[3] = v-crc[i] + ',' + string(v-sums[i]). else {1}.info[3] = {1}.info[3] + ',' + v-crc[i] + ',' + string(v-sums[i]). end.
 {1}.who = g-ofc. {1}.whn = g-today. end. else pause. hide frame fr no-pause. end."

&end = "hide frame kdaffil9. hide frame fr."
}
hide message.


            

