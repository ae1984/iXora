/* kdklass.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Классификация кредита на момент выдачи - функции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 Класифик
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
        17/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных.
        25/08/2004 madiar - функции в зависимости от значения 2го вх. пар-ра меняют оценки кд-менеджера или риск-менеджера
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}

function defdata returns char (p-spr as char, p-value as char).
  def var vp-param as char.
  if p-spr = "" then vp-param = trim(p-value).
  else do:
    find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
    if avail bookcod then vp-param = trim(bookcod.name).
  end.
  return vp-param.
end.

function defdata1 returns decimal (p-spr as char, p-value as char).
  def var vp-rat as deci.
  if p-spr = "" then vp-rat = 0.
  else do:
    find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
    if avail bookcod then vp-rat = deci(trim(bookcod.info[1])).
  end.
  return vp-rat.
end.

procedure prat.
   def input parameter v-cod as char.
   def input parameter v-sec as char.
   def var v-param as char.
   def var v-rat as decimal.
   
   find first kdlonkl where  kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon 
                             and kdlonkl.kod = v-cod no-lock no-error.
   find first kdklass where kdklass.kod = kdlonkl.kod no-lock no-error.
   if v-sec = 'kd-mngr' then do:
     v-param = defdata (kdklass.sprav, kdlonkl.val1).
     v-rat = defdata1 (kdklass.sprav, kdlonkl.val1).
  
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.valdesc = v-param.
     kdlonkl.rating = v-rat.
     find current kdlonkl no-lock no-error.
   end.
   if v-sec = 'risk-mngr' then do:
     v-param = defdata (kdklas.sprav, kdlonkl.info[1]).
     v-rat = defdata1 (kdklas.sprav, kdlonkl.info[1]).
  
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.info[2] = v-param.
     kdlonkl.info[3] = string(v-rat).
     find current kdlonkl no-lock no-error.
   end.
end.

procedure plong.
   def input parameter v-cod as char.
   def input parameter v-sec as char.
   def var v-param as char.
   def var v-rat as decimal.

   find first kdlonkl where  kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon  
                             and kdlonkl.kod = v-cod no-lock no-error.
   find first kdklas where kdklas.kod = kdlonkl.kod no-lock no-error.
          
   find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
      if avail bookcod then assign v-param = bookcod.name 
                                   v-rat = deci(trim(bookcod.info[1])). 

   if v-sec = 'kd-mngr' then do:
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.valdesc = v-param.
     kdlonkl.rating = deci(kdlonkl.val1) * v-rat.
     find current kdlonkl no-lock no-error.
   end.
   if v-sec = 'risk-mngr' then do:
     find current kdlonkl exclusive-lock no-error.
     kdlonkl.info[2] = v-param.
     kdlonkl.info[3] = string(deci(kdlonkl.val1) * v-rat).
     find current kdlonkl no-lock no-error.
   end.
end.
