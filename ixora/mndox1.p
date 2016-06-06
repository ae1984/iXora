/* mndox1.p
 * MODULE
        Кредитное досье - Мониторинг
 * DESCRIPTION
        доходы в ТКБ по комиссиям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11 КредИст - ДоходКом
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}

define var god as inte.
define buffer jl2 for jl.
define var v-sum as deci format '->>>,>>>,>>>,>>9.99' extent 2.
define var v-sumob as deci.
define var v-sumcom360 as deci.
define var i as inte init 1.
define var dt_st as date.
def var v-sel as char.

def temp-table temp_jl
    field tjh like jl.jh
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tjh tgl.
    
/*def temp-table tempcom_jl
    field tjh like jl.jh
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tjh tgl.
*/
define var date1 as char.
define var sum1 as deci.
define var date2 as char.
define var sum2 as deci.
define var vs-info as char.

define buffer b-crchis for crchis.

if s-kdcif = '' then return.

find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom and (kdcifhis.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcifhis then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.



define variable s_rowid as rowid.

define frame kdaffil7 skip(2)
       "За  " date1 format 'x(4)' no-label " год   "
       sum1 format '-zzz,zzz,zz9.99' no-label at 25 " тыс. тенге" skip   
       "За  " date2 format 'x(4)' no-label " год   "
       sum2 format '-zzz,zzz,zz9.99' no-label at 25 " тыс. тенге" skip(2)   
       kdaffilh.info[2]  label "Комментарии   " VIEW-AS EDITOR SIZE 60 by 4 skip(1)
       kdaffilh.whn      label "Проведено " kdaffilh.who  no-label
       with overlay width 80 side-labels column 3 row 3          
       title "КОМИССИОННЫЕ ДОХОДЫ ПО КЛИЕНТУ В TEXAKABANK " .


find first kdaffilh where  kdaffilh.kdcif = s-kdcif  and kdaffilh.nom = s-nom and kdaffilh.code = '07' no-lock no-error.

if not avail kdaffilh then do:
  if s-ourbank = kdcifhis.bank then do:
    create kdaffilh.
    assign kdaffilh.bank = s-ourbank
           kdaffilh.code = '07'
           kdaffilh.kdcif = s-kdcif
           kdaffilh.nom = s-nom
           kdaffilh.who = g-ofc
           kdaffilh.whn = g-today.
    find current kdaffilh no-lock no-error.
    vs-info = ''.
  end.
  else do:
    message " Запрашиваемые данные не были введены " view-as alert-box title " Нет данных! ".
    bell. undo, retry.
  end.
end.
else vs-info = kdaffilh.info[1].

if vs-info <> '' and s-ourbank = kdcifhis.bank then do:
  run sel2 ("Выбор :", " 1. Просмотреть сохраненные данные | 2. Расчитать данные заново ", output v-sel).
  if v-sel = "2" then do:
     find current kdaffilh exclusive-lock no-error.
     kdaffilh.info[1] = ''. vs-info = ''.
     kdaffilh.who = g-ofc.
     kdaffilh.whn = g-today.
     find current kdaffilh no-lock no-error.
  end.
  else if v-sel <> "1" then leave.
end.

if vs-info = '' and s-ourbank = kdcifhis.bank then do:
  display " Идет расчет доходности !"  with row 5 frame ww centered.

  dt_st = g-today - 360.
  repeat god = year(g-today) - 1 to year(g-today) by 1:   
  for each aaa where aaa.cif = s-kdcif no-lock.
    for each jl where jl.acc = aaa.aaa and jl.lev = 1 and  year(jl.jdt) = god no-lock. 
      for each jl2 where jl2.jh = jl.jh and string(jl2.gl) begins '4'
           and (jl2.gl ne 441160 and jl2.gl ne 441170 and jl2.gl ne 441460 
           and jl2.gl ne 441470 and jl2.gl ne 441760 and jl2.gl ne 441770
           and jl2.gl ne 444900 and jl2.gl ne 460610 and jl2.gl ne 461200)
           no-lock.

        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           temp_jl.tjh = jl2.jh.
           temp_jl.tgl = jl2.gl.
            
           find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt no-lock no-error.
 
           if avail crchis then temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1].
           
           /* 11/05/2004 madiar */
           
/*           if jl.jdt >= dt_st and jl.jdt <= g-today then do:
              create tempcom_jl.
              tempcom_jl.tjh = jl2.jh.
              tempcom_jl.tgl = jl2.gl.
              tempcom_jl.sumjl = tempcom_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1].
           end.
 */          
           /* 11/05/2004 madiar - end */
           
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
  end. /* repeat */

  /* 11/05/2004 madiar */
  
  pause 0 before-hide.                  
end.

find current kdaffilh exclusive-lock no-error.
kdaffilh.info[1] = vs-info.
find current kdaffilh no-lock no-error.

date1 = entry(1,kdaffilh.info[1]).
sum1 = deci(entry(2,kdaffilh.info[1])). 
date2 = entry(3,kdaffilh.info[1]).
sum2 = deci(entry(4,kdaffilh.info[1])). 

message 'F1 - Перейти на след поле,  F4-Выход.'.
displ  date1 sum1 date2 sum2  kdaffilh.info[2] kdaffilh.who kdaffilh.whn with frame kdaffil7.
if (s-ourbank = kdcifhis.bank) then do:
  find current kdaffilh exclusive-lock no-error.
  update kdaffilh.info[2] with frame kdaffil7.
  find current kdaffilh no-lock no-error.
end.
else do:
  display kdaffilh.info[2] with frame kdaffil7.
  pause.
end.


hide message.


            

