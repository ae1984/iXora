/* cdaget.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Частичные изъятия сумм с депозитов
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        19.01.04 nataly была изменена сумма частичного изъятия (мин 5 %)
        15.03.04 nataly была добавлена обработка депозитов схемы 5
        19.03.04 nataly убрано условие intavail = 0
        01/04/04 nataly добавлена обработка част изъятий до и после 3-х мес
        21/04/04 kanat  по 5 схеме переделал изъятие.
        28/04/04 kanat  поменял формат для ввода суммы по изъятиям.
        20.05.2004 nadejda - в форму добавлен просмотр признака исключения по % ставке
                             добавлен параметр номера счета в вызов tdagetrate
        02.04.2010 id00004 сделал возможность изъятия не более 30% в соответствии с ТЗ-643
        29/12/2010 evseev - заремил v-paynow в форме, т.к. расчитывается неверно.
        10.01.2011 evseev - частичное изъятие "Недропользователь" 518,519,520
        25.01.2011 evseev - минимальный остаток для 518,519,520 = 0, а так же убран % изъятия
        13/02/2012 evseev - СЗ от 13/02/2012. Мин остаток для KZ81470162215A141115 = 30 000 000
        14/02/2012 evseev - СЗ от 13/02/2012.
        20/02/2012 evseev - СЗ от 13/02/2012.
        22/02/2012 evseev - СЗ от 13/02/2012. исправлена ошибка при отправлении письма
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        28.06.2013 evseev - tz-1909
*/


{mainhead.i}

def  new shared var s-jh like jh.jh.

def new shared var s-aaa like aaa.aaa.



def var vdel as char initial "^".
def var vparam as char.
def var vparam2 as char.
def var v-jh like jh.jh.
def var rcode as inte.
def var rdes as char.
def var restint as deci.
def var t-restint as deci.
def var vacr as deci.
define var s-amt1 like aal.amt.
define var s-amt2 like aal.amt.
define var s-amt3 like aal.amt.
def var v-templ as char.
def buffer b-crc for crc.
def var v-minus as decimal.
def var v-allsum as decimal.
def var t-iza as decimal decimals 2.    /* Сумма которую можно взять с взноса   */


def var vln as inte initial 7777777.
def var sum as decimal extent 5.
def var  v-rate as decimal.
def var  v-accr as decimal format 'zzz,zzz,zzz9.99'.

def var ja as log format "да/нет".
def var vou-count as int initial 1.
def var i as int.
def var v-sum as decimal format 'zzzzzzzzz9.99'.
def var v-sum1 as decimal format 'zzz,zzz,zzz9.99'.
def var v-sum2 as decimal format 'zzz,zzz,zzz9.99'.
def var v-count as integer.
def var d_sumfreez as decimal decimals 2.  /* Минимальный остаток на депозите   */


def var vrate as decimal.
def var v-prd as integer.
def var sum%% as decimal.
def var tot%% as decimal.
def var tot%%2 as decimal.
def var j as integer.
def var i2 as integer.
def var sum2 as decimal.
def var averrate as decimal.
def var dt1 as date.
def var dt2 as date.
def var v-usdrate as decimal.

def var d-rtocap as decimal.


def var v-tmppri like aaa.pri.
def var l-newlgr as logical init false.
def buffer buflgr FOR lgr.

def var i_dayost  as integer.
def var i_month   as integer.
def var v_sumfaad as decimal.

def var v_sumfirst as decimal.

def var d_sumost  as decimal.
def var v-aadrate as decimal.
def var v-aadpri  as decimal.
def var d_%store  as decimal.
def var d_%2level as decimal.
def var d_rate    as decimal.
def var i_day as integer.
def var d_ost    as decimal.



    Function GetHoldAmount returns decimal (input v-aaa as char).
        find aas where aas.aaa = v-aaa and aas.ln = 7777777 no-lock no-error.
        if available aas then return aas.chkamt.
        else return 0.0.
    End Function.



find last crc where crc.crc = 2 no-lock no-error.
if avail crc then
  v-usdrate = crc.rate[1].

{tdainfo.f}

on help of vaaa in frame tda0 do:
   run tdaaaa-help.
end.

upper:
repeat on error undo, return:

/*message "F2 - список счетов, F4 - выход".*/
message  "F4 - выход".


view frame tda0.
view frame tda1.
view frame tda2.

/*update vaaa with frame tda0.*/

update vaaa with frame tda0.

find aaa where aaa.aaa = vaaa exclusive-lock no-error.
if not available aaa then do:
   message "Счет " vaaa " не существует" view-as alert-box title "".
   pause.
   next upper.
end.
find lgr where lgr.lgr = aaa.lgr no-lock no-error.

if lgr.led <> "CDA" then do:
   message "Счет не является депозитом юридических лиц." view-as alert-box title "".
   pause.
   next upper.
end.

if lookup(lgr.lgr,"484,485,486,487,488,489,518,519,520,B09,B10,B11,B15,B16,B17,B18,B19,B20,151,152,153,154,171,172,157,158,176,177,173,175,174") = 0 then do:
   if aaa.aaa <> 'KZ81470162215A141115' then do:
       message "По данному депозиту изъятия запрещены." view-as alert-box title "".
       pause.
       next upper.
   end.
end.


if aaa.sta = "C" or aaa.sta = "E" then do:
   message "Закрытый счет" view-as alert-box title "".
   pause.
   next upper.
end.


find lgr where aaa.lgr = lgr.lgr no-lock no-error.
find cif where cif.cif = aaa.cif no-lock no-error.
find crc where crc.crc = aaa.crc no-lock no-error.



  sum[1] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.05,0).
  sum[2] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.1,0).
  sum[3] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.2,0).
  sum[4] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.3,0).
  sum[5] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.4,0).




hotkeys:
repeat:
run ShowInfo.
message "P-частичное изъятие, T-история проводок, H-история изменения % ставки, I-таблица % ставок, F4-выход".
   readkey.
   if keyfunction(lastkey) = 'T' then do:
      if available aaa then run tdajlhist(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'H' then do:
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.
      if available aaa and (lgr.feensf <> 3 and lgr.feensf <> 4 ) then run tdaaabhist(aaa.aaa).
      if available aaa and (lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 1 or lgr.feensf = 2) then run histrez(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'I' then do:
      if available aaa then run tdainthist(aaa.pri).
      readkey pause 0.
   end.


   else

   if keyfunction(lastkey) = "P" then do : /* депозитные счета НАКОПИТЕЛЬНЫЙ */
      if aaa.opnamt = 0 then do:
         message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip " дата открытия не совпадает с взносом основной суммы или " skip " сделана неверная операция " skip " ПРОВЕРЬТЕ КОРРЕКТНОСТЬ СУММ И ВЫПОЛНИТЕ НАЧИСЛЕНИЕ % " view-as alert-box question buttons ok title "".
         return.
      end.
      if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") > 0 then do:
            message "Частичные изъятия не предусмотрены!" view-as alert-box question buttons ok title "".
            return.
      end.

      if lookup(lgr.lgr,"518,519,520") = 0 then do:
         if aaa.crc = 1  then d_sumfreez = 150000.
         if aaa.crc <> 1 then d_sumfreez = 1000.
      end.
      else do:
         if aaa.crc = 1  then d_sumfreez = 0.
         if aaa.crc <> 1 then d_sumfreez = 0.
      end.

      v-sum = 0.
      update v-sum format 'z,zzz,zzz,zz9.99-' label 'Введите сумму частичного изъятия' with row 8 centered  side-label frame opt.
      run savelog('cdaget','243. ' + aaa.aaa + " " + lgr.lgr).
      if lookup(lgr.lgr,"B09,B10,B11") > 0 then do:
         d_sumfreez = lgr.tlimit[1].
         find first jl where jl.acc = aaa.aaa and jl.cam > 0 no-lock no-error.
         if not avail jl then do:
            message "Не найдена первая проводка!" view-as alert-box question buttons ok title "".
            run savelog('cdaget','249. ' + aaa.aaa + " " + lgr.lgr).
            return.
         end.
         run savelog('cdaget','253. ' + aaa.aaa + " " + lgr.lgr + " " + string(d_sumfreez) + " " + string(jl.cam * 30 / 100) + " " + string(GetHoldAmount(aaa.aaa)) + " " + string(v-sum)).
         if (jl.cam * 30 / 100) > (GetHoldAmount(aaa.aaa) - v-sum ) then do:
               message "Остаток на сбер.счете менее 30% от первоначального взноса!" view-as alert-box question buttons ok title "".
               return.
         end.
      end.


      if  aaa.aaa = 'KZ81470162215A141115' then d_sumfreez = 30000000.
      if d_sumfreez > ((GetHoldAmount(aaa.aaa)) - v-sum ) then do:
         if aaa.aaa <> 'KZ81470162215A141115' then
            message "Минимально допустимый остаток " trim(string(d_sumfreez,'z,zzz,zzz,zz9.99-')) skip
                 "----------------------------------------" skip
                 "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ" trim(string((GetHoldAmount(aaa.aaa)) - d_sumfreez, 'z,zzz,zzz,zz9.99-')) view-as alert-box.
         else
            message "Минимально допустимый остаток " trim(string(d_sumfreez,'z,zzz,zzz,zz9.99-')) skip
                 "----------------------------------------" skip
                 "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ " trim(string((GetHoldAmount(aaa.aaa)) - d_sumfreez, 'z,zzz,zzz,zz9.99-')) skip
                 " иначе договор считается расторгнутым!" view-as alert-box.

         if aaa.aaa <> 'KZ81470162215A141115' then next hotkeys.
      end.
      if lookup(lgr.lgr,"518,519,520,B09,B10,B11") = 0 and aaa.aaa <> 'KZ81470162215A141115' then do:
          d_ost = 0.
          for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
              d_ost = d_ost + aad.sumg.
          end.
          d_ost = d_ost + aaa.opnamt.

          if aaa.regdt < 04.01.2010 then do: /*Согласно ТЗ-643 необходимо внести изменения в расчет изъятий с 01.04.2010*/
                find last jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and jl.jdt = g-today  no-lock no-error.
                if avail jl then do:
                   message "Разрешено только одно частичное изъятие не более 50% от остатка за день! "  view-as alert-box.
                   next hotkeys.
                end.

                if v-sum > (d_ost / 2 ) then do:
                   message "Разрешено только одно частичное изъятие не более 50% от остатка за день "  view-as alert-box.
                   next hotkeys.
                end.
          end.

          if aaa.regdt >= 04.01.2010 then do:
             find first jl where jl.acc = aaa.aaa and jl.lev = 1  and jl.dc = "C" no-lock use-index acc .
             v_sumfirst = jl.cam. /*Сумма первоначального вклада*/


            find last jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and month(jl.jdt) = month(g-today)  no-lock use-index acc no-error.
            if avail jl then do:
               message "Разрешено только одно изъятие в месяц. Последнее было "  jl.jdt view-as alert-box.
               next hotkeys.
            end.
            else do:
               if v-sum > v_sumfirst * 30 / 100 then do:
                  message "Разрешено изъятие не более 30% от первоначальной суммы" view-as alert-box.
                  next hotkeys.
               end.
            end.
          end.
      end.

      message "ЧАСТИЧНОЕ ИЗЪЯТИЕ!" skip "ПОДТВЕРДИТЕ ЧАСТИЧНОЕ ИЗЪЯТИЕ." view-as alert-box question buttons yes-no title "" update v-ans as logical.
      if not v-ans then  return.

      for each aas where aas.aaa eq aaa.aaa and aas.ln <> 7777777  no-lock:
          find sic of aas.
          display aas.sic sic.des label "НАИМЕНОВАНИЕ" FORMAT "X(20)"  aas.regdt LABEL "ДАТ.РЕГ." format "99/99/9999" aas.chkamt LABEL "СУММА" aas.payee format "x(20)"  with row 9  9 down  overlay  top-only centered title " СПЕЦИАЛЬНОЕ СОСТОЯНИЕ СЧЕТА (" + string(aas.aaa) + ")" frame aas.
      end.
      hide frame aas.



      d_sumost = v-sum.
      /* v-allsum = 0.
      for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
          v-allsum = v-allsum + aad.sumg.
      end.
      v-allsum = v-allsum + aaa.opnamt.*/

      for each aad where aad.aaa = aaa.aaa and aad.who <> 'bankadm' exclusive-lock break by aad.regdt desc.
          t-iza = 0.
          if d_sumost > 0 and aad.sumg > 0 then do: /* если есть деньги*/
             t-iza = min(aad.sumg, d_sumost).      /* сумма изъятия */
             d_sumost = d_sumost - t-iza.          /* сумма остатка */
             run savelog('cdaget','337. ' + aaa.aaa + " " + string(t-iza)).
             aad.sumg = aad.sumg - t-iza.
             aad.dam = aad.dam + t-iza.
           end.
      end.
      run savelog('cdaget','342. ' + aaa.aaa + " " + string(d_sumost)).
      if d_sumost > 0 then do:
         run savelog('cdaget','344. ' + aaa.aaa + " " + string(aaa.opnamt)).
         aaa.opnamt = aaa.opnamt - d_sumost.
         run savelog('cdaget','346. ' + aaa.aaa + " " + string(aaa.opnamt)).
      end.

      run savelog('cdaget','347. ' + aaa.aaa + " " + string(v-sum)).
      run tdaremhold(aaa.aaa, v-sum).
      run savelog('cdaget','349. ' + aaa.aaa + " " + string(v-sum)).

      if  aaa.aaa = 'KZ81470162215A141115' then do:
          if d_sumfreez > ((aaa.cr[1] - aaa.dr[1]) - v-sum ) then do:
             run tdaremholda(aaa.aaa).
             message "Договор расторгнут! " view-as alert-box.
          end.
      end.
      message "Произведена разблокировка суммы для частичного изъятия!".
      pause.
      if  aaa.aaa = 'KZ81470162215A141115' then do:
          for each ofc where ofc.exp[1] matches "*P00032*" or ofc.exp[1] matches "*P00121*" or ofc.exp[1] matches "*P00136*" or ofc.exp[1] matches "*P00046*" or ofc.exp[1] matches "*P00033*" no-lock:
             run mail(ofc.ofc + "@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Частичное изъятие KZ81470162215A141115", "Необходим перерасчет 2ого уровня счета KZ81470162215A141115", "0", "", "").
          end.
      end.

   end.

   else if keyfunction(lastkey) = 'end-error' then do:
      leave hotkeys. return.
   end.




end.

end.

return.

Procedure ShowInfo.

if aaa.cr[1] > 0 then vopnamt = aaa.opnamt.
else vopnamt = 0.
find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
if available aas then currentbase = aas.chkamt.
else currentbase = 0.
capitalized = aaa.stmgbal.
adddepos = currentbase - vopnamt - capitalized.
if adddepos < 0 then adddepos = 0.
/*
if lgr.feensf <> 3 and lgr.feensf <> 5 and lgr.feensf <> 7 then do:
 intavail = aaa.cr[1] - aaa.dr[1] - currentbase.
 intpaid = aaa.dr[2] - intavail - capitalized.
end.
else*/ do: /* для депозитов типа резервный */
 intavail = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
 intpaid = aaa.dr[1] .
end.
/*---------nataly------------*/
/*if intavail < 0 then intavail = 0.
if intpaid < 0 then intpaid = 0.*/
/*---------nataly------------*/

vterm = aaa.expdt - g-today /*+ 1*/.
/*if vterm < 0 then vterm = 0.*/
vday  = aaa.expdt - aaa.regdt.
if g-today < aaa.expdt /*+ 1*/ then
v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2] - aaa.accrued.
else
v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].

if aaa.payfre = 1 then v-excl = "!".
/*
if aaa.sta = "M" then do:
   find sysc where sysc = "bsrate" no-lock no-error.
   if available sysc then intrat = sysc.deval.
   else intrat = 0.
   intrat = aaa.rate.
end.
else run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, currentbase, output intrat).
*/
   intrat = aaa.rate.

if g-today < aaa.expdt /*+ 1*/ then do:
   v-pay = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].

   if lgr.intcal <> "S" and lgr.intcal <> "N" then
do:


   v-pay = v-pay + aaa.m10 + (aaa.expdt - g-today /*+ 1*/) * currentbase * intrat / aaa.base / 100.

end.
   else if lgr.intcal = "S" and aaa.lstmdt = g-today and aaa.cr[2] = 0 then
   v-pay = v-pay + (aaa.expdt - aaa.lstmdt /*+ 1*/) * currentbase * intrat / aaa.base / 100.

end.
else
   v-pay = v-paynow.


display aaa.cif cif.name crc.code aaa.sta aaa.pri lgr.lgr lgr.des aaa.lstmdt aaa.expdt
        /*aaa.cla*/ vday vterm /*v-paynow*/ v-pay with frame tda0.
display vopnamt adddepos capitalized currentbase with frame tda1.
display intrat v-excl aaa.accrued intpaid intavail with frame tda2.

End Procedure.

