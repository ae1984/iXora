/* cif-cda.p
 * MODULE
        Депозиты Ю.Л
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
 * AUTHOR
        06/12/2005 dpuchkov
 * CHANGES
        17.04.2009 galina - изменения для открытия 20-тизначных счетов, соотвествующих 9-тизначным
        02/11/2009 galina - убрала услови на 02 ноября 2009 для 20_тизначных счетов
        02.04.2010 id00004 - сделал возможность открытия счетов на период с 1-6 и 7-30 дней в соотв с ТЗ-643
        30/12/2010 evseev - % ставка для Lgr = 518,519,520
        17/01/2011 evseev - убрал отладочный "message 'vdaytm <> 0'. pause 60." "message 'vdaytm = 0'. pause 60."
        19/01/2011 evseev - ввод даты окончания вместо кол-ва месяцев
        17/05/2011 evseev - для групп 478,479,480,481,482,483 ограничение срока депозита не более 36мес.
        23.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

{global.i}
{er.i}
def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.

def var vdaytm as int label "TERM (DAYS)".
def var vdayrate as int  .

def var vdays as int.
def var mbal like aaa.opnamt label "MATURE-VALUE".
def var vans as log initial false.
def var v-oldaccrued like aaa.accrued.
def var v-weekbeg as int.
def var v-weekend as int.
def var d-effect as decimal.

def var inf-bnfjss  as char.
def var inf-bnfbank as char.
def var inf-bnfbik  as char.
def var inf-bnfiik  as char.
def var inf-empty  as logical init no.
def var inf-nalog  as logical init yes.
def shared var v-aaa9 as char.
def buffer b-aaa for aaa.

def var v-grduedt as date label "CLOSE DATE".

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


define frame frt1
      aaa.aaa                        label "Счет клиента    "
      aaa.cif                        label "Код клиента     "
      aaa.regdt format "99/99/9999" label  "Дата начала     "
      vdayrate label                       "Кол-во дней     "
      vdaytm label                         "Кол-во месяцев  "
      aaa.expdt  format "99/99/9999" label "Дата окончания  "
      aaa.rate format "zzzz.9999" label    "Процент. ставка "
      aaa.opnamt label                     "Сумма начальная " validate(aaa.opnamt <> 0, "Введите сумму вклада")
      mbal label                           "Сумма конечная  "
      d-effect label                       "Эффективная ставка"
      inf-nalog   label                    "Удерживать налог"
      with row 3   centered 1 col overlay
      title " Параметры депозита Ю.Л.".



find aaa where aaa.aaa eq s-aaa.

def var v-val as char.

if aaa.crc = 1 then  v-val = "KZT" .
if aaa.crc = 2 then  v-val = "USD" .
if aaa.crc = 3 then  v-val = "EUR" .

if not available aaa then do:
   bell.
   {mesg.i 8813}.
   undo, return.
end.


if aaa.expdt eq ? then aaa.expdt = aaa.regdt.

if length(s-aaa) = 20 then do:
    if aaa.complex = true then mbal = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdaytm).
    else mbal = aaa.opnamt * (1 + aaa.rate * vdaytm / aaa.base / 100).

    find depogar where depogar.aaa = aaa.aaa no-lock no-error.
    if avail depogar then do:
        v-grduedt =  depogar.duedt.
    end.

    display aaa.aaa aaa.cif
            aaa.regdt aaa.rate
            aaa.opnamt
            vdaytm vdayrate aaa.expdt
            mbal d-effect with frame frt1.

    aaa.regdt = g-today.
    aaa.lstmdt = aaa.regdt.

    repeat:
        if lookup(aaa.lgr,"B15,B16,B17,B18,B19,B20") <> 0  then do:
           update  vdaytm  with frame frt1.
           if lookup(aaa.lgr,"B15,B16,B17") <> 0  then do:
              if vdaytm > 12 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteMaximum"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
           if lookup(aaa.lgr,"B18,B19,B20") <> 0  then do:
              if vdaytm < 24 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteMaximum"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
        end. else if lookup(aaa.lgr,"B01,B02,B03,B04,B05,B06") <> 0  then do:
           update  vdaytm  with frame frt1.
           if lookup(aaa.lgr,"B01,B02,B03") <> 0  then do:
              if vdaytm > 12 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
           if lookup(aaa.lgr,"B04,B05,B06") <> 0  then do:
              if vdaytm < 24 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
        end. else if lookup(aaa.lgr,"B07,B08") <> 0  then do:
           update  vdaytm  with frame frt1.
           if lookup(aaa.lgr,"B07") <> 0  then do:
              if vdaytm > 12 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable1"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
           if lookup(aaa.lgr,"B08") <> 0  then do:
              if vdaytm < 24 then do:
                 message "Данный период недопустим!". pause.
              end. else do:
                   find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable1"  no-lock no-error.
                   if not avail rtur then do:
                      message "Данный период недопустим!". pause.
                   end. else leave.
              end.
           end.
        end. else if lookup(aaa.lgr,"B09,B10,B11") <> 0  then do:
           update  vdaytm  with frame frt1.
           find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteUniversal"  no-lock no-error.
           if not avail rtur then do:
              message "Данный период недопустим!". pause.
           end. else leave.
        end. else if lookup(aaa.lgr,"518,519,520") <> 0  then do:
           update aaa.expdt with frame frt1.
           vdayrate = aaa.expdt - aaa.regdt.
        end. else update /*aaa.regdt*/ vdaytm vdayrate with frame frt1.
         /*Срочный*/
         if lookup(aaa.lgr,"478,479,480,481,482,483") <> 0  then do:
            if vdaytm <> 0 and vdayrate <> 0 then do:
               message "Должен быть выбран период в месяцах или днях". pause.
            end.
            else
            if vdaytm <> 0 and vdayrate = 0 then do:
               if vdaytm > 36 or vdaytm <= 0 then do:
                  message "Данный период недопустим!". pause.
               end.
               else leave.
            end.
            else
            if vdaytm = 0 and vdayrate <> 0 then do:
               if vdayrate > 30  then do:
                  message "Данный период недопустим". pause.
               end.
               else leave.
            end.
         end.
         /*Накопит*/
         if lookup(aaa.lgr,"484,485,486,487,488,489") <> 0  then do:
            if (vdaytm <> 7 and vdaytm <> 13 and vdaytm <> 25)  then do:
                message "Данный период недопустим!". pause.
            end.
            else leave.
         end.
         /*Недропользователь*/
         if lookup(aaa.lgr,"518,519,520") <> 0  then do:
            if vdaytm = 0 and vdayrate <= 0 then do:
               message "Данный период недопустим!". pause.
            end.
            else leave.
         end.
    end.
end. else do:
  find b-aaa where b-aaa.aaa = v-aaa9 no-lock no-error.
  if avail b-aaa then do:
     aaa.cla = b-aaa.cla.
     aaa.lstmdt = b-aaa.lstmdt.
     aaa.regdt = b-aaa.regdt.
     aaa.rate = b-aaa.rate.
     aaa.expdt = b-aaa.expdt.
  end.
end.

if  length(s-aaa) = 20 then do:
    if vdayrate <> 0 then do:
       aaa.expdt = aaa.lstmdt + vdayrate.
    end. else run EvaluateExpiryDate.

    display vdaytm vdayrate aaa.expdt inf-nalog with frame frt1.

    if lookup(aaa.lgr,"478,479,480,481,482,483") <> 0 then do:
       if vdayrate <> 0 then do:
          find last rtur where rtur.cod = v-val and rtur.trm = vdayrate and rtur.rem = "SRd"  no-lock no-error.
          aaa.rate = rtur.rate.
       end.
       else
       if vdaytm <> 0 then
       do:
          find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "SR"  no-lock no-error.
          aaa.rate = rtur.rate.
       end.
    end.
    if lookup(aaa.lgr,"484,485,486,487,488,489") <> 0 then do:
       find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "NK"  no-lock no-error.
       aaa.rate = rtur.rate.
    end.
    if lookup(aaa.lgr,"B01,B02,B03,B04,B05,B06") <> 0 then do:
       aaa.cla = vdaytm.
       find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable"  no-lock no-error.
       aaa.rate = rtur.rate.
    end.
    if lookup(aaa.lgr,"B07,B08") <> 0 then do:
       aaa.cla = vdaytm.
       find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteProfitable1"  no-lock no-error.
       aaa.rate = rtur.rate.
    end.

    if lookup(aaa.lgr,"B09,B10,B11") <> 0 then do:
       aaa.cla = vdaytm.
       find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteUniversal"  no-lock no-error.
       aaa.rate = rtur.rate.
    end.

    if lookup(aaa.lgr,"B15,B16,B17,B18,B19,B20") <> 0 then do:
       aaa.cla = vdaytm.
       find last rtur where rtur.cod = v-val and rtur.trm = vdaytm and rtur.rem = "ForteMaximum"  no-lock no-error.
       aaa.rate = rtur.rate.
    end.
    if lookup(aaa.lgr,"518,519,520") = 0 then displ aaa.rate with frame frt1.
    display vdaytm vdayrate inf-nalog with frame frt1.
    find ofc where ofc.ofc = g-ofc no-lock.
    find lgr where lgr.lgr = aaa.lgr no-lock.
    if ofc.expr[5] matches "*a*" or lgr.led <> "CDA" then do:
       update aaa.rate with frame frt1.
    end.

    if lookup(aaa.lgr,"B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 then do:
       repeat:
          update aaa.opnamt with frame frt1.
          if aaa.opnamt < lgr.tlimit[1] then do:
             message "Сумма должна быть не менее " + string(lgr.tlimit[1]). pause.
          end. else leave.
       end.
    end. else update aaa.opnamt with frame frt1.

    if lookup(aaa.lgr,"518,519,520") <> 0 then do:
       aaa.cla = truncate((aaa.expdt - aaa.regdt) / aaa.base * 12, 0).
       vdaytm = truncate((aaa.expdt - aaa.regdt) / aaa.base * 12, 0).
       /*message aaa.aaa " " aaa.pri " " aaa.cla " " aaa.regdt " " aaa.opnamt. pause 90.*/
       run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.regdt, aaa.opnamt, output aaa.rate).
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

v-lgr = aaa.lgr.
v-sum = aaa.opnamt.
v-srok = vdaytm.
v-rt = aaa.rate.
v-rdt  = aaa.regdt.

if vdaytm <> 0 then do:
    run er_depf(v-lgr, v-sum,v-srok,v-rt,v-rdt,v-rdt, 0, 0, 0,output v-er).
end. else do:
    create b2cl.
    b2cl.dt   = aaa.expdt.
    b2cl.days = aaa.expdt - aaa.regdt .
    v-sum = (aaa.opnamt * vdayrate * aaa.rate) / 36500.
    b2cl.sum  = round(v-sum + aaa.opnamt, 2).

    v-er = get_er(0.0,0.0,aaa.opnamt,0.0).
end.

d-effect = v-er.
/*Эффективная ставка*/

find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
if not avail acvolt then do:
   create acvolt.
          acvolt.aaa = aaa.aaa.
end.
acvolt.x1 = string(aaa.regdt). /*дата открытия*/
acvolt.x2 = string(d-effect).  /*Эффективная ставка*/
acvolt.x3 = string(aaa.expdt). /*дата закрытия*/
if vdaytm <> 0 then do:
   acvolt.x4 = string(vdaytm) .
end.
if vdayrate <> 0 then do:
   acvolt.x4 = string(vdayrate) .
   acvolt.sts = "d" .
end.

if  length(s-aaa) = 20 then do:
    if aaa.complex = true then mbal = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdaytm).
    else  mbal = aaa.opnamt * (1 + aaa.rate * vdaytm / aaa.base / 100).
    if aaa.regdt lt g-today then do:
      vdays = g-today - aaa.regdt.
      {mesg.i 0930} update vans .
      if vans eq false then undo, retry.
      vans = no.
      {mesg.i 750} update vans .
        if vans  then do:
            v-oldaccrued = aaa.accrued.
            if aaa.complex = true then
            aaa.accrued = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdays).
            else
                aaa.accrued = aaa.opnamt * aaa.rate * vdays / aaa.base / 100.
            if v-oldaccrued ne aaa.accrued then do:

              run savelog ("cif-cda", "Change accrued for " + string(aaa.aaa) + " old " + string (v-oldaccrued) + " new " + string(aaa.accrued)).

            end.
        end.
    end.
end.

/*update v-grduedt. */

find depogar where depogar.aaa = aaa.aaa no-error.
if not avail depogar then do:
      create depogar.
         depogar.aaa   = aaa.aaa.
         depogar.duedt = v-grduedt.
end. else do:
      depogar.duedt = v-grduedt.
end.

inf-empty = False.

create urdpinfo.
       urdpinfo.aaa     = aaa.aaa.
       urdpinfo.who     = g-ofc      .
       urdpinfo.whn     = g-today    .
       if inf-nalog = True then urdpinfo.rem1 = "1".
       else urdpinfo.rem1 = "0".

if  length(s-aaa) = 20 then do:
     display aaa.cif aaa.regdt aaa.rate aaa.expdt aaa.opnamt mbal d-effect with frame frt1.
     pause 10.
end.


Procedure EvaluateExpiryDate.
 def var years as inte initial 0.
 def var months as inte initial 0.
 def var days as inte.
 days = day(aaa.lstmdt).
 years = integer(vdaytm / 12 - 0.5).
 months = vdaytm - years * 12.
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
   /* nataly - если выпадает 29.02.yyyy то дата меняется на 01.03.yyyy */
   if months = 2 and days = 29 and  (( (year(aaa.lstmdt)  + years) - 2000) modulo 4) <> 0 then do:
      months = 3.  days = 1.
   end.
   /* nataly ------------------ */
   aaa.expdt = date(months, days, year(aaa.lstmdt) + years).
   if month(aaa.lstmdt) <> month(aaa.lstmdt + 1) then aaa.expdt = aaa.expdt - 1.
End procedure.


