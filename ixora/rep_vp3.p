/* rep_vp3.p
 * MODULE
        отчет
 * DESCRIPTION
        сбор данных по провизии для отчета по валют позиции
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
 * BASES
        BANK COMM TXB
 * AUTHOR

 * CHANGES
            03/05/2012 Luiza
            04/05/2012 Luiza - уменьшила формат вывода сообщения
*/

def shared var fdt as date.
def shared var g-ofc as char.
def shared var g-today as date.
def shared var d-rates as deci no-undo extent 20.
def shared var c-rates as deci no-undo extent 20.
def var prov_od as deci no-undo.
def var prov_prc as deci no-undo.
def var prov_pen as deci no-undo.
def var prov_afn as deci no-undo.

def var lst_grp as char no-undo init ''.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-grp as integer no-undo.


for each txb.longrp no-lock:
  if lst_grp <> '' then lst_grp = lst_grp + ','.
  lst_grp = lst_grp + string(txb.longrp.longrp).
end.

define shared temp-table wrkk no-undo
    field fil as char
    field crc as int
    field od as decim
    field pr as decim
    field pen as decim
    field afn as decim
    field rate as decim
    field pr1 as decim
    index ind is primary  crc.


find first txb.cmp no-lock no-error.
if available txb.cmp then displ ("Идет расчет по провизии " + txb.cmp.name) format "x(70)".
pause 0.
def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).


do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"6",no,txb.lon.crc,output prov_od).
        prov_od = - prov_od /* * d-rates[txb.lon.crc] */.
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"36",no,txb.lon.crc,output prov_prc).
        prov_prc = - prov_prc /* * d-rates[txb.lon.crc] */.
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"37",no,1,output prov_pen).
        prov_pen =  - prov_pen.
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"41",no,txb.lon.crc,output prov_afn).
        prov_afn =  - prov_afn /* * d-rates[txb.lon.crc] */.
        if txb.lon.crc = 2 then do:
            find first wrkk no-error.
            if not available wrkk then do:
                create wrkk.
                wrkk.rate = d-rates[txb.lon.crc].
                wrkk.crc = txb.lon.crc.
            end.
            /*wrkk.fil = txb.cmp.name.*/

            wrkk.afn = wrkk.afn + prov_afn.
            wrkk.od = wrkk.od + prov_od.
            wrkk.pr = wrkk.pr + prov_prc.
            wrkk.pen = wrkk.pen + prov_pen.
        end.
    end. /* for each txb.lon */

end. /* do i = 1 to */

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"6",yes,txb.lon.crc,output prov_od).
        prov_od = - prov_od /* * d-rates[txb.lon.crc] */.
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"36",yes,txb.lon.crc,output prov_prc).
        prov_prc = - prov_prc /* * d-rates[txb.lon.crc] */.
        /*run lonbalcrc_txb('lon',txb.lon.lon,fdt,"37",yes,1,output prov_pen).
        prov_pen =  - prov_pen.*/
        run lonbalcrc_txb('lon',txb.lon.lon,fdt,"41",yes,txb.lon.crc,output prov_afn).
        prov_afn =  - prov_afn /* * d-rates[txb.lon.crc] */.
        if txb.lon.crc = 2 then do:
            find first wrkk no-error.
            wrkk.pr1 = wrkk.pr1 + (prov_od + prov_prc - prov_afn).
        end.
    end. /* for each txb.lon */

end. /* do i = 1 to */
