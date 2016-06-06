/* loanday.p
 * MODULE
        3-4-2-16-19
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21.06.2011 aigul
 * BASES
        BANK
 * CHANGES
*/

{global.i}

define input parameter v-lon as char no-undo.
define input parameter v-act_leave as logical no-undo. /* прекращать ли анализ просрочек при наличии непогашенного кредита */

define output parameter v-coun as integer no-undo init 0. /* количество просрочек */
define output parameter v-maxpr as integer no-undo init 0. /* дней максимальная просрочка */
def var v-res as integer no-undo init 0.
def var v-lnlast as integer no-undo init 0.
def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-bal as deci no-undo init 0.
def var v-bal7 as deci no-undo init 0.
def var p-coun as integer no-undo.
def var p-maxpr as integer no-undo.
def var p-lnlast as integer no-undo.
def var fdt as date no-undo.
def var dayc1 as integer no-undo.

p-coun = 0. p-maxpr = 0.

  find lon where lon.lon = v-lon no-lock no-error.
  if not avail lon then next.

  run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).
  if v-bal > 0 then do: /* есть непогашенный кредит */
    v-res = 2.
    if v-act_leave then leave.
  end.


  fdt = ?.
  for each lonres where lonres.lon = lon.lon no-lock use-index jdt:
      if lonres.lev <> 7 then next.
      if lonres.dc = 'd' then do:
        if v-bal7 = 0 and lonres.amt > 0 then do:
          p-coun = p-coun + 1.
          fdt = lonres.jdt.
        end.
        v-bal7 = v-bal7 + lonres.amt.
      end.
      else do:
        v-bal7 = v-bal7 - lonres.amt.
        if v-bal7 <= 0 then do:
          v-bal7 = 0.
          dayc1 = lonres.jdt - fdt.
          if p-maxpr < dayc1 then p-maxpr = dayc1.
        end.
      end.
  end. /* for each lonres */



if p-maxpr >= 15 then v-res = 3.
assign v-coun = p-coun v-maxpr = p-maxpr v-lnlast = p-lnlast.

