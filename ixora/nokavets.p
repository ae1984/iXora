/* nokavets.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define input        parameter p-lon like lon.lon.
define input        parameter p-dt  like lon.rdt.
define input        parameter p-rz  as integer.
define input-output parameter p-sm  like lon.opnamt.
define output       parameter p-dn  as integer.
define new shared temp-table calenda
                  field    dt    like lnshis.dt
                  field    amt   like lnshis.amt.
define variable sm1 as decimal.
define variable sm2 as decimal.
define variable m-dt  as date.

p-dn = 0.
find lon where lon.lon = p-lon no-lock.
if p-rz = 1
then do:
     p-sm = 0.
     run atl-dat(p-lon,p-dt,output sm1).
     if lon.gua = "LK"
     then do:
          find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock.
          sm1 = sm1 - lonhar.rez-dec[3] * lon.opnamt / 100.
     end.
end.
else if p-rz = 2
then sm1 = p-sm.
else return.
if sm1 > 0
then do:
     run get-shis("lnsch",p-lon,p-dt).
     sm2 = 0.
     p-sm = sm1.
     for each calenda by calenda.dt descending:
         if lon.gua = "OD"
         then sm2 = sm1.
         else sm2 = sm2 + calenda.amt.
         if calenda.dt > p-dt
         then p-sm = sm1 - sm2.
         if sm2 >= sm1
         then do:
              p-dn = p-dt - calenda.dt.
              leave.
         end.
     end.
     if p-sm <= 0 or p-dn <= 0
     then do:
          p-sm = 0.
          p-dn = 0.
     end.
end.
