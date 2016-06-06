/* get-shis.p
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

/*------------------------------------------------------------------------------
  #3.Labojums,lai nelasa liekus ierakstus no faila
     2.izmai‡a - lasa arЁ procentu vёsturi
------------------------------------------------------------------------------*/
define input  parameter fl as character.
define input parameter  p-lon like lon.lon.
define input  parameter p-dt as date.
define shared temp-table  calenda
              field     dt  like lnshis.fdt
              field     amt like lnshis.amt.
define variable m-dt    as date.
define variable laiks as integer.

for each calenda:
    delete calenda.
end.
m-dt = ?.

for each lnshis use-index lon where lnshis.lon = p-lon and
    lnshis.file = fl no-lock
    by lnshis.fdt by lnshis.dt:
    if m-dt eq ? or (lnshis.fdt gt m-dt  and lnshis.fdt le p-dt)
    then m-dt = lnshis.fdt.
end.
if m-dt = ?
then do:
     if fl = "lnsch"
     then do:
          for each lnsch where lnsch.lnn = p-lon and lnsch.flp = 0 and
              lnsch.fpn = 0 and lnsch.f0 > - 1 no-lock by lnsch.stdat:
              create calenda.
              calenda.dt = lnsch.stdat.
              calenda.amt = lnsch.stval.
          end.
     end.
     else if fl = "lnsci"
     then do:
          for each lnsci where lnsci.lni = p-lon and lnsci.flp = 0 and
              lnsci.fpn = 0 and lnsci.f0 > - 1 no-lock by lnsci.idat:
              create calenda.
              calenda.dt = lnsci.idat.
              calenda.amt = lnsci.iv-sc.
              m-dt = calenda.dt.
          end.
     end.
end.
else 
for each lnshis use-index lon where lnshis.lon = p-lon and
    lnshis.fdt eq m-dt and lnshis.file = fl no-lock
    by lnshis.fdt by lnshis.dt:
    create calenda.
    calenda.dt = lnshis.dt.
    calenda.amt = lnshis.amt.
end.

