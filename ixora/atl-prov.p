/* atl-prov.p
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

/*------------------------------------------------------------------------------
  #3.Programma aprё±ina bilancё ieskaitЁto aprё±in–to un uzkr–to procentu
     summas uzdotajam kredЁtam uz uzdot– mёneЅa s–kumu
     1.izmai‡a - programmas korekcija, ‡emot vёr– gada p–reju
  #4.Parametri p-lon - kredЁta kods
               p-dt  - datums,uz kuru grib summas.Datums var b­t arЁ atЅ±irЁgs
                       no 1,programma izmanto tikai mёnesi un gadu
  #5.Parametri p-apr - aprё±in–t– summa
               p-uzk - uzkr–t– summa
------------------------------------------------------------------------------*/
{global.i}
define input  parameter p-lon   like lon.lon.
define input  parameter p-dt    as date.
define output parameter p-prov   as decimal.
def temp-table wt
    field crc like crc.crc
    field amt as  dec
    index wt is unique crc.

p-prov = 0.
find lon where lon.lon eq p-lon no-lock no-error.

if not available lon then  return.
for each trxbal where trxbal.sub eq "lon" and trxbal.acc eq lon.lon
no-lock :
    if trxbal.dam ne trxbal.cam then do:
        if trxbal.lev eq 3 or trxbal.lev eq 6 then do:
            find wt where wt.crc eq trxbal.crc no-error.
            if not available wt then do :
                create wt.
                wt.crc = trxbal.crc.
            end.    
            wt.amt = wt.amt - trxbal.dam + trxbal.cam.
        end.
    end.    
end.

for each lonres use-index lon where lonres.lon eq p-lon no-lock:
    if lonres.whn gt p-dt then do:
        if lonres.lev eq 3 or lonres.lev eq 6 
        then do:
            find wt where wt.crc eq lonres.crc no-error.
            if not available wt then do :
                create wt.
                wt.crc = lonres.crc.
            end.    
            if lonres.dc = "D"
            then wt.amt = wt.amt + lonres.amt.
            else wt.amt = wt.amt - lonres.amt.
        end.
    end.
end.

for each wt :
    if wt.amt ne 0 then do:
        find last crchis where crchis.crc eq wt.crc and crchis.rdt le p-dt
        no-lock no-error.
        if available crchis then 
        p-prov = p-prov + wt.amt * crchis.rate[1] / crchis.rate[9].
    end.
end.
        
