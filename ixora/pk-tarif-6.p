/* pk-tarif-6.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Расчет комиссии для Быстрых денег (s-credtype = "6")
        копия "Быстрых кредитов"
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-13-2
 * AUTHOR
        03.07.2003 marinav
 * CHANGES
        24.12.2003 nadejda  - дополнительная комиссия "Фонд покрытия кредитного риска" (ТЗ 618)
        15.01.2004 nadejda  - обработка исключений по тарифам при поиске суммы комиссии
        18.01.2004 nadejda  - добавлен параметр p-type, добавлен расчет комиссии по сумме кредита
        08.12.2004 saltanat - берутся тарифы со статусом "r" - рабочий.
        13/05/2005 madiar   - упрощение комиссий - одна комиссия (5%), само значение прописано в тарификаторе 913 "Фонд страхования кредитных рисков"
        05.07.2005 saltanat - Выборка льгот по счетам.
        19/10/2005 madiar   - новая программа в филиалах - упрощение комиссий, одна комиссия (5%), само значение прописано в тарификаторе 913 "Фонд страхования кредитных рисков"
        28/02/2006 madiar   - по казпочтовым анкетам ставка по комиссии - из pk-sysc
        02/03/2006 madiar   - убрал отладочное сообщение
        19.09.2008 galina - проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. проставляем комиссию за выдачу кредита из справочника
        02.06.2009 galina - по рефининсированию не подтягиваем спец.условия
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

--02.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. проставляем комиссию за выдачу кредита из справочника--
 find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
 if not avail pkanketh or pkanketh.rescha[1] = '' or pkanketh.resdec[1] = 0 then do:

    find last lnpriv where lnpriv.credtype = s-credtype and lnpriv.bank = s-ourbank and (g-today >= lnpriv.dtb and lnpriv.dte > g-today) and lnpriv.rnn = trim(pkanketa.jobrnn) no-lock no-error.
    if avail lnpriv then do:
      v-proc = lnpriv.compay.
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "dogorg" exclusive-lock no-error.
      if not avail pkanketh then do:
        create pkanketh.
        assign pkanketh.bank = s-ourbank
               pkanketh.credtype = s-credtype
               pkanketh.ln = s-pkankln
               pkanketh.kritcod = "dogorg".
       end.
       if num-entries(pkanketh.value1) < 2 then do:
          if pkanketh.value1 <> "" then pkanketh.value1 = pkanketh.value1 + ",".
          pkanketh.value1 = pkanketh.value1 + "2".
          find current pkanketh no-lock.
       end.
    end.
 end.

if p-type = 0 then p-sumres = round(p-sum * v-proc / (100 - v-proc),2). -- комиссия --
else p-sumres = round(p-sum - p-sum * v-proc / 100,2). -- сумма, не комиссия! --

*/

if p-type = 0 then p-sumres = 0. /* комиссия */
else p-sumres = p-sum. /* сумма, не комиссия! */


