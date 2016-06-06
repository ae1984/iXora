/* pkdiscount.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Процедура для определения, подходит ли клиент для скидки
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
        19/08/2005 madiyar
 * BASES
        bank, comm
 * CHANGES
        03/05/2006 madiyar - третий входной параметр v-act_leave
        06/05/2006 madiyar - убрал {pk.i} - оттуда почти ничего не нужно
        23/02/2007 madiyar - берем анкеты всех видов
*/

{global.i}

define input parameter v-rnn as char no-undo. /* РНН */
define input parameter v-ln_skip as integer no-undo. /* номер анкеты, которую не анализируем */
define input parameter v-act_leave as logical no-undo. /* прекращать ли анализ просрочек при наличии непогашенного кредита */

define output parameter v-res as integer no-undo init 0. /* статус */
define output parameter v-coun as integer no-undo init 0. /* количество просрочек */
define output parameter v-maxpr as integer no-undo init 0. /* дней максимальная просрочка */
define output parameter v-lnlast as integer no-undo init 0. /* номер последней анкеты */

/*
v-res:
0 - не повторный кредит
1 - повторный кредит
2 - есть непогашенный кредит
3 - есть по крайней мере 1 просрочка больше 15 дней
*/

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

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.rnn = v-rnn no-lock:
  if pkanketa.ln = v-ln_skip then next.
  if trim(pkanketa.lon) = '' then next.
  find lon where lon.lon = pkanketa.lon no-lock no-error.
  if not avail lon then next.
  
  v-res = 1.
  
  run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).
  if v-bal > 0 then do: /* есть непогашенный кредит */
    v-res = 2.
    if v-act_leave then leave.
  end.
  
  if p-lnlast < pkanketa.ln then p-lnlast = pkanketa.ln.
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
  
end. /* for each pkanketa */

if p-maxpr >= 15 then v-res = 3.
assign v-coun = p-coun v-maxpr = p-maxpr v-lnlast = p-lnlast.

