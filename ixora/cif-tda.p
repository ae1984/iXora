/* cif-tda.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        10.05.2004 nadejda - добавила присваивание aaa.nextint = aaa.lstmdt после проставления aaa.lstmdt
        20.05.2004 nadejda - добавлена информация, является ли счет исключением по % ставке
                             добавлен параметр номера счета в вызов tdagetrate
        21.06.2004 nadejda - добавлена переменная v-rate
        28.06.2004 nadejda - установка искл. % ставки перенсена в cif-tda%.p, здесь запрещена
        01.07.2004 dpuchkov - добавил привязку по VIP депозитам
        10.04.2006 dpuchkov - добавил условие по депозитам(белая и красная)
        12.03.2008 id00004 - условия по депозитам Метро
        15/04/2009 galina - для 20-ти значных счетов открытых до 02/11/09 копируем условия с 9-тизначного д/с
        17.04.2009 galina - изменения для открытия 20-тизначных счетов, соотвествующих 9-тизначным
        02/11/2009 galina - убрала услови на 02 ноября 2009 для 20_тизначных счетов
        02.04.2010 id00004 - исключил сроки размещения 18 и 24 мес для депозитов МетроЛюкс, МетроVIP, Пенсионный
        08.06.10 - переход на iban
        25.05.2011 evseev - создать запись, если lgr.feensf = 6
        15.05.2013 evseev - tz-1828
*/

/* cif-tda.p
   Creates/updates TDA account.
*/

{global.i}

def shared var s-aaa like aaa.aaa.

def var vdaytm as int             no-undo.
def var vdays as int              no-undo.
def var mbal like aaa.opnamt      no-undo.
def var vans as log initial false no-undo.
def var termdays as inte          no-undo.
def var v-rate like aaa.rate      no-undo.  /* ставка на группе на текущий момент */
def var v-tl as decimal init 0    no-undo.
def shared var v-aaa9 as char.
def buffer b-aaa for aaa.



{cif-tda.f}

define buffer sysc-star   for sysc.
define buffer sysc-zvezda for sysc.
define buffer sysc-juldiz for sysc.
define buffer baaak for aaa.
find last sysc-star   where sysc-star.sysc   = "STAR"   no-lock no-error.
find last sysc-zvezda where sysc-zvezda.sysc = "ZVEZDA" no-lock no-error.
find last sysc-juldiz where sysc-juldiz.sysc = "JULDIZ" no-lock no-error.
on help of aaa.pri in frame aaa do:
   run tdaint-help1.
end.


find aaa where aaa.aaa eq s-aaa exclusive-lock.
find lgr where lgr.lgr = aaa.lgr no-lock.
if not available aaa then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.

aaa.lstmdt = aaa.regdt.
aaa.expdt = aaa.regdt.
aaa.nextint = aaa.regdt.

if aaa.payfre = 1 then v-excl = yes.
d-effect =  0.

  display aaa.aaa aaa.cla aaa.lstmdt aaa.expdt aaa.pri
       aaa.rate aaa.opnamt mbal v-excl d-effect with frame aaa.


/*Проверка периода*/
repeat:

     update aaa.cla aaa.lstmdt with frame aaa.

   if lgr.feensf = 3 or lgr.feensf = 4 then do:
      if  aaa.cla <> 37 then do:
         message "Данный период не предусмотрен условиями депозита". pause.
      end.
      else leave.
   end.
   else
   if lgr.feensf = 5 then do:
      if aaa.cla <> 37 then do:
         message "Данный период не предусмотрен условиями депозита". pause.
      end.
      else leave.
   end.
   else
     leave.
end.





run EvaluateExpiryDate.
termdays = aaa.expdt - aaa.lstmdt + 1.

 display aaa.expdt termdays with frame aaa.
 update aaa.opnamt with frame aaa.

aaa.nextint = aaa.lstmdt.


if lgr.feensf = 7 then do: /*по депозиту метрошка не заполняем */
   run tdagetrate(aaa.aaa, aaa.pri, "18", aaa.nextint, aaa.opnamt, output aaa.rate).
end.
else do:

   run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output aaa.rate).
end.
mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).




  if lgr.feensf = 9 then do:
     def var d_koef as decimal.
     def var x1 as decimal init 0.
     def var x2 as decimal init 0.
     def var x3 as decimal init 0.
     def var x4 as decimal init 0.
     def var prd as integer init 0.
     def var vl as integer init 0.
     def var acct as char.

     if avail sysc-star and lookup(lgr.lgr, sysc-zvezda.chval) <> 0 then do: /*ZVEZDA белая*/
        define frame frt1
               x1  format "9" label "Частичные изъятия?          " validate(x1 = 1 or x1 = 2 or x1 = 3, "Сделайте правильный выбор") skip
               x2  format "9" label  "Автоматическая пролонгация? " validate(x2 = 1 or x2 = 2 or x2 = 3, "Сделайте правильный выбор") skip
               prd format "99" label "Период пролонгации          " validate(prd > 5 and prd < 61 , "Данный период недопустим") skip
               x3  format "9" label "Дополнительные взносы?      " validate(x3 = 1 or x3 = 2 or x3 = 3, "Сделайте правильный выбор") skip
               x4  format "9" label "Бонус?                      " validate(x4 = 1 or x4 = 2 or x4 = 3, "Сделайте правильный выбор")
        with side-labels centered row 8 title "".
        message "1-ДА   2-НЕТ   3-КЛИЕНТ НЕ ВЫБРАЛ".
        update x1  with frame frt1.
        message "1-На любой срок(по выбору). 2-на соотв. депозиту срок  3-не выбрал ".
        update  x2  with frame frt1.

        if x2 = 1 then do: update prd with frame frt1. end.
        if x2 = 2 then do: prd = aaa.cla. displ prd with frame frt1. end.
        if x2 = 3 then do: prd = 0. displ prd with frame frt1. end.
        message "1-ДА   2-НЕТ   3-КЛИЕНТ НЕ ВЫБРАЛ".
        update x3 with frame frt1.
        message "1-0.5% от осн суммы. 2-фиксированн % на 18 мес. 3-не выбрал ".
        update x4 with frame frt1.

 message "1-выплата на текущий или карт счет. 2-выплата наличными.".
 define frame frtn12
    v-tl  format "9" label "Выплата процентов" validate(v-tl = 1 or v-tl = 2, "Сделайте правильный выбор") with side-labels centered row 8 title "".
 update v-tl  with frame frtn12.
 if v-tl = 1 then do:
    define frame frtn1
    vl   format "9"     label "Выплата процентов" validate(vl = 1 or vl = 2, "Сделайте правильный выбор") skip
    acct format "x(15)" label "Текущий/Карт счет" with side-labels centered row 8 title "1-Текущий 2-КАРТ-СЧЕТ".
    update vl with frame frtn1.
    if vl = 1 or vl = 2 then do:
       repeat:
        acct = "".
        update acct with frame frtn1.
        if vl = 1 then do:
           find last baaak where baaak.aaa = acct no-lock no-error.
           if not avail baaak then do:
              message "Счета не существует. Выберите другой счет".
              end. else leave.
           end.
           if vl = 2 then leave.
       end.
    end.
 end.


     end.
     else
     if avail sysc-star and lookup(lgr.lgr, sysc-star.chval) <> 0 then do: /*STAR синяя*/
        define frame frt2
               x1  format "9" label "Ежеквартальная выплата?     " validate(x1 = 1 or x1 = 2 or x1 = 3, "Сделайте правильный выбор") skip
               x2  format "9" label "Автоматическая пролонгация? " validate(x2 = 1 or x2 = 2 or x2 = 3, "Сделайте правильный выбор") skip
               prd format "99" label "Период пролонгации          " validate(prd > 0 and prd < 38 , "Данный период недопустим") skip
               x3  format "9" label "Дополнительные взносы?      " validate(x3 = 1 or x3 = 2 or x3 = 3, "Сделайте правильный выбор") skip
               x4  format "9" label "Бонус?                      " validate(x4 = 1 or x4 = 2 or x4 = 3, "Сделайте правильный выбор")
        with side-labels centered row 8 title "".

        message "1-выплата на текущий или карт счет. 2-выплата наличными или на сберегат.счет.  3-не выбрал ".
        update x1  with frame frt2.

if x1 = 1 then do:
         define frame frtn1
         vl   format "9"     label "Выплата процентов" validate(vl = 1 or vl = 2, "Сделайте правильный выбор") skip
         acct format "x(15)" label "Текущий/Карт счет" with side-labels centered row 8 title "1-Текущий 2-КАРТ-СЧЕТ".
         update vl with frame frtn1.
         if vl = 1 or vl = 2 then do:
repeat:
           acct = "".
           update acct with frame frtn1.
           if vl = 1 then do:
              find last baaak where baaak.aaa = acct no-lock no-error.
              if not avail baaak then do:
                 message "Счета не существует. Выберите другой счет".
              end. else leave.
           end.
           if vl = 2 then leave.
end.

         end.
end.
if x1 = 2 then do:
         define frame frtn2
         vl   format "9"     label "Выплата процентов" validate(vl = 1 or vl = 2, "Сделайте правильный выбор") skip
         acct format "x(15)" label "Сберегательный счет" with side-labels centered row 8 title "1-Наличными 2-На Сберег. счет".
         update vl with frame frtn2.
         if vl = 2 then do:
repeat:
            acct = "".
            update acct with frame frtn2.
            find last baaak where baaak.aaa = acct no-lock no-error.
            if not avail baaak then do:
               message "Счета не существует. Выберите другой счет".
            end. else leave.
end.
         end.
end.

        message "1-На любой срок(по выбору). 2-на соотв. депозиту срок  3-не выбрал ".
        update  x2  with frame frt2.


        if x2 = 1 then do: update prd with frame frt2. end.
        if x2 = 2 then do: prd = aaa.cla. displ prd with frame frt2. end.
        if x2 = 3 then do: prd = 0. displ prd with frame frt2. end.
        message "1-ДА   2-НЕТ   3-КЛИЕНТ НЕ ВЫБРАЛ".
        update x3 with frame frt2.
        message "1-0.5% от осн суммы. 2-фиксированн % на 18 мес. 3-не выбрал ".
        update x4 with frame frt2.



     end.
     else
     if avail sysc-juldiz and lookup(lgr.lgr, sysc-juldiz.chval) <> 0 then do: /*JULDIZ красная*/
        define frame frt3
               x1  format "9" label  "Капитализация?              " validate(x1 = 1 or x1 = 2 or x1 = 3, "Сделайте правильный выбор") skip
               x2  format "9" label  "Автоматическая пролонгация? " validate(x2 = 1 or x2 = 2 or x2 = 3, "Сделайте правильный выбор")  skip
               prd format "99" label "Период пролонгации          " validate(prd > 11 and prd < 61 , "Данный период недопустим") skip
               x3  format "9" label  "Дополнительные взносы?      " validate(x3 = 1 or x3 = 2 or x3 = 3, "Сделайте правильный выбор")  skip
               x4  format "9" label  "Бонус?                      " validate(x4 = 1 or x4 = 2 or x4 = 3, "Сделайте правильный выбор")
        with side-labels centered row 8 title "".
        message "1-ДА   2-НЕТ   3-КЛИЕНТ НЕ ВЫБРАЛ".
        update x1  with frame frt3.
        message "1-На любой срок(по выбору). 2-на соотв. депозиту срок  3-не выбрал ".
        update  x2  with frame frt3.

        if x2 = 1 then do: update prd with frame frt3. end.
        if x2 = 3 then do: prd = 0. displ prd with frame frt3. end.
        if x2 = 2 then do: prd = aaa.cla. displ prd with frame frt3. end.
        message "1-ДА   2-НЕТ   3-КЛИЕНТ НЕ ВЫБРАЛ".
        update x3 with frame frt3.
        message "1-0.5% от осн суммы. 2-фиксированн % на 18 мес. 3-не выбрал ".
        update x4 with frame frt3.
 message "1-выплата на текущий или карт счет. 2-выплата наличными.".
 define frame frtn12
    v-tl  format "9" label "Выплата процентов" validate(v-tl = 1 or v-tl = 2, "Сделайте правильный выбор") with side-labels centered row 8 title "".
 update v-tl  with frame frtn12.
 if v-tl = 1 then do:
    define frame frtn1
    vl   format "9"     label "Выплата процентов" validate(vl = 1 or vl = 2, "Сделайте правильный выбор") skip
    acct format "x(15)" label "Текущий/Карт счет" with side-labels centered row 8 title "1-Текущий 2-КАРТ-СЧЕТ".
    update vl with frame frtn1.
    if vl = 1 or vl = 2 then do:
       repeat:
        acct = "".
        update acct with frame frtn1.
        if vl = 1 then do:
           find last baaak where baaak.aaa = acct no-lock no-error.
           if not avail baaak then do:
              message "Счета не существует. Выберите другой счет".
              end. else leave.
           end.
           if vl = 2 then leave.
       end.
    end.
 end.

     end.

/*prlng*/
     find last sub-cod where sub-cod.acc = s-aaa and sub-cod.sub = 'CIF' exclusive-lock no-error.
     if not avail sub-cod then create sub-cod.
     sub-cod.acc = aaa.aaa.
     sub-cod.sub = 'CIF'.
     sub-cod.d-cod = 'prlng'.
     if x2 = 1 or x2 = 2 then sub-cod.ccod = 'yes'. else sub-cod.ccod = 'no'.
     sub-cod.rdt = g-today.
/*prlng*/


     find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
     if not avail acvolt then do:
        create acvolt.
               acvolt.aaa = aaa.aaa.
     end.
          acvolt.x1 = string(x1).
          acvolt.x2 = string(x2).
          acvolt.x3 = string(x3).
          acvolt.x4 = string(x4).
          acvolt.prim1 = string(prd).
          acvolt.who = g-ofc.
          acvolt.whn = g-today.
          acvolt.accp = acct.
          acvolt.sts = string(vl).
if x4 = 1  then do:
/*        acvolt.bonusopnamt = aaa.opnamt. */
          acvolt.bonusyes = True.
end.
else do:
          acvolt.bonusopnamt = 0.   acvolt.bonusyes = False.
end.

if avail sysc-zvezda and lookup(lgr.lgr, sysc-zvezda.chval) <> 0 then do: /*ZVEZDA*/
     if x1 = 1 then x1 = 0.       if x1 = 2 then x1 = 1.   if x1 = 3 then x1 = 0.5.
     if x2 = 1 then x2 = 0.       if x2 = 2 then x2 = 1.   if x2 = 3 then x2 = 0.5.
     if x3 = 1 then x3 = 1.       if x3 = 2 then x3 = 0.   if x3 = 3 then x3 = 0.5.
     if x4 = 1 then x4 = 0.       if x4 = 2 then x4 = 1.   if x4 = 3 then x4 = 0.5.
     d_koef = x1 + x2 + x3 + x4.
end.

if avail sysc-star and lookup(lgr.lgr, sysc-star.chval) <> 0 then do:     /*STAR*/
     if x1 = 1 then x1 = 1.       if x1 = 2 then x1 = 0.   if x1 = 3 then x1 = 0.5.
     if x2 = 1 then x2 = 0.       if x2 = 2 then x2 = 1.   if x2 = 3 then x2 = 0.5.
     if x3 = 1 then x3 = 1.       if x3 = 2 then x3 = 0.   if x3 = 3 then x3 = 0.5.
     if x4 = 1 then x4 = 0.       if x4 = 2 then x4 = 1.   if x4 = 3 then x4 = 0.5.
     d_koef = x1 + x2 + x3 + x4.
end.

if avail sysc-juldiz and lookup(lgr.lgr, sysc-juldiz.chval) <> 0 then do: /*JULDIZ*/
/*    да                            нет                     не выбр  */
     if x1 = 1 then x1 = 0.       if x1 = 2 then x1 = 1.   if x1 = 3 then x1 = 0.5.
     if x2 = 1 then x2 = 0.       if x2 = 2 then x2 = 1.   if x2 = 3 then x2 = 0.5.
     if x3 = 1 then x3 = 1.       if x3 = 2 then x3 = 0.   if x3 = 3 then x3 = 0.5.
     if x4 = 1 then x4 = 0.       if x4 = 2 then x4 = 1.   if x4 = 3 then x4 = 0.5.
     d_koef = x1 + x2 + x3 + x4.
end.

      define variable quest   as logical format "Да/Нет".
/*    message "Оформление не третье лицо? " update acvolt.person.
      if acvolt.person = True then d_koef = 0.  */

      acvolt.prim2 = string(d_koef).

      def var v1 as decimal.
      def var v2 as decimal.

 def var dm as decimal decimals 2.
 dm = aaa.opnamt.
 find last crc where crc.crc = lgr.crc no-lock no-error.
 if crc.crc = 2 or crc.crc = 11 then do:
    if aaa.opnamt >= 7000000 / crc.rate[1] then dm = 50000.
    else dm = 49000.
 end.


  run tdagetrate2(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, dm, output v1, output v2).

     find last spred where spred.pri = aaa.pri and  spred.min_month <= aaa.cla and spred.max_month >= aaa.cla no-lock no-error.
     if avail spred then do:
        aaa.rate = round(v1 + ((v2 - v1) / 5) * (d_koef + ((aaa.cla - spred.min_month) * (1 / (spred.max_month - spred.min_month)))), 1).
     /* aaa.rate = round(spred.min_rate + ((spred.max_rate -  spred.min_rate) / 5) * (d_koef + ((aaa.cla - spred.min_month) * (1 / (spred.max_month - spred.min_month)))),1 ). */
     end.
  end.



/*Эффективная ставка*/
def var v-sum as deci no-undo.
def var v-srok as integer no-undo.
def var v-rt as deci no-undo.
def var v-rdt as date no-undo.
def var v-pdt as date no-undo.
def var v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def var v-komv as deci no-undo. /* комиссия за ведение счета */
def var v-komr as deci no-undo. /* комиссия за рассмотрение заявки */
def var v-er as deci no-undo.
def var v-lgr as char.

v-lgr = lgr.lgr.
v-sum = aaa.opnamt.
v-srok = aaa.cla.
v-rt = aaa.rate.
v-rdt  = aaa.regdt.

message "ЖДИТЕ: ИДЕТ РАСЧЕТ ЭФФЕКТИВНОЙ ПРОЦЕНТНОЙ СТАВКИ!!!!!!" .

run er_depf(v-lgr, v-sum,v-srok,v-rt,v-rdt,v-rdt, 0, 0, 0,output v-er).


message "". pause 0.
message "". pause 0.



d-effect = v-er.
/*Эффективная ставка*/
  if (lgr.feensf = 1 or lgr.feensf = 2 or lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 5 or lgr.feensf = 7 or lgr.feensf = 6) or lookup(lgr.lgr, "A38,A39,A40") > 0 then do:
     find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
     if not avail acvolt then do:
        create acvolt.
               acvolt.aaa = aaa.aaa.
     end.
          acvolt.x1 = string(aaa.regdt). /*дата открытия*/
          acvolt.x2 = string(d-effect).  /*Эффективная ставка*/
          acvolt.x3 = string(aaa.expdt). /*дата закрытия*/

          if lgr.feensf = 5 then do:
             if aaa.crc = 1 then acvolt.x4 = "10". else
             if aaa.crc = 2 then acvolt.x4 = "5".  else
             if aaa.crc = 3 then acvolt.x4 = "4".

          end.
  end.

disp aaa.rate d-effect mbal with frame aaa.


Procedure EvaluateExpiryDate.
 def var years as inte initial 0.
 def var months as inte initial 0.
 def var days as inte.
 days = day(aaa.lstmdt).
 years = integer(aaa.cla / 12 - 0.5).
 months = aaa.cla - years * 12.
 months = months + month(aaa.lstmdt).
 if months > 12 then do:
    years = years + 1.
    months = months - 12.
 end.
   if month(aaa.lstmdt) <> month(aaa.lstmdt + 1) then do:
      months = months + 1.
      if months = 13 then do:
         months = 1.
         years = years + 1.
      end.
      days = 1.
   end.


         if months = 2 and days = 30 then do: months = 3. days = 1. end.
         if months = 2 and days = 29  and  (( (year(aaa.lstmdt)  + years) - 2000) modulo 4) <> 0 then do:
         months = 3.  days = 1.  end.



   aaa.expdt = date(months, days, year(aaa.lstmdt) + years).
   if month(aaa.lstmdt) <> month(aaa.lstmdt + 1) then do:

if month(aaa.expdt) = 3 and day(aaa.expdt) = 1 then do:
end.
else
 aaa.expdt = aaa.expdt - 1.


   end.

End procedure.

























