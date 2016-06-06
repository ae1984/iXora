/* r-arpd1.p
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

/* r-arpd1.p
   остаток на счетах ARP на заданную дату по счету главной книги 600510 (аккредитивы)

   12.03.2003 nadejda - копия r-arpdat.p с добавлением привязанных счетов с ГК = 185500 и исполняющим банком
*/

{mainhead.i}
{name2sort.i}

def var v-bal as deci.
def var v-balrate as deci.
def var v-balbank as deci.
def var sum-bal as deci.
def var sum-balrate as deci.

def var v-asof as date.
def var varp like arp.gl.
def var v-bank as char.
def var v-zerobal as logical init yes.
def var v-sortbnk as logical init no.
def var i as integer.
def var v-file as char init "akkred.htm".

def temp-table t-gls
  field gl like gl.gl
  index gl is primary unique gl.

def temp-table t-arp like arp
  field bal as deci
  field balrate as deci
  index spby spby.

def temp-table t-arpfin like arp
  field bal as deci
  field balrate as deci
  field bankname as char
  field banksort as char
  index main is primary unique gl crc arp
  index bnk is unique gl banksort crc arp.



def buffer b-jl for jl.

def var v-akkred as char init "600510".
find sysc where sysc.sysc = "glakkr" no-lock no-error.
if avail sysc then v-akkred = sysc.chval.

def var v-deb as char init "185500".
find sysc where sysc.sysc = "gldebs" no-lock no-error.
if avail sysc then v-deb = sysc.chval.

v-asof = g-today.

update 
    skip(1) 
    v-asof    label "ОТЧЕТНАЯ ДАТА "         colon 25 "  "
    v-zerobal label "СЧЕТА С ОСТАТКОМ >0 ? " colon 25 "  "
    v-sortbnk label "ПО ИСПОЛН. БАНКАМ ? "   colon 25 "  "
    skip(1)
    with centered overlay row 8 side-label title " ПАРАМЕТРЫ ОТЧЕТА " frame f-opt.


do i = 1 to num-entries(v-deb):
  create t-gls.
  t-gls.gl = integer(entry(i, v-deb)).
end.

for each t-gls:
  for each arp no-lock where arp.gl = t-gls.gl:
    if arp.spby <> "" then do:
      create t-arp.
      buffer-copy arp to t-arp.

      find gl where gl.gl = arp.gl no-lock no-error.

      /* остаток на счету на текущий момент */
      if gl.type = "A"
          then t-arp.bal = arp.dam[1] - arp.cam[1].
      else
          t-arp.bal = arp.cam[1] - arp.dam[1].

      /* остаток на счету на дату запроса */
      for each jl no-lock where jl.gl = arp.gl and jl.acc = arp.arp
          and jl.jdt > v-asof by jl.jdt:

          if gl.type = "A" or gl.type = "E" then
              t-arp.bal = t-arp.bal - jl.dam + jl.cam.
          else
              t-arp.bal = t-arp.bal + jl.dam - jl.cam.
          end.

      if arp.crc <> 1 then do:
          find last crchis where crchis.crc = arp.crc and crchis.rdt <= v-asof
              no-lock no-error.
          t-arp.balrate = t-arp.bal * crchis.rate[1] / crchis.rate[9].
      end.
      else
          t-arp.balrate = t-arp.bal.
    end.
  end.
end.


for each t-gls. delete t-gls. end.
do i = 1 to num-entries(v-akkred):
  create t-gls.
  t-gls.gl = integer(entry(i, v-akkred)).
end.

for each t-gls:
  find gl where gl.gl = t-gls.gl no-lock.

  for each arp no-lock where arp.gl = t-gls.gl break by arp.crc:

      /* остаток на счету на текущий момент */
      if gl.type = "A"
          then v-bal = arp.dam[1] - arp.cam[1].
      else
          v-bal = arp.cam[1] - arp.dam[1].

      /* остаток на счету на дату запроса */
      for each jl no-lock where jl.gl = arp.gl and jl.acc = arp.arp and jl.jdt > v-asof by jl.jdt:
        if gl.type = "A" or gl.type = "E" then
            v-bal = v-bal - jl.dam + jl.cam.
        else
            v-bal = v-bal + jl.dam - jl.cam.
      end.

      if first-of(arp.crc) then 
        find last crchis where crchis.crc = arp.crc and crchis.rdt <= v-asof no-lock no-error.

      /* найти связанную дебеторскую карточку */
      find t-arp where t-arp.spby = arp.arp use-index spby no-lock no-error.

      if not v-zerobal or (v-zerobal and (v-bal > 0 or (avail t-arp and t-arp.bal > 0))) then do:
        create t-arpfin.
        buffer-copy arp to t-arpfin.
        t-arpfin.bal = v-bal.

        if arp.crc = 1 then t-arpfin.balrate = v-bal.
                       else t-arpfin.balrate = v-bal * crchis.rate[1] / crchis.rate[9].

        find bankl where bankl.bank = arp.reason no-lock no-error.
        if avail bankl then t-arpfin.bankname = bankl.name.
                       else t-arpfin.bankname = arp.reason.
        t-arpfin.banksort = name2sort(t-arpfin.bankname).
      end.
  end.
end.

output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "xx-"
}

put unformatted 
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD>" skip
    "<P align = ""center""><B><FONT size=""3"">"
    "ARP ОСТАТКИ ЗА : " + string(v-asof) + "</FONT></B></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
    "<TR align=""center"" style=""font-size:10px;font:bold"">" skip
      "<TD>N КАРТОЧКИ</TD>" skip
      "<TD>С</TD>" skip
      "<TD>ПО</TD>" skip
      "<TD>ТИП</TD>" skip
      "<TD>РИСК</TD>" skip
      "<TD>ОПИСАНИЕ</TD>" skip
      "<TD>ИСПОЛНЯЮЩИЙ<BR>БАНК</TD>" skip
      "<TD>ГЕО</TD>" skip
      "<TD>ВАЛЮТА</TD>" skip
      "<TD>СУММА</TD>" skip
      "<TD>СУММА<BR>В ТЕНГЕ</TD>" skip
      "<TD>ДЕБ.<BR>КАРТ.</TD>" skip
      "<TD>СУММА</TD>" skip
      "<TD>СУММА<BR>В ТЕНГЕ</TD>" skip
    "</TR>" skip.

if v-sortbnk then do:
  for each t-arpfin break by t-arpfin.gl by t-arpfin.banksort by t-arpfin.crc by t-arpfin.arp:
    if first-of(t-arpfin.gl) then do:
      find gl where gl.gl = t-arpfin.gl no-lock no-error.
      put unformatted 
        "<TR><TD colspan=""14"">&nbsp;</TD></TR>" skip
        "<TR><TD colspan=""14""><B><FONT size=""2"">СЧЕТ ГК : " gl.gl "  " gl.des "</FONT></B></TD></TR>" skip.
      v-balrate = 0.
    end.

    if first-of(t-arpfin.banksort) then do:
      put unformatted 
        "<TR><TD colspan=""14"">&nbsp;</TD></TR>" skip
        "<TR><TD colspan=""14""><B><FONT size=""2"">ИСПОЛНЯЮЩИЙ БАНК : " t-arpfin.bankname "</FONT></B></TD></TR>" skip.
      v-balbank = 0.
    end.

    if first-of(t-arpfin.crc) then do:
      find last crchis where crchis.crc = t-arpfin.crc and crchis.rdt <= v-asof no-lock no-error.
      sum-bal = 0.
      sum-balrate = 0.
    end.

    accumulate t-arpfin.bal (sub-total by t-arpfin.gl by t-arpfin.banksort by t-arpfin.crc).
    accumulate t-arpfin.balrate (total by t-arpfin.gl by t-arpfin.banksort by t-arpfin.crc).

    find cif where cif.cif = t-arpfin.cif no-lock no-error.
    /* найти связанную дебеторскую карточку */
    find t-arp where t-arp.spby = t-arpfin.arp use-index spby no-lock no-error.
    if avail t-arp then do:
      sum-bal = sum-bal + t-arp.bal.
      sum-balrate = sum-balrate + t-arp.balrate.
    end.

    put unformatted 
      "<TR>" skip
        "<TD>&nbsp;" t-arpfin.arp "</TD>" skip
        "<TD align=""center"">" t-arpfin.rdt "</TD>" skip
        "<TD align=""center"">" t-arpfin.duedt "</TD>" skip
        "<TD align=""center"">&nbsp;" t-arpfin.type format "999" "</TD>" skip
        "<TD>" t-arpfin.risk "</TD>" skip
        "<TD>" t-arpfin.des "</TD>" skip
        "<TD>" t-arpfin.bankname "</TD>" skip
        "<TD align=""center"">&nbsp;" t-arpfin.geo "</TD>" skip
        "<TD align=""center"">" crchis.code "</TD>" skip
        "<TD align=""right"">" string(t-arpfin.bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;" if avail t-arp then t-arp.arp else "" "</TD>" skip
        "<TD align=""right"">" if avail t-arp then string(t-arp.bal, "->>>,>>>,>>>,>>9.99") else "&nbsp;" "</TD>" skip
        "<TD align=""right"">" if avail t-arp then string(t-arp.balrate, "->>>,>>>,>>>,>>9.99") else "&nbsp;" "</TD>" skip.

    if last-of(t-arpfin.crc) then do:
      put unformatted 
        "<TR style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Итого по валюте:</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.crc t-arpfin.bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.crc t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(sum-bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(sum-balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "</TR>" skip
        "<TR><TD colspan=""14"">&nbsp;</TD></TR>" skip.

      v-balbank = v-balbank + sum-balrate.
      v-balrate = v-balrate + sum-balrate.
    end.

    if last-of(t-arpfin.banksort) then do:
      put unformatted 
        "<TR style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Итого по исполняющему банку:</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.banksort t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(v-balbank, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "</TR>" skip.
    end.

    if last-of(t-arpfin.gl) then do:
      put unformatted 
        "<TR style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Итого по счету ГК:</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.gl t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(v-balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "</TR>" skip.
    end.
  end.
end.
else do:
  for each t-arpfin break by t-arpfin.gl by t-arpfin.crc by t-arpfin.arp:
    if first-of(t-arpfin.gl) then do:
      find gl where gl.gl = t-arpfin.gl no-lock no-error.
      put unformatted 
        "<TR><TD colspan=""14"">&nbsp;</TD></TR>" skip
        "<TR><TD colspan=""14""><B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">СЧЕТ ГК : " gl.gl "  " gl.des "</FONT></B></TD></TR>" skip.
      v-balrate = 0.
    end.

    if first-of(t-arpfin.crc) then do:
      find last crchis where crchis.crc = t-arpfin.crc and crchis.rdt <= v-asof no-lock no-error.
      sum-bal = 0.
      sum-balrate = 0.
    end.

    accumulate t-arpfin.bal (sub-total by t-arpfin.gl by t-arpfin.crc).
    accumulate t-arpfin.balrate (total by t-arpfin.gl by t-arpfin.crc).

    find cif where cif.cif = t-arpfin.cif no-lock no-error.
    /* найти связанную дебеторскую карточку */
    find t-arp where t-arp.spby = t-arpfin.arp use-index spby no-lock no-error.
    if avail t-arp then do:
      sum-bal = sum-bal + t-arp.bal.
      sum-balrate = sum-balrate + t-arp.balrate.
    end.

    put unformatted 
      "<TR>" skip
        "<TD>&nbsp;" t-arpfin.arp "</TD>" skip
        "<TD align=""center"">" t-arpfin.rdt "</TD>" skip
        "<TD align=""center"">" t-arpfin.duedt "</TD>" skip
        "<TD align=""center"">&nbsp;" t-arpfin.type format "999" "</TD>" skip
        "<TD>" t-arpfin.risk "</TD>" skip
        "<TD>" t-arpfin.des "</TD>" skip
        "<TD>" t-arpfin.bankname "</TD>" skip
        "<TD align=""center"">&nbsp;" t-arpfin.geo "</TD>" skip
        "<TD align=""center"">" crchis.code "</TD>" skip
        "<TD align=""right"">" string(t-arpfin.bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;" if avail t-arp then t-arp.arp else "" "</TD>" skip
        "<TD align=""right"">" if avail t-arp then string(t-arp.bal, "->>>,>>>,>>>,>>9.99") else "&nbsp;" "</TD>" skip
        "<TD align=""right"">" if avail t-arp then string(t-arp.balrate, "->>>,>>>,>>>,>>9.99") else "&nbsp;" "</TD>" skip.

    if last-of(t-arpfin.crc) then do:
      put unformatted 
        "<TR style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Итого по валюте:</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.crc t-arpfin.bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.crc t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(sum-bal, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD align=""right"">" string(sum-balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "</TR>" skip
        "<TR><TD colspan=""14"">&nbsp;</TD></TR>" skip.

      v-balrate = v-balrate + sum-balrate.
    end.

    if last-of(t-arpfin.gl) then do:
      put unformatted 
        "<TR style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Итого по счету ГК:</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(accum sub-total by t-arpfin.gl t-arpfin.balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" string(v-balrate, "->>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
        "</TR>" skip.
    end.
  end.
end.

put unformatted "</TABLE></TABLE>" skip.

{html-end.i " "}

output close.

unix silent value("cptwin " + v-file + " excel").
