/* put-shis.p
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

/*-----------------------------------------------------------------------------
  #3.Labojums,lai neveido liekus ierakstus fail– lnshis
     2.izmai‡a - raksta arЁ procentu vёsturi
----------------------------------------------------------------------------*/
define input parameter fl as character.
define shared variable s-lon like lon.lon.
define shared variable g-today as date.
define temp-table calenda
       field    bija      as logical
       field    dt        as date
       field    amt       as decimal.
define variable i         as integer.
define variable j         as integer.
define variable m-dt      as date.
define variable laiks as integer.
laiks = time.

find lon where lon.lon = s-lon no-lock.
i = 0.
j = 0.
m-dt = date(1,1,1).
if fl = "lnsch"
then do:
     for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and
         lnsch.fpn = 0 and lnsch.f0 > - 1 no-lock:
         j = j + 1.
         create calenda.
         calenda.bija = no.
         calenda.dt = lnsch.stdat.
         calenda.amt = lnsch.stval.
     end.
end.
if fl = "lnsci"
then do:
     for each lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and
         lnsci.fpn = 0 and lnsci.f0 > - 1 no-lock:
         j = j + 1.
         create calenda.
         calenda.bija = no.
         calenda.dt = lnsci.idat.
         calenda.amt = lnsci.iv-sc.
     end.
end.
for each lnshis use-index lon where lnshis.lon = lon.lon and
    lnshis.file = fl no-lock by lnshis.fdt:
    if lnshis.fdt > m-dt
    then do:
         for each calenda:
             calenda.bija = no.
         end.
         m-dt = lnshis.fdt.
         i = 0.
    end.
    if lnshis.fdt = m-dt
    then do:
         find first calenda where not calenda.bija and
              calenda.dt = lnshis.dt and calenda.amt = lnshis.amt no-error.
         if not available calenda
         then next.
         calenda.bija = yes.
         i = i + 1.
    end.
end.
if j <> i
then do:
     for each lnshis use-index lon where lnshis.lon = lon.lon and
         lnshis.file = fl and lnshis.fdt = g-today:
         delete lnshis.
     end.
     /* if fl = "lnsci"
     then do:
          find loncon where loncon.lon = s-lon exclusive-lock.
          i = index(loncon.rez-char[6],"/" +
              string(g-today,"99/99/9999") + "&").
          if i = 0
          then loncon.rez-char[6] = loncon.rez-char[6] + "#" +
                      "/" + string(g-today,"99/99/9999") + "&".
     end. */
     for each calenda:
         create lnshis.
         lnshis.file = fl.
         lnshis.lon = lon.lon.
         lnshis.fdt = g-today.
         lnshis.dt = calenda.dt.
         lnshis.amt = calenda.amt.
         lnshis.whn = today.
         lnshis.who = userid("bank").
     end.
end.
