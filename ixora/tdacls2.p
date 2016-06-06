/* tdacls2.p
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
        01.07.2004 dpuchkov - добавил привязку к USD по VIP депозитам
        09.08.2004 dpuchkov - Изменил откат процентов в соответствии с текущей % ставкой
        11.08.2004 dpuchkov - поправил возмажность част изъятий неск раз
        24.08.2004 dpuchkov - поправил поиск групп соответствия
        03.09.2004 dpuchkov - добавил привязку валютных VIP депозитов к тенге в соответствии с изменением в законодательстве(ТЗ1100)
        10.09.2004 dpuchkov - сделал возможным частичные изъятия по депозиту Пенсионный на сумму меньше 5 (%)
        06.10.2004 dpuchkov - изменил алгоритм расчета по депозиту "Звезда" согласно ТЗ 1085.
        13.10.2004 dpuchkov - при изъятии добавил отображение сумм удерживаемых % (начисленых и капитализированых).
        29/12/2010 evseev - заремил v-paynow в форме, т.к. расчитывается неверно.
        20/05/2011 evseev - при частичном изъятии для lgr.feensf = 6 вызов tdaget3
        10.06.2011 aigul - проверка срока действия УЛ
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        13.05.2013 evseev - tz-1828
        28/10/2013 Luiza  - ТЗ 1932 изменила параметры шаблона cda0003
*/

/*TDA deposits closing
adding printing vaucher  by nataly 28/05/02
при досрочном рассторжении депозита и нехватке ср-в на 11-уровне
добавлена возможность частичного погашения 11-го и списания
избыточных %% на ГК 492120 by nataly 06/06/02 */

{mainhead.i}

def  new shared var s-jh like jh.jh.

def new shared var s-aaa like aaa.aaa.


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
define var s-amt3 like aal.amt.
def var v-templ as char.
def buffer b-crc for crc.
def var v-minus as decimal.

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
def var d_sumost  as decimal.
def var v-aadrate as decimal.
def var v-aadpri  as decimal.
def var d_%store  as decimal.
def var d_%2level as decimal.
def var d_rate    as decimal.
def var i_day as integer.


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
    run check_ul(vaaa).
    find aaa where aaa.aaa = vaaa no-lock no-error.
    if not available aaa then do:
       message "Счет " vaaa " не существует" view-as alert-box title "".
       pause.
       next upper.
    end.
    find lgr where lgr.lgr = aaa.lgr no-lock no-error.
    if lgr.led <> "TDA" then do:
       message "Счет не является счетом срочного депозита типа TDA." view-as alert-box title "".
       pause.
       next upper.
    end.
    if aaa.sta = "C" or aaa.sta = "E" then do:
       message "Закрытый счет" view-as alert-box title "".
       pause.
       next upper.
    end.
    find lgr where aaa.lgr = lgr.lgr no-lock no-error.
    if lgr.tlimit[3] = 0 then do:
       message "Депозит не является сберегательным с изъятием!!!" view-as alert-box title " Внимание ".
       pause.
       next upper.
    end.

    find cif where cif.cif = aaa.cif no-lock no-error.
    def var v-rate1 as deci no-undo.
    find last crc where crc.crc = aaa.crc no-lock no-error.
    v-rate1  = crc.rate[1].

    sum[1] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.05,0).
    sum[2] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.1,0).
    sum[3] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.2,0).
    sum[4] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.3,0).
    sum[5] = truncate((aaa.cr[1] - aaa.dr[1]) * 0.4,0).

    hotkeys:
    repeat:
       run ShowInfo.
       /*message "P-выплатить % в день начала депозита, C-закрыть депозит, T-история проводок,       H-история изменения % ставки, I-таблица % ставок, F4-выход".*/
       message "P-частичное изъятие, T-история проводок, H-история изменения % ставки, I-таблица % ставок, F4-выход".
       readkey.
       if keyfunction(lastkey) = 'T' then do:
          if available aaa then run tdajlhist(aaa.aaa).
          readkey pause 0.
       end. else if keyfunction(lastkey) = 'H' then do:
          find lgr where lgr.lgr = aaa.lgr no-lock no-error.
          if available aaa and ((lgr.feensf <> 3 and lgr.feensf <> 4 and lgr.feensf <> 5 and lgr.feensf <> 7 and lgr.feensf <> 6) or lookup(lgr.lgr, "A38,A39,A40") = 0)then run tdaaabhist(aaa.aaa).
          if available aaa and ((lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 5 or lgr.feensf = 1 or lgr.feensf = 2 or lgr.feensf = 7 or lgr.feensf = 6) or lookup(lgr.lgr, "A38,A39,A40") > 0) then run histrez(aaa.aaa).
          readkey pause 0.
       end. else if keyfunction(lastkey) = 'I' then do:
          if available aaa then run tdainthist(aaa.pri).
          readkey pause 0.
       end. else if keyfunction(lastkey) = "P"  and ((lgr.feensf <> 1  and lgr.feensf <> 2 and lgr.feensf <> 3 and lgr.feensf <> 6 and lgr.feensf <> 4 and lgr.feensf <> 5 and lgr.feensf <> 7 ) and lookup(lgr.lgr, "A38,A39,A40") = 0) then do:
          if aaa.sta = "E"  or aaa.sta = "C" then do:
             message "  Депозит уже закрыт  " view-as alert-box title "".
             next hotkeys.
          end. else if aaa.sta = "M" then do:
              message "  Срок  депозита уже наступил  "  aaa.expdt skip " Для закрытия депозита см. п.п. 10-7-4 " view-as alert-box title " Внимание ".
              next hotkeys.
          end. else if aaa.sta = "A"  or aaa.sta = "N" then do:
             bell.
             update v-sum  label 'Введите сумму частичного изъятия' with row 8 centered  side-label frame opt.
             find aas where aas.aaa = aaa.aaa and aas.ln = vln no-lock no-error.
             find crc where crc.crc = aaa.crc no-lock no-error.
             if  (v-sum > sum[1] and v-sum <> sum[2] and v-sum <> sum[3] and v-sum <> sum[4] and v-sum <> sum[5]) then do:
                 message  " Можно снять "  sum[1] sum[2] sum[3] sum[4] sum[5]  crc.code '.' view-as alert-box.
                 next hotkeys.
             end. else do: /*v-sum is true*/
                 find b-crc where b-crc.crc = aaa.crc no-lock no-error.
                 find first aab where aab.aaa = aaa.aaa no-lock no-error.
                 v-rate = aab.rate.
                 v-accr = truncate ((v-sum * v-rate / 100 / aaa.base * 30),2).
                 message "Частичное  изъятие!" skip " Начисленные проценты  в размере " ( v-accr )  b-crc.code " будут удержаны." skip "Подтвердите частичное изъятие."  view-as alert-box question buttons yes-no title "" update v-ans.
                 if not v-ans then next hotkeys. else do transaction:
                    s-amt1 = 0.
                    s-amt2 = v-accr. /*ск-ко надо удержать */
                    vacr = aaa.accrued.
                    find first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 11 no-lock no-error.
                    s-amt3 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1],2).
                    v-jh = 0.
                    /* Подгонка 11 уровня, излишек перекидываем на 470310 */
                    /* if vacr = s-amt2 then do:  /*не было промежуточных выплат*/   */
                    if s-amt2 > s-amt3 then s-amt1 = s-amt2 - s-amt3. else do : s-amt1 = 0.  s-amt3= s-amt2. end.
                    if s-amt3 > 0 then do:
                       v-templ = "cda0003".
                       /*vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt3).*/
                       if aaa.crc = 1 then vparam = string(0) + vdel + aaa.aaa + vdel + string(0) + vdel + aaa.aaa + vdel + "0" + vdel + string(s-amt3) + vdel + aaa.aaa.
                       else vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt3) + vdel + aaa.aaa + vdel + string(round(s-amt3 * v-rate1,2)) + vdel + string(0) + vdel + aaa.aaa.
                       run trxgen (v-templ, vdel, vparam, "CIF" , aaa.aaa , output rcode, output rdes, input-output v-jh).
                       if rcode ne 0 then do:
                          message v-templ ' ' rdes.
                          pause.
                          message vparam.
                          pause.
                          undo,retry.
                       end.
                    end. /*if s-amt3 > 0 */
                    if s-amt1 > 0 then do:
                         v-templ = 'uni0144'.
                         vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие".
                         run trxgen (v-templ, vdel, vparam, "CIF" , aaa.aaa , output rcode, output rdes, input-output v-jh).
                         if rcode ne 0 then do:
                             message v-templ ' ' rdes.
                             pause.
                             message vparam.
                             pause.
                             undo,retry.
                         end.
                    end. /*if s-amt1 > 0  - есть излишки*/
                    run trxsts(v-jh, 6, output rcode, output rdes).
                    if rcode ne 0 then do:
                       message rdes view-as alert-box title "".
                       next hotkeys.
                    end.
                    if v-sum < sum[1] then v-sum = v-sum + (aaa.hbal - (aaa.cr[1] - aaa.dr[1])).
                    run tdaremhold(aaa.aaa,v-sum).
                 end. /*do transaction*/
             end. /*v-sum is true*/
          end. /*aaa.sta  "A" ot aaa.sta = "N" */
          release aaa.
          /*voucher printing nataly--------------------*/
          if v-jh ne 0 then do :
            do on endkey undo:
                find first jl where jl.jh = v-jh exclusive-lock no-error.
                if available jl  then do:
                   message "Печатать ваучер ?" update ja.
                   if ja   then do:
                      message "Сколько ?" update vou-count.
                      if vou-count > 0 and vou-count < 10 then do:
                          s-jh =  v-jh.
                          {mesg.i 0933} s-jh.
                          do i = 1 to vou-count:
                              run x-jlvou.
                          end.
                      end.  /* if vou-count > 0 */
                   end. /* if ja */
                   if not ja then  do:
                      {mesg.i 0933} v-jh.   /* s-jh = jh.jh.*/ pause 5.
                   end. /*  if not ja*/
                   pause 0.
                end. else do:
                    message "Can't find transaction " v-jh view-as alert-box.
                    return.
                end.
                pause 0.
            end. /* do on endkey undo: */
          end.
          /*voucher printing nataly--------------------*/
          clear frame tda0.
          clear frame tda1.
          clear frame tda2.
          leave hotkeys.
       end. else if keyfunction(lastkey) = "P" and lgr.feensf = 3  then do : /* депозитные счета ЛЮКС */
         run tdaget3(aaa.aaa).
       end. else if keyfunction(lastkey) = "P" and lgr.feensf = 6  then do : /* депозитные счета ЛЮКС */
          run tdaget3(aaa.aaa).
       end. else if keyfunction(lastkey) = "P" and lgr.feensf = 4  then do : /* депозитные счета VIP */
          run tdaget4(aaa.aaa).
       end. else if keyfunction(lastkey) = "P" and lgr.feensf = 5  then do : /* депозитные счета супер люкс */
          run tdaget5(aaa.aaa).
       end. else if keyfunction(lastkey) = "P" and lgr.feensf = 7  then do : /* депозитные счета Детский */
          run tdaget7(aaa.aaa).
       end. else if keyfunction(lastkey) = "P" and lookup(lgr.lgr, "A38,A39,A40") > 0  then do : /* депозитные счета ЛЮКС */
          run tdaget8(aaa.aaa).
       end. else if keyfunction(lastkey) = 'end-error' then do:
          leave hotkeys. return.
       end.
    end.
end.

return.

Procedure ShowInfo.
    if aaa.cr[1] > 0 then vopnamt = aaa.opnamt. else vopnamt = 0.
    find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
    if available aas then currentbase = aas.chkamt. else currentbase = 0.
    capitalized = aaa.stmgbal.
    adddepos = currentbase - vopnamt - capitalized.
    if adddepos < 0 then adddepos = 0.
    if lgr.feensf <> 3 and lgr.feensf <> 6 and lgr.feensf <> 4 then do:
     intavail = aaa.cr[1] - aaa.dr[1] - currentbase.
     intpaid = aaa.dr[2] - intavail - capitalized.
    end. else do:
     intavail = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
     intpaid = aaa.dr[1] .
    end.
    vterm = aaa.expdt - g-today /*+ 1*/.
    vday  = aaa.expdt - aaa.regdt.
    if g-today < aaa.expdt /*+ 1*/ then v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2] - aaa.accrued.
    else v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].

    if aaa.payfre = 1 then v-excl = "!".
    intrat = aaa.rate.
    if g-today < aaa.expdt /*+ 1*/ then do:
       v-pay = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].
       if lgr.intcal <> "S" and lgr.intcal <> "N" then do:
          v-pay = v-pay + aaa.m10 + (aaa.expdt - g-today /*+ 1*/) * currentbase * intrat / aaa.base / 100.
       end. else if lgr.intcal = "S" and aaa.lstmdt = g-today and aaa.cr[2] = 0 then
          v-pay = v-pay + (aaa.expdt - aaa.lstmdt /*+ 1*/) * currentbase * intrat / aaa.base / 100.
    end. else v-pay = v-paynow.
    display aaa.cif cif.name crc.code aaa.sta aaa.pri lgr.lgr lgr.des aaa.lstmdt aaa.expdt vday vterm  v-pay with frame tda0.
    display vopnamt adddepos capitalized currentbase with frame tda1.
    display intrat v-excl aaa.accrued intpaid intavail with frame tda2.
End Procedure.

