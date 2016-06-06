/* compens.p
 * MODULE

 * DESCRIPTION
        Начисление вознаграждения по счетам клиентов
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
        BANK
 * AUTHOR
        20/08/08 id00205
 * CHANGES
        18/09/08 id00205           Убрал удержание подоходного налога
        28/10/2008                 Перенос в WIN кодировку
        30/10/2008 id00205         Добавил таблицу compens_data для хранения параметров начисления процентов
        05/01/2009 id00205         Изменил today на s-target
        20/01/2009 id00205         Когда баланс меньше минимальной суммы = сохраненный остаток  = 0
        21/01/2009 id00205         Добавил выплату с удержанием налога для валютных счетов
        17/03/2009 id00205         Добавил в таблицу compens сохранение текущей процентной ставки
        03/04/2009 id00205         Добавил получателей сообщений
        03/04/2009 id00205         Добавил хранение в справочнике арп счета для зачисления подоходного налога
                                   Изменил шаблон DCL0014 добавил шаблон DCL0015
        20.07.2012 evseev ТЗ-1280
        11.01.2013 evseev - устранил ошибку. письмо от 10/01/13
        29.03.2013 evseev tz1780
        07.08.2013 evseev - tz-1834
        12.08.2013 evseev - tz-1836
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит
*/

 {global.i}

define shared var s-target as date.
define shared var s-bday as log.

/*******************************************************************************/
def var curr-acc as char format "X(10)".            /* иик клиента*/
def var sutrax as decimal init  15.0.               /* процент подоходного налога*/
def var pay-sutrax as logical init Yes.             /* Удерживать подоходный налог */
def var cap-pay as logical init Yes.                /* Капитализировать выплату */
def var annual as decimal init 0.                   /* процент годового вознаграждения*/
def var acc-list as char.                           /* Список ИИК */
def var acc-index as int init 1.                    /* Индекс текущего ИИК */
def var pay-day as int init 0.                      /* День выплаты */
def var sum-pay as decimal decimals 2 init 0.       /* Общая сумма выплат (для не капитализируемых)*/
/*def var pay-dates as char. */                         /* Даты выплат */
def var acc-pay as char .                           /* счет выплаты*/
/*******************************************************************************/
def var balans as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-".  /*Остаток на счете*/
def var day-sum as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-". /*Сумма вознаграждения День*/
def var day-sum1 as decimal decimals 10 format "z,zzz,zzz,zzz,zz9.9999999999-". /*Сумма вознаграждения День с точностью 10 знаков*/
def var sut-sum as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-". /*Расчетная сумма подоходного налога*/
def var rest as decimal decimals 10 format "z,zzz,zzz,zzz,zz9.9999999999-". /*Сохраняемый остаток  с точностью 10 знаков*/
def var days as int init 0. /*Разница в днях между текущей и операционной датой*/
def var min-sum as decimal decimals 2 init 0. /* Минимальный остаток для начисления процентов*/
def var pay-bal as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-".  /*сумма на втором уровне при выплате*/
def var old-bal as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-".  /*баланс на предыдущий день*/
def var vdel   as char init "^".
def var vparam as char.
def var v-jh  as int.
def var rcode  as int.
def var rdes   as char.
def var real-day as date.
def var MESS as char.
def var days_in_month as int.

def var v-tempstr as char.
def var v-day as int.
def var v-day1 as int.
def var v-month as int.
def var v-year as int.
def var v-i as int.
def var v-date as date.
def var i as int.
def var str as char.

def temp-table t-dates field dt as date.

function GetDaysOfMonth returns integer (input  mm as inte, input  yy as inte).
    /*if      mm = 0  then return 28.
    else*/ if mm = 1  then return 31.
    else if mm = 2  then do: if yy <> 0 then do: if round((yy - 1900) / 4 , 0) = (yy - 1900) / 4 then return 29. else return 28. end. end.
    else if mm = 3  then return 31.
    else if mm = 4  then return 30.
    else if mm = 5  then return 31.
    else if mm = 6  then return 30.
    else if mm = 7  then return 31.
    else if mm = 8  then return 31.
    else if mm = 9  then return 30.
    else if mm = 10 then return 31.
    else if mm = 11 then return 30.
    else if mm = 12 then return 31.
end function.

def var arp-tax as char. /* Арп счет для зачисления подоходного налога (в каждом филиале свой )*/
def var pmail as char.   /* получатели логов работы */
pmail = "id00024@metrocombank.kz;id00363@metrocombank.kz;id00205@metrocombank.kz;id00787@metrocombank.kz".


def buffer b-aaa for aaa.
def buffer b-compens_data for compens_data.

find first sysc where sysc.sysc = "vip-com" no-lock no-error.
if avail sysc then acc-list = sysc.chval.
if acc-list = "" then return.

find first sysc where sysc.sysc = "tax-com" no-lock no-error.
if avail sysc then arp-tax = sysc.chval.
if arp-tax = "" then do: run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", "Нет записи tax-com в таблице sysc!" , "", "",""). return. end.



DO acc-index = 1 to NUM-ENTRIES(acc-list,",").
   curr-acc = ENTRY(acc-index,acc-list).
   find first compens_data where compens_data.acc = curr-acc no-lock NO-ERROR.
   if avail(compens_data)then  do:
      /* Заполняем переменные для вычисления */
      annual  = compens_data.rate.    /* Годовой процент */
      pay-day = compens_data.payday.  /* День выплаты */
      pay-sutrax = compens_data.tax.  /* Удерживать подоходный налог Да - Нет */
      min-sum = compens_data.minbal.  /* Минимальный остаток на счете */
      cap-pay = compens_data.cappay.  /* Капитализировать выплату Да - Нет */
      sum-pay = compens_data.sumpay.  /* Сумма выплат */
      acc-pay = compens_data.accpay.  /* счет выплаты*/
      /*pay-dates = compens_data.paydates.*/ /* Даты выплат */
      old-bal = 0.  /* Баланс на предыдущий день*/
      empty temp-table t-dates.

      days = s-target - g-today.
      if days = 0 then do:
          MESS = "s-target = g-today Ошибка в базе! ".
          run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
          return.
      end.
      real-day = g-today.
      DO i = 1 to days:
          do v-i = 1 to num-entries(compens_data.paydates, ";"):
                str = entry(v-i,compens_data.paydates,";").
                v-day = 0. v-month = 0. v-year = 0.
                v-tempstr = "err". v-tempstr = entry(1,str,".") no-error.
                if v-tempstr <> "err" then v-day = int(v-tempstr) no-error.
                if not(v-day >= 1 and v-day <= 31) or v-tempstr = "err" then do:
                   run savelog ("compens", "112. " + curr-acc + " Неверно указан день! " + v-tempstr).
                   next.
                end.
                v-tempstr = "err". v-tempstr = entry(2,str,".") no-error.
                if v-tempstr <> "err" then v-month = int(v-tempstr) no-error.
                if not(v-month >= 1 and v-month <= 12) and v-tempstr <> "err" then do:
                   run savelog ("compens", "118. " + curr-acc + " Неверно указан месяц " + v-tempstr).
                   next.
                end.
                v-tempstr = "err". v-tempstr = entry(3,str,".") no-error.
                if v-tempstr <> "err" then v-year = int(v-tempstr) no-error.
                if not(v-year >= 2012 and v-year <= 2100) and v-tempstr <> "err" then do:
                   run savelog ("compens", "124. " + curr-acc + " Неверно указан год! " + v-tempstr).
                   next.
                end.
                if v-year = 0 then v-year = year(real-day).
                if v-month = 0 then v-month = month(real-day).
                if v-day > GetDaysOfMonth(v-month,v-year) then do:
                   v-day1 = v-day.
                   v-day = GetDaysOfMonth(v-month,v-year).
                   run savelog ("compens", "128. " + curr-acc + " Неверно указан день! Изменение " + string (v-day1) + " на " + string(v-day)).
                end.

                if v-day <> 0 and v-month <> 0 and v-year <> 0 then do:
                   find first t-dates where t-dates.dt = date(string(v-day) + "." + string(v-month) + "." + string(v-year)) no-error.
                   if not avail t-dates then do:
                      create t-dates.  t-dates.dt = date(string(v-day) + "." + string(v-month) + "." + string(v-year)).
                      run savelog ("compens", "168. " + curr-acc + " " + string(date(string(v-day) + "." + string(v-month) + "." + string(v-year)))).
                   end.
                end. else do:
                   run savelog ("compens", "170. " + curr-acc + " Дата не была добавлена!").
                end.
          end.
          real-day = real-day + 1.
      end.

      find first aaa where aaa.aaa = curr-acc no-lock NO-ERROR.
      if avail(aaa)then do:
          /**************************************/
         if min-sum = 0 then min-sum = sum-pay.
         balans = aaa.cr[1] - aaa.dr[1].
         if balans >= min-sum then do:
              days = s-target - g-today.
              if days = 0 then do:
                  MESS = "s-target = g-today Ошибка в базе! ".
                  run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
                  return.
              end.
              real-day = g-today.

              DO i = 1 to days:
                   find first compens where compens.acc = curr-acc and compens.pay-date = real-day  no-lock NO-ERROR.
                   if not avail(compens)then do:
                        rest = aaa.m10.
                        /************* Проверка соответствия сохраненного остатка (для теста )  **************************************************/
                        find last compens where compens.acc = curr-acc and compens.pay-date < real-day  no-lock NO-ERROR.
                        if avail(compens) then do:
                           if compens.rest <> rest then do:
                              MESS = "Сохраненный остаток :" + string( aaa.m10 ) + " не соответствует остатку в темп таблице : " + string( compens.rest ).
                              /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
                              run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
                           end.
                        end.
                        /***************************************************************************************************************************/
                        if length(trim(acc-pay)) = 20  then do:
                           /* Выплата на другой счет */
                           balans = aaa.cr[1] - aaa.dr[1] - compens_data.sumpay.
                        end. else do:
                            if cap-pay = No then do:
                               /* Без капитализации */
                               sum-pay = compens_data.sumpay.
                               old-bal = 0.
                               run lonbalcrc('cif',aaa.aaa,g-today,"1",no,aaa.crc,output old-bal).
                               old-bal = - old-bal.
                               balans = aaa.cr[1] - aaa.dr[1].
                               /* Определить не снимались ли деньги со счета, при необходимости откорректировать sum-pay */
                               if balans < old-bal then do:
                                  sum-pay = ( sum-pay - ( old-bal - balans )).
                                  if sum-pay < 0 then sum-pay = 0.
                                  do transaction:
                                     find first b-compens_data where b-compens_data.acc = compens_data.acc exclusive-lock no-error.
                                     if avail b-compens_data then b-compens_data.sumpay = sum-pay.
                                     find current  b-compens_data no-lock.
                                  end. /* transaction */
                               end.
                               balans = balans - sum-pay.
                            end. else do:
                               /* С капитализацией */
                               balans = aaa.cr[1] - aaa.dr[1].
                            end.
                        end.
                        /***************************************************************************************************************************/
                        for each t-dates:
                            if t-dates.dt = real-day then do:
                               run PayDay.
                               if rcode = 0 and pay-bal > 0 then do:
                                  MESS = "Для ИИК: " + curr-acc + " произведена выплата вознаграждения " + string( v-jh ) + " в сумме " + string( pay-bal ).
                                  run mail(pmail, "<bankadm@metrocombank.kz>", "Выплата", MESS , "", "","").
                               end.
                            end.
                        end.


                        day-sum1 =  TRUNCATE((( balans * annual / 100 ) / 365) + rest , 10 ).
                        day-sum =   TRUNCATE( day-sum1 , 2).
                        rest = day-sum1 - day-sum.
                        run CapDay(day-sum).
                        if rcode = 0 then do:
                           do transaction:
                              find first b-aaa where b-aaa.aaa = aaa.aaa exclusive-lock no-error.
                              if avail b-aaa then b-aaa.m10 = rest.
                              find current b-aaa no-lock.
                           end. /* transaction */
                           run WrTest.
                           MESS = "Для ИИК: " + curr-acc + " произведено накопление вознаграждения - " + string( v-jh ) + " в сумме " + string( day-sum ).
                           run mail(pmail, "<bankadm@metrocombank.kz>", "OK Message", MESS , "", "","").
                           run mondays(month(real-day), year(real-day),output days_in_month).
                           /*if month( real-day ) = 2 and day( real-day ) = 28 and month( real-day + 1) = 3 and pay-day = 29  or day( real-day ) = pay-day then */
                           /*if day( real-day ) = pay-day or ( pay-day > days_in_month and day( real-day ) = days_in_month ) then do:
                              run PayDay.
                              if rcode = 0 then do:
                                 MESS = "Для ИИК: " + curr-acc + " произведена выплата вознаграждения " + string( v-jh ) + " в сумме " + string( pay-bal ).
                                 run mail(pmail, "<bankadm@metrocombank.kz>", "Выплата", MESS , "", "","").
                              end.
                           end.*/
                        end.
                        /***************************************************************************************************************************/
                   end. else do:
                        MESS = "Для ИИК: " + curr-acc + " на дату <" + string( real-day ) + "> расчет проводился!".
                        /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
                        run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
                   end.
                   real-day = real-day + 1.
              END.
         end. else do:
              do transaction:
                   find first b-compens_data where b-compens_data.acc = compens_data.acc exclusive-lock no-error.
                   if avail b-compens_data then b-compens_data.sumpay = 0.
                   find current  b-compens_data no-lock.
              end. /* transaction */
              MESS = "Сумма на счете :" + curr-acc + " меньше минимальной, начисление процентов не производится!".
              /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
              run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
         end.
      end. else do:
          MESS = "ИИК: " + curr-acc + " не найден!".
          /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
          run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
      end.
   end. else do:
       MESS = "ИИК: " + curr-acc + " не найден, данные в справочнике vip-com не соответствуют данным в таблице compens_data".
         /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
       run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
   end.
END.

/****************************************Ежедневное накопление % ***********************************/
Procedure CapDay.
    def input param sum as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-".
    /*vparam = string(sum) + vdel + aaa.aaa. */
    if aaa.crc = 1 then vparam = string(sum) + vdel + aaa.aaa + vdel + "0" + vdel + aaa.aaa.
    else do:
        find first crc where crc.crc = aaa.crc no-lock.
        vparam = "0" + vdel + aaa.aaa + vdel + string(sum * crc.rate[1])+ vdel + aaa.aaa + vdel.
    end.
    v-jh = 0.
    run trxgen("CDA0007", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
    if rcode ne 0 then do:
       run savelog ("compens", "Не удалось сформировать проводку накопления % для : " + aaa.aaa + " в сумме : " + string( sum ) + " -> " + rdes + "Проводка :" + string( v-jh )).
       MESS = "Не удалось сформировать проводку накопления % для : " + aaa.aaa + " в сумме : " + string( sum ) + " -> " + rdes + "Проводка :" + string( v-jh ).
       /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
       run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
    end. else do:
       run CheckDay.
       run trxsts(v-jh, 6, output rcode, output rdes).
       if rcode ne 0 then do:
       run savelog ("compens", "Не удалось отштамповать проводку накопления % для : " + aaa.aaa + " в сумме : " + string( sum ) + " -> " + rdes + "Проводка :" + string( v-jh )).
         MESS =  "Не удалось отштамповать проводку накопления % для : " + aaa.aaa + " в сумме : " +  string( sum ) + " -> " +  rdes + "Проводка :" + string( v-jh ).
        /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
        run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
       end.
    end.

end procedure.
/****************************************Ежемесячная выплата *********************************/
Procedure PayDay.
   /* def var pay-bal as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-". */
    pay-bal = aaa.cr[2] - aaa.dr[2].
    run savelog('compens','321. ' + string(aaa.aaa) + ' ' + string(pay-bal) ).
    if pay-bal <= 0 then return.
    sut-sum = 0.
    if pay-sutrax = Yes then do:
       /* С удержанием подоходного налога */
       /* arp-tax  арп счет для подоходного налога*/
       sut-sum = ( pay-bal * sutrax ) / 100.
       if aaa.crc = 1 then do:
          /*Для теньговых*/
          /*vparam = string(pay-bal) + vdel + aaa.aaa + vdel + aaa.aaa + vdel + string ( sut-sum ) + vdel + aaa.aaa.*/
          vparam = string(pay-bal) + vdel + aaa.aaa + vdel + string ( sut-sum ) + vdel + arp-tax.
          v-jh = 0.
          /*run trxgen("DCL0012", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).*/
          run trxgen("DCL0015", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
       end. else do:
           /*Для валютных*/
           vparam = string(pay-bal) + vdel + aaa.aaa + vdel + string ( sut-sum ) + vdel + arp-tax.
           v-jh = 0.
           run trxgen("DCL0014", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
       end.
    end. else do:
       /* Без удержания налога  */
       vparam = string(pay-bal) + vdel + aaa.aaa.
       v-jh = 0.
       run trxgen("DCL0013", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
    end.
    run savelog('compens','340. ' + string(v-jh) + ' ' + rdes ).
    /* Расчет новой общей суммы выплат для некапитализируемых*/
    if rcode = 0 and cap-pay = No and length(trim(acc-pay)) <> 20 then do:
       do transaction:
         find first b-compens_data where b-compens_data.acc = compens_data.acc exclusive-lock no-error.
         if avail b-compens_data then b-compens_data.sumpay = sum-pay +  ( pay-bal - sut-sum ) .
         find current  b-compens_data no-lock.
       end. /* transaction */
    end.
    /* b-compens_data.sumpay = sum-pay +  ( pay-bal - sut-sum ) .  b-compens_data.sumpay = sum-pay +  pay-bal. */
    if rcode ne 0 then do:
       MESS = "Не удалось сформировать проводку для : " + aaa.aaa + " в сумме : " + string( pay-bal ) + " -> " + rdes  + "Проводка :" + string( v-jh ).
       /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
       run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
    end. else do:
       run CheckDay.
       run trxsts(v-jh, 6, output rcode, output rdes).
       run savelog('compens','357. '  + rdes ).
       if rcode ne 0 then do:
          MESS =  "Не удалось отштамповать проводку для : " + aaa.aaa + " в сумме : " +  string( pay-bal ) + " -> " +  rdes  + "Проводка :" + string( v-jh ).
          /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
          run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
       end.
    end.


    if length(trim(acc-pay)) = 20  then do:
        /*run tdaremhold("KZ74470272240A205208",pay-bal - sut-sum).*/
        find last jl where jl.acc = aaa.aaa and jl.rem[1] matches "*Выплата процентов*" and jl.jdt < g-today no-lock no-error.
        if not avail jl then find last jl where jl.acc = aaa.aaa and jl.rem[1] matches "*Выплата вознаграждения*" and jl.jdt < g-today no-lock no-error.
        if avail jl then  v-date = jl.jdt.
        else do:
           find first histrxbal  where histrxbal.sub = 'cif' and  histrxbal.acc = aaa.aaa and histrxbal.lev = 2 no-lock no-error.
           v-date = histrxbal.dt.
        end.

        vparam = string(pay-bal - sut-sum) + vdel +
                 "1" + vdel +
                 aaa.aaa + vdel +
                 "1" + vdel +
                 trim(acc-pay) + vdel +
                 "Выплата вознаграждения с " + string(v-date,'99/99/9999') + " по " + string(g-today,'99/99/9999').
        v-jh = 0.
        run trxgen("vnb0069", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
        run savelog('compens','376. ' + string(v-jh) + ' ' + rdes ).
        if rcode ne 0 then do:
           MESS = "Не удалось сформировать проводку для : " + aaa.aaa + " в сумме : " + string( pay-bal - sut-sum ) + " -> " + rdes  + "Проводка :" + string( v-jh ).
           /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
           run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
        end. else do:
           run CheckDay.
           run trxsts(v-jh, 6, output rcode, output rdes).
           run savelog('compens','384. ' + rdes ).
           if rcode ne 0 then do:
              MESS =  "Не удалось отштамповать проводку для : " + aaa.aaa + " в сумме : " +  string( pay-bal - sut-sum ) + " -> " +  rdes  + "Проводка :" + string( v-jh ).
              /*MESSAGE MESS VIEW-AS ALERT-BOX.*/
              run mail(pmail, "<bankadm@metrocombank.kz>", "Error Message", MESS , "", "","").
           end.
        end.
    end.


end procedure.
/*****************************************************************************************************/
procedure WrTest.
   def var curr-bal as decimal decimals 2 format "z,zzz,zzz,zzz,zz9.99-".
   curr-bal = aaa.cr[1] - aaa.dr[1].
   create compens.
         compens.acc = curr-acc.
         compens.pay-date = real-day.
         compens.bal = curr-bal. /*balans.*/
         compens.rest = rest.
         compens.pay = day-sum.
         compens.v-jh = v-jh.
         compens.rate = annual.
end procedure.
/*****************************************************************************************************/
procedure CheckDay.
  if not s-bday then do:
     find jh where jh.jh = v-jh exclusive-lock no-error.
     if avail jh then do:
        jh.jdt = s-target.
        for each jl where jl.jh = jh.jh exclusive-lock:
           jl.jdt = jh.jdt.
        end.
     end.
     find current jh no-lock.
  end.
end procedure.

