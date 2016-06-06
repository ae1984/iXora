/* kddox2.i
 * MODULE
        ЭКД - Электронное кредитное досье

 * DESCRIPTION
        доходы в ТКБ по кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 КредИст - ДоходКред
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


define var god as inte.
define buffer jl2 for jl.
define var v-sum as deci format '->>>,>>>,>>>,>>9.99' extent 2.
define var i as inte init 1.

def temp-table temp_jl
    field tjh like jl.jh
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tjh tgl.


define var date1 as char.
define var sum1 as deci.
define var date2 as char.
define var sum2 as deci.
def var vs-info as char.
def var v-sel as char.

define buffer b-crchis for crchis.

if s-kdcif = '' then return.

find {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.



define variable s_rowid as rowid.

define frame kdaffil7 skip(1)
       "За  " date1 format 'x(4)' no-label "  "
       sum1 format '-zzz,zzz,zz9.99' no-label at 20 " тыс. тенге" skip   
       "За  " date2 format 'x(4)' no-label "  "
       sum2 format '-zzz,zzz,zz9.99' no-label at 20 " тыс. тенге" skip   
       {1}.info[2]  label "Будущие доходы" VIEW-AS EDITOR SIZE 60 by 4 skip(1)
       {1}.info[3]  label "Комментарии   " VIEW-AS EDITOR SIZE 60 by 4 skip(1)
       {1}.whn      label "Проведено " {1}.who  no-label
       with overlay width 80 side-labels column 3 row 3          
       title "ДОХОДЫ ПО КРЕДИТОВАНИЮ В TEXAKABANK " .


find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '08'  no-lock no-error.

if not avail {1} then do:
  if s-ourbank = {2}.bank then do:
    create {1}.
    assign {1}.bank = s-ourbank
           {1}.code = '08'
           {1}.kdcif = s-kdcif
           
           {1}.who = g-ofc
           {1}.whn = g-today.
           {3}.
    find current {1} no-lock no-error.
    vs-info = ''.
  end.
  else do:
    message " Запрашиваемые данные не были введены " view-as alert-box title " Нет данных! ".
    bell. undo, retry.
  end.
end.
else vs-info = {1}.info[1].

if vs-info <> '' and s-ourbank = {2}.bank then do:
  run sel2 ("Выбор :", " 1. Просмотреть сохраненные данные | 2. Расчитать данные заново ", output v-sel).
  if v-sel = "2" then do:
     find current {1} exclusive-lock no-error.
     {1}.info[1] = ''. vs-info = ''.
     {1}.who = g-ofc.
     {1}.whn = g-today.
     find current {1} no-lock no-error.
  end.
  else if v-sel <> "1" then leave.
end.

if vs-info = '' and s-ourbank = {2}.bank then do:
  display " Идет расчет доходности !"  with row 5 frame ww centered.
  repeat god = year(g-today) - 1 to year(g-today) by 1:   
  for each lon where lon.cif = s-kdcif no-lock.
    for each jl where jl.acc = lon.lon and jl.lev = 2 and year(jdt) = god no-lock. 
      for each jl2 where jl2.jh = jl.jh
           and (jl2.gl = 441160 or jl2.gl = 441170 or jl2.gl = 441460 
           or jl2.gl = 441470 or jl2.gl = 441760 or jl2.gl = 441770)
           no-lock:
        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           tjh = jl2.jh.
           temp_jl.tgl = jl2.gl.                                                   
            
        find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt
                  no-lock no-error.
 
        if avail crchis then temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1] .
        end.
      end.
    end.   
    for each jl where jl.acc = lon.lon and jl.lev = 1 and year(jdt) = god no-lock. 
      for each jl2 where jl2.jh = jl.jh
           and (jl2.gl = 444900 or jl2.gl = 460610 or jl2.gl = 461200)
           no-lock:
        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           tjh = jl2.jh.
           temp_jl.tgl = jl2.gl.
            
        find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt
                  no-lock no-error.

        if avail crchis then temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1] .
        end.
      end.
    end.   
  end.
  for each aaa where aaa.cif = s-kdcif no-lock.
    for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and year(jdt) = god no-lock. 
      for each jl2 where jl2.jh = jl.jh
           and (jl2.gl = 444900 or jl2.gl = 460610 or jl2.gl = 461200)
           no-lock:
        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           tjh = jl2.jh.
           temp_jl.tgl = jl2.gl.
            
        find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt
                  no-lock no-error. 
        if avail crchis then temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1] .
        end.
      end.
    end.   
  end.

  for each temp_jl where temp_jl.sumjl > 0.
      ACCUMULATE temp_jl.sumjl (total).
  end.
  v-sum[i] = ACCUMulate total temp_jl.sumjl.   

  if i = 1 then vs-info = vs-info + string(year(g-today) - 1) + ',' + string(v-sum[i] / 1000) + ','.
           else vs-info = vs-info + string(year(g-today)) + ',' + string(v-sum[i] / 1000) + ','.

  i = i + 1.
  for each temp_jl. delete temp_jl. end.
  end.
   pause 0 before-hide.
end.

find current {1} exclusive-lock no-error.
{1}.info[1] = vs-info.
find current {1} no-lock no-error.

date1 = entry(1,{1}.info[1]).
sum1 = deci(entry(2,{1}.info[1])). 
date2 = entry(3,{1}.info[1]).
sum2 = deci(entry(4,{1}.info[1])). 

message 'F1 - Перейти на след поле,  F4-Выход.'.
displ date1 sum1 date2 sum2 {1}.info[2] {1}.info[3] {1}.who {1}.whn with frame kdaffil7.
if (s-ourbank = {2}.bank) then do:
  find current {1} exclusive-lock no-error.
  update {1}.info[2] with frame kdaffil7.
  update {1}.info[3] with frame kdaffil7.
  find current {1} no-lock no-error.
end.
else do:
  displ {1}.info[2] {1}.info[3] with frame kdaffil7.
  pause.
end.

hide message.


