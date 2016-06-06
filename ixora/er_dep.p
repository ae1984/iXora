/* er_bd.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по кредитам БД
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
 * BASES
        BANK COMM
 * AUTHOR
        17/01/2007 madiyar
 * BASES
        bank, comm
 * CHANGES
        19/09/2007 madiyar
        17/01/11 evseev - 518,519,520 *Недропользователь*
        01/06/2011 evseev - исправил EUR с 11 на 3
        10.06.2013 evseev - tz-1845
*/

{mainhead.i}

def var v-sum as deci no-undo.
def var v-srok as integer no-undo.
def var v-rate as deci no-undo.
def var v-rdt as date no-undo.
def var v-pdt as date no-undo.
def var v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def var v-komv as deci no-undo. /* комиссия за ведение счета */
def var v-komr as deci no-undo. /* комиссия за рассмотрение заявки */
def var v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.
def var v-lgr like lgr.lgr no-undo.
def var v-val as char.
def var v-stf as integer.

 run sel2 (" Параметры ", " 1. Посчитать эффективную ставку | 2. Изменить эффективную ставку у счета | ВЫХОД", output v-stf).
 if v-stf = 2 then do:
    def var n-aaan like aaa.aaa.
    update n-aaan label "Номер счета" with centered overlay color message row 5 frame f-aaa.
    hide frame f-aaa.

    find last aaa where aaa.aaa = n-aaan no-lock no-error.
    if avail aaa then do:
       find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
       if avail acvolt then do:
          update acvolt.x2 label "Введите эффективную ставку" with centered overlay color message row 5 frame f-aab.
          hide frame f-aab.
          message "Ставка успешно изменена" . pause.
       end.
       else do:
           message "Счета не сушествует возможно он открыт на другой базе или не является депозитом" . pause.
       end.
    end.
    else do:
       message "Счета не сушествует возможно он открыт на другой базе" . pause.
    end.
 end.

 if v-stf = 2 or v-stf = 3  then do:
    return.
 end.


form
  skip(1)
  v-sum  label "Сумма депозита..........." format ">,>>>,>>9.99" /*validate (v-sum > 0 and v-sum <= 3000000, " Сумма должна быть больше 0 и меньше 3,000,000 ! ") " тенге " */   skip
  v-lgr  label "Группа депозита.........." skip
  v-rdt label  "Дата открытия............" skip
  v-srok label "Срок депозита............" /*validate (v-srok >= 6 and v-srok <= 36, " Срок должен быть от 6 до 36 месяцев ! ") */ skip


  v-rate label "Ставка вознаграждения...." validate (v-rate >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip

  v-pdt label  "Дата первой выплаты......" /*validate (v-pdt > v-rdt and v-pdt - v-rdt < 50, " Некорректная дата первого погашения ! ")*/   skip
/*  v-komf label "Комиссия - фонд.........." format ">,>>>,>>9.99" help " Комиссия за оформление кредитной документации " skip
  v-komv label "Комиссия - обслуж. счета." format ">,>>>,>>9.99" help " Комиссия за ведение текущего счета " " (ежемесячно) " skip
  v-komr label "Комиссия - рассм.заявки.." format ">,>>>,>>9.99" help " Комиссия за рассмотрение заявки " skip  */
  skip(1)
  v-er label "Эффективная ставка......." format ">,>>>,>>9.99"  " % годовых " skip(1)
with centered side-label column 1 row 5 title " Расчет эффективной ставки (БД) " frame erf.



{er.i}



/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

repeat:
    assign
        v-sum = 0
        v-srok = 0
        v-rate = 0
        v-rdt = g-today
        v-pdt = get-date(v-rdt,1)
        v-komf = 0
        v-komv = 0
        v-komr = 0.

    for each b2cl: delete b2cl. end.
    for each cl2b: delete cl2b. end.

    displ v-sum v-srok v-lgr v-rate v-rdt v-pdt /* v-komf v-komv v-komr */ with frame erf.

    update v-sum with frame erf.
/*  v-komf = round(v-sum * 0.07,2).
    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "bdacc" no-lock no-error.
    if avail pksysc then v-komv = round(v-sum * pksysc.deval / 100,2). else v-komv = 0.
    displ v-komf v-komv with frame erf. */



    update v-lgr with frame erf.

find last lgr where lgr.lgr = v-lgr no-lock no-error.
if not avail lgr then do:
   message "Введенной вами группы не существует".
   return.
end.


    update v-rdt with  frame erf.

    update v-srok with frame erf.
if lgr.led = "TDA" then do:
   run tdagetrate("", lgr.pri, v-srok, v-rdt, v-sum, output v-rate).
end.
else do:


      if lgr.crc = 1 then  v-val = "KZT" .
      if lgr.crc = 2 then  v-val = "USD" .
      if lgr.crc = 3 then v-val = "EUR" .


      /*Срочный*/
      if lookup(lgr.lgr,"478,479,480,481,482,483") <> 0 then do:
         find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "SR"  no-lock no-error.
         v-rate = rtur.rate.
      end.
      /*Накопительный*/
      if lookup(lgr.lgr,"484,485,486,487,488,489") <> 0 then do:
         find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "NK"  no-lock no-error.
         v-rate = rtur.rate.
      end.
      /*Недропользователь*/
      if lookup(lgr.lgr,"518,519,520") <> 0 then do:
         run tdagetrate("", lgr.pri, v-srok, v-rdt, v-sum, output v-rate).
      end.

      if lookup(lgr.lgr,"484,485,486,487,488,489") <> 0 then do:
         find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "NK"  no-lock no-error.
         v-rate = rtur.rate.
      end.

    if lookup(lgr.lgr,"B01,B02,B03,B04,B05,B06") <> 0 then do:
       find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "ForteProfitable"  no-lock no-error.
       v-rate = rtur.rate.
    end.
    if lookup(lgr.lgr,"B07,B08") <> 0 then do:
       find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "ForteProfitable1"  no-lock no-error.
       v-rate = rtur.rate.
    end.
    if lookup(lgr.lgr,"B09,B10,B11") <> 0 then do:
       find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "ForteUniversal"  no-lock no-error.
       v-rate = rtur.rate.
    end.
    if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") <> 0 then do:
       find last rtur where rtur.cod = v-val and rtur.trm = v-srok and rtur.rem = "ForteMaximum"  no-lock no-error.
       v-rate = rtur.rate.
    end.

end.


    update v-rate with frame erf.

    update v-pdt with  frame erf.

/*  update v-komf with frame erf.
    update v-komv with frame erf.
    update v-komr with frame erf. */


    /* расчет */

    run er_depf(v-lgr, v-sum,v-srok,v-rate,v-rdt,v-pdt,v-komf,v-komv,v-komr,output v-er).

    displ v-er with frame erf.

    v-ok = no.
    message "Повторить расчет? (y/n) " update v-ok.
    if not v-ok then leave.

end. /* repeat */


hide message no-pause.
















Procedure Ptdagetrate.

def input parameter vaaa as char.
def input parameter vpri as char format "x(3)".
def input parameter vterm as inte.
def input parameter vuntil as date.
def input parameter vamt like jl.dam.
def output parameter vrate like aaa.rate.

def var highamount like jl.dam initial 999999999.99.
def var lowlowvalue as inte initial 0.
def var lowvalue as inte initial 1.
def var highhighvalue as inte initial 100.
def var highvalue as inte initial 99.
def var highterm as inte.
def var lowterm as inte.
def var cpri as char.
def var v-inc as inte.
def var v-min like jl.dam.
def var v-max like jl.dam.

/*
find first aaa where aaa.aaa = vaaa no-lock no-error.
if avail aaa and aaa.payfre = 1 then do:
  vrate = aaa.rate.
  return.
end.
*/

if vamt > highamount then vamt = highamount.
if vterm < lowvalue then vterm = lowvalue.
if vterm > highvalue then vterm = highvalue.

highterm = highhighvalue.

for each pri where pri.pri begins "^" + vpri no-lock group by pri.pri desc:
   lowterm = integer(substring(pri.pri,5,2)).
   if vterm > lowterm and vterm <= highterm then leave.
   highterm = lowterm.
end.
if lowterm  = lowlowvalue and highterm = highhighvalue then do:
   find last prih where prih.pri = pri.pri and prih.until = vuntil
                        no-lock no-error.
   if available prih then vrate = prih.rat.
   else vrate = pri.rate.
   return.
end.
else if highterm = highhighvalue
then cpri = "^" + string(vpri,"x(3)") + string(highvalue,"99").
else cpri = "^" + string(vpri,"x(3)") + string(highterm,"99").

find pri where pri.pri = cpri no-lock no-error.
if not available pri then  return.
find last prih where prih.pri = pri.pri and prih.until <= vuntil
                     no-lock no-error.
if available prih then do:
  repeat v-inc = 6 to 1 by -1:
     v-max = prih.tlimit[v-inc].
     if v-inc gt 1 then v-min = prih.tlimit[v-inc - 1].
     else v-min = 0.
     if vamt > v-min and vamt <= v-max then do:
        vrate = prih.trate[v-inc].
        leave.
     end.
  end.
end.
else do:
  repeat v-inc = 6 to 1 by -1:
     v-max = pri.tlimit[v-inc].
     if v-inc gt 1 then v-min = pri.tlimit[v-inc - 1].
     else v-min = 0.
     if vamt > v-min and vamt <= v-max then do:
        vrate = pri.trate[v-inc].
        leave.
     end.
  end.
end.
end.







