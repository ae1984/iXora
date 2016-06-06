/* vcrepdbe.p
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

/* vcrepdbe.p Валютный контроль
   Отчет по задолжникам за период - консигнация

   13.11.2002 nadejda создан
  
*/

{vc.i}

{global.i}
{comm-txb.i}
{name2sort.i}
{sum2str.i}

def new shared var s-vcourbank as char.

def temp-table t-dolgs
  field cif like cif.cif
  field cifname as char
  field cifsort as char
  field contract like vccontrs.contract
  field ctdate as date
  field ctnum as char
  field ncrc like ncrc.crc
  field sumcon as decimal init 0
  field sumusd as decimal init 0
  index main is primary cifsort cif ctdate ctnum contract.


def var v-dtb as date.
def var v-dte as date.
def var v-dt as date.
def var v-month as integer.
def var v-god as integer.
def var v-days as integer.
def var v-docsgtd as char.
def var v-docsplat as char.
def var v-cifname as char.
def var v-contrnum as char.
def var v-partname as char.
def var v-rnn as char.
def var v-psnum as char.
def var v-ctei as char.
def var v-cttype as char.
def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sumret as deci.
def var v-numcif as integer.
def var v-numkon as integer.
def var v-strsum as char.
def var v-strsumret as char.
def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumdoc as deci.
def var v-sumavans as deci.
def var v-sumpost as deci.
def var v-filename as char init "vcdolgko.htm".


def buffer b-his for ncrchis.

form 
  skip(1)
  v-dtb label "Контракты после" format "99/99/9999" skip
  v-dte label "  Отчетная дата" format "99/99/9999" skip
  with centered side-label row 5 title " ЗАДОЛЖНИКИ ПО КОНСИГНАЦИИ " frame f-dt.


v-dtb = date("01/01/" + string(year(g-today))).
v-dte = g-today.

update v-dtb v-dte with frame f-dt.

s-vcourbank = comm-txb().

v-docsgtd = "".
for each codfr where codfr.codfr = "vcdoc" and index("g", codfr.name[5]) > 0 no-lock:
  v-docsgtd = v-docsgtd + codfr.code + ",".
end.
v-docsplat = "".
for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
  v-docsplat = v-docsplat + codfr.code + ",".
end.

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte. 
else v-days = 120.

/* ЭКСПОРТ */  
for each vccontrs where vccontrs.bank = s-vcourbank and vccontrs.expimp = "e"
      and vccontrs.ctdate >= v-dtb
      use-index main no-lock break by vccontrs.cif:
  /* сумма ГТД по контракту */
  v-sumgtd = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and 
        lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
    else v-sum = vcdocs.sum.
    v-sum = v-sum / vcdocs.cursdoc-con.
    accumulate v-sum (total).
  end.
  v-sumgtd = (accum total v-sum).
  /* сумма платежных док-тов по контракту */
  v-sumplat = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and 
     lookup(vcdocs.dntype, v-docsplat) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
    else v-sum = vcdocs.sum.
    v-sum = v-sum / vcdocs.cursdoc-con.
    accumulate v-sum (total).
  end.
  v-sumplat = (accum total v-sum).

  if v-sumgtd > v-sumplat then do:
    /* есть ГТД, не покрытые извещениями */
    if v-sumplat = 0 then do:
      /* нет извещений - берем просто первую ГТД */
      find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "14" 
         and vcdocs.dndate < v-dte
         use-index main no-lock no-error.
      v-dt = vcdocs.dndate.
    end.
    else do:
      /* идем по ГТД, пока их сумма меньше суммы платежей */
      v-sum = 0.
      for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "14" 
         and vcdocs.dndate < v-dte
         no-lock use-index main.
        v-sum = v-sum + vcdocs.sum / vcdocs.cursdoc-con.
        if v-sum > v-sumplat then do:
          v-dt = vcdocs.dndate.
          leave.
        end.
      end.
    end.
    find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "22" and
           vcrslc.dndate >= v-dt use-index main no-lock no-error.
    if not avail vcrslc then do:
      /* проверка на лицензию  */
      if g-today > v-dt + v-days then do:
        /* задолжник! */
        create t-dolgs.

        find cif where cif.cif = vccontrs.cif no-lock no-error.
        t-dolgs.cif = cif.cif.
        t-dolgs.cifname = trim(trim(cif.sname) + " " + trim(cif.prefix)).
        t-dolgs.cifsort = name2sort(t-dolgs.cifname).
        t-dolgs.contract = vccontrs.contract.
        t-dolgs.ctdate = vccontrs.ctdate.
        t-dolgs.ctnum = vccontrs.ctnum.
        t-dolgs.ncrc = vccontrs.ncrc.
        t-dolgs.sumcon = v-sumgtd - v-sumplat.

        /* сумма ГТД по контракту в USD на дату платежа */
        v-sumgtd = 0.
        for each vcdocs where vcdocs.contract = vccontrs.contract and 
              lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < v-dte no-lock:
          if vcdocs.pcrc = 2 then v-sumdoc = vcdocs.sum.
          else do:
            find last b-his where b-his.crc = 2 and b-his.rdt <= vcdocs.dndate no-lock no-error.
            find last ncrchis where ncrchis.crc = vcdocs.pcrc and 
               ncrchis.rdt <= vcdocs.dndate 
               no-lock no-error. 
            v-sumdoc = (vcdocs.sum * ncrchis.rate[1]) / b-his.rate[1].
          end.
          accumulate v-sumdoc (total).
        end.
        v-sumgtd = (accum total v-sumdoc).
        /* сумма платежных док-тов по контракту в USD на дату платежа */
        v-sumplat = 0.
        for each vcdocs where vcdocs.contract = vccontrs.contract and 
           lookup(vcdocs.dntype, v-docsplat) > 0 and vcdocs.dndate < v-dte no-lock:
          if vcdocs.payret then v-sumdoc = - vcdocs.sum.
          else v-sumdoc = vcdocs.sum.
          if vcdocs.pcrc <> 2 then do:
            find last b-his where b-his.crc = 2 and b-his.rdt <= vcdocs.dndate no-lock no-error.
            find last ncrchis where ncrchis.crc = vcdocs.pcrc and 
               ncrchis.rdt <= vcdocs.dndate 
               no-lock no-error. 
            v-sumdoc = (v-sumdoc * ncrchis.rate[1]) / b-his.rate[1].
          end.
          accumulate v-sumdoc (total).
        end.
        v-sumplat = (accum total v-sumdoc).
        
        t-dolgs.sumusd = v-sumgtd - v-sumplat.

/*          message skip
            "Есть ГТД, не покрытые поступлениями валюты," skip 
            " прошло больше " + string(vp-days) + " дней ! Лицензии нет !" skip(1) 
            "Нельзя создавать извещение о поступлении валюты без" skip "ЛИЦЕНЗИИ" skip(1)
            view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
*/
      end.
    end.
  end.
end.


def stream vcrpt.
output stream vcrpt to value(v-filename).

put stream vcrpt unformatted 
   "<HTML>" skip 
   "<HEAD>" skip
   "<TITLE>Задолжники по консигнации на " + string(v-dte, "99/99/99") + 
   ", контракты с " + string(v-dtb, "99/99/99") +
   "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table " 
      "\{font:Times New Roman Cyr, Verdana, sans; font-size:x-small; 
       border-collapse: collapse\; valign:top}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>КЛИЕНТЫ-ЗАДОЛЖНИКИ ПО КОНСИГНАЦИИ<BR>на " + string(v-dte, "99/99/9999") + 
   "<BR>по контрактам с " + string(v-dtb, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата контракта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Паспорт сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вал. кон.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма задолженности в валюте контракта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма задолженности в USD</B></FONT></TD>" skip
   "</TR>" skip.

v-numcif = 0.

for each t-dolgs break by t-dolgs.cifsort by t-dolgs.cif by t-dolgs.ctdate 
      by t-dolgs.ctnum by t-dolgs.contract:
  v-numcif = v-numcif + 1.
  if first-of(t-dolgs.cif) then do:
    put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
        "<TD align=""left""><B>" + string(v-numcif) + "</B></TD>" skip
        "<TD colspan = ""7"" align=""left""><B>" + t-dolgs.cifname + " (" + t-dolgs.cif + ")</B></TD>" skip
      "</TR>" skip.
    v-numkon = 0.
  end.

  find first vcps where vcps.contract = t-dolgs.contract and vcps.dntype = "01" no-lock no-error.
  if avail vcps then v-psnum = vcps.dnnum. else v-psnum = "&nbsp;".
  find ncrc where ncrc.crc = t-dolgs.ncrc no-lock no-error.
  if avail ncrc then v-ncrccod = ncrc.code. else v-ncrccod = "&nbsp;".

  v-numkon = v-numkon + 1.
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>&nbsp;</TD>" skip
      "<TD align=""left"">" + string(v-numkon) + "</TD>" skip
      "<TD align=""left"">" + t-dolgs.ctnum + "</TD>" skip
      "<TD align=""center"">" + string(t-dolgs.ctdate, "99/99/9999") + "</TD>" skip
      "<TD align=""left"">" + v-psnum + "</TD>" skip
      "<TD align=""center"">" + v-ncrccod + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-dolgs.sumcon) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-dolgs.sumusd) + "</TD>" skip
    "</TR>" skip.

end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

find bankl where bankl.bank = s-vcourbank no-lock no-error.

put stream vcrpt unformatted
  "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip
    bankl.name skip.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.

put stream vcrpt unformatted
   "</B></FONT></P>" skip.


put stream vcrpt unformatted
  "</BODY>" skip
  "</HTML>" skip.

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.


