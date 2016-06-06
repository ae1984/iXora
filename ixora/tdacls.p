/* tdacls.p
 * MODULE
        Депозиты
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
        10.7.4
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 nataly
 * CHANGES
        21.09.03 nataly  вычисляется сумма начисленных процентов как на счет
        довостребования согласно таблице %% ставок
        15.12.03 nataly был перенесен блок по штамповке проводок при досрочном закрытии депозита ( не всегда был статус 6!)
        16/03/04 nataly feensf = 5
        19.03.04 nataly убрано условие intavail = 0
        20.05.2004 nadejda - в форму добавлен просмотр признака исключения по % ставке
                             добавлен параметр номера счета в вызов tdagetrate
        11.11.2004 dpuchkov- добавил проверку если депозит пролонгирован и статус не проставлен
        10.12.2004 dpuchkov- при закрытии производится пересчет по таблице % ставок (ТЗ#1243) по новой схеме
        31.12.2004 dpuchkov- добавил возможность закрытия счетов которые открыли сегодня
        03.02.2005 dpuchkov - добавил алгоритм досрочного закрытия по депозитам типа Звезда без капитализации
        27.05.2005 dpuchkov - при закрытии депозита Classic(новый) ставка до востребования за целое число месяцев.
        15.06.2005 dpuchkov - перекомпиляция
        30.03.2006 nataly  - закрытие тек счета ФЛ с неснижаемым остатком
        27/04/2006 nataly  - добавлена проверка на исключения по коду 193,180/181
        20.10.2006 u00124  - добавил удержание комиссии при досрочном расторжении(ТЗ 483).
        30.10.2006 u00124  - (ТЗ-483) удержание комиссии при расторжении депозита если срок меньше месяца
        30.10.2006 u00124  - (ТЗ-502) пересчет вознаграждения по депозитам Dallas Dallas VIP за целое число месяцев
        17.03.2009 id00004 - добавил предварительный просмотр сумм при закрытии депозита
        28/12/2010 evseev - заремил v-paynow в форме, т.к. расчитывается неверно.
        23.05.2011 evseev - добавил схему 6.
        10.06.2011 aigul - проверка срока действия УЛ
        22/12/2011 evseev - логирование в закрытии депозита
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        13.05.2013 evseev - tz-1828
*/



{mainhead.i}

{comm-txb.i}

def  new shared var s-jh like jh.jh.

def var v-sumcom as decimal                no-undo.
def var v-sumcom1 as decimal init 0        no-undo.
def var v-tarifval as char init '181'      no-undo.
def var v-tarifkzt as char init '180'      no-undo.
def var v-gl like gl.gl                    no-undo.
def var v-rem as char                      no-undo.
def var v-ans as logi                      no-undo.
def var vdel as char initial "^"           no-undo.
def var vparam as char                     no-undo.
def var vparam2 as char                    no-undo.
def var v-jh like jh.jh                    no-undo.
def var v-jhcom like jh.jh                 no-undo.
def var rcode as inte                      no-undo.
def var rdes as char                       no-undo.
def var restint as deci                    no-undo.
def var t-restint as deci                  no-undo.
def var vacr as deci                       no-undo.
def var s-amt1 like aal.amt                no-undo.
def var s-amt2 like aal.amt                no-undo.
def var s-amt22 like aal.amt               no-undo.
def new shared var s-amtcom as decimal decimals 2.
def var s-amt3 like aal.amt init 0         no-undo.
def var v-templ as char                    no-undo.
def buffer b-crc for crc.
def var v-minus as decimal                 no-undo.
def var i_month   as integer               no-undo.
def var i_day as integer                   no-undo.
def var d_%store  as decimal               no-undo.
def var v-aadrate as decimal               no-undo.
def var v-aadpri  as decimal               no-undo.
def var d_rate    as decimal               no-undo.
def var d_store1  as decimal               no-undo.
def var d_sm1 as decimal                   no-undo.
def var d_sm2% as decimal                  no-undo.
def var d-rtocap as decimal                no-undo.
def var d-brate   as decimal decimals 2    no-undo.
def var v-com as logi                      no-undo.
def var ja as log format "да/нет"          no-undo.
def var vou-count as int initial 1         no-undo.
def var i as int                           no-undo.
def var v-tarif as decimal                 no-undo.
def var d_trdaydate as date                no-undo.



Function rDAY returns integer (input dt1 as date, input dt2 as date, input dt3 as date).
def var i as date.
def var f as integer.
do i = dt1 to dt3:
   if day(dt1) = 31 and  i >= dt2 then do:
     if lookup(string(month(i)),"3,5,10,12") <> 0 and day(i) = 1 then do:
        f = f + 1.
     end.
   end.
   if i >= dt2 and (day(dt1) = 30 or day(dt1) = 29) then do:
      if month(i) = 2 and day(i) = 28 then do: f = f + 1. end.
   end.
   if i >= dt2 and day(i) = day(dt1) then
   do:
      f = f + 1.
   end.
end.
   if f < 0 then f = 0.
   return f - 1.
End Function.


def var fizlgr as char init "202,204,222,208" no-undo.


def var seltxb as int.
seltxb = comm-cod().


find sysc where sysc.sysc = "FIZLGR" no-lock no-error.
if avail sysc then fizlgr = sysc.chval.

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

/*Синхронизация замороженных средств и основной суммы*/
find aaa where aaa.aaa = vaaa exclusive-lock no-error.
if avail aaa then do:
   find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 exclusive-lock no-error.
   if aaa.cbal - aaa.hbal = 0.01 or
      aaa.cbal - aaa.hbal = 0.02 or
      aaa.cbal - aaa.hbal = 0.03 or
      aaa.cbal - aaa.hbal = -0.01 or
      aaa.cbal - aaa.hbal = -0.02 or
      aaa.cbal - aaa.hbal = -0.03 then do:
          aaa.hbal = aaa.cbal.
          aas.chkamt = aaa.cbal.
      end.
end.


run check_ul(vaaa).
find aaa where aaa.aaa = vaaa no-lock no-error.
if not available aaa then do:
   message "Счет " vaaa " не существует" view-as alert-box title "".
   pause.
   next upper.
end.
find lgr where lgr.lgr = aaa.lgr no-lock.
if lgr.led <> "TDA" and lookup(lgr.lgr,fizlgr) = 0  then do:
   message "Счет не является счетом срочного депозита типа TDA."
           view-as alert-box title "".
   pause.
   next upper.
end.
if lookup(lgr.lgr,fizlgr) <> 0 then do:
   find aas where aas.aaa = aaa.aaa and aas.payee begins 'Неснижаемый остаток ОД' no-lock no-error.
   if not avail aas then do:
    message 'На счете нет неснижаемого остатка!' view-as alert-box.
    pause.
    next upper.
   end.
end.
if aaa.sta = "C" or aaa.sta = "E" then do:
   message "Закрытый счет" view-as alert-box title "".
   pause.
   next upper.
end.
find cif where cif.cif = aaa.cif no-lock no-error.
find crc where crc.crc = aaa.crc no-lock no-error.

hotkeys:
repeat:
run ShowInfo.
/*message "P-выплатить % в день начала депозита, C-закрыть депозит, T-история проводок,       H-история изменения % ставки, I-таблица % ставок, F4-выход".*/
message "C-закрыть депозит, T-история проводок, H-история изменения % ставки, I-таблица % ставок, L- Сумма при закрытии, F4-выход".
   readkey.
   if keyfunction(lastkey) = 'T' then do:
      if available aaa then run tdajlhist(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'H' then do:
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.
      if available aaa and (lgr.feensf <> 3 and lgr.feensf <>4 and lgr.feensf <> 5 and lgr.feensf <> 7) then run tdaaabhist(aaa.aaa).
      if available aaa and (lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 5 or lgr.feensf = 7) then run histrez(aaa.aaa).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'I' then do:
      if available aaa then run tdainthist(aaa.pri).
      readkey pause 0.
   end.
   else if keyfunction(lastkey) = 'L' then do:

        if lgr.feensf = 5  then do:
           run tda5(aaa.aaa).
        end.
        else
        do:
           message "" skip
           "Сумма депозита при досрочном закрытии на текущую дату" skip
           " составляет "   trim(string((aaa.cr[1] - aaa.dr[1])  + (aaa.cr[2] - aaa.dr[2])  ,'z,zzz,zzz,zz9.99-')) crc.code

            view-as alert-box  title "" .
        end.

      readkey pause 0.
   end.

   else if keyfunction(lastkey) = "C" then do:
      run savelog( "tdacls", aaa.aaa + " Закрытие депозита " + aaa.lgr + " статус " + aaa.sta).

      if aaa.sta = "E" then do:
         message "  Депозит уже закрыт  " view-as alert-box title "".
         next hotkeys.
      end.
      else do:
          def var vln as inte initial 7777777 no-undo.
          def var bal1 as decimal no-undo.
          def var v-day as integer no-undo.
          def var sum1 as decimal no-undo.
          def var v-rate as decimal no-undo.


           if lgr.feensf = 1  then do: /* Закрытие депозита "Метро-СТАНДАРТ" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose1").
               run tdaclose1(aaa.aaa).
           end.
           if lgr.feensf = 2  then do: /* Закрытие депозита "Метро-КЛАССИК" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose2").
               run tdaclose2(aaa.aaa).
           end.
           if lgr.feensf = 3  then do: /* Закрытие депозита "Метро-ЛЮКС" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose3").
               run tdaclose3(aaa.aaa).
           end.
           if lgr.feensf = 4  then do: /* Закрытие депозита "Метро-VIP" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose4").
               run tdaclose4(aaa.aaa).
           end.
           if lgr.feensf = 5  then do: /* Закрытие депозита "Метро-супер-люкс" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose5").
               run tdaclose5(aaa.aaa).
           end.
           if lgr.feensf = 7  then do: /* Закрытие депозита "Метро-детский" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose7").
               run tdaclose7(aaa.aaa).
           end.
           if lgr.feensf = 6  then do: /* Закрытие депозита "Метролюкс" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose6").
               run tdaclose6(aaa.aaa).
           end.
           if lookup(lgr.lgr, "A38,A39,A40") > 0   then do: /* Закрытие депозита "Метролюкс" */
               run savelog( "tdacls", aaa.aaa + " run tdaclose8").
               run tdaclose8(aaa.aaa).
           end.

      end.

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
                   /* s-jh = jh.jh.*/
                    do i = 1 to vou-count:
                        run x-jlvou.
                    end.

              end.  /* if vou-count > 0 */
        end. /* if ja */

       if not ja then  do:
        {mesg.i 0933} v-jh.   /* s-jh = jh.jh.*/ pause 5.

        end. /*  if not ja*/
        pause 0.

      end.  /* if available jl */
           else do:
                    message "Can't find transaction " v-jh view-as alert-box.
                    return.
                end.
    pause 0.
  end. /* do on endkey undo: */
end.  /*  if v-jh ne 0 then do : */

/*voucher printing nataly--------------------*/


      clear frame tda0.
      clear frame tda1.
      clear frame tda2.
      leave hotkeys.
  end.
   else if keyfunction(lastkey) = 'end-error' then do:
      leave hotkeys.
   end.
end.

end.



Procedure ShowInfo.

if aaa.cr[1] > 0 then vopnamt = aaa.opnamt.
else vopnamt = 0.
find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
if available aas then currentbase = aas.chkamt.
else currentbase = 0.
capitalized = aaa.stmgbal.
adddepos = currentbase - vopnamt - capitalized.



/*message currentbase  vopnamt  capitalized. pause 444. */


if adddepos < 0 then adddepos = 0.
if lgr.feensf <> 3 and lgr.feensf <> 4 and lgr.feensf <> 2 then do:
 intavail = aaa.cr[1] - aaa.dr[1] - currentbase.
 intpaid = aaa.dr[2] - intavail - capitalized.
  if intpaid < 0 then do:
     intpaid = aaa.dr[1].
  end.

end.
else do: /* для депозитов типа резервный */
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
