/* pkzakcc.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Печать Заключения о предоставлении займа - Кредитные карточки
 * RUN
        
 * CALLER
        pkzapr-4.p, pkankdog.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-10-2, 4-10-3
 * AUTHOR
        29.04.2003 marinav
 * CHANGES
        13.06.2003 nadejda - убрана строка "Обеспечение"
                           - обрабатывается валюта кредита
                           - добавлена строка "Утвержденный кредитный лимит"
                           - добавлена строка "Контролер"
        23.06.2003 nadejda - если валюта кредита не тенге, то макс.сумма в тенге не показывается
        25.06.2003 nadejda - для программы Депозит+Карточка : добавлен вывод номера счета и убран вывод рейтинга и лимита
                             изменен пересчет максимальных сумм с учетом Депозит+Карточка
        25.08.2003 nadejda - разрешается сумма кредитного лимита = 0, поэтому нулевая сумма теперь тоже печатается - если статус 10, т.е. лимит подтвержден менеджером
        12.09.2003 nadejda - изменен пересчет максимальной суммы в валюте для Депозит+Карточка - также, как в обычной с тем же шагом
        23.09.2003 nadejda - курс пересчета сумм изменен на фиксированный в pksysc = "pkcrc1"
                             для Депозит+Карточка макс.сумма и сумма запроса привязываются к справочнику кредитных лимитов
        07.04.2004 nadejda - для Депозит+Карточка поставлены условия if avail
        12.05.2004 nadejda - для Деп+Карт изменен расчет макс.суммы - 90% от общей суммы депозитов, записанная при оформлении
        17.09.2004 saltanat - для "Платежных карт": 1. изменила "Максимальная сумма" на "Максимальный кредитный лимит"
                                   добавила вывод: для Депозит + Карточка : Возраст заемщика, Сумма вклада, Срок вклада;
                                                   для Creditcard : Возраст заемщика, Общий чистый доход по ГЦВП, Количество работадателей, Изменение в анкете скоринга
        07.12.2004 saltanat - Для учета кредитного лимита "Депозит + Карточка" учитывается средневзвешанный курс
        10.12.2004 saltanat - Добавила в вывод "Возраст заемщика" + "лет."
        28.04.2005 marinav - Добавлена вторая часть отчета БЭК-ОФИС
        05.05.05   marinav - Изменен расчет возраста заемщика и срок вклада теперь - дата окончания
        18.05.05 marinav -   для всех видов кредитов учитываетя средневзвешенный курс
        12/08/2005 marinav - к сумме депозита прибавляются все доп взносы
        19/04/2006 Natalya D. - добавила изменения для Подарочной карты (s-credtype = '9')

*/


{global.i}
{pk.i}

/*
s-credtype = "4".
s-pkankln = 584.
*/

def var v-gcvptxt as char init ''.
def var v-kolrab  as inte init 0.
def var v-chdox   as decimal init 0.
def var v-amt   as decimal init 0.
def var v-scoring as char init ''.
def var v-age as inte.
def var v-sum as deci.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-sumkzt as decimal.
def var v-sumcrc as decimal.
def var v-lim as char.
def var v-repfile as char init "repcc.htm".
def var v-refusname as char format "x(40)".
def var v-stsname as char.
def var v-str as char.
def var v-datastr as char.
def var v-num as integer.
def var v-titl1 as char.
def var v-titl2 as char.
def var v-info as char.
def var v-infi as integer.
def var v-adresp as char.
def var v-adresf as char.
def var v-ofc as char.
def var v-crcval like crc.crc.
def var v-crccod as char.
def var v-crc as char.
def var v-crcrate as decimal.
def var v-cod as char.
def var v-card as char.
def var v-limit as char.
def var v-limitkzt as decimal.
def var v-limitval as decimal.
def var v-datastrkz as char no-undo.

def temp-table t-limit
  field limitval as decimal
  field limitkzt as decimal
  index limitkzt is primary unique limitkzt.


{pk-sysc.i}

/* вторая валюта пересчета суммы кредита */
v-crcval = get-pksysc-int ("pkcrc1").
   /* 07.12.2004 saltanat - Берем средневзвешанный курс */
   find crc where crc.crc = v-crcval no-lock no-error.
   if avail crc then v-crcrate = crc.rate[1].
   else v-crcrate = get-pksysc-dec ("pkcrc1").
v-str = get-pksysc-char ("anksum").
v-num = get-pksysc-int("step").

/* найти максимальные суммы кредита в тенге и валюте (USD по умолчанию) */

if pkanketa.crc = 1 then do:

if s-credtype = '9' then do:
   v-sumkzt = pkanketa.summax.
   if pkanketa.sernom = "" then do:
      v-sumkzt = pkanketa.summax.      
   end.
   v-sumcrc = trunc((v-sumkzt / v-crcrate), 0).
end. else do: 
  v-sumkzt = pkanketa.summax.
  if pkanketa.sernom = "" then do:
    /* для простых кредитных карточек есть максимальные пределы */
    if v-sumkzt > deci(entry(2, v-str)) then v-sumkzt = deci(entry(2, v-str)).

    if v-sumkzt = deci(entry(2, v-str)) then v-sumcrc = deci(entry(3, v-str)).
    else do:
/*
      find last crchis where crchis.crc = v-crcval and crchis.rdt <= pkanketa.rdt no-lock no-error.
      v-sumcrc = v-num * trunc((v-sumkzt / crchis.rate[1]) / v-num, 0).
*/
      v-sumcrc = v-num * trunc((v-sumkzt / v-crcrate) / v-num, 0).
    end.
  end.
  else do:
    /* 12.05.2004 nadejda - теперь не по справочнику считаем, а как 90% от общей суммы депозитов - сумма сохраняется в pkccdep.p */
    v-sumcrc = pkanketa.resdec[4].

    /* для Депозит+Карточка максимальная сумма лимита высчитывается ПО СПРАВОЧНИКУ ! * /
    / * справочник сумм кредитного лимита для Депозит+Карточка * /
    for each bookcod where bookcod.bookcod = "pkankdk" no-lock :
      create t-limit.
      assign t-limit.limitval = decimal(entry(2, bookcod.name))
             t-limit.limitkzt = decimal(entry(3, bookcod.name)).
    end.

    / * найти строку справочника * /
    find t-limit where t-limit.limitkzt = v-sumkzt no-lock no-error.
    if avail t-limit then do:
      v-sumcrc = t-limit.limitval.
    end.
    else do:
      / * если не найдена точная сумма -> найти ближайшую сумму лимита в KZT в справочнике * /
      find last t-limit where t-limit.limitkzt <= v-sumkzt no-lock no-error.
      if avail t-limit then do:
        v-limitkzt = t-limit.limitkzt.
        v-limitval = t-limit.limitval.
        find first t-limit where t-limit.limitkzt >= v-sumkzt no-lock no-error.
        if v-sumkzt - v-limitkzt > v-sumkzt - t-limit.limitkzt then v-sumcrc = t-limit.limitval. else v-sumcrc = v-limitval.
      end.
      else do:
        find first t-limit no-lock no-error.
        v-sumcrc = t-limit.limitval.
      end.
    end.
    */
  end.
end.
end.
else do:
  v-sumcrc = pkanketa.summax.
  v-crcval = pkanketa.crc.
end.

find crc where crc.crc = v-crcval no-lock no-error.
if avail crc then v-crccod = crc.code.

find crc where crc.crc = pkanketa.crc no-lock no-error.
if avail crc then v-cod = crc.code.

find first cmp no-lock no-error.
v-num = 0.

run pkdefdtstr (pkanketa.rdt, output v-datastr, output v-datastrkz).

find first bookcod where bookcod.bookcod = "kktype" and bookcod.code = pkanketa.partner no-lock no-error.
if avail bookcod then v-card = bookcod.name.

if pkanketa.sernom = "" then do:
  /* лимит только для потребительских карточек считаем */
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "krlim" no-lock no-error.
  if avail pkanketh then v-limit = entry(1, pkanketh.value2).
end.

find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
if avail ofc then do :
v-ofc = entry(1, ofc.name, " ").
if num-entries(ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, ofc.name, " "), 1, 1) + ".".
if num-entries(ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, ofc.name, " "), 1, 1) + ".".
end.

output to value(v-repfile).

{html-title.i 
 &stream = " "
 &title = "Заключение Департамента платежных карт "
 &size-add = "x-"
}

if avail cmp then 
put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR><TD>" skip
  "<P align=""center""><B>ЗАКЛЮЧЕНИЕ<BR>Департамента платежных карт " cmp.name 
  "<BR></B></P>" skip.


put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR valign=""top"">"
    "<TD width=""40%""><u><b>ФРОНТ-ОФИС </b></u></TD>" skip
  "</TR><TR>&nbsp;</TR>" skip
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD width=""40%"">Анкета : </TD>" skip
    "<TD width=""60%"">" s-pkankln "</TD>" skip
  "</TR>" skip.

put unformatted 
  "<TR valign=""top"">"
    "<TD >Заемщик : </TD>" skip
    "<TD >" pkanketa.name "</TD>" skip
  "</TR>" skip
  "<TR valign=""top"">"
    "<TD>РНН : </TD>" skip
    "<TD>" pkanketa.rnn "</TD>" skip
  "</TR>" skip.

if s-credtype = '4' or s-credtype = '9' then do:
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "bdt" no-lock no-error.
  if avail pkanketh then do:
    if date(substr(string(date(pkanketh.value1)),1,5)) > g-today then v-age = year(g-today) - year(date(pkanketh.value1)) - 1.
                                                   else v-age = year(g-today) - year(date(pkanketh.value1)) .
      put unformatted 
        "<TR valign=""top"">"
          "<TD>Возраст заемщика : </TD>" skip
          "<TD>" string(v-age) + " лет" "</TD>" skip
        "</TR>" skip.
  end.
end.

if pkanketa.sernom = "" then do:
  /* потребительская кредитная карточка */
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Рейтинг платежеспособности: </TD>" skip
      "<TD>" pkanketa.rating "</TD>" skip
    "</TR>" skip.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Социальный рейтинг: </TD>" skip
      "<TD>" pkanketa.resdec[5] "</TD>" skip
    "</TR>" skip.
  
  if s-credtype = '4' then do:         
	find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
	                      and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.

	if avail pkanketh then do:

	if pkanketh.rescha[3] <> "" then do:
	v-gcvptxt = pkanketh.rescha[3].

        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
                                  pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobs" no-lock no-error.
        if avail pkanketh then do:
        run pkgcvpkol (v-gcvptxt, pkanketh.value1, output v-kolrab, output v-chdox).
        
	put unformatted 
	  "<TR valign=""top"">"
	    "<TD >Общий чистый доход по ГЦВП : </TD>" skip
	    "<TD >" truncate(v-chdox,2) " тенге </TD>" skip
	  "</TR>" skip
	  "<TR valign=""top"">"
	    "<TD>Количество работадателей : </TD>" skip
	    "<TD>" v-kolrab "</TD>" skip
	  "</TR>" skip.

        end. /* avail 'jobs' */
        end. /* rescha[3] <> '' */
        end. /* avail 'sik' */ 
  end.

end.
else do:
  /* Депозит + Карточка */
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "acc2" no-lock no-error.
  if avail pkanketh then 
  put unformatted 
    "<TR valign=""top"">"
      "<TD>ИИК депозита : </TD>" skip
      "<TD>" if avail pkanketh then pkanketh.value1 else "нет данных" "</TD>" skip
    "</TR>" skip.

  if s-credtype = '4' then do:
  find first aaa where aaa.aaa = pkanketh.value1 no-lock no-error.
  if avail aaa then do:
     for each aad where aad.aaa = aaa.aaa no-lock.
        v-sum = v-sum + aad.sumg.
     end.

     find first crc where crc.crc = aaa.crc no-lock no-error.
     if avail crc then
     put unformatted 
    "<TR valign=""top"">"
      "<TD>Сумма вклада : </TD>" skip
      "<TD>" if avail aaa then string(v-sum + aaa.opnamt) + " " + crc.code else "нет данных" "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Срок вклада : </TD>" skip
      "<TD>" if avail aaa then string(aaa.expdt)  else "нет данных" "</TD>" skip
    "</TR>" skip.
  end.
  end.

end.

if s-credtype = '4' or s-credtype = '9' then
put unformatted 
  "<TR valign=""top"">"
    "<TD> Максимальный кредитный лимит : </TD>" skip.
else
put unformatted 
  "<TR valign=""top"">"
    "<TD> Максимальная сумма : </TD>" skip.

if pkanketa.crc = 1 then 
  put unformatted 
      "<TD>" v-sumkzt format ">>>>>>>>9.99" " тенге</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>&nbsp;</TD>" skip.

put unformatted 
    "<TD>" v-sumcrc format ">>>>>>>>9.99" " " v-crccod "</TD>" skip
  "</TR>" skip.

/* 13.06.2003 nadejda временно убрали
if v-lim = "06" then 
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Обеспечение : </TD>" skip
      "<TD> Дополнительное обеспечение </TD>" skip
    "</TR>" skip.
else
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Обеспечение : </TD>" skip
      "<TD> Нет </TD>" skip
    "</TR>" skip.
*/

put unformatted 
  "<TR valign=""top"">"
    "<TD>Вид карты : </TD>" skip
    "<TD>" v-card "</TD>" skip
  "</TR>" skip.
/*
if pkanketa.sernom = "" then do:
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Лимит на снятие наличности: </TD>" skip
      "<TD>" v-limit " % </TD>" skip
    "</TR>" skip.
end.
*/ 
put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Утвержденный кредитный лимит : </TD>" skip
    "<TD>" if pkanketa.sumq = 0 and pkanketa.sts < "10" then "&nbsp;" else string(pkanketa.sumq, ">>>>>>>>9.99") + " " + v-cod "</TD>" skip
  "</TR>" skip.

if pkanketa.sernom = "" then do:
  if s-credtype = '4' or s-credtype = '9' then do: 
     /* Изменения в анкете скоринга */   
     v-scoring = ''.
     for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
                             pkanketh.ln = s-pkankln no-lock.
     if (pkanketh.value3 <> '') and (pkanketh.value3 <> pkanketh.value4) then do:
        find pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
        if avail pkkrit then v-scoring = v-scoring + pkkrit.kritname + "; ".
     end.
     end.

     if v-scoring <> '' then
     put unformatted 
     "<TR valign=""top"">"
          "<TD >Изменения в анкете скоринга : </TD>" skip
          "<TD >" v-scoring "</TD>" skip
     "</TR>" skip.
  end.
end.

if s-credtype = '9' then do:
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
                             pkanketh.ln = s-pkankln and pkanketh.kritcod = 'clncrd' no-lock.
   find first lon where lon.lon = pkanketh.value1 no-lock no-error.
   if avail lon then do:
      find first cif where cif.cif = lon.cif and (lon.dam[1] - lon.cam[1] <> 0 ) no-lock no-error.
      if avail cif and cif.type = 'B' then
         put unformatted 
         "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
         "<TR valign=""top"">"
           "<TD > Клиент имеет непогашенный кредит! Необходимо вынести вопрос на рассмотрение МКК. </TD>" skip
           "<TD ></TD>" skip
         "</TR>" skip.
   end.
end.

if pkanketa.sts = '05' then do:
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "acclon" no-lock no-error.
  if avail pkanketh and pkanketh.value2 ne '' then 
     put unformatted 
     "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
     "<TR valign=""top"">"
          "<TD > КРЕДИТ ВЫНЕСЕН НА КРЕДИТНЫЙ КОМИТЕТ </TD>" skip
          "<TD ></TD>" skip
     "</TR>" skip.

end.

put unformatted 
  "</TABLE><BR><BR><BR><BR>" skip.

put unformatted 
  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR valign=""top"">"
    "<TD width=""30%"">Подготовил : </TD>" skip
    "<TD>&nbsp;</TD>" skip
    "<TD width=""40%"">&nbsp;</TD>" skip
  "</TR>" skip
  "<TR valign=""top"">"
    "<TD>" get-pksysc-char("mngr") "</TD>" skip
    "<TD><TABLE width=""70%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись</TD></TR>"
    "</TABLE></TD>" skip
    "<TD><TABLE width=""50%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""left"">" skip
      "<TR><TD align=""center"">" v-ofc "</TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">&nbsp;</TD></TR>"
    "</TABLE></TD>" skip
  "</TR>" skip
  "<TR valign=""top"">"
    "<TD>Дата : <U>" v-datastr "</U></TD>" skip
    "<TD>&nbsp;</TD>" skip
    "<TD>&nbsp;</TD>" skip
  "</TR>" skip
  "<TR>"
    "<TD>&nbsp;</TD>" skip
    "<TD>&nbsp;</TD>" skip
    "<TD>&nbsp;</TD>" skip
  "</TR>" skip
  "<TR valign=""top"">"
    "<TD>Контролер : </TD>" skip
    "<TD><TABLE width=""70%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись</TD></TR>"
    "</TABLE></TD>" skip
    "<TD><TABLE width=""50%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""left"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">ФИО</TD></TR>"
    "</TABLE></TD>" skip
  "</TR>" skip
  "</TABLE>" skip
  "</TD></TR></TABLE>" skip.


put unformatted "<br><br>" skip.


/*        28.04.2005 marinav - Добавлена вторая часть отчета БЭК-ОФИС*/

put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR valign=""top"">"
    "<TD width=""40%""><u><b>БЭК-ОФИС </b></u></TD>" skip
  "</TR><TR>&nbsp;</TR><br>" skip.

if pkanketa.sernom = "" then do:
put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Кредитный лимит установлен : </TD>" skip
    "<TD><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись исполнителя</TD></TR>"
    "</TABLE></TD>" skip
    "<TD><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""left"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись контролера</TD></TR>"
    "</TABLE></TD>" skip
  "</TR>" skip.

end.
else do:

put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Кредитный лимит установлен : </TD>" skip
    "<TD><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись исполнителя</TD></TR>"
    "</TABLE></TD>" skip
  "</TR>" skip.


find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "acc2" no-lock no-error.

if avail pkanketh then do:
  find first aas where aas.aaa = pkanketh.value1 and aas.payee = 'Кр лимит по п/к , анкета N ' + string(s-pkankln) no-lock no-error. 
  if avail aas then v-amt  = aas.chkamt.
  find first aaa where aaa.aaa = pkanketh.value1 no-lock no-error.
  if avail aaa then do:
     find first crc where crc.crc = aaa.crc no-lock no-error.
     if avail crc then v-crc = crc.code.
  end.

end.

put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Размер заблокированной суммы депозита : </TD>" skip
    "<TD align=""center"">" string(v-amt, ">>>>>>>>>>9.99") + " " + v-crc "</TD>" skip
  "</TR><TR></TR>" skip.

put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Спец.инструкция на депозит наложена : </TD>" skip
    "<TD><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись исполнителя</TD></TR>"
    "</TABLE></TD>" skip
    "<TD><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""left"">" skip
      "<TR><TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD></TR>" skip
      "<TR><TD align=""center"" style=""font-size:8px"">подпись контролера</TD></TR>"
    "</TABLE></TD>" skip
  "</TR>" skip.

end.

put unformatted 
  "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
  "<TR valign=""top"">"
    "<TD>Дата : _____________________</TD>" skip
  "</TR>" skip.

put unformatted 
  "</TABLE>" skip.


{html-end.i " " }

output close.

unix silent cptwin value(v-repfile) iexplore. 
pause 0.

