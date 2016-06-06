/* kddox1.p
 * MODULE
        Название Программного Модуля
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
        4-11-3 КредИст - ДоходКом
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр досье филиалов в ГБ
        12/05/2004 madiar - Изменил расчет прогнозируемой доходности - теперь она равна (сумма комиссий по клиенту за период 360 дней до
                            даты расчета) / (сумма текущих остатков по кредитам + новый кредит) * 100
        15/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
                            Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
        15/06/2004 madiar - Исправил ошибку в расчете прогнозируемой доходности - надо конвертировать суммы по кредитам в тенге
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
    
def temp-table tempcom_jl
    field tjh like jl.jh
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tjh tgl.

define var date1 as char.
define var sum1 as deci.
define var date2 as char.
define var sum2 as deci.
define var date3 as char.
define var sum3 as deci.
define var sum4 as deci.
define var vs-info as char.

define buffer b-crchis for crchis.

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.



define variable s_rowid as rowid.

define frame kdaffil7 skip(1)
       "За  " date1 format 'x(4)' no-label " год   "
       sum1 format '-zzz,zzz,zz9.99' no-label at 25 " тыс. тенге" skip   
       "За  " date2 format 'x(4)' no-label " год   "
       sum2 format '-zzz,zzz,zz9.99' no-label at 25 " тыс. тенге" skip(1)   
       "Доходность по СПФ, получаемая в" skip
       "будущем от финанс-ния клиента  " 
       sum3 format '-zzz,zzz,zz9.9999' no-label at 33 " % годовых "skip(1)
       "Всего доходность за период " skip
       "финансирования клиента     " 
       sum4 format '-zzz,zzz,zz9.99' no-label at 35 " тыс.тенге "skip(1)
       kdaffil.info[2]  label "Комментарии   " VIEW-AS EDITOR SIZE 60 by 4 skip(1)
       kdaffil.whn      label "Проведено " kdaffil.who  no-label
       with overlay width 80 side-labels column 3 row 3          
       title "КОМИССИОННЫЕ ДОХОДЫ ПО КЛИЕНТУ В TEXAKABANK " .


find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '07' no-lock no-error.

if not avail kdaffil then do:
  if s-ourbank = kdlon.bank then do:
    create kdaffil.
    assign kdaffil.bank = s-ourbank
           kdaffil.code = '07'
           kdaffil.kdcif = s-kdcif
           kdaffil.kdlon = s-kdlon
           kdaffil.who = g-ofc
           kdaffil.whn = g-today.
    find current kdaffil no-lock no-error.
    vs-info = ''.
  end.
  else do:
    message " Запрашиваемые данные не были введены " view-as alert-box title " Нет данных! ".
    bell. undo, retry.
  end.
end.
else vs-info = kdaffil.info[1].

if vs-info <> '' and s-ourbank = kdlon.bank then do:
  run sel2 ("Выбор :", " 1. Просмотреть сохраненные данные | 2. Расчитать данные заново ", output v-sel).
  if v-sel = "2" then do:
     find current kdaffil exclusive-lock no-error.
     kdaffil.info[1] = ''. vs-info = ''.
     kdaffil.who = g-ofc.
     kdaffil.whn = g-today.
     find current kdaffil no-lock no-error.
  end.
  else if v-sel <> "1" then leave.
end.

if vs-info = '' and s-ourbank = kdlon.bank then do:
  display " Идет расчет доходности !"  with row 5 frame ww centered.

  dt_st = g-today - 360.
  repeat god = year(g-today) - 1 to year(g-today) by 1:   
  for each aaa where aaa.cif = s-kdcif no-lock.
    for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and  year(jl.jdt) = god no-lock. 
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
 
           temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1].
           
           /* 11/05/2004 madiar */
           
           if jl.jdt >= dt_st and jl.jdt <= g-today then do:
              create tempcom_jl.
              tempcom_jl.tjh = jl2.jh.
              tempcom_jl.tgl = jl2.gl.
              tempcom_jl.sumjl = tempcom_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1].
           end.
           
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
  
/*  for each lgr where lgr.led eq "DDA" or lgr.led eq "SAV" no-lock, each
      aaa of lgr where aaa.cif = s-kdcif and aaa.crc = 1 no-lock.
      for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and year(jdt) = year(g-today) and jl.dc = 'C' no-lock.
           find first jh  where  jh.jh = jl.jh and jh.ref begins 'RMZ' no-lock no-error.
           if avail jh then v-sumob = v-sumob + jl.cam .
      end.
  end. */
  
  for each tempcom_jl where tempcom_jl.sumjl > 0.
      accumulate tempcom_jl.sumjl (total).
  end.
  v-sumcom360 = accum total tempcom_jl.sumjl.
  
  v-sumob = 0.
  for each lon where lon.cif = s-kdcif no-lock:
    if lon.crc = 1 then v-sumob = v-sumob + lon.dam[1] - lon.cam[1].
    else do:
      find first crc where crc.crc = lon.crc no-lock no-error.
      v-sumob = v-sumob + (lon.dam[1] - lon.cam[1]) * crc.rate[1].
    end.
  end.
  
  if kdlon.crc = 1 then do:
    if kdlon.amount <> 0 then v-sumob = v-sumob + kdlon.amount.
    else v-sumob = v-sumob + kdlon.amountz.
  end.
  else do:
    if kdlon.amount <> 0 then do:
      find first crc where crc.crc = kdlon.crc no-lock no-error.
      v-sumob = v-sumob + kdlon.amount * crc.rate[1].
    end.
    else do:
      find first crc where crc.crc = kdlon.crcz no-lock no-error.
      v-sumob = v-sumob + kdlon.amountz * crc.rate[1].
    end.
  end.
  
  v-sumob = (v-sumcom360 / v-sumob) * 100.
  
  /* 11/05/2004 madiar - end*/

  vs-info = vs-info + string(year(g-today)) + ',' + string(v-sumob) + ','.

  pause 0 before-hide.                  
end.

find current kdaffil exclusive-lock no-error.
kdaffil.info[1] = vs-info.
find current kdaffil no-lock no-error.

date1 = entry(1,kdaffil.info[1]).
sum1 = deci(entry(2,kdaffil.info[1])). 
date2 = entry(3,kdaffil.info[1]).
sum2 = deci(entry(4,kdaffil.info[1])). 
date3 = entry(5,kdaffil.info[1]).
sum3 = deci(entry(6,kdaffil.info[1])). 
sum4 = (amountz * (sum3 + ratez) / 12 * srokz) / 1000.

message 'F1 - Перейти на след поле,  F4-Выход.'.
displ  date1 sum1 date2 sum2 sum3 sum4 kdaffil.info[2] kdaffil.who kdaffil.whn with frame kdaffil7.
if (s-ourbank = kdlon.bank) then do:
  find current kdaffil exclusive-lock no-error.
  update kdaffil.info[2] with frame kdaffil7.
  find current kdaffil no-lock no-error.
end.
else do:
  display kdaffil.info[2] with frame kdaffil7.
  pause.
end.


hide message.


            

