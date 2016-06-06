/* pkkkzakl.p
 * MODULE
        Название Программного Модуля
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
        31/12/99 pragma
 * CHANGES
        01.02.2004 nadejda - изменен формат вызова pkdefadres для совместимости
*/

/* pkkkzakl.p   ПотребКРЕДИТ
   Печать Заключения о предоставлении займа - Автокредиты

   14.03.2003 nadejda
*/

{global.i}
{pk.i}
{pk-sysc.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

/*
def shared temp-table t-anks
  field ln like pkanketa.ln
  index ln is primary unique ln.
*/

def var v-datastrkz as char no-undo.
def var v-repfile as char init "repankzakl.htm".
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
def var v-adresp1 as char.
def var v-adresf1 as char.
def var v-txb as char.
def var v-ofc as char.

output to value(v-repfile).

find first cmp no-lock no-error.
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.

v-txb = string(integer(substr(s-ourbank,4,2))).

v-titl1 = entry(1, get-pksysc-char("kklst")) no-error.
if error-status:error then do:
  message skip " Не найден первый параметр KKLST для данного вида кредита!" skip(1) view-as alert-box title "".
  v-titl1 = "имущество".
end.

v-titl2 = entry(2, get-pksysc-char("kklst")) no-error.
if error-status:error then do:
  message skip " Не найден второй параметр KKLST для данного вида кредита!" skip(1) view-as alert-box title "".
  v-titl2 = "магазина".
end.

{html-title.i 
 &stream = " "
 &title = "Заключение Департамента потребительского кредитования о предоставлении займа"
 &size-add = "x-"
}

put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
/*  "<TR><TD>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " " g-ofc "<BR></TD></TR>" skip*/
  "<TR><TD>" skip
  "<P align=""center""><B>ЗАКЛЮЧЕНИЕ<BR>Департамента потребительского кредитования " cmp.name 
  "<BR>о предоставлении займа на приобретение " get-pksysc-char("pkgoal") "</B></P>" skip.

v-num = 0.

run pkdefdtstr (g-today, output v-datastr, output v-datastrkz).

/*for each t-anks:
  find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = t-anks.ln no-lock no-error.
*/

  put unformatted 
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR valign=""top"">"
      "<TD width=""40%"">Заемщик : </TD>" skip
      "<TD width=""60%"">" pkanketa.name "</TD>" skip
    "</TR>" skip.

  run pkdefadres (pkanketa.ln, no, output v-adresp, output v-adresf, output v-adresp1, output v-adresf1).
  if v-adresp = "" then v-adresp = "&nbsp;".
  if v-adresf = "" then v-adresf = "&nbsp;".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "bdt" and pkanketh.value1 <> "" no-lock no-error.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Дата рождения : </TD>" skip
      "<TD>" if avail pkanketh then string(date(pkanketh.value1), "99/99/9999") else "&nbsp;" "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Адрес прописки : </TD>" skip
      "<TD>" v-adresp "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Место жительства : </TD>" skip
      "<TD>" v-adresf "</TD>" skip
    "</TR>" skip.

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "joborg" no-lock no-error.
  if avail pkanketh then v-info = pkanketh.value1.
                    else v-info = "".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "jobadd" no-lock no-error.
  if avail pkanketh then do:
    if v-info <> "" then v-info = v-info + ", ".
    v-info = v-info + "адрес : " + pkanketh.value1.
  end.
  if v-info = "" then v-info = "&nbsp;".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "jobsn" and pkanketh.value1 <> "" no-lock no-error.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Место работы : </TD>" skip
      "<TD>" v-info "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Должность : </TD>" skip
      "<TD>" if avail pkanketh then pkanketh.value1 else "&nbsp;" "</TD>" skip
    "</TR>" skip.

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "jobother" no-lock no-error.
  if avail pkanketh then v-info = pkanketh.value1.
                    else v-info = "&nbsp;".
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "jobothersn" and pkanketh.value1 <> "" no-lock no-error.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Работа по совместительству : </TD>" skip
      "<TD>" v-info "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Должность : </TD>" skip
      "<TD>" if avail pkanketh then pkanketh.value1 else "&nbsp;" "</TD>" skip
    "</TR>" skip.

  
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "family" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then do:
    find bookcod where bookcod.bookcod = "pkankfam" and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-info = bookcod.name.
                     else v-info = "&nbsp;".
  end.
  else v-info = "&nbsp;".

  
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Семейное положение : </TD>" skip
      "<TD>" v-info "</TD>" skip
    "</TR>" skip                                
    "<TR valign=""top"">".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "childin" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then v-infi = integer(pkanketh.value1).
                                              else v-infi = 0.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "childout" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then v-infi = v-infi + integer(pkanketh.value1).
  put unformatted 
      "<TD>Наличие детей : </TD>" skip
      "<TD>" v-infi "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "nedv" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then do:
    v-info = pkanketh.value1.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "nedvkomn" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "колич.комнат : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "nedvsquar" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "общая площадь : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "nedvz" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "залог.обременение : " + pkanketh.value1.
    end.
  end.
  else v-info = "&nbsp;".

  put unformatted 
      "<TD>Недвижимость в собственности : </TD>" skip
      "<TD>" v-info "</TD>" skip
    "</TR>" skip.

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "auto" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then do:
    v-info = pkanketh.value1.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "autom" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "марка : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "autoy" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "год : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "autoz" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if v-info <> "" then v-info = v-info + ", ".
      v-info = v-info + "залог.обременение : " + pkanketh.value1.
    end.
  end.
  else v-info = "&nbsp;".

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "ak1" and pkanketh.value1 <> "" no-lock no-error.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Автотранспортное средство в собственности : </TD>" skip
      "<TD>" v-info "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Наличие банковских счетов : </TD>" skip
      "<TD>" if avail pkanketh then pkanketh.value1 else "0" "</TD>" skip
    "</TR>" skip.

  v-infi = 0.
  for each pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod matches "ob." no-lock:
    if pkanketh.value1 <> "" then v-infi = v-infi + integer(pkanketh.value1).
  end.

  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "autosalon" and pkanketh.value1 <> "" no-lock no-error.
  find crc where crc.crc = pkanketa.crc no-lock no-error.
  put unformatted 
    "<TR valign=""top"">"
      "<TD>Обязательства перед другими кредиторами : </TD>" skip
      "<TD>" v-infi "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Фирма-Продавец : </TD>" skip
      "<TD>" if avail pkanketh then pkanketh.value1 else "&nbsp;" "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Модель приобретаемого " get-pksysc-char("pkgoal") " : </TD>" skip
      "<TD>" pkanketa.goal "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Продажная стоимость " get-pksysc-char("pkgoal") " : </TD>" skip
      "<TD>" pkanketa.billsum "&nbsp;" crc.code "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Размер авансового платежа : </TD>" skip
      "<TD>" pkanketa.sumavans "&nbsp;" crc.code " (" pkanketa.sumavans% "%)</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Сумма займа : </TD>" skip
      "<TD>" pkanketa.sumq "&nbsp;" crc.code "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Срок займа : </TD>" skip
      "<TD>" pkanketa.srok " мес.</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Ставка вознаграждения : </TD>" skip
      "<TD>" pkanketa.rateq "%</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Обеспечение : </TD>" skip
      "<TD>" get-pksysc-char("pkobes") "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Погашение : </TD>" skip
      "<TD>ежемесячно, равными долями</TD>" skip
    "</TR>" skip
   "</TABLE>" skip.

  put unformatted 
    "<P><B>Анализ финансового состояния.</B><BR>" skip
       "Средний ежемесячный доход Заявителя составляет <U>" fill("&nbsp;", 15) "</U>.<BR>" skip
       "Средний ежемесячный доход супруга(ги) Заявителя составляет <U>" fill("&nbsp;", 15) "</U>.<BR>" skip
       "Прочие доходы <U>" fill("&nbsp;", 15) "</U>.<BR>" skip
       "Итого общий ежемесячный доход равен в среднем <U>" fill("&nbsp;", 15) "</U>.<BR>" skip
       "Суммы выплат по предполагаемому займу, включая основной долг и вознаграждение, будут составлять от <U>" fill("&nbsp;", 15) "</U> " crc.code " до <U>" fill("&nbsp;", 15) "</U> " crc.code ".<BR>" skip
       "При этом расходы Заявителя, относящиеся к обязательным ежемесячным платежам в месяц, составляют <U>" fill("&nbsp;", 15) "</U>.<BR>" skip
       "Из вышеизложенного следует, что Заявитель способен производить выплаты по займу за счет собственных средств, при этом у Заявителя будет оставаться достаточно средств для расходов на социальные нужды.<BR>" skip 
       "Считаю возможным выдачу займа <U>" fill("&nbsp;", 30) "</U> в сумме <U>" fill("&nbsp;", 15) "</U> " crc.code ", сроком на <U>" fill("&nbsp;", 5) "</U> месяцев." skip
    "</P>" skip.

  find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
  v-ofc = entry(1, ofc.name, " ").
  if num-entries(ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, ofc.name, " "), 1, 1) + ".".
  if num-entries(ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, ofc.name, " "), 1, 1) + ".".

  put unformatted 
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR valign=""top"">"
      "<TD width=""45%"">Подготовил : </TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD width=""30%"">&nbsp;</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>" get-pksysc-char("mngr") "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>" v-ofc "</TD>" skip
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
      "<TD>Согласовано : </TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>" entry(2, get-pksysc-char("mngrh" + v-txb)) "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>" entry(1, get-pksysc-char("mngrh" + v-txb)) "</TD>" skip
    "</TR>" skip
    "<TR valign=""top"">"
      "<TD>Дата : <U>" v-datastr "</U></TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR></TABLE>" skip.
/*end.*/

put unformatted 
  "</TD></TR>"
  "</TABLE>" skip.

{html-end.i " " }

output close.
unix silent value("cptwin " + v-repfile + " winword"). 

pause 0.

