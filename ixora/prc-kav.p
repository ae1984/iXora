/* prc-kav.p
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

define input parameter p-lon like lon.lon.
define input parameter p-dt as date.
define output parameter p-sm as decimal.
define output parameter p-dn as integer.
define variable sm1 as decimal.
define variable sm2 as decimal.
define variable v-dt0 as date.
define variable v-dt1 as date.
define variable v-dt2 as date.

define new shared temp-table  calenda
              field     dt  like lnshis.fdt
              field     amt like lnshis.amt.

p-sm = 0.
p-dn = 0.
run get-shis("lnsci",p-lon,p-dt).
v-dt1 = date(1,1,1).
for each calenda where calenda.dt < p-dt by calenda.dt:
    if calenda.dt > v-dt1
    then v-dt1 = calenda.dt.
end.
find first calenda where calenda.dt >= p-dt no-error.
if not available calenda
then v-dt1 = p-dt.
if v-dt1 > date(1,1,1)
then do:
     run prc-last(p-lon,v-dt1 + 1,output sm1,output sm2,output v-dt2).
     if sm1 > sm2
     then do:
          v-dt0 = date(1,1,2999).
          for each calenda where calenda.dt > v-dt2 and calenda.dt < p-dt
              by calenda.dt:
              if calenda.dt < v-dt0 
              then v-dt0 = calenda.dt.
          end.
          if v-dt0 < date(1,1,2999)
          then do:
               p-sm = sm1 - sm2.
               p-dn = p-dt - v-dt0.
          end.
     end.
end.
