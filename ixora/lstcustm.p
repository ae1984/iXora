/* lstcustm.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Список отправленных налоговых платежей на КБК таможенного управления за период
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        27.05.2004 nadejda
 * CHANGES
        15.05.2004 nadejda - сортировка по дате платежа, а не квитанции
                             обработка 144-х счетов
        18.06.2004 nadejda - добавила вывод наименования получателя
        18.10.2004 kanat   - индекс не нужен
        21.04.2005 kanat   - добавил отдельный отчет для районов
        29.04.2005 kanat   - убрал "обязательные" условия по КБК
        17.06.2005 kanat   - добавил таможню АЛАТАУ
         12/12/05   marinav - добавила КБК = 106105
*/

{get-dep.i}
{mainhead.i}
{comm-txb.i}

def var v-kbks as char init "105102,105105,105106,105107,105241,105242,105243,105244,105245,105246,105247,105248,105249,105250,105251,105255,105258,105259,105260,105261,105269,105270,105271,105272,105273,105274,105275,105276,105277,105278,105279,105280,105281,105283,105284,105285,105286,105287,105402,106101,106102,106103,106104,106105,106201,106202,106203,106204,203101".
def var v-kbk as char.
def var v-racc as char.
def var v-rnn as char.
def var v-dt as date.
def var v-dtb as date.
def var v-dte as date.
def var v-mid as char init "080".
def var n as integer.
def var v-ourbank as char.
def var v-depart as integer.

v-ourbank = comm-txb().

def temp-table t-tax like tax
  field dtplat as date
  field kbk as char
  field rbank as char
  field racc as char
  field ord as char
  field sacc as char
  field npp as char
  field rnnnk as char
  field sofc as char
  field dep as integer
/*
  index main is primary unique dtplat kbk date rbank racc*/.

v-dtb = g-today.
v-dte = g-today.

update v-dtb label "   Начало периода " format "99/99/9999" 
             help " Первая дата ОТПРАВКИ платежей (не приема от клиента!)"
             validate (v-dtb <= g-today, " Неверная дата!")
       skip
       v-dte label "    Конец периода " format "99/99/9999" 
             help " Последняя дата ОТПРАВКИ платежей (не приема от клиента!)"
             validate (v-dte <= g-today, " Неверная дата!") 
       skip(1)
       v-mid label " Счета получателя " format "xxx"
             help " 080 - налоговые платежи, 144 - таможенное управление"
             validate (lookup(v-mid, "080,144") > 0, " Неверно указан признак счета получателя!")
       with side-labels centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

message " Формируется отчет...".

v-mid = "..." + v-mid + "...".

/* для отделения налоговых платежей */
def var v-arpmid as char init "076,904".
find sysc where sysc.sysc = "arpmid" no-lock no-error.
if avail sysc then v-arpmid = sysc.chval.

def temp-table t-arpmid
  field mid as char
  index mid is primary unique mid.

do n = 1 to num-entries(v-arpmid):
  create t-arpmid.
  t-arpmid.mid = "..." + entry(n, v-arpmid) + "...".
end.

find first cmp no-lock no-error.
if not avail cmp then return.


if v-mid matches "*080*" then do:
do v-dt = v-dtb to v-dte:
  for each remtrz where remtrz.valdt2 = v-dt no-lock:
    if lookup(remtrz.ptype, "2,6") = 0 or 
       remtrz.sbank <> v-ourbank or
       index(remtrz.rcvinfo[1], "/TAX/") = 0 then next.

    v-kbk = trim(remtrz.ba).
    v-racc = entry(num-entries(v-kbk, "/") - 1, v-kbk, "/").
    v-kbk = entry(num-entries(v-kbk, "/"), v-kbk, "/").

    if not v-racc matches v-mid then next.
    if lookup(string(v-kbk), v-kbks) = 0 then next.

    find first t-arpmid where remtrz.sacc matches t-arpmid.mid no-lock no-error.
    if not avail t-arpmid then next.

    /* РНН получателя */
    v-rnn = trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]).
    n = index (v-rnn, "/RNN/").
    if n = 0 then v-rnn = "".
             else v-rnn = substr(trim(substr(v-rnn, n + 5)), 1, 12).

    create t-tax.
    t-tax.dtplat = remtrz.valdt2.
    t-tax.rbank = remtrz.rbank.
    t-tax.kbk = v-kbk.
    t-tax.racc = remtrz.racc.
    t-tax.sacc = remtrz.sacc.
    t-tax.ord = trim(substr(remtrz.ord, 1, index (remtrz.ord, "/RNN/") - 1)).
    t-tax.npp = trim(substring(remtrz.sqn, 19, 8)).
    t-tax.sum = remtrz.amt.
    t-tax.rnnnk = v-rnn.
    t-tax.rnn = substr(trim(substr(remtrz.ord, index (remtrz.ord, "/RNN/") + 5)), 1, 12).

    find first tax where tax.senddoc = remtrz.remtrz no-lock no-error.
    if avail tax then do:

v-depart = get-dep(tax.uid, tax.date).

      t-tax.date = tax.date.
      t-tax.dnum = tax.dnum.
      t-tax.sofc = tax.uid.
      t-tax.dep = v-depart.
      if t-tax.ord begins "тр.счет" then t-tax.ord = tax.chval[1].
    end.
    else do:
      find first commonpl where commonpl.rmzdoc = remtrz.remtrz no-lock no-error.
      if avail commonpl then do:

v-depart = get-dep(commonpl.uid, commonpl.date).

        t-tax.date = commonpl.date.
        t-tax.dnum = commonpl.dnum.
        t-tax.sofc = commonpl.uid.
        t-tax.dep = v-depart.
      end.
      else do:
        t-tax.date = remtrz.rdt.
        t-tax.dnum = integer(t-tax.npp).
      end.
    end.
  end.
end.
end. /* if v-mid = "080" then ... */


if v-mid matches "*144*" then do:
do v-dt = v-dtb to v-dte:
  for each remtrz where remtrz.valdt2 = v-dt no-lock:
    if lookup(remtrz.ptype, "2,6") = 0 or 
       remtrz.sbank <> v-ourbank /*or
       index(remtrz.rcvinfo[1], "/TAX/") = 0*/ then next.

/*
    v-kbk = trim(remtrz.ba).
    v-racc = entry(num-entries(v-kbk, "/") - 1, v-kbk, "/").
    v-kbk = entry(num-entries(v-kbk, "/"), v-kbk, "/").
*/

    if not remtrz.ba matches "*" + v-mid + "*" then next.
/*
    if lookup(string(v-kbk), v-kbks) = 0 then next.
*/

    find first t-arpmid where remtrz.sacc matches "*" + t-arpmid.mid + "*" no-lock no-error.
    if not avail t-arpmid then next.

    /* РНН получателя */
    v-rnn = trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]).
    n = index (v-rnn, "/RNN/").
    if n = 0 then v-rnn = "".
             else v-rnn = substr(trim(substr(v-rnn, n + 5)), 1, 12).

    create t-tax.
    t-tax.dtplat = remtrz.valdt2.
    t-tax.rbank = remtrz.rbank.
    t-tax.racc = remtrz.racc.
    t-tax.sacc = remtrz.sacc.
    t-tax.ord = trim(substr(remtrz.ord, 1, index (remtrz.ord, "/RNN/") - 1)).
    t-tax.npp = trim(substring(remtrz.sqn, 19, 8)).
    t-tax.sum = remtrz.amt.
    t-tax.rnnnk = v-rnn.
    t-tax.rnn = substr(trim(substr(remtrz.ord, index (remtrz.ord, "/RNN/") + 5)), 1, 12).

    find first tax where tax.senddoc = remtrz.remtrz no-lock no-error.
    if avail tax then do:

v-depart = get-dep(tax.uid, tax.date).

      t-tax.kbk = string(tax.kb).
      t-tax.date = tax.date.
      t-tax.dnum = tax.dnum.
      t-tax.sofc = tax.uid.
      t-tax.dep = v-depart.
      if t-tax.ord begins "тр.счет" then t-tax.ord = tax.chval[1].
    end.
    else do:
      find first commonpl where commonpl.rmzdoc = remtrz.remtrz no-lock no-error.
      if avail commonpl then do:

v-depart = get-dep(commonpl.uid, commonpl.date).

        t-tax.kbk = string(commonpl.kb).
        t-tax.date = commonpl.date.
        t-tax.dnum = commonpl.dnum.
        t-tax.sofc = commonpl.uid.
        t-tax.dep = v-depart.
      end.
      else do:
        t-tax.date = remtrz.rdt.
        t-tax.dnum = integer(t-tax.npp).
      end.
    end.
  end.
end.
end. /*  if v-mid = "144" then ... */


find first t-tax no-lock no-error.
if not avail t-tax then do:
  message skip " Платежи не найдены!" 
          skip(1) view-as alert-box title "".
  return.
end.

output to tax-cust.xls.
{html-start.i " "}

for each t-tax no-lock where t-tax.dep <> 41 and t-tax.dep <> 42 break by t-tax.dtplat by t-tax.kbk by t-tax.npp by t-tax.date by t-tax.rbank by t-tax.racc:

  if first-of (t-tax.dtplat) then do:
    put unformatted "<table >" skip.
    put unformatted "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=left>" string(today, "99/99/9999") "</td></tr>" skip
                    "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=center>Ведомость проведенных платежей за "  string(t-tax.dtplat, "99/99/9999") "</td></tr>"
                    "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=center>Владелец счета: " cmp.name "</td></tr>" skip
                    "<tr style=""font-size:xx-small;font:bold"">" skip
                      "<td>Дата плат.</td><td>N плат.пор.</td><td>Дата квит.</td><td>N квит.</td>"
                      "<td>РНН отпр.</td><td>БИК получ.</td><td>Л/С получ.</td><td>РНН получ.</td><td>КБК</td><td>Сумма док.</td>"
                      "<td>Плательщик (отправитель)</td></tr>" skip.
  end.                    

  accumulate t-tax.sum (count total by t-tax.dtplat).

  put unformatted "<tr valign=top style=""font-size:xx-small""><td>" t-tax.dtplat
     "</td><td>" t-tax.npp
     "</td><td>" t-tax.date
     "</td><td>" t-tax.dnum 
     "</td><td>&nbsp;" t-tax.rnn 
     "</td><td>" t-tax.rbank 
     "</td><td>&nbsp;" t-tax.racc 
     "</td><td>&nbsp;" t-tax.rnnnk  
     "</td><td>" t-tax.kbk
     "</td><td>" replace(trim(string(t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",")
     "</td><td width=50%>" t-tax.ord "</td></tr>" skip.

  if last-of(t-tax.dtplat) then do:
    put unformatted 
      "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Количество за " string(t-tax.dtplat, "99/99/9999") "</td><td></td>"
        "<td>" accum sub-count by t-tax.dtplat t-tax.sum "</td></tr>" skip
      "<tr style=""font-size:xx-small;font:bold"">"
        "<td colspan=5>Общая сумма</td><td></td><td>" replace(trim(string(accum sub-total by t-tax.dtplat t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",") "</td></tr>" skip.
    put "<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" skip.

    put unformatted "</table><p></p>" skip.
  end.
end.
put unformatted 
  "<table>" skip
  "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Общее количество</td><td></td><td>" accum count t-tax.sum "</td></tr>" skip
  "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Общая сумма</td><td></td><td>" replace(trim(string(accum total t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",") "</td></tr>" skip
  "<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" skip
  "</table>" skip
  "</table>" skip.


{html-end.i " "}
output close.


output to cust_rep.xls.
{html-start.i}

for each t-tax no-lock where t-tax.dep = 41 or t-tax.dep = 42 break by t-tax.dtplat by t-tax.kbk by t-tax.npp by t-tax.date by t-tax.rbank by t-tax.racc:

  if first-of (t-tax.dtplat) then do:
    put unformatted "<table >" skip.
    put unformatted "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=left>" string(today, "99/99/9999") "</td></tr>" skip
                    "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=center>Ведомость проведенных платежей за "  string(t-tax.dtplat, "99/99/9999") "</td></tr>"
                    "<tr style=""font-size:xx-small;font:bold""><td colspan=8 align=center>Владелец счета: " cmp.name "</td></tr>" skip
                    "<tr style=""font-size:xx-small;font:bold"">" skip
                      "<td>Дата плат.</td><td>N плат.пор.</td><td>Дата квит.</td><td>N квит.</td>"
                      "<td>РНН отпр.</td><td>БИК получ.</td><td>Л/С получ.</td><td>РНН получ.</td><td>КБК</td><td>Сумма док.</td>"
                      "<td>Плательщик (отправитель)</td></tr>" skip.
  end.                    

  accumulate t-tax.sum (count total by t-tax.dtplat).

  put unformatted "<tr valign=top style=""font-size:xx-small""><td>" t-tax.dtplat
     "</td><td>" t-tax.npp
     "</td><td>" t-tax.date
     "</td><td>" t-tax.dnum 
     "</td><td>&nbsp;" t-tax.rnn 
     "</td><td>" t-tax.rbank 
     "</td><td>&nbsp;" t-tax.racc 
     "</td><td>&nbsp;" t-tax.rnnnk  
     "</td><td>" t-tax.kbk
     "</td><td>" replace(trim(string(t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",")
     "</td><td width=50%>" t-tax.ord "</td></tr>" skip.

  if last-of(t-tax.dtplat) then do:
    put unformatted 
      "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Количество за " string(t-tax.dtplat, "99/99/9999") "</td><td></td>"
        "<td>" accum sub-count by t-tax.dtplat t-tax.sum "</td></tr>" skip
      "<tr style=""font-size:xx-small;font:bold"">"
        "<td colspan=5>Общая сумма</td><td></td><td>" replace(trim(string(accum sub-total by t-tax.dtplat t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",") "</td></tr>" skip.
    put "<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" skip.

    put unformatted "</table><p></p>" skip.
  end.

end.
put unformatted 
  "<table>" skip
  "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Общее количество</td><td></td><td>" accum count t-tax.sum "</td></tr>" skip
  "<tr style=""font-size:xx-small;font:bold""><td colspan=5>Общая сумма</td><td></td><td>" replace(trim(string(accum total t-tax.sum, ">>>>>>>>>>>9.99")), ".", ",") "</td></tr>" skip
  "<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" skip
  "</table>" skip
  "</table>" skip.


{html-end.i}
output close.


hide message no-pause.

unix silent cptwin tax-cust.xls excel.
pause 0.

unix silent cptwin cust_rep.xls excel.
pause 0.

unix silent rm -f cust_rep.xls.
unix silent rm -f tax-cust*.xls.
pause 0.
