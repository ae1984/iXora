/* r-arpd2.p
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

/* r-arpd2.p
   Отчет по аккредитивам и гарантиям

   12.03.2003 nadejda
*/

{mainhead.i}

def var v-bal as deci.
def var v-balrate as deci.
def var sum-bal as deci.
def var sum-balra as deci.
def var gl-balra as deci.

def var v-asof as date.
def var varp like arp.gl.
def var v-bank as char.
def var v-zerobal as logical init yes.
def var v-file as char init "akkred.htm".
def var i as integer.

def temp-table t-gls
  field gl like gl.gl
  index gl is primary unique gl.

def temp-table t-arp like arp
  field bal as deci
  field balrate as deci
  index main is primary unique gl crc arp.

def buffer b-jl for jl.

def var v-akkred as char init "600510,605560,285500,605530".
find sysc where sysc.sysc = "glakks" no-lock no-error.
if avail sysc then v-akkred = sysc.chval.

v-asof = g-today.

update 
    skip(1) 
    v-asof label "  ОТЧЕТНАЯ ДАТА " "  "
    skip(1)
    with centered overlay row 8 side-label title " ПАРАМЕТРЫ ОТЧЕТА " frame f-opt.


do i = 1 to num-entries(v-akkred):
  create t-gls.
  t-gls.gl = integer(entry(i, v-akkred)).
end.

for each t-gls:
  find gl where gl.gl = t-gls.gl no-lock no-error.

  for each arp no-lock where arp.gl = t-gls.gl break by arp.crc:
    /* остаток на счету на текущий момент */
    if gl.type = "A"
        then v-bal = arp.dam[1] - arp.cam[1].
    else
        v-bal = arp.cam[1] - arp.dam[1].

    /* остаток на счету на дату запроса */
    for each jl no-lock where jl.gl = arp.gl and jl.acc = arp.arp
        and jl.jdt > v-asof by jl.jdt:

      if gl.type = "A" or gl.type = "E" then
          v-bal = v-bal - jl.dam + jl.cam.
      else
          v-bal = v-bal + jl.dam - jl.cam.
    end.

    if first-of(arp.crc) then 
      find last crchis where crchis.crc = arp.crc and crchis.rdt <= v-asof no-lock no-error.

    if v-bal > 0 then do:
      create t-arp.
      buffer-copy arp to t-arp.
      t-arp.bal = v-bal.

      if arp.crc = 1 then t-arp.balrate = v-bal.
                     else t-arp.balrate = v-bal * crchis.rate[1] / crchis.rate[9].

    end.
  end.
end.

output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted 
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD>" skip
    "<P align = ""center""><B><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
    "ОТЧЕТ ПО АККРЕДИТИВАМ И ГАРАНТИЯМ<BR>на " + string(v-asof) + "</FONT></B></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
    "<TR align=""center"" style=""font-size:xx-small;font:bold"">" skip
      "<TD>N КАРТОЧКИ</TD>" skip
      "<TD>НАЗВАНИЕ КОМПАНИИ</TD>" skip
      "<TD>N ДОКУМЕНТА</TD>" skip
      "<TD>СУММА</TD>" skip
      "<TD>ВАЛЮТА</TD>" skip
      "<TD>СУММА В ТЕНГЕ</TD>" skip
      "<TD>ДАТА ПОГАШЕНИЯ</TD>" skip
      "<TD>СРЕДНЕВЗВ.КУРС</TD>" skip
    "</TR>" skip.


for each t-arp break by t-arp.gl by t-arp.crc by t-arp.arp:
  if first-of(t-arp.gl) then do:
    find gl where gl.gl = t-arp.gl no-lock no-error.
    put unformatted 
      "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip
      "<TR><TD colspan=""8""><B><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">СЧЕТ ГК : " gl.gl "  " gl.des "</FONT></B></TD></TR>" skip.
  end.

  if first-of(t-arp.crc) then do:
    find last crchis where crchis.crc = t-arp.crc and crchis.rdt <= v-asof no-lock no-error.
  end.

  accumulate t-arp.bal (sub-total by t-arp.gl by t-arp.crc).
  accumulate t-arp.balrate (total by t-arp.gl by t-arp.crc).

  find cif where cif.cif = t-arp.cif no-lock no-error.

  put unformatted 
    "<TR>" skip
      "<TD>&nbsp;" t-arp.arp "</TD>" skip
      "<TD>" if avail cif then trim(trim(cif.prefix) + " " + trim(cif.name))
                          else "&nbsp;"
      "</TD>" skip
      "<TD>" t-arp.des "</TD>" skip
      "<TD align=""right"">" t-arp.bal format "zzz,zzz,zzz,zz9.99-" "</TD>" skip
      "<TD align=""center"">" crchis.code "</TD>" skip
      "<TD align=""right"">" t-arp.balrate format "zzz,zzz,zzz,zz9.99-" "</TD>" skip
      "<TD align=""center"">" t-arp.duedt "</TD>" skip
      "<TD align=""right"">&nbsp;" crchis.rate[1] format "zzzzzz9.9999" "</TD></TR>" skip.

  if last-of(t-arp.crc) then do:
    put unformatted 
      "<TR style=""font:bold"">" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>Итого по валюте:</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD align=""right"">" (accum sub-total by t-arp.crc t-arp.bal) format "zzz,zzz,zzz,zz9.99-" "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD align=""right"">" (accum sub-total by t-arp.crc t-arp.balrate) format "zzz,zzz,zzz,zz9.99-" "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD></TR>" skip
      "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip.


  end.

  if last-of(t-arp.gl) then do:
    put unformatted 
      "<TR style=""font:bold"">" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>Итого по счету ГК:</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD align=""right"">" accum sub-total by t-arp.gl t-arp.balrate format "zzz,zzz,zzz,zz9.99-" "</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD></TR>" skip.
  end.
end.

put unformatted "</TABLE></TABLE>" skip.

{html-end.i " "}

output close.

unix silent value("cptwin " + v-file + " excel").
