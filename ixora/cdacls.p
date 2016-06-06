/* cdacls.p
 * MODULE
        Депозиты юридических лиц.
 * DESCRIPTION
        Просмотр начисленных %% по депозиту, закрытие депозита
 * RUN
        Основное меню
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-1-11
 * AUTHOR
        12/14/2005 dpuchkov
 * BASES
        BANK COMM
 * CHANGES
        29/12/2010 evseev - заремил v-paynow в форме, т.к. расчитывается неверно.
        14/01/2010 evseev - добавление депозит недропользователь 518,519,520
        22/02/2011 evseev - удержание налога 15% с выплаты процентов нерезидентам
        28/06/2011 evseev - при досрочном закрытии 478-483 % не выплачивать. ТЗ-1070
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        28.11.2012 evseev - ТЗ-1374
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        05.07.2013 evseev - tz-1856
        28/10/2013 Luiza  - ТЗ 1932 изменила параметры шаблона cda0003 и uni0048
*/



{mainhead.i}
{convgl.i "bank"}
{dclstda.i}

def  new shared var s-jh like jh.jh.


def var v-ans as logi.
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
define var s-amt22 like aal.amt.

define var d_tssum_nalog as decimal.

define var s-amt3 like aal.amt init 0.
def var v-templ as char.
def buffer b-crc for crc.
def var v-minus as decimal.
def var i_month   as integer.
def var i_day as integer.
def var d_%store  as decimal.
def var v-aadrate as decimal.
def var v-aadpri  as decimal.
def var d_rate    as decimal.
def var d_store1  as decimal.
def var d_sm1 as decimal.
def var d_sm2% as decimal.
def var d-rtocap as decimal.
def var d-brate   as decimal decimals 2.
def var d_1%    as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def var d_2%    as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */
def var d_3%    as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def buffer b-bufaaa for aaa.
def var d_daycount as integer.
def var d_trdaydate as date                no-undo.
def var v-sum as decimal.
def var v-allsum as decimal.
def var i-mon as integer.


def var ja as log format "да/нет".
def var vou-count as int initial 1.
def var i as int.

def var i_kvoday as integer init 0.
def var dta1 as date.
def var d_tssum as decimal.
def var d_tsprs as decimal.
 def var ss as decimal.
 def var dd as decimal.

def var s-amt11 as decimal decimals 2.
def var v-val as char.
def var v-nlg as char.
def var v-sumchkamt1 as decimal.

d_tssum_nalog = 0.

define buffer bnlg-sysc for sysc.
define buffer bb-sysc for sysc.
find last bb-sysc where bb-sysc.sysc = "JUR" no-lock no-error.

{tdainfo.f}

on help of vaaa in frame tda0 do:
   run tdaaaa-help.
end.

upper:
repeat on error undo, return:

message "F2 - список счетов, F4 - выход".

view frame tda0.
view frame tda1.
view frame tda2.

update vaaa with frame tda0.

find aaa where aaa.aaa = vaaa no-lock no-error.
if not available aaa then do:
   message "Счет " vaaa " не существует" view-as alert-box title "".
   pause.
   next upper.
end.
find lgr where lgr.lgr = aaa.lgr no-lock.
if lgr.led <> "CDA" then do:
   message "Счет не является депозитом юридическиго лица."  view-as alert-box title "".
   pause.
   next upper.
end.
if aaa.sta = "C" or aaa.sta = "E" then do:
   message "Закрытый счет" view-as alert-box title "".
   pause.
   next upper.
end.

if lookup(lgr.lgr, bb-sysc.chval) = 0 then do:
   message "Только новые депозиты Ю.Л. по группам" bb-sysc.chval view-as alert-box title "".
   pause.
   next upper.
end.

   find last acvolt where acvolt.aaa =  aaa.aaa no-lock no-error.
   if not avail acvolt then do:
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip "" view-as alert-box question buttons ok title "".
      next upper.
   end.



find cif where cif.cif = aaa.cif no-lock no-error.
def var v-rate as deci no-undo.
find last crc where crc.crc = aaa.crc no-lock no-error.
v-rate  = crc.rate[1].

hotkeys:
repeat:
run ShowInfo.
/*message "P-выплатить % в день начала депозита, C-закрыть депозит, T-история проводок,       H-история изменения % ставки, I-таблица % ставок, F4-выход".*/
message "C-закрыть депозит, T-история проводок, H-история изменения % ставки,  F4-выход".
   readkey.
   if keyfunction(lastkey) = 'T' then do:
      if available aaa then run tdajlhist(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'H' then do:
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.
      if available aaa and (lgr.feensf <> 3 and lgr.feensf <> 5 and lgr.feensf <> 7) then run tdaaabhist(aaa.aaa).
      if available aaa and (lgr.feensf = 3 or lgr.feensf = 5 or lgr.feensf = 7) then run histrez(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = "C" then do:
      if aaa.sta = "E" then do:
         message "  Депозит уже закрыт  " view-as alert-box title "".
         next hotkeys.
      end.
      else
      do:
          d_3% = 0.
          d_2% = 0.
          d_1% = 0.
          d_sm1 = 0.
          if aaa.crc = 1   then   do: find sysc "ratekz" no-lock no-error. if available sysc then d-brate = sysc.deval. end.
          if aaa.crc = 2   then   do: find sysc "rateus" no-lock no-error. if available sysc then d-brate = sysc.deval. end.
          if aaa.crc = 3  then   do: find sysc "rateeu" no-lock no-error. if available sysc then d-brate = sysc.deval. end.


          /* Срочный вклад */
          if (aaa.regdt < 08/01/2011) and (lookup(lgr.lgr,"478,479,480,481,482,483") <> 0) then do:
             i-mon = 0.
             /*Закрытие после окончания сроков после всех пролонгаций*/
             if (g-today > date(acvolt.x3) and acvolt.x7 = 4) then do:
                d_1% = 0.
                d_3% = 0.
             end.
             else do: /*досрочное расторжение*/
                  run Get_Month_Begin(date(acvolt.x1), g-today, output i-mon).
                  if i-mon < 1 then do:
                     d_tssum = 0.
                     d_1% = 0.
                     d_3% = 0.
                  end.
                  else do:
                       run Get_Month_Data(date(acvolt.x1), g-today, output d_daycount, output d_trdaydate).
                       if i-mon < 12  then do:
                          d_tssum = 0.
                          d_tssum =  (d_trdaydate - date(acvolt.x1)) * aaa.opnamt *  d-brate / (365 * 100).
                       end.
                       else do:
                            if aaa.crc = 1 then v-val = "KZT" .
                            if aaa.crc = 2 then v-val = "USD" .
                            if aaa.crc = 3 then v-val = "EUR" .

                            find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SR"  no-lock no-error.
                            d_tssum = 0.
                            d_tssum =  (d_trdaydate - date(acvolt.x1)) * aaa.opnamt *  (rtur.rate / 2) / (365 * 100).
                       end.
                       ss = 0.
                       dd = 0.

                       find last b-bufaaa where b-bufaaa.aaa20 = aaa.aaa no-lock no-error.
                       if avail b-bufaaa then do:
                           for each jl where jl.acc = b-bufaaa.aaa and jl.lev = 1 and jl.dc = "D" and  jl.rem[1] begins "15%"  no-lock use-index acc :
                               ss = ss + (if jl.dc = "D" then jl.dam else jl.cam).
                           end.

                           for each jl where jl.acc = b-bufaaa.aaa and jl.lev = 1 and jl.dc = "D"  and  not jl.rem[1] begins "Перенос в связи с переходом на" no-lock use-index acc :
                               dd = dd + (if jl.dc = "D" then jl.dam else jl.cam).
                           end.
                       end.

                       for each jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and  jl.rem[1] begins "15%"  no-lock use-index acc :
                           ss = ss + (if jl.dc = "D" then jl.dam else jl.cam).
                       end.

                       for each jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and    not jl.rem[1] begins "Перенос в связи с переходом на"  no-lock use-index acc :
                           dd = dd + (if jl.dc = "D" then jl.dam else jl.cam).
                       end.

                       d_tssum = (d_tssum + aaa.opnamt + acvolt.bonusopnamt) - (dd - ss).  /* должны выплатить ели клиент не забирал */
                       d_tssum = round(d_tssum, 2).

                       d_1% = 0.
                       d_3% = 0.
                       if (aaa.cr[1] - aaa.dr[1])  >  d_tssum then  d_1% = (aaa.cr[1] - aaa.dr[1]) - d_tssum.
                       if (aaa.cr[1] - aaa.dr[1])  <  d_tssum then  d_3% = d_tssum - (aaa.cr[1] - aaa.dr[1]).
                       if cif.geo = '022' and cif.type = 'B' then do:
                           if d_3% > 0 then d_tssum_nalog = d_3% * 15 / 100.
                       end.

                  end.
             end.

             find b-crc where b-crc.crc = aaa.crc no-lock no-error.
             message "F2 - список счетов, F4 - выход". pause 0.

             if cif.geo = '022' and cif.type = 'B' then do:
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
             end.
             else do:
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
             end.
          end.


          /* Срочный вклад c 05/07/2011*/
          if (aaa.regdt >= 08/01/2011) and (lookup(lgr.lgr,"478,479,480,481,482,483") <> 0) then do:
                 d_tssum = 0.
                 d_1% = 0.
                 d_3% = 0.
                 if aaa.aaa = 'KZ13470172215A319508' then do:
                     v-sumchkamt1 = 0.
                     for each aad where aad.aaa = aaa.aaa and aad.who = "bankadm" no-lock:
                         v-sumchkamt1 = v-sumchkamt1 + aad.cam - aad.dam .
                     end.
                     d_1% = v-sumchkamt1.
                     d_3% = 0.
                 end.
                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 message "F2 - список счетов, F4 - выход". pause 0.

                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
          end.

          /*Накопительный вклад*/
          if lookup(lgr.lgr,"484,485,486,487,488,489") <> 0 then do:
             i-mon = 0.
             /*Закрытие после окончания сроков после всех пролонгаций*/
             if (g-today > date(acvolt.x3) and acvolt.x7 = 4) then do:
                d_1% = 0.
                d_3% = 0.
             end.
             else do: /*досрочное расторжение*/
                  run Get_Month_Begin(date(acvolt.x1), g-today, output i-mon).
                  if i-mon < 1 then do:
                     d_tssum = 0.
                     d_1% = 0.
                     d_3% = 0.
                  end.
                  else do:
                      message "ОШИБКА ПРИ ВЕДЕНИИ СЧЕТА: необходим пересчет вручную"  view-as alert-box question buttons yes-no title "" update v-ans.
                      return.


                       run Get_Month_Data(date(acvolt.x1), g-today, output d_daycount, output d_trdaydate).

                       find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                       if not avail acvolt then do:
                          message "ОШИБКА ПРИ ВЕДЕНИИ СЧЕТА: продолжение невозможно"  view-as alert-box question buttons yes-no title "" update v-ans.
                          return.
                       end.
                       ss = 0.
                       find last b-bufaaa where b-bufaaa.aaa20 = aaa.aaa no-lock no-error.
                       if avail b-bufaaa then do:
                            for each jl where jl.acc = b-bufaaa.aaa and jl.lev = 1 and jl.dc = "D" and  jl.rem[1] begins "15%"  no-lock use-index acc :
                                ss = ss + (if jl.dc = "D" then jl.dam else jl.cam).
                            end.

                       end.
                       for each jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and  jl.rem[1] begins "15%"  no-lock use-index acc :
                           ss = ss + (if jl.dc = "D" then jl.dam else jl.cam).
                       end.

                       d_tssum_nalog = 0.
                       d_tssum =  (decimal(acvolt.prim1) - ss - acvolt.bonusopnamt) / 2.


                       d_tssum_nalog = d_tssum * 15 / 100.
                       /*   d_tssum = d_tssum - d_tssum_nalog. */

                       d_tssum = d_tssum + acvolt.bonusopnamt.

                       ss = 0.
                       for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
                           d_tssum = d_tssum + aad.sumg.
                           ss = ss + aad.sumg.
                       end.

                       d_tssum = d_tssum + aaa.opnamt.
                       ss = ss + aaa.opnamt.
                       /*message (acvolt.bonusopnamt + ss) (aaa.cr[1] - aaa.dr[1]).
                       pause 333. */

                       if (acvolt.bonusopnamt + ss) >= (aaa.cr[1] - aaa.dr[1]) then do:
                           d_tssum = d_tssum - ((acvolt.bonusopnamt + ss) - (aaa.cr[1] - aaa.dr[1])).
                       end.

                       d_tssum = round(d_tssum, 2).

                       d_1% = 0.
                       d_3% = 0.

                       if (aaa.cr[1] - aaa.dr[1])  >  d_tssum then  d_1% = (aaa.cr[1] - aaa.dr[1]) - d_tssum.
                       if (aaa.cr[1] - aaa.dr[1])  <  d_tssum then  d_3% = d_tssum - (aaa.cr[1] - aaa.dr[1]).

                  end.
             end.

             find b-crc where b-crc.crc = aaa.crc no-lock no-error.
             message "F2 - список счетов, F4 - выход". pause 0.
             message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
             "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
             "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

             "Подтвердите закрытие депозита."
             view-as alert-box question buttons yes-no title "" update v-ans.
          end.
          /*   end.*/


          /*Недропользователь*/
          if lookup(lgr.lgr,"518,519,520") <> 0 then do:
             i-mon = 0.
             /*Закрытие после окончания срока*/
             if g-today > date(acvolt.x3) then do:
                d_1% = 0.
                d_3% = 0.
             end.
             else do: /*досрочное расторжение*/
                d_tssum = 0.
                d_1% = 0.
                d_3% = 0.
                /*
                run Get_Month_Begin(date(acvolt.x1), g-today, output i-mon). /*кол-во месяцев*/
                if i-mon < 1 then do:
                   d_tssum = 0.
                   d_1% = 0.
                   d_3% = 0.
                end.
                else do:
                   run Get_Month_Data(date(acvolt.x1), g-today, output d_daycount, output d_trdaydate).

                   find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                   if not avail acvolt then do:
                      message "ОШИБКА ПРИ ВЕДЕНИИ СЧЕТА: продолжение невозможно"  view-as alert-box question buttons yes-no title "" update v-ans.
                      return.
                   end.
                   ss = 0.
                   for each jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" and  jl.rem[1] begins "15%"  no-lock use-index acc :
                       ss = ss + (if jl.dc = "D" then jl.dam else jl.cam).
                   end.

                   d_tssum_nalog = 0.
                   d_tssum =  (decimal(acvolt.prim1) - ss - acvolt.bonusopnamt) / 2. /*Начисленные % за период пролонгации*/
                   d_tssum_nalog = d_tssum * 15 / 100. /*Сумма 15% налога с начисленных %*/
                   d_tssum = d_tssum + acvolt.bonusopnamt. /*Общая сумма (выплаченная за предыдущий период + начисленные% за период пролонгации)*/

                   ss = 0.
                   for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
                       d_tssum = d_tssum + aad.sumg.
                       ss = ss + aad.sumg.
                   end.

                   d_tssum = d_tssum + aaa.opnamt.
                   ss = ss + aaa.opnamt.

                   if (acvolt.bonusopnamt + ss) >= (aaa.cr[1] - aaa.dr[1]) then do:
                      d_tssum = d_tssum - ((acvolt.bonusopnamt + ss) - (aaa.cr[1] - aaa.dr[1])).
                   end.

                   d_tssum = round(d_tssum, 2).

                   d_1% = 0.
                   d_3% = 0.

                   if (aaa.cr[1] - aaa.dr[1])  >  d_tssum then  d_1% = (aaa.cr[1] - aaa.dr[1]) - d_tssum.
                   if (aaa.cr[1] - aaa.dr[1])  <  d_tssum then  d_3% = d_tssum - (aaa.cr[1] - aaa.dr[1]).
                end. /*if i-mon < 1*/
                */
             end. /* if g-today > date(acvolt.x3)*/

             find b-crc where b-crc.crc = aaa.crc no-lock no-error.
             message "F2 - список счетов, F4 - выход". pause 0.
             message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
             "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
             "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

             "Подтвердите закрытие депозита."
             view-as alert-box question buttons yes-no title "" update v-ans.
          end. /*if lookup(lgr.lgr,"A38,518,519,520") <> 0*/


          if lookup(lgr.lgr,"B01,B02,B03,B04,B05,B06") <> 0 then do:
             if aaa.crc <> 1 then do:
                 d_tssum_nalog = 0.
                 d_1% = 0.
                 d_3% = 0.

                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 message "F2 - список счетов, F4 - выход". pause 0.
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
             end. else do:
                 if aaa.expdt <= g-today then do:
                     d_tssum_nalog = 0.
                     d_1% = 0.
                     d_3% = 0.
                 end. else do:
                     find first jl where jl.acc = aaa.aaa and jl.cam > 0 no-lock no-error.
                     /*displ jl.acc format 'x(20)' cam dam jdt today - jl.jdt*/
                     d_tssum = IntBase() * 0.1 * (g-today - jl.jdt) / 365 / 100.
                     d_tssum_nalog = d_tssum * 15 / 100.
                     /*  d_1%  Сумма удерживаемая с 1 уровня  */
                     /*  d_2%  Сумма удерживаемая со 2 уровня */
                     /*  d_3%  Сумма для выплаты на 1 уровень */
                     d_3% = d_tssum.
                     d_1% = 0.
                 end.

                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 message "F2 - список счетов, F4 - выход". pause 0.
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
             end.

          end.
          if lookup(lgr.lgr,"B07,B08") <> 0 then do:
             if aaa.crc <> 1 then do:
                 if aaa.expdt <= g-today then do:
                     d_tssum_nalog = 0.
                     d_1% = 0.
                     d_3% = 0.
                 end. else do:
                     v-sumchkamt1 = 0.
                     for each aad where aad.aaa = aaa.aaa and aad.who = "bankadm" no-lock:
                         v-sumchkamt1 = v-sumchkamt1 + aad.cam - aad.dam .
                     end.
                     d_1% = v-sumchkamt1.
                     d_3% = 0.
                 end.

                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 message "F2 - список счетов, F4 - выход". pause 0.
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.
             end. else do:
                 if aaa.expdt <= g-today then do:
                     d_tssum_nalog = 0.
                     d_1% = 0.
                     d_3% = 0.
                 end. else do:
                     v-sumchkamt1 = 0.
                     for each aad where aad.aaa = aaa.aaa and aad.who = "bankadm" no-lock:
                         v-sumchkamt1 = v-sumchkamt1 + aad.cam - aad.dam .
                     end.
                     d_1% = 0.
                     d_3% = 0.
                     find first jl where jl.acc = aaa.aaa and jl.cam > 0 no-lock no-error.
                     /*displ jl.acc format 'x(20)' cam dam jdt today - jl.jdt*/
                     d_tssum = IntBase() * 0.1 * (g-today - jl.jdt) / 365 / 100.

                     if d_tssum = v-sumchkamt1 then do:
                        d_1% = 0.
                        d_3% = 0.
                        d_tssum_nalog = 0.
                     end.
                     if d_tssum > v-sumchkamt1 then do:
                        d_1% = 0.
                        d_3% = d_tssum - v-sumchkamt1.
                        d_tssum_nalog = d_3% * 15 / 100.
                     end.
                     if d_tssum < v-sumchkamt1 then do:
                        d_1% = v-sumchkamt1 - d_tssum.
                        d_3% = 0.
                        d_tssum_nalog = 0.
                     end.
                 end.
                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 message "F2 - список счетов, F4 - выход". pause 0.
                 message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

                 "Подтвердите закрытие депозита."
                 view-as alert-box question buttons yes-no title "" update v-ans.

             end.
          end.

          if lookup(lgr.lgr,"B09,B10,B11") <> 0 then do:
             d_tssum_nalog = 0.
             d_1% = 0.
             d_3% = 0.

             find b-crc where b-crc.crc = aaa.crc no-lock no-error.
             message "F2 - список счетов, F4 - выход". pause 0.
             message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
             "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
             "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

             "Подтвердите закрытие депозита."
             view-as alert-box question buttons yes-no title "" update v-ans.
          end.

          if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") <> 0 then do:
             d_tssum_nalog = 0.
             d_1% = 0.
             d_3% = 0.

             find b-crc where b-crc.crc = aaa.crc no-lock no-error.
             message "F2 - список счетов, F4 - выход". pause 0.
             message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
             "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
             "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip

             "Подтвердите закрытие депозита."
             view-as alert-box question buttons yes-no title "" update v-ans.
          end.

      end. /*if keyfunction(lastkey) = "C" */




      if v-ans = False then  return.
      run tdaremholda(aaa.aaa).

      if v-ans = true then do:
          /* Проводка с 2 на 1 уровень */
          if d_3% > 0 and d_3% <= (aaa.cr[2] - aaa.dr[2]) then do:
             run savelog( "cdacls", aaa.aaa + " Проводка с 2 на 1 уровень").
             v-jh = 0.
             run trxgen("TDA0001", vdel, string(d_3%) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                run savelog( "cdacls", aaa.aaa + " TDA0001 " + rdes).
                message "TDA0001" rdes. pause. undo,retry.
             end.
             else do:
                run trxsts(v-jh, 6, output rcode, output rdes).
                if rcode ne 0 then do:
                   run savelog( "cdacls", aaa.aaa + " " + rdes).
                   message rdes view-as alert-box title "". undo,retry.
                end.
             end.
          end.

          v-jh = 0.

          /* Проводка с 1 на 2 уровень */
          if d_1% > 0 and (aaa.cr[1] - aaa.dr[1]) >= d_1% then do:
             run trxgen("UNI0074", vdel, string(d_1%) + vdel + aaa.aaa + vdel + "Удержание процентов с 1 уровня" + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "UNI0074 " rdes. pause. undo,retry.
             end.
          end.


          s-amt2 = aaa.cr[2] - aaa.dr[2]. s-amt11 = 0.
          run savelog('cdacls', '596. ' + aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          find first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 11 no-lock no-error.
          s-amt11 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1], 2).
          run savelog('cdacls', '599. ' + aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          if s-amt2 > s-amt11 then s-amt1 = s-amt2 - s-amt11.
          else do : s-amt1 = 0. s-amt11 = s-amt2. end.
          run savelog('cdacls', '602. ' + aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          /*!!!!!!*/
          /* Проводка со 2 на 11 уровень */
          if s-amt11 > 0 then do:
             v-jh = 0.
             /*vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11).*/
             if aaa.crc = 1 then vparam = string(0) + vdel + aaa.aaa + vdel + string(0) + vdel + aaa.aaa + vdel + "0" + vdel + string(s-amt11) + vdel + aaa.aaa.
             else vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11) + vdel + aaa.aaa + vdel + string(round(s-amt11 * v-rate,2)) + vdel + string(0) + vdel + aaa.aaa.
             run trxgen ("cda0003", vdel, vparam, "CIF" , aaa.aaa ,  output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "cda0003" ' ' rdes. pause. undo,retry.
             end. else
             do: /* штамповка транзакции */
                  run trxsts(v-jh, 6, output rcode, output rdes).
                  if rcode ne 0 then do:
                     message rdes view-as alert-box title "". return.
                  end.
             end.
          end.

          /* Урегулируем разность если на 2 ур > чем на 11 */
          if s-amt1 > 0 then do:
             v-jh = 0.
             /*vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов ".*/
            if aaa.crc = 1 then vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов" + vdel +
                                    string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
            else vparam = string(0) + vdel + aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов" + vdel + string(round(s-amt1 * v-rate,2)).
             run trxgen ("uni0048", vdel, vparam, "CIF" , aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "uni0048" ' ' rdes. pause. undo,retry.
             end.
          end.
          /*!!!!!!*/
          if d_tssum_nalog > 0 then do:
               if cif.geo = '022' and cif.type = 'B' then do:
                  v-nlg = "".
                  find last bnlg-sysc where bnlg-sysc.sysc = "nlg022"  no-lock no-error.
                  if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                  if aaa.crc <> 1 then do:
                     vparam = string(d_tssum_nalog)
                         + vdel + aaa.aaa
                         + vdel + string(getConvGL(aaa.crc,"C"))
                         + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin)
                         + vdel + v-nlg
                         + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin).
                     /*message vparam. pause.*/
                     v-jh = 0.
                     run trxgen("vnb0083", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode <> 0 then do:
                        message "Произошла ошибка при удержании налога. Не настроен ARP счет. [1] " rdes.
                        pause 555.
                     end.
                  end.
                  else do:
                     vparam = string(d_tssum_nalog) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel + string(v-nlg) + vdel +
                              string("15% подоходный налог, " + cif.name + " " + cif.bin) + vdel + "390".
                     v-jh = 0.
                     run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode <> 0 then do:
                        message "Произошла ошибка при удержании налога. Не настроен ARP счет. [2] " rdes.
                        pause 555.
                     end.
                  end. /*aaa.crc <> 1*/
               end.
               else do:
                  find last bnlg-sysc where bnlg-sysc.sysc = "nlg"  no-lock no-error.
                  if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                  if aaa.crc <> 1 then do:
                     /*run trxgen("vnb0024", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).*/
                     vparam = string(d_tssum_nalog)
                          + vdel + aaa.aaa
                          + vdel + string(getConvGL(aaa.crc,"C"))
                          + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin)
                          + vdel + v-nlg
                          + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin).
                     v-jh = 0.
                     run trxgen("vnb0083", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).

                  end. else do:
                     vparam = string(d_tssum_nalog) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel +  string(v-nlg) + vdel +
                              string("15% подоходный налог, " + cif.name + " " + cif.bin) + vdel + "390".
                     v-jh = 0.
                     run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).

                  end. /*aaa.crc <> 1*/
                  if rcode ne 0 then do:
                     message "Произошла ошибка при удержании налога. Не настроен ARP счет. [3] " rdes.
                     pause 555.
                  end.

               end.
          end.

          aaa.sta = "E".
          aaa.accrued = 0.
      end.
      leave hotkeys.
  end.

   else if keyfunction(lastkey) = 'end-error' then do:
      leave hotkeys.
   end.
end.
end.









Procedure DayCount. /*возвращает количество дней за целое число месяцев*/
def input parameter a_start as date.
def input parameter a_expire as date.
def output parameter e_day as integer.
def output parameter e_daydate as date.

def var vterm as inte.
def var e_refdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.
def var i as inte initial 0.

def var e_fire as logical init False.
def var t-days as date.
def var e_date as date.

do e_date = a_start to a_expire - 1:

     e_fire = false.
     vterm = 1.
     t_date = a_start.
     i = 1.
     repeat:
       days = day(t_date).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
         if month(t_date) <> month(t_date + 1) then do:
           months = months + 1.
           if months = 13 then do:
              months = 1.
              years = years + 1.
           end.
           days = 1.
         end.
         if months = 2 and days = 30 then do: months = 2. days = 29. end.

         if months = 2 and days = 29
          and  (( (year(t_date) + years) - 2000) modulo 4) <> 0 then do:
         months = 3.  days = 1.  end.
       if i = 1 then e_refdate = date(months, days, year(t_date) + years) - 1.
                else e_refdate = date(months, days, year(t_date) + years) .

         if month(t_date) <> month(t_date + 1) then e_refdate = e_refdate - 1.
       if e_refdate > e_date then leave.
       else if e_refdate > a_expire then leave.

       if e_date = e_refdate then do:
          e_fire = true.
          leave.
       end.
       t_date = e_refdate.
        i = i + 1.
     end. /*repeat*/

     if e_fire then do:
        t-days = e_date .
     end.
end.
     e_day = t-days - a_start.
     if e_day = ? then e_day = 0.
     e_daydate = t-days.
End procedure.














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
if lgr.feensf <> 3 and lgr.feensf <> 5 then do:
 intavail = aaa.cr[1] - aaa.dr[1] - currentbase.
 intpaid = aaa.dr[2] - intavail - capitalized.
  if intpaid < 0 then do:
     intpaid = aaa.dr[1].
  end.

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
    if aaa.crc = 1 then  find sysc "ratekz" no-lock no-error.
    if aaa.crc = 2 then  find sysc "rateus" no-lock no-error.
    if aaa.crc = 11 then find sysc "rateeu" no-lock no-error.
    if available sysc then intrat = sysc.deval.
    else intrat = 0.
end.
else run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, currentbase, output intrat).
*/
intrat = aaa.rate.

if g-today < aaa.expdt /*+ 1*/ then do:
   v-pay = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].
   if lgr.intcal <> "S" and lgr.intcal <> "N" then
   v-pay = v-pay + aaa.m10 + (aaa.expdt - g-today /*+ 1*/) * currentbase * intrat / aaa.base / 100.
   else if lgr.intcal = "S" and aaa.lstmdt = g-today and aaa.cr[2] = 0 then
   v-pay = v-pay + (aaa.expdt - aaa.lstmdt /*+ 1*/) * currentbase * intrat / aaa.base / 100.
end.
else
   v-pay = v-paynow.

display aaa.cif trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name
  crc.code aaa.sta aaa.pri lgr.lgr lgr.des aaa.lstmdt aaa.expdt
        /*aaa.cla*/ vday vterm /*v-paynow*/ v-pay with frame tda0.
display vopnamt adddepos capitalized currentbase with frame tda1.
display intrat v-excl aaa.accrued intpaid intavail with frame tda2.

End Procedure.









Procedure Get_Month_Begin.
   def input parameter a_start as date.
   def input parameter e_date as date.
   def output parameter out_month as integer.

   def var vterm as inte.
   def var e_refdate as date.
   def var e_displdate as date.
   def var t_date as date.
   def var years as inte initial 0.
   def var months as inte initial 0.
   def var days as inte initial 0.

   def var t-years as inte initial 0.
   def var t-months as inte initial 0.
   def var t-days as inte initial 0.

   def var i as integer initial 0.


     vterm = 1.
     t_date = a_start.
     i = 0.



     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do:
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/

          if months = 2 and (days = 29 or days = 30 or days = 31) then
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.



       if e_displdate + 1 >= e_date then do:
          if e_displdate + 1 = e_date then i = i + 1.
          out_month = i.
          return.
       end.

       i = i + 1.

       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/
End procedure.














Procedure Get_Month_Data.
   def input parameter a_start as date.
   def input parameter e_date as date.
   def output parameter out_month as integer.
   def output parameter o_date as date.

   def var vterm as inte.
   def var e_refdate as date.
   def var e_displdate as date.
   def var t_date as date.
   def var years as inte initial 0.
   def var months as inte initial 0.
   def var days as inte initial 0.

   def var t-years as inte initial 0.
   def var t-months as inte initial 0.
   def var t-days as inte initial 0.

   def var i as integer initial 0.


     vterm = 1.
     t_date = a_start.
     i = 0.



     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do:
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/

          if months = 2 and (days = 29 or days = 30 or days = 31) then
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.


       if e_displdate + 1 > e_date then do:
          if e_displdate + 1 = e_date then do:
             i = i + 1.
          end.
          out_month = i.
/*          o_date =  e_displdate + 1.*/
          return.
       end.
          o_date =  e_displdate + 1.


       i = i + 1.

       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/
End procedure.







