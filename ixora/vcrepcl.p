/* vcrepcl.p
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
*/

/* vcctrppl.p - Валютный контроль 
   Список клиентов с контрактами, по которым были проплаты USD за указанный период 

   30.05.2003 nadejda создан

*/


{mainhead.i}
{vc.i}

{name2sort.i}

def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sum0 as deci.
def var v-sumcon as deci.
def var v-sumkzt as deci.
def var v-sumstr as char.
def var v-depart as integer.
def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".
def var v-dnvid as char.
def var v-doctypes as char.
def var v-icif as integer.
def var v-icontract as integer.
def var v-idocs as integer.
def var v-koldocs as integer.
def var v-prim as char.
def var v-maxnum like vcdocs.docs.
def var v-sign as char.
def var v-crc like crc.crc init 2.
def var v-crccod as char.

def temp-table t-cif
  field nmsort like cif.name
  field cif like cif.cif
  field name like cif.name
  field crc like crc.crc
  field kolpl as integer
  field sumpl as deci
  index main is primary nmsort cif.

{comm-txb.i}
def var s-vcourbank as char.
s-vcourbank = comm-txb().

def stream vcrpt.
output stream vcrpt to vcrep.htm.

v-dtb = date("01/" + string(month(g-today), "99") + "/" + string(year(g-today), "9999")).
v-dte = g-today.

find crc where crc.crc = v-crc no-lock no-error.
v-crccod = crc.code.

displ skip(1) 
   v-dtb label "  НАЧАЛО ПЕРИОДА " skip 
   v-dte label "   КОНЕЦ ПЕРИОДА " skip(1) 
   v-crc label " ВАЛЮТА ПЛАТЕЖЕЙ " 
     help " Задайте код валюты проплат или 0 - все валюты"
     validate (v-crc = 0 or can-find(crc where crc.crc = v-crc no-lock), " Неверный код валюты !")
   v-crccod no-label format "x(12)" skip(1)
   with side-label centered row 5 title " ВВЕДИТЕ ПАРАМЕТРЫ ОТЧЕТА : " frame f-param.

update v-dtb v-dte v-crc with frame f-param.

if v-crc = 0 then v-crccod = "все валюты".
else do:
  find crc where crc.crc = v-crc no-lock no-error.
  v-crccod = crc.code.
end.            

displ v-crccod with frame f-param.

message "  Формируется отчет...".



for each vcdocs where vcdocs.dntype = "03"
       and vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte 
       and not vcdocs.payret
       and vcdocs.sum <> 0 no-lock break by vcdocs.contract by vcdocs.pcrc:

  if first-of(vcdocs.pcrc) then do:
    v-idocs = 0.
  end.

  if v-crc = 0 or vcdocs.pcrc = v-crc then do:

    accumulate vcdocs.docs (sub-count by vcdocs.contract by vcdocs.pcrc).
    accumulate vcdocs.sum  (sub-total by vcdocs.contract by vcdocs.pcrc).

    v-idocs = v-idocs + 1.
  end.

  if last-of (vcdocs.pcrc) and v-idocs > 0 then do:
    find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
    if vccontrs.bank = s-vcourbank and vccontrs.cttype <> "3" then do:
      find t-cif where t-cif.cif = vccontrs.cif and t-cif.crc = vcdocs.pcrc no-error.
      if not avail t-cif then do:
        find cif where cif.cif = vccontrs.cif no-lock no-error.
        create t-cif.
        assign t-cif.cif = vccontrs.cif
               t-cif.name = trim(trim(cif.prefix) + " " + trim(cif.name))
               t-cif.crc = vcdocs.pcrc.
        t-cif.nmsort = name2sort(t-cif.name).
      end.
      t-cif.kolpl = t-cif.kolpl + accum sub-count by vcdocs.pcrc vcdocs.docs.
      t-cif.sumpl = t-cif.sumpl + accum sub-total by vcdocs.pcrc vcdocs.sum.
    end.
  end.
end.


{html-title.i &stream = "stream vcrpt" &title = " " &size-add = "x-"}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Список клиентов АО TEXAKABANK, имеющих валютные контракты," + "<BR></B></FONT></P>" skip
     "<P align = ""center""><B> по которым были сделаны проплаты с " + string(v-dtb, "99/99/99") + 
     " по " + string(v-dte, "99/99/99") + "</B><BR><BR>" skip
     "валюта : " v-crccod skip
     "<BR></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD>N</TD><TD>КОД КЛ</TD><TD>КЛИЕНТ</TD>" skip
     if v-crc = 0 then "<TD>ВАЛЮТА</TD>" else ""
     "<TD>КОЛИЧ.<BR>ПЛАТЕЖЕЙ</TD><TD>СУММА ПЛАТЕЖЕЙ</TD></TR>" skip.

v-icif = 0.
for each t-cif break by t-cif.nmsort by t-cif.cif by t-cif.crc:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip.

  if first-of (t-cif.cif) then do:
    v-icif = v-icif + 1.
    put stream vcrpt unformatted
        "<TD align=""right"">" v-icif "</TD>" skip
        "<TD align=""left"">" t-cif.cif "</TD>" skip
        "<TD>" t-cif.name "</TD>" skip.
  end.
  else do:
    put stream vcrpt unformatted
        "<TD colspan=""3"">&nbsp;</TD>" skip.
  end.

  if v-crc = 0 then do:
    find crc where crc.crc = t-cif.crc no-lock no-error.
    put stream vcrpt unformatted "<TD align=""center"">" crc.code "</TD>" skip.
  end.

  put stream vcrpt unformatted
      "<TD align=""right"">" t-cif.kolpl "</TD>" skip
      "<TD align=""right"">" trim(string(t-cif.sumpl, ">>>,>>>,>>>,>>>,>>9.99")) "</TD>" skip
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "<TR><TD colspan=""" if v-crc = 0 then "6" else "5" """>&nbsp;</TD></TR><TR valign=""top"">" skip
    "<TD colspan=""" if v-crc = 0 then "6" else "5" """><B>ИТОГО</B></TD></TR>" skip.

for each t-cif break by t-cif.crc:
  accumulate t-cif.kolpl (sub-total by t-cif.crc).
  accumulate t-cif.sumpl (sub-total by t-cif.crc).

  if last-of(t-cif.crc) then do:
    find crc where crc.crc = t-cif.crc no-lock no-error.
    put stream vcrpt unformatted
      "<TR align=""right""><TD colspan=""3"">&nbsp;</TD>" skip
        "<TD align=""center"">" crc.code "</TD>" skip
        "<TD>" (accum sub-total by t-cif.crc t-cif.kolpl) "</TD>" skip
        "<TD>" trim(string((accum sub-total by t-cif.crc t-cif.sumpl), ">>>,>>>,>>>,>>>,>>9.99")) "</TD>" skip
      "</TR>" skip.
  end.
end.


put stream vcrpt unformatted
  "</TABLE>" skip
  "<BR><BR>" skip(1).

{html-end.i "stream vcrpt"}


output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcrep.htm iexplore.






