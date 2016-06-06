/* vcrepfr.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Список клиентов с контрактами
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-15
 * AUTHOR
        09.10.2003 nadejda
 * CHANGES
        11.01.2004 nadejda - список по формам расчетов переделан на полный список клиентов валютного контроля с контрактами
*/

{vc.i}
{mainhead.i}
{get-dep.i}

def var v-depart as integer.
def var v-dt as date format "99/99/9999".
def var v-icif as integer.
def var v-closed as logical.
def var v-depcurrent as integer.
def var v-daysgtd as integer.
def var v-dayspl as char.
def var v-daysdolg as integer init 120.

def temp-table t-cif
  field cif like cif.cif
  field name like cif.name
  index cif is primary unique name cif.

{comm-txb.i}
def var s-vcourbank as char.
s-vcourbank = comm-txb().

def stream vcrpt.


v-dt = g-today.

update skip(1) 
   v-dt     label "         Отчетная дата " " " skip(1)
   v-closed label " Закрытые показывать ? " format "да/нет" skip(1)
   with side-label centered row 4 title " ПАРАМЕТРЫ ОТЧЕТА : ".


message "  Формируется отчет...".

v-depcurrent = get-dep (g-ofc, g-today).

/* список клиентов по контрактам */
for each vccontrs where vccontrs.bank = s-vcourbank and vccontrs.ctdate <= v-dt no-lock :
  if not v-closed and vccontrs.sts begins "C" and vccontrs.stsdt <= v-dt then next.

  
  /* определить, где обслуживается клиент */
  v-depart = 0.
  find last vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dndate <= v-dt no-lock no-error.
  if avail vcdocs and vcdocs.rwho <> "" then do:
    /* по документам контракта */
    v-depart = get-dep (vcdocs.rwho, vcdocs.rdt).
  end.
  else do:
    if vccontrs.cttype = "1" then do:
      /* попробуем по паспорту сделки или доплисту */
      find last vcps where vcps.contract = vccontrs.contract and vcps.dndate <= v-dt no-lock no-error.
      if avail vcps and vcps.rwho <> "" then v-depart = get-dep (vcps.rwho, vcps.rdt).
    end.
  end.

  if v-depart = 0 then do:
    /* по офицеру, акцептовавшему контракт */
    if vccontrs.cwho <> "" then do:
      v-depart = get-dep (vccontrs.cwho, vccontrs.cdt).
    end.
    else do:
      /* по офицеру, внесшему контракт, если это не nadejda (nadejda => автоматически внесено при импорте из старой базы) */
      if vccontrs.rwho <> "" and vccontrs.rwho <> "nadejda" then v-depart = get-dep (vccontrs.rwho, vccontrs.rdt).
    end.
  end.

  if v-depart = 0 then do:
    /* на крайний случай - по осблуживающему департаменту (клиент иногда обслуживается по валютным счетам не там, где по тенговым !) */
    find cif where cif.cif = vccontrs.cif no-lock no-error.
    v-depart = integer (cif.jame) mod 1000.
  end.

  /* список только клиентов текущего подразделения */
  if v-depart <> v-depcurrent then next.

  find t-cif where t-cif.cif = vccontrs.cif no-error.
  if not avail t-cif then do:
    find cif where cif.cif = vccontrs.cif no-lock no-error.
    create t-cif.
    assign t-cif.cif = vccontrs.cif
           t-cif.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
  end.
end.

find first cmp no-lock no-error.
find first ppoint where ppoint.depart = v-depcurrent no-lock no-error.

output stream vcrpt to vcrep.html.

{html-title.i &title ="Список клиентов валютного контроля" &size-add = "x-" &stream = " stream vcrpt " }



put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Список клиентов " cmp.name ", имеющих валютные контракты<BR><BR>на " skip
   string(v-dt, "99/99/9999") "</B></FONT></P>" skip
   "<P><FONT face=""Times New Roman Cyr, Verdana, sans""><B>Департамент : " ppoint.name "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR style=""font-size:xx-small;font:bold"" align=""center"">" skip
     "<TD width=""5%"" align=""center"">N</TD>" skip
     "<TD>Код<BR>клиента</TD>" skip
     "<TD>Наименование клиента<BR>N контракта</TD>" skip
     "<TD>Дата<BR>контракта</TD>" skip
     "<TD>Тип</TD>" skip
     "<TD>Эксп/Имп</TD>" skip
     "<TD>Статус<BR>контракта</TD>" skip
     "<TD>Валюта<BR>контракта</TD>" skip
     "<TD>Сумма<BR>контракта</TD>" skip
     "<TD>N паспорта<BR>сделки</TD>" skip
     "<TD>Дата ПС</TD>" skip
     "<TD>Отсутств<BR>ГТД<BR>(дни)</TD>" skip
     "<TD>Последняя<BR>оплата<BR>(дни)</TD>" skip
   "</TR>" skip.

v-icif = 0.
for each t-cif :
  v-icif = v-icif + 1.

  put stream vcrpt unformatted
    "<TR valign = ""top"" style=""font:bold"">" skip 
      "<TD>" string(v-icif) "</TD>" skip
      "<TD align=""center"">" t-cif.cif "</TD>" skip
      "<TD>" t-cif.name "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR>" skip.

  for each vccontrs where vccontrs.cif = t-cif.cif and vccontrs.ctdate <= v-dt no-lock break by cttype by ctdate by expimp:
    if not v-closed and vccontrs.sts begins "C" and vccontrs.stsdt <= v-dt then next.

    find first ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" and vcps.dndate <= v-dt no-lock no-error.

    /* для контрактов без ПС найти, когда была последняя ГТД */
    v-daysgtd = 0.
    v-dayspl = "&nbsp;".
    if vccontrs.cttype = "2" and not vccontrs.sts begins "C" then do:
      find last vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "14" and 
                       vcdocs.dndate <= v-dt and
                       vcdocs.payret = false 
                       no-lock  use-index docret no-error.
      if avail vcdocs then do:
        if v-dt - vcdocs.dndate > v-daysdolg then v-daysgtd = v-dt - vcdocs.dndate.
      end.
      else do:
        if v-dt - vccontrs.ctdate > v-daysdolg then v-daysgtd = v-dt - vccontrs.ctdate.
      end.
    end.

    /* если по ГТД задолженность - найти, когда была последняя проплата */
    if v-daysgtd > 0 then do:
      if vccontrs.expimp = "e" then
        find last vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "02" and 
                         vcdocs.dndate <= v-dt and
                         vcdocs.payret = false 
                         no-lock use-index docret no-error.
      else
        find last vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "03" and 
                         vcdocs.dndate <= v-dt and
                         vcdocs.payret = false 
                         no-lock use-index docret no-error.

      if avail vcdocs then v-dayspl = string (v-dt - vcdocs.dndate).
                      else v-dayspl = "нет оплаты".
    end.

    put stream vcrpt unformatted
      "<TR>" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;" vccontrs.ctnum "</TD>" skip
        "<TD align=""center"">" string (vccontrs.ctdate, "99/99/9999") "</TD>" skip
        "<TD align=""center"">" vccontrs.cttype "</TD>" skip
        "<TD align=""center"">" caps(vccontrs.expimp) "</TD>" skip
        "<TD align=""center"">" vccontrs.sts "</TD>" skip
        "<TD align=""center"">" ncrc.code "</TD>" skip
        "<TD align=""right"">" replace (string (vccontrs.ctsum , ">>>>>>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
        "<TD>" if vccontrs.cttype = "1" and avail vcps then vcps.dnnum else "&nbsp;" "</TD>" skip
        "<TD align=""center"">" if vccontrs.cttype = "1" and avail vcps then string (vcps.dndate, "99/99/9999") else "&nbsp;" "</TD>" skip
        "<TD align=""center"">" if v-daysgtd = 0 then "&nbsp;" else string (v-daysgtd) "</TD>" skip
        "<TD align=""center"">" v-dayspl "</TD>" skip
      "</TR>" skip.
  end.
    
  put stream vcrpt unformatted
      "<TR><TD>&nbsp;</TD></TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i " stream vcrpt " }


output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcrep.html excel.

pause 0.





