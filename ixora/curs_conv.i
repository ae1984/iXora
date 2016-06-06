/* curs_conv.i
 * MODULE
        Прагма
 * DESCRIPTION
        Для конвертации с любой валюты на USD
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
        01/07/2005 saltanat 
 * CHANGES
*/

function konv2usd returns decimal (p-sum as decimal, p-crc as integer, p-date as date).
  def var vp-sum as decimal.
  def var v-kurs as decimal init 0.
  def var v-curssusd as deci.

  find last crchis where crchis.crc = 2 and crchis.rdt <= p-date no-lock no-error.
  v-curssusd = crchis.rate[1].

  if p-crc = 2 then vp-sum = p-sum.
  else do:
    find last crchis where crchis.crc = p-crc and crchis.rdt <= p-date no-lock no-error. 
    if avail crchis and crchis.rate[1] <> 0 then do:
      v-kurs = crchis.rate[1].
    end.
    else do:
      find last crchis where crchis.crc = p-crc and crchis.rdt <= p-date and crchis.rate[1] <> 0 no-lock no-error. 
      if avail crchis then v-kurs = crchis.rate[1].
      else v-kurs = 1.
    end.

    vp-sum = (p-sum * v-kurs) / v-curssusd.
  end.
  
  return vp-sum.
  
end function.

function avail_bal returns decimal(p-aaa as char).
def var vbal     as deci.
def var vavl     as deci.
def var vhbal    as deci.
def var vfbal    as deci.
def var vcrline  as deci.
def var vcrlused as deci.
def var vooo     as char.
	
	run aaa-bal777(p-aaa, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
	return vavl.
	
end function.