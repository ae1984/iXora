/* vcrepblk.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по блокированным средствам, актуальным на заданную дату
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-13
 * AUTHOR
        17.03.2003 nadejda
 * CHANGES
        14.10.2003 nadejda  - с какого-то момента суммы стали кидаться через транзитные счета и специнструкций на них нет
                              надо собрать такие суммы за нужное число - те, которые к дате отчета не были закинуты на счет
        15.10.2003 nadejda  - теперь все блокировки видит только Центральный офис, остальные видят только свои транзитные счета

*/


{mainhead.i}
{comm-txb.i}
{get-dep.i}

def temp-table t-aas
  field cif like cif.cif
  field dt as date
  field tim as integer
  field aaa like aaa.aaa
  field ln like aas_hist.ln
  field sum as decimal
  field ofc like ofc.ofc
  field days as integer
  index main is primary dt tim aaa ln.

def var s-vcourbank as char.
def var v-dte as date.
def var v-chcrc as integer init 3.
def var v-num as integer.
def var v-local as integer init 1.
def var v-valcon as logical.
def var v-filename as char init "repblk076.htm".
def var v-depart as integer.
def var v-proftcn as char.

def buffer b-aas_hist for aas_hist.

function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  if p-value = 0 then vp-str = "&nbsp;".
  else vp-str = trim(string(p-value, "->>>,>>>,>>>,>>>,>>9.99")).
  return vp-str.
end.


form 
  skip(1)
  v-dte   label " Отчетная дата" format "99/99/9999" 
      validate (v-dte <= g-today, " Дата отчета не может быть больше текущей!")
      help " Введите дату отчета (включительно)" 
  "   " skip(1)
  v-chcrc label " 1) в валюте, 2) в KZT, 3) все валюты" format "9" help "Выберите вариант отчета" " " skip
  with centered side-label row 5 title " ПАРАМЕТРЫ ОТЧЕТА : " frame f-dt.


v-dte = g-today.

update v-dte v-chcrc with frame f-dt.

message " Формируется отчет...".

/* нацвалюта */
find crchs where crchs.Hs = "L" no-lock no-error.
if avail crcHs then v-local = crchs.crc.

s-vcourbank = comm-txb().


find ofc where ofc.ofc = g-ofc no-lock no-error.
v-proftcn = ofc.titcd.

v-depart = get-dep (g-ofc, g-today).

if v-depart = 1 then do:
  /* сборка наложенных специнструкций - показываем только Центральному офису */
  for each aas_hist where aas_hist.sic = 'hb' and 
           aas_hist.chgdat <= v-dte and 
           aas_hist.chgoper = "a" 
           no-lock use-index aasreport:

    /* найти, офицер какого департамента накладывал специнструкцию - отчет делаем только по Департаменту Валютного контроля */
    find last ofcprofit where ofcprofit.ofc = aas_hist.who and ofcprofit.regdt <= aas_hist.chgdat no-lock no-error.
    if avail ofcprofit then do:
      v-valcon = (ofcprofit.profitcn = "506").
    end.
    else do:
      find first ofcprofit where ofcprofit.ofc = aas_hist.who no-lock no-error.
      if avail ofcprofit then v-valcon = (ofcprofit.profitcn = "506").
      else do:
        find ofc where ofc.ofc = aas_hist.who no-lock no-error.
        v-valcon = (avail ofc and ofc.titcd = "506").
      end.
    end.

    if v-valcon then do:
      /* проверить, не была ли блокировка снята */
      find first b-aas_hist where b-aas_hist.aaa = aas_hist.aaa and b-aas_hist.ln = aas_hist.ln and b-aas_hist.chgoper = "d" 
                 and b-aas_hist.chgdat <= v-dte no-lock no-error.

      if not avail b-aas_hist then do:
        /* если специнструкция была живая на заданную дату - включить в список */

        find aaa where aaa.aaa = aas_hist.aaa no-lock no-error.
        if (v-chcrc = 1 and aaa.crc <> v-local) or (v-chcrc = 2 and aaa.crc = v-local) or
            (v-chcrc = 3) then do:
          /* если валюты совпадают - создать запись */
          create t-aas.
          assign t-aas.cif = aas_hist.cif
                 t-aas.dt = aas_hist.chgdat
                 t-aas.tim = aas_hist.chgtime
                 t-aas.aaa = aas_hist.aaa
                 t-aas.ln = aas_hist.ln
                 t-aas.sum = aas_hist.chkamt
                 t-aas.ofc = aas_hist.who
                 t-aas.days = v-dte - aas_hist.chgdat.
        end.
      end.
    end.
  end.
end.

/* если выбран режим с валютой - собрать суммы на транзитных счетах */
def temp-table t-block like vcblock
  field remdt as date
  field racc as char.

def var v-maxlen as integer init 30.
def var i as integer.
def var n as integer.
def var v-str as char.
def var v-maxdays as integer init 10.

if v-chcrc <> 2 then do:
  for each vcblock where vcblock.bank = s-vcourbank no-lock:
    if vcblock.rdt > v-dte or
       not ((vcblock.sts = "b") or 
            (vcblock.sts <> "b" and vcblock.deldt > v-dte)) then next.

    /* если это не Центральный офис - показываем только своих клиентов */
    if v-depart <> 1 and vcblock.depart <> v-proftcn then next.

    create t-block.
    buffer-copy vcblock to t-block.

    find remtrz where remtrz.remtrz = vcblock.remtrz no-lock no-error.
    t-block.remdt = remtrz.rdt.
    t-block.racc = remtrz.racc.

    t-block.remdetails = trim (t-block.remdetails).
    if length (t-block.remdetails) > v-maxlen then do:
      n = integer (length (t-block.remdetails) / v-maxlen).
      if length (t-block.remdetails) mod v-maxlen > 0 then n = n + 1.
      v-str = substr (t-block.remdetails, 1, v-maxlen).
      do i = 2 to n:
        v-str = v-str + "<BR>" + substr (t-block.remdetails, (i - 1) * v-maxlen + 1, v-maxlen).
      end.
      v-str = replace (v-str, " ", "&nbsp;").
      t-block.remdetails = v-str.
    end.
  end.
end.



/* вывод отчета */
def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i 
 &stream = "stream vcrpt"
 &title = "АО ""TEXAKABANK"". Ведомость заблокированных сумм"
 &size-add = "x-"
}


find first t-aas no-error.

if avail t-aas then do:

  put stream vcrpt unformatted 
     "<P align=""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
     "<B>ВЕДОМОСТЬ<BR>" skip
     "заблокированных сумм на текущих счетах клиентов<BR>по Департаменту валютного контроля" skip
     "<BR><BR>на " string(v-dte, "99/99/9999") "</B></FONT></P>" skip
     "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
     "<TR align=""center"" style=""font-size:xx-small;font:bold"">" skip
       "<TD>N</TD>" skip
       "<TD>Наименование организации-клиента банка</TD>" skip
       "<TD>Текущий счет</TD>" skip
       "<TD>Сумма</TD>" skip
       "<TD>Валюта</TD>" skip
       "<TD>Дата выписки<BR>уведомления</TD>" skip
       "<TD>Блокировавший<BR>офицер</TD>" skip
       "<TD>Дней до<BR>даты отчета</TD>" skip
     "</TR>" skip.

  v-num = 0.

  for each t-aas :
    find aaa where aaa.aaa = t-aas.aaa no-lock no-error.

    v-num = v-num + 1.
    find cif where cif.cif = t-aas.cif no-lock no-error.
    find crc where crc.crc = aaa.crc no-lock no-error.
    put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
        "<TD align=""left"">" string(v-num) "</TD>" skip
        "<TD align=""left"">" if avail cif then trim(trim(cif.prefix) + " " + trim(cif.name)) else "" "</TD>" skip
        "<TD align=""center"">" t-aas.aaa "</TD>" skip
        "<TD align=""right"">" sum2str(t-aas.sum) "</TD>" skip
        "<TD align=""center"">" crc.code "</TD>" skip
        "<TD align=""center"">" string(t-aas.dt, "99/99/99") "</TD>" skip
        "<TD align=""center"">" t-aas.ofc "</TD>" skip
        "<TD align=""center"">" 
             if t-aas.days >= v-maxdays then "<B><FONT color=""red"">" else "" 
             string(t-aas.days) 
             if t-aas.days >= v-maxdays then "</FONT></B>" else "" "</TD>" skip
      "</TR>" skip.
  end.

  put stream vcrpt unformatted
      "</TABLE>" skip
      "<BR><BR>" skip.
end.


put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ВЕДОМОСТЬ<BR>" skip
   "заблокированных сумм на транзитных счетах валютного контроля" skip
   "<BR><BR>на " string(v-dte, "99/99/9999") "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" style=""font-size:xx-small;font:bold"">" skip
     "<TD>N</TD>" skip
     "<TD>Наименование получателя блокированных средств</TD>" skip
     "<TD>Референс<BR>входящего платежа</TD>" skip
     "<TD>Счет<BR>получателя</TD>" skip
     "<TD>Детали платежа</TD>" skip
     "<TD>Сумма блокировки</TD>" skip
     "<TD>Валюта</TD>" skip
     "<TD>Дата<BR>платежа</TD>" skip
     "<TD>Дата<BR>блокировки</TD>" skip
     "<TD>Блокировавший<BR>офицер</TD>" skip
     "<TD>Дней до<BR>даты отчета</TD>" skip
   "</TR>" skip.


for each t-block no-lock break by t-block.depart by t-block.crc by t-block.arp:
  if first-of (t-block.depart) then do:
    find codfr where codfr.codfr = "sproftcn" and codfr.code = t-block.depart no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD colspan=""11"">&nbsp;</TD></TR>" skip
      "<TR><TD colspan=""11""><B>ДЕПАРТАМЕНТ : " codfr.name[1] "</B></TD></TR>" skip.
    v-num = 0.
  end.

  if first-of (t-block.arp) then do:
    find arp where arp.arp = t-block.arp no-lock no-error.
    put stream vcrpt unformatted
      "<TR style=""font:bold""><TD>&nbsp;</TD><TD colspan=""10"">СЧЕТ : " t-block.arp "&nbsp;&nbsp;&nbsp;" arp.des "</TD></TR>" skip.

    find crc where crc.crc = arp.crc no-lock no-error.
  end.

  v-num = v-num + 1.

  put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
        "<TD>" string(v-num) "</TD>" skip
        "<TD>" t-block.remname "</TD>" skip
        "<TD align=""center"">" t-block.remtrz "</TD>" skip
        "<TD align=""center"">" t-block.racc "</TD>" skip
        "<TD>" t-block.remdetails "</FONT></TD>" skip
        "<TD align=""right"">" sum2str(t-block.amt) "</TD>" skip      
        "<TD align=""center"">" crc.code "</TD>" skip
        "<TD align=""center"">" string(t-block.remdt, "99/99/99") "</TD>" skip
        "<TD align=""center"">" string(t-block.rdt, "99/99/99") "</TD>" skip
        "<TD align=""center"">" t-block.rwho "</TD>" skip
        "<TD align=""center"">" 
                if v-dte - t-block.rdt >= v-maxdays then "<B><FONT color=""red"">" else "" 
                string(v-dte - t-block.rdt, ">>>>>>>>>9") 
                if v-dte - t-block.rdt >= v-maxdays then "</FONT></B>" else "" "</TD>" skip
      "</TR>" skip.

  accumulate t-block.amt (sub-total by t-block.arp).

  if last-of (t-block.arp) then do:
    put stream vcrpt unformatted
      "<TR style=""font:bold""><TD colspan=""5"" align=""right"">ИТОГО по счету " t-block.arp "</TD>" skip
        "<TD align=""right"">" sum2str(accum sub-total by t-block.arp t-block.amt) "</TD>" skip
        "<TD colspan=""5"">&nbsp;</TD></TR>" skip.
  end.
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

{html-end.i}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.


