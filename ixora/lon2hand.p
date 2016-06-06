/* lon2hand.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/* KOVAL Реально выданная сумма кредита */

def input  parameter s-lon like lon.lon.
def output parameter ss like lon.dam[1].

for each lonres no-lock where lonres.lon = s-lon and lonres.lev eq 1 and
         trx ne 'lon0023' and  trx ne 'lon0024':
   if lonres.dc = "D" then ss = ss + lonres.amt.
end.
