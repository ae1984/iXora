/*pkdogorg.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Ведомость по кредитам со спец.условиями
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19/09/2008 galina
 * BASES
        BANK COMM
 * CHANGES
        03/10/2008 galina - заменила TEXAKABANK в <titel> на METROCOMBANK
                            тип кредита определятся по входному параметру p-credtype
        10.10.2008 galina - прибавляем комиссию за ведение счета к ежемесячному платежу
        25/04/2012 evseev  - rebranding. Название банка из sysc.

*/


{global.i}
{nbankBik.i}
{pk.i "new"}
def input parameter p-credtype as char.

/* период отчета */
def var d1 as date no-undo init today format '99/99/9999'.
def var d2 as date no-undo init today format '99/99/9999'.
def var i as int no-undo.
def var j as int no-undo.
def var v-podr as char no-undo.
def var v-sum as deci no-undo.
def var v-sumall as deci no-undo.
def var v-bal as deci no-undo.
def var v-count as integer.

def stream rep.

def temp-table  t-vedrep
    field cifname as char
    field aaa as char
    field podr as char
    field sum as deci
    field ctnum as char
    field vednum as integer
    field ctname as char.

update d1 label "Начало периода" d2 label "Конец периода"
       with side-labels centered overlay frame dtfr.
hide frame dtfr.

find first cmp no-lock no-error.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = p-credtype no-lock:
 find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dogorg" no-lock no-error.
 if not avail pkanketh then next.
 if num-entries(pkanketh.value1) <> 2 then next.
 if trim(pkanketa.lon) = '' then next.
 run lonbalcrc('lon',pkanketa.lon,g-today,"1",yes,1,output v-bal).
 if v-bal <= 0 then next.

 find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.ln = pkanketa.ln
 and pkanketh.kritcod = 'jobpodr' and pkanketh.credtype = p-credtype no-lock no-error.
 if avail pkanketh then v-podr = pkanketh.value1.
 else v-podr = ''.

 v-sum = 0.
 v-count = 0.
 for each lnsch where lnsch.lnn = pkanketa.lon and lnsch.f0 > 0 and lnsch.stdat >= d1 and lnsch.stdat <= d2  no-lock.
   v-sum = v-sum + lnsch.stval.
   v-count = v-count + 1.
 end.

 for each lnsci where lnsci.lni = pkanketa.lon and lnsci.f0 > 0 and lnsci.idat >= d1 and lnsci.idat <= d2  no-lock.
   v-sum = v-sum + lnsci.iv-sc.
 end.

 if v-sum > 0 then do:
   find last lnpriv where lnpriv.rnn = pkanketa.jobrnn and lnpriv.bank = pkanketa.bank and pkanketa.docdt >= lnpriv.dtb and lnpriv.dte >= pkanketa.docdt no-lock no-error.
   find tarifex2 where tarifex2.aaa = pkanketa.aaa and tarifex2.cif  = pkanketa.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    create t-vedrep.
    assign
      t-vedrep.cifname = pkanketa.name
      t-vedrep.aaa = pkanketa.aaa
      t-vedrep.podr = v-podr
      t-vedrep.sum = v-sum + (v-count * tarifex2.ost)
      t-vedrep.ctname = lnpriv.name.
      if avail lnpriv then do:
        t-vedrep.ctnum = lnpriv.ctnum.
      end.
  end.
end.



for each t-vedrep break by t-vedrep.ctnum:
  if first-of(t-vedrep.ctnum) then do:
     find last lnpriv where lnpriv.ctnum = t-vedrep.ctnum exclusive-lock no-error.
     lnpriv.vednum = lnpriv.vednum + 1.
     find current lnpriv no-lock.
  end.
  t-vedrep.vednum = lnpriv.vednum.
end.


j = 0.

find first t-vedrep no-lock no-error.
if avail  t-vedrep then do:
  for each t-vedrep  no-lock break by t-vedrep.ctnum:
    if first-of(t-vedrep.ctnum) then do:
       j = j + 1.
       output stream rep to value ("pkdogorg" + string(j) + ".html").

       put stream rep unformatted
                "<HTML> <HEAD> <TITLE>METROCOMBANK</TITLE>" skip
                "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.

       put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""  style=""border-collapse: collapse"">" skip.

       put stream rep unformatted "<tr align=""right""><td colspan = 8>Приложение N 2 к Договору N " t-vedrep.ctnum  "</td></tr>".
       put stream rep unformatted "<tr align=""right""><td colspan = 8> '_____' ________________ 2008 г. </td></tr>".

       put stream rep unformatted "<tr align=""center""><td colspan = 8><h4>Сводная ведомость N " string(t-vedrep.vednum) " на  " string(g-today) "</td></tr>".

       put stream rep unformatted "<tr align=""center""><td colspan = 8><h4>удержание из заработной платы клиентов </td></tr>".
       put stream rep unformatted "<tr align=""center""><td colspan = 8><h4>в счет погашения кредита за период " string(d1) " - " string(d2) "</td></tr>".
       put stream rep unformatted "<tr></tr><tr></tr>" skip(1).


       put stream rep unformatted "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.

       put stream rep unformatted "<tr style=""background: #D0D0D0;"">"
                       "<td ><b> N п/п </b></td>"
                       "<td ><b> ФИО клиента </b></td>"
                       "<td ><b> Номер текущего <br> счета клиента </b></td>"
                       "<td ><b> Подразделение <br> по месту работы <br> заемщика </b></td>"
                       "<td ><b> Табельный <br> номер по месту <br> работы</b></td>"
                       "<td ><b> Сумма очередного <br> платежа заемщика</b></td>"
                       "<td ><b> Сумма по тарифу <br> за перечисление <br> (0.25% от суммы платежа) </b></td>"
                       "<td ><b> Итого к удержанию <br> из зарплаты заемщика </b></td>"
                      "</tr>" skip.
       i = 0.

    end.
    i = i + 1.
    accumulate t-vedrep.sum (TOTAL by t-vedrep.ctnum).

    put stream rep unformatted "<tr>"
        "<td> " i " </td>"
        "<td> " t-vedrep.cifname " </td>"
        "<td>&nbsp;" t-vedrep.aaa "</td>"
        "<td>" t-vedrep.podr "</td>"
        "<td>  </td>"
        "<td>" replace(trim(string(t-vedrep.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" "</td>"
        "<td>" replace(trim(string(t-vedrep.sum, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "</tr>" skip.

    if last-of(t-vedrep.ctnum) then do:
    v-sumall = ACCUM total by (t-vedrep.ctnum) t-vedrep.sum.
        put stream rep unformatted "<tr>"
             "<td> </td>"
             "<td> Итого </td>"
             "<td> </td>"
             "<td> </td>"
             "<td> </td>"
             "<td><b> " replace(trim(string(v-sumall, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
             "<td><b> "  "</b></td>"
             "<td><b> " replace(trim(string(v-sumall, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
             "</tr>" skip.

         put stream rep unformatted "</table>" skip.
         put stream rep unformatted "<tr></tr><tr></tr></table><br><br>" skip.

         put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""  style=""border-collapse: collapse"">" skip.

         put stream rep unformatted "<br><br><tr align=""left""><td colspan = 8>Сумма тарифа за перечислеине ___________  тенге  </td></tr>" skip.

         if s-ourbank = "TXB00" then
          put stream rep unformatted "<tr align=""left""><td colspan = 8> Подлежит перечислению Центральному офису " + v-nbankru + " по " entry(1,cmp.addr[1]) " ____________ тенге </td></tr>" skip.
         else put stream rep unformatted "<tr align=""left""><td colspan = 8> Подлежит перечислению филиалу " + v-nbankru + " по " entry(1,cmp.addr[1]) " ____________ тенге </td></tr>" skip.

         put stream rep unformatted "<tr></tr><tr></tr></table>" skip.

         put stream rep unformatted
             "<TABLE border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" valign=""top"">" skip
               "<TR valign=""top"" align=""left"">" skip
                 "<TD colspan = 4> " + v-nbankru + " по " entry(1,cmp.addr[1]) "</TD>" skip
                 "<TD colspan = 3>" t-vedrep.ctname "</TD>" skip
               "<TR></TR>" skip
               "</TR>" skip
                "<TR valign=""top"" align=""left"">" skip
                  "<TD colspan = 4>_________________________________ </TD>" skip
                  "<TD colspan = 3>_________________________________ </TD>" skip
               "</TR>" skip
               "<TR valign=""top"" align=""left"">" skip
                  "<TD colspan = 4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(подпись, м.п.)</TD>" skip
                  "<TD colspan = 3>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(подпись, м.п.)</TD>" skip
               "</TR>" skip.

        put stream rep unformatted "</table></body></html>" skip.

        output stream rep close.
        unix silent value ("cptwin pkdogorg" + string(j) + ".html excel").
        unix silent value ("rm pkdogorg" + string(j) + ".html").
    end.

  end.
end.



