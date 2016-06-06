/* vcraktfl.p
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

/* vcraktpa.p - Валютный контроль 
   Акт сверки с таможней сводный за введенный год 

   09.06.2002 nadejda создан
*/

{vc.i}

{mainhead.i}

{comm-txb.i}

def var v-godb as integer format "9999" init 1997.
def var v-gode as integer format "9999" init 1998.
def var v-stsi as integer.
def var v-ncrc as integer init 2 format ">>9".
def var v-sum like vccontrs.ctsum.
def var v-ncrccod as char format "xxx".
def var v-ourbank as char.

def temp-table t-sver 
  field god as integer FORMAT "9999" label "ГОД"
  field kol as integer extent 3 format "zzzzzz9" label "КОЛИЧ"
  field sum as decimal extent 3 format "zzz,zzz,zzz,zz9.99" label "СУММА"
  index god is primary unique god.


find ncrc where ncrc.crc = v-ncrc no-lock no-error.
v-ncrccod = ncrc.code.

displ skip(1) 
   v-godb     label "  ГОД СВЕРКИ С " skip
   v-gode     label " ГОД СВЕРКИ ПО " skip
   v-ncrc     label " ВАЛЮТА ОТЧЕТА " v-ncrccod no-label skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПАРАМЕТРЫ ОТЧЕТА : " frame f-param.


update v-godb v-gode v-ncrc with frame f-param.

find ncrc where ncrc.crc = v-ncrc no-lock no-error.
v-ncrccod = ncrc.code.
displ v-ncrccod with frame f-param.

v-ourbank = comm-txb().

for each vccontrs where vccontrs.bank = v-ourbank and vccontrs.cttype = "1" no-lock break by vccontrs.sts by vccontrs.ctdate:
  if first-of (vccontrs.sts) then do:
    if caps(vccontrs.sts) begins "C" then v-stsi = 2.
    else if caps(vccontrs.sts) = "S" then v-stsi = 3.
                                     else v-stsi = 0.
  end.


  if year(vccontrs.ctdate) < v-godb or year(vccontrs.ctdate) > v-gode then next.

  find t-sver where t-sver.god = year(vccontrs.ctdate) no-error.
  if not avail t-sver then do:
    create t-sver.
    t-sver.god = year(vccontrs.ctdate).
  end.
  t-sver.kol[1] = t-sver.kol[1] + 1.

  if v-stsi > 0 then t-sver.kol[v-stsi] = t-sver.kol[v-stsi] + 1.


  if vccontrs.ncrc = v-ncrc then v-sum = vccontrs.ctsum.
  else do:
    find last ncrchis where ncrchis.crc = vccontrs.ncrc and ncrchis.rdt <= vccontrs.ctdate no-lock no-error.
    if avail ncrchis then v-sum = vccontrs.ctsum * ncrchis.rate[1].
                     else do:
                       message "no ncrc!" vccontrs.ncrc. pause 5.
                       find first ncrchis where ncrchis.crc = vccontrs.ncrc no-lock no-error.
                       v-sum = vccontrs.ctsum * ncrchis.rate[1].
                     end.
    find last ncrchis where ncrchis.crc = v-ncrc and ncrchis.rdt <= vccontrs.ctdate no-lock no-error.
    v-sum = v-sum / ncrchis.rate[1].
  end.

  t-sver.sum[1] = t-sver.sum[1] + v-sum.
  if v-stsi > 0 then t-sver.sum[v-stsi] = t-sver.sum[v-stsi] + v-sum.
end.

output to rpt.htm.

{html-title.i 
 &stream = " " 
 &title = " " 
 &size-add = " "
}

find ncrc where ncrc.crc = v-ncrc no-lock no-error.
put unformatted 
  "<P>СВОДНЫЙ ОТЧЕТ ПО АКТУ СВЕРКИ</P>" skip
  "<P>валюта отчета : " trim(ncrc.des) " (" ncrc.code ")</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold;font-size:x-small"">" skip
      "<TD rowspan=""2"">ГОД</TD>" skip
      "<TD colspan=""2"">ОФОРМЛЕННЫЕ ПАСПОРТА СДЕЛОК</TD>" skip
      "<TD colspan=""2"">ЗАКРЫТЫЕ ПАСПОРТА СДЕЛОК</TD>" skip
      "<TD colspan=""2"">СВЕРЕННЫЕ ПАСПОРТА СДЕЛОК</TD></TR>" skip
    "<TR align=""center"" style=""font:bold;font-size:x-small"">" skip
      "<TD>КОЛИЧ</TD>" skip
      "<TD>СУММА</TD>" skip
      "<TD>КОЛИЧ</TD>" skip
      "<TD>СУММА</TD>" skip
      "<TD>КОЛИЧ</TD>" skip
      "<TD>СУММА</TD></TR>" skip.

for each t-sver.
  put unformatted 
    "<TR align=""right""><TD align=""center"">" t-sver.god "</TD>" skip
        "<TD>" t-sver.kol[1] "</TD>" skip
        "<TD>" replace(trim(string(t-sver.sum[1], ">>>,>>>,>>>,>>>,>>9.99")), ",", " ") "</TD>" skip
        "<TD>" t-sver.kol[2] "</TD>" skip
        "<TD>" replace(trim(string(t-sver.sum[2], ">>>,>>>,>>>,>>>,>>9.99")), ",", " ") "</TD>" skip
        "<TD>" t-sver.kol[3] "</TD>" skip
        "<TD>" replace(trim(string(t-sver.sum[3], ">>>,>>>,>>>,>>>,>>9.99")), ",", " ") "</TD></TR>" skip.
end.
put unformatted "</TABLE>" skip.

{html-end.i " "}

output close.
pause 0.

unix silent cptwin rpt.htm iexplore.


pause 0.




