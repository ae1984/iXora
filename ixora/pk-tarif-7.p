/* pk-tarif-7.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Расчет комиссии для Быстрых денег
        копия "Быстрых кредитов"
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        marinav
 * CHANGES
        25/07/2011 madiyar - рефинансирование, комиссия = 0
*/


{global.i}
{pk.i}
{pk-sysc.i}

def input parameter p-type as integer.
def input parameter p-sum as decimal.
def output parameter p-sumres as decimal.

define var v-tarfnd as char.
def var v-proc as decimal init 0.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message " Не найдена анкета " + string(s-pkankln) view-as alert-box buttons ok.
  return.
end.

p-sumres = 0.

if p-sum = 0 then return.

/*
find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
if avail pksysc then v-tarfnd = string(pksysc.inval) + trim (pksysc.chval).

if pkanketa.id_org = "kazpost" then v-proc = get-pksysc-dec("kpcomb").
else
if v-tarfnd <> "" then do:
  find first tarifex2 where tarifex2.aaa = pkanketa.aaa
                          and tarifex2.cif = pkanketa.cif
                          and tarifex2.str5 = v-tarfnd
                          and tarifex2.stat = 'r' no-lock no-error.
  if avail tarifex2 then  v-proc = tarifex2.proc.
  else do:
  find first tarifex where tarifex.str5 = v-tarfnd and tarifex.cif = pkanketa.cif
                       and tarifex.stat = 'r' no-lock no-error.
  if avail tarifex then v-proc = tarifex.proc.
  else do:
    find first tarif2 where tarif2.str5 = v-tarfnd and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then v-proc = tarif2.proc.
  end.
  end.
end.

if p-type = 0 then p-sumres = round(p-sum * v-proc / (100 - v-proc),2). -- комиссия --
else p-sumres = round(p-sum - p-sum * v-proc / 100,2). -- сумма, не комиссия! --
*/

if p-type = 0 then p-sumres = 0. /* комиссия */
else p-sumres = p-sum. /* сумма, не комиссия! */
