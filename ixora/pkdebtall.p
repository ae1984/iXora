/* pkdebtall.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Задолженность по быстрым кредитам в разрезе
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
        08/09/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/
{global.i}
{comm-txb.i}
{nbankBik.i}
def new shared var dates as date no-undo extent 3.
def var dates1 as date no-undo extent 3.
def var dat as date no-undo.
def var bdat as date no-undo.
def var coun as integer no-undo.
def var k as integer no-undo.

def var v-od_ost_kzt as deci.
def var v-bal1_kzt as deci.
def var v-od_ost_usd as deci.
def var v-bal1_usd as deci.

def var v-od_tot_kzt as deci.
def var v-bal1_tot_kzt as deci.
def var v-od_tot_usd as deci.
def var v-bal1_tot_usd as deci.
def var v-count_tot as integer    .
def var i as integer.

def new shared temp-table  wrk no-undo
    field lon    like lon.lon
    field cif    like lon.cif
    field name   like cif.name
    field rdt    like lon.rdt
    field opnamt like lon.opnamt /*сумма кредита*/
    field balans like lon.opnamt /*остаток долга*/
    field crc    like lon.crc
    field bal1   like lon.opnamt /*просрочка ОД*/
    field dt_pros    as   inte /*дней просрочки ОД*/
    field bal2   like lon.opnamt /*просрочка %*/
    field balpen   like lon.opnamt /*пеня вся*/
    field bal13 as decimal
    field bal14 as decimal
    field bal30 as decimal
    /*field bal4 as decimal
    field bal5 as decimal*/
    field com_acc as decimal
    field year as integer /*год выдачи кредита*/
    field bank as char
    field guarant as char /*поручитель*/
    field is-cl as logical
    field crccode as char
    field dtrep as date
    index main is primary bank year crc name
    index guar guarant.

def temp-table t-guarant like wrk.

def temp-table t-reptot1 no-undo
  field od_ost_kzt like lon.opnamt
  field bal1_kzt like lon.opnamt
  field od_ost_usd like lon.opnamt
  field bal1_usd like lon.opnamt
  field year as integer
  field clcount as integer
  index idx is primary year.

def new shared temp-table tmpcl no-undo
  field cif as char
  field rnn as char
  field is-cl as logical
  index idx is primary cif.


def temp-table t-repfil1 no-undo
   field crc like crc.crc
   field bank as char
   field od_pros30 as deci
   field prc_pros30 as deci
   field pen30 as deci
   field com30 as deci
   field od_pros as deci /*просрочка больше 30 дней*/
   field prc_pros as deci
   field pen as deci
   field com as deci
   index idx is primary crc bank.

def temp-table t-repfil2 no-undo
   field bank as char
   field dtrep as date
   field sum_kzt as deci
   field sum_usd as deci
   field amt as integer
  index ind2 is primary bank dtrep descending.

def buffer b-repfil2 for t-repfil2.
def var v-sum_kzt as deci.
def var v-sum_usd as deci.
def var v-amt as integer.
def var v-sum_kzt2 as deci.
def var v-sum_usd2 as deci.
def var v-amt2 as integer.


def var v-od_prs30_kzt as deci no-undo.
def var v-prc_prs30_kzt as deci no-undo.
def var v-pen30_kzt as deci no-undo.
def var v-com30_kzt as deci no-undo.
def var v-od_prs_kzt as deci no-undo.
def var v-prc_prs_kzt as deci no-undo.
def var v-pen_kzt as deci no-undo.
def var v-com_kzt as deci no-undo.

def var v-od_prs30_usd as deci no-undo.
def var v-prc_prs30_usd as deci no-undo.
def var v-pen30_usd as deci no-undo /*пеня в тенге для кредитов в долларах*/.
def var v-pen_usd as deci no-undo /*пеня в тенге для кредитов в долларах*/.
def var v-com30_usd as deci no-undo.
def var v-od_prs_usd as deci no-undo.
def var v-prc_prs_usd as deci no-undo.
def var v-com_usd as deci no-undo.
def var v-bank as char no-undo.
def var v-banklist as char no-undo.
def var v-sel as integer no-undo.

def stream rep.

dat = g-today.
update dat label ' Укажите дату ' format '99/99/9999' validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
with side-label row 5 centered frame dat.

bdat = dat.
dates1[1] = dat.
do i = 2 to 3:
  if day(bdat) <> 1 then bdat = date(month(bdat),1,year(bdat)).
  else do:
    if month(bdat) = 1 then bdat = date(12,1,year(bdat) - 1).
    else bdat = date(month(bdat) - 1,1,year(bdat)).
  end.
  dates1[i] = bdat.
end.

do i = 1 to 3:
  dates[i] = dates1[4 - i].
end.

v-bank = comm-txb().
v-banklist = "".

if v-bank = "TXB00" then do:
  if v-banklist = "" then do:
    v-banklist = v-banklist + string(0) + " " + "Консолидировано".
    for each txb where txb.consolid = true no-lock:
      if v-banklist <> "" then v-banklist = v-banklist + " |".
       v-banklist = v-banklist + string(txb.txb + 1) + " " + txb.name.
    end.
  end.
  v-sel = 0.
  run sel2 ("ВЫБЕРИТЕ ФИЛИАЛ", v-banklist, output v-sel).
  if v-sel = 0 then return.
  if v-sel = 1 then do:
    message "Формируется отчет...".
    {r-branch.i &proc = "pkdebtall_txb(txb.bank)"}.

  end.
end.

if v-sel > 1 or v-bank <> "TXB00" then do:
   if connected ("txb") then disconnect "txb".
   find first comm.txb where ((comm.txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1 and v-bank = "TXB00") or (comm.txb.bank = v-bank and v-bank <> "TXB00")) and comm.txb.consolid = true no-lock.
   connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
   message "Формируется отчет...".
   run pkdebtall_txb(txb.bank).
   if connected ("txb") then disconnect "txb".
end.




for each wrk:
    find cif where cif.cif = wrk.cif no-lock no-error.
    if avail cif and cif.item <> "" then do:
        create tmpcl.
        tmpcl.cif =  wrk.cif.
        tmpcl.rnn = entry(1, cif.item, "|").
        tmpcl.is-cl = no.
    end.
end.


for each txb where txb.consolid = true no-lock:
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
  run chkcl.
end.
if connected ("txb") then disconnect "txb".

if dat < g-today then message "Сумма комиссии за ведение счета будет расчитана~n на операционную дату " + string(g-today,'99/99/9999') view-as alert-box title "ВНИМАНИЕ".
for each wrk:
  find first tmpcl where tmpcl.cif =  wrk.cif no-lock no-error.
  if avail tmpcl then wrk.is-cl = tmpcl.is-cl.
  else wrk.is-cl = no.
  find first crc where crc.crc = wrk.crc no-lock no-error.
  if not avail crc then message "не найдена валюта " + string(wrk.crc) view-as alert-box.
  else wrk.crccode = crc.code.
end.



for each wrk where wrk.guarant <> 'нет' and wrk.dtrep = dat no-lock:
  create t-guarant.
  buffer-copy wrk to t-guarant.
end.

do coun = 1 to 3:
  for each wrk where wrk.dtrep = dates[coun] no-lock break by wrk.bank:
    if wrk.crc = 1 then v-sum_kzt = v-sum_kzt + wrk.balans.
    if wrk.crc = 2 then v-sum_usd = v-sum_usd + wrk.balans.
    v-amt = v-amt + 1.
    if last-of(wrk.bank) then do:
      if v-amt > 0 then do:
        create t-repfil2.
        t-repfil2.bank = wrk.bank.
        t-repfil2.dtrep =wrk.dtrep.
        t-repfil2.sum_kzt = v-sum_kzt.
        t-repfil2.sum_usd = v-sum_usd.
        t-repfil2.amt = v-amt.
        v-sum_kzt = 0.
        v-sum_usd = 0.
        v-amt = 0.
      end.
    end.
  end.
end.

output stream rep to value("test.html").
{html-title.i
        &title = "METROCOMBANK" &stream = "stream rep" &size-add = "x-"}

put stream rep unformatted
    "<center><b>Задолженность по ссудным счетам клиентов на " dat format "99/99/9999" " в разрезе</b></center><BR>" skip.
for each wrk where wrk.guarant = 'нет' and wrk.dtrep = dat no-lock break by wrk.bank  by wrk.year by wrk.crc by wrk.name:
   accumulate wrk.balans - wrk.bal1 (TOTAL by  wrk.crc).
   accumulate wrk.bal1 (TOTAL by wrk.crc).


  if wrk.dt_pros > 0 and wrk.dt_pros < 30 then do:
    if wrk.crc = 1 then do:
      v-od_prs30_kzt = v-od_prs30_kzt +  wrk.bal1.
      v-prc_prs30_kzt = v-prc_prs30_kzt + wrk.bal2.
      v-pen30_kzt = v-pen30_kzt + wrk.balpen.
      v-com30_kzt = v-com30_kzt + wrk.com_acc.
    end.
    if wrk.crc = 2 then do:
      v-od_prs30_usd = v-od_prs30_usd +  wrk.bal1.
      v-prc_prs30_usd = v-prc_prs30_usd + wrk.bal2.
      v-pen30_usd = v-pen30_usd + wrk.balpen.
      v-com30_usd = v-com30_usd + wrk.com_acc.
    end.
  end.
  if wrk.dt_pros >= 30 then do:
    if wrk.crc = 1 then do:
      v-od_prs_kzt = v-od_prs_kzt +  wrk.bal1.
      v-prc_prs_kzt = v-prc_prs_kzt + wrk.bal2.
      v-pen_kzt = v-pen_kzt + wrk.balpen.
      v-com_kzt = v-com_kzt + wrk.com_acc.
    end.
    if wrk.crc = 2 then do:
      v-od_prs_usd = v-od_prs_usd +  wrk.bal1.
      v-prc_prs_usd = v-prc_prs_usd + wrk.bal2.
      v-pen_usd = v-pen_usd + wrk.balpen.
      v-com_usd = v-com_usd + wrk.com_acc.
    end.
  end.

  if first-of(wrk.bank) then do:
     empty temp-table t-reptot1.
     v-od_prs30_kzt = 0.
     v-prc_prs30_kzt = 0.
     v-pen30_kzt = 0.
     v-com30_kzt = 0.
     v-od_prs_kzt = 0.
     v-prc_prs_kzt = 0.
     v-pen_kzt = 0.
     v-com_kzt = 0.
     v-od_prs30_usd = 0.
     v-prc_prs30_usd = 0.
     v-pen30_usd = 0.
     v-pen_usd = 0.
     v-com30_usd = 0.
     v-od_prs_usd = 0.
     v-prc_prs_usd = 0.
     v-com_usd = 0.


     find first txb where txb.bank = wrk.bank no-lock no-error.
     put stream rep unformatted
     "<table border=1 cellpadding=0 cellspacing=0>" skip
     "<tr></tr>"
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td colspan = 14> Филиал " + v-nbankru + " " + txb.info + "</td></tr>" skip
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td>№</td>" skip
     "<td>Код<BR>клиента</td>" skip
     "<td>Наименование заемщика</td>" skip
     "<td>Поручитель</td>" skip
     "<td>Сумма кредита</td>" skip
     "<td>Остаток<BR>долга</td>" skip
     "<td>Итого задолженность<BR>(без штрафов)</td>" skip
     "<td>Просрочка ОД</td>" skip
     "<td>Просрочка %</td>" skip
     "<td>Задол-ть по ком.<BR>за вед. счета</td>" skip
     "<td>Пеня</td>" skip
     "<td>Дней<BR>просрочки</td>" skip
     "<td>Дата открытия<BR>кредита</td>" skip
     "<td>Валюта<BR>кредита</td>" skip
     "</tr>" skip.
  end.
  if first-of(wrk.year) then do:
     put stream rep unformatted
     "<tr></tr>"
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td colspan = 14> Просроченные кредиты выданные в " + string(wrk.year,'9999') + " г.</td></tr>" skip.
     k = 0.
     v-od_ost_kzt = 0.
     v-bal1_kzt = 0.
     v-od_ost_usd = 0.
     v-bal1_usd = 0.

  end.
  if last-of(wrk.crc) then do:
     if wrk.crc = 1 then do:
       v-od_ost_kzt = ACCUM total by (wrk.crc) wrk.balans - wrk.bal1.
       v-bal1_kzt = ACCUM total by (wrk.crc) wrk.bal1.
     end.
     if wrk.crc = 2 then do:
       /*create t-repfil1.*/
       v-od_ost_usd = ACCUM total by (wrk.crc) wrk.balans - wrk.bal1.
       v-bal1_usd = ACCUM total by (wrk.crc) wrk.bal1.
     end.
  end.

  k = k + 1.

  put stream rep unformatted
  "<tr style=""font-size:xx-small"" align=""left"">" skip
  "<td>" k "</td>" skip
  "<td align=""left""" if wrk.bal1 < 1 then " style=""font:bold;color:green""" else "" "> " wrk.cif "</td>"
  "<td>" if wrk.is-cl then "<font color=""blue"">" else "<font color=""black"">" wrk.name "</font></td>"
  "<td>" wrk.guaran "</td>" skip
  "<td>"replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.balans - wrk.bal1, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.bal1 + wrk.bal2 + wrk.com_acc, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.com_acc, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>"replace(trim(string(wrk.balpen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
  "<td>" wrk.dt_pros format "->>>9" "</td>" skip
  "<td>" wrk.rdt format "99.99.9999" "</td>" skip
  "<td align=""center"">" wrk.crccode "</td>" skip
  "</tr>" skip.

  if last-of(wrk.year) then do:
    create t-reptot1.
     t-reptot1.od_ost_kzt = v-od_ost_kzt.
     t-reptot1.bal1_kzt = v-bal1_kzt.
     t-reptot1.od_ost_usd = v-od_ost_usd.
     t-reptot1.bal1_usd = v-bal1_usd.
     t-reptot1.year = wrk.year.
     t-reptot1.clcount = k.
  end.
  if last-of(wrk.bank) then do:

     k = 0.
     v-od_ost_kzt = 0.
     v-bal1_kzt = 0.
     v-od_ost_usd = 0.
     v-bal1_usd = 0.
     find first t-guarant where t-guarant.bank = wrk.bank and t-guarant.dtrep = wrk.dtrep no-lock no-error.
     if avail t-guarant then do:
        if t-guarant.dt_pros > 0 and t-guarant.dt_pros < 30 then do:
          if t-guarant.crc = 1 then do:
              v-od_prs30_kzt = v-od_prs30_kzt +  t-guarant.bal1.
              v-prc_prs30_kzt = v-prc_prs30_kzt + t-guarant.bal2.
              v-pen30_kzt = v-pen30_kzt + t-guarant.balpen.
              v-com30_kzt = v-com30_kzt + t-guarant.com_acc.
          end.
          if t-guarant.crc = 2 then do:
              v-od_prs30_usd = v-od_prs30_usd +  t-guarant.bal1.
              v-prc_prs30_usd = v-prc_prs30_usd + t-guarant.bal2.
              v-pen30_usd = v-pen30_usd + t-guarant.balpen.
              v-com30_usd = v-com30_usd + t-guarant.com_acc.
         end.
       end.
      if t-guarant.dt_pros >= 30 then do:
        if t-guarant.crc = 1 then do:
          v-od_prs_kzt = v-od_prs_kzt +  t-guarant.bal1.
          v-prc_prs_kzt = v-prc_prs_kzt + t-guarant.bal2.
          v-pen_kzt = v-pen_kzt + t-guarant.balpen.
          v-com_kzt = v-com_kzt + t-guarant.com_acc.
        end.
        if wrk.crc = 2 then do:
          v-od_prs_usd = v-od_prs_usd +  t-guarant.bal1.
          v-prc_prs_usd = v-prc_prs_usd + t-guarant.bal2.
          v-pen_usd = v-pen_usd + t-guarant.balpen.
          v-com_usd = v-com_usd + t-guarant.com_acc.
        end.
      end.
       put stream rep unformatted
       "<tr></tr>"
       "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
       "<td colspan = 14> Просроченные кредиты выданные под поручительство</td></tr>" skip.
       for each t-guarant where t-guarant.bank = wrk.bank and t-guarant.dtrep = wrk.dtrep break by t-guarant.year by t-guarant.crc by t-guarant.name:

         k = k + 1.
         put stream rep unformatted
         "<tr style=""font-size:xx-small"" align=""left"">" skip
         "<td>" k "</td>" skip
         "<td align=""left""" if t-guarant.bal1 < 1 then " style=""font:bold;color:green""" else "" "> " t-guarant.cif "</td>"
         "<td>" if t-guarant.is-cl then "<font color=""blue"">" else "<font color=""black"">" t-guarant.name "</font></td>"
         "<td>" t-guarant.guaran "</td>" skip
         "<td>"replace(trim(string(t-guarant.opnamt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.balans - t-guarant.bal1, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.bal1 + t-guarant.bal2 + t-guarant.com_acc, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.bal1, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.bal2, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.com_acc, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"replace(trim(string(t-guarant.balpen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
         "<td>"t-guarant.dt_pros format "->>>9" "</td>" skip
         "<td>"t-guarant.rdt format "99.99.9999" "</td>" skip
         "<td align=""center"">" t-guarant.crccode "</td>" skip
         "</tr>" skip.

         if t-guarant.crc = 1 then do:
             v-od_ost_kzt = v-od_ost_kzt + (t-guarant.balans - t-guarant.bal1).
             v-bal1_kzt = v-bal1_kzt + t-guarant.bal1.
         end.
         if t-guarant.crc = 2 then do:
             v-od_ost_usd = v-od_ost_usd + (t-guarant.balans - t-guarant.bal1).
             v-bal1_usd = v-bal1_usd + t-guarant.bal1.
         end.

       end.

       create t-reptot1.
       t-reptot1.year = 1.
       t-reptot1.od_ost_kzt = v-od_ost_kzt.
       t-reptot1.bal1_kzt = v-bal1_kzt.
       t-reptot1.od_ost_usd = v-od_ost_usd.
       t-reptot1.bal1_usd = v-bal1_usd.
       t-reptot1.clcount = k.
     end.

     put stream rep unformatted "<tr></tr>"
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td rowspan = 2>Период выдачи</td>" skip
     "<td rowspan = 2 >Количество<BR>задолженников</td>" skip
     "<td colspan = 2 >KZT</td>" skip
     "<td colspan = 2 >USD</td>" skip
     "</tr>" skip.

     put stream rep unformatted
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td>Остаток долга</td>" skip
     "<td>Просрочка ОД</td>" skip
     "<td>Остаток долга</td>" skip
     "<td>Просрочка ОД</td>" skip
     "</tr>" skip.

     v-od_tot_kzt = 0.
     v-bal1_tot_kzt = 0.
     v-od_tot_usd  = 0.
     v-bal1_tot_usd = 0.
     v-count_tot = 0.
     for each t-reptot1 where t-reptot1.year > 1 no-lock:
       v-od_tot_kzt = v-od_tot_kzt + t-reptot1.od_ost_kzt.
       v-bal1_tot_kzt = v-bal1_tot_kzt + t-reptot1.bal1_kzt.
       v-od_tot_usd = v-od_tot_usd + t-reptot1.od_ost_usd.
       v-bal1_tot_usd = v-bal1_tot_usd + t-reptot1.bal1_usd.
       v-count_tot = v-count_tot + t-reptot1.clcount.
       put stream rep unformatted
       "<tr style=""font-size:xx-small"" align=""center"">" skip
       "<td>" t-reptot1.year format "9999" "</td>" skip
       "<td>" t-reptot1.clcount "</td>" skip
       "<td>"replace(trim(string(t-reptot1.od_ost_kzt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
       "<td>"replace(trim(string(t-reptot1.bal1_kzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
       "<td>"replace(trim(string(t-reptot1.od_ost_usd, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
       "<td>"replace(trim(string(t-reptot1.bal1_usd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
       "</tr>" skip.
     end.
     find first t-reptot1 where t-reptot1.year = 1 no-lock no-error.
     if avail t-reptot1 then do:
       v-od_tot_kzt = v-od_tot_kzt + t-reptot1.od_ost_kzt.
       v-bal1_tot_kzt = v-bal1_tot_kzt + t-reptot1.bal1_kzt.
       v-od_tot_usd = v-od_tot_usd + t-reptot1.od_ost_usd.
       v-bal1_tot_usd = v-bal1_tot_usd + t-reptot1.bal1_usd.
       v-count_tot = v-count_tot + t-reptot1.clcount.

       put stream rep unformatted
       "<tr style=""font-size:xx-small"" align=""center"">" skip
       "<td>Выданно кредитов под поручительство</td>" skip
       "<td>" t-reptot1.clcount "</td>" skip
       "<td>"replace(trim(string(t-reptot1.od_ost_kzt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
       "<td>"replace(trim(string(t-reptot1.bal1_kzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
       "<td>"replace(trim(string(t-reptot1.od_ost_usd, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
       "<td>"replace(trim(string(t-reptot1.bal1_usd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
       "</tr>" skip.
     end.

     put stream rep unformatted
     "<tr style=""font:bold;font-size:xx-small""  align=""center"">" skip
     "<td>Итого</td>" skip
     "<td>" v-count_tot "</td>" skip
     "<td>"replace(trim(string(v-od_tot_kzt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
     "<td>"replace(trim(string(v-bal1_tot_kzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
     "<td>"replace(trim(string(v-od_tot_usd, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
     "<td>"replace(trim(string(v-bal1_tot_usd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
     "</tr>" skip.

     put stream rep unformatted
     "<tr style=""font:bold;font-size:xx-small"" align=""center"">" skip
     "<td colspan = 2></td>" skip
     "<td colspan = 2>"replace(trim(string(v-od_tot_kzt + v-bal1_tot_kzt, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
     "<td colspan = 2>"replace(trim(string(v-bal1_tot_usd + v-od_tot_usd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
     "</tr></table>" skip.

     find first txb where txb.bank = wrk.bank no-lock no-error.
     if v-od_prs30_kzt + v-prc_prs30_kzt + v-pen30_kzt + v-com30_kzt + v-od_prs_kzt + v-prc_prs_kzt + v-pen_kzt + v-com_kzt > 0 then do:
       create t-repfil1.
       t-repfil1.crc = 1.
       t-repfil1.bank = trim(txb.info).
       t-repfil1.od_pros30 = v-od_prs30_kzt.
       t-repfil1.prc_pros30 = v-prc_prs30_kzt.
       t-repfil1.pen30 = v-pen30_kzt.
       t-repfil1.com30 = v-com30_kzt.
       t-repfil1.od_pros = v-od_prs_kzt.
       t-repfil1.prc_pros = v-prc_prs_kzt.
       t-repfil1.pen = v-pen_kzt.
       t-repfil1.com = v-com_kzt.
     end.

     if v-od_prs30_usd + v-prc_prs30_usd + v-pen30_usd + v-com30_usd + v-od_prs_usd + v-prc_prs_usd + v-pen_usd + v-com_usd > 0 then do:
       create t-repfil1.
       t-repfil1.crc = 2.
       t-repfil1.bank = trim(txb.info).
       t-repfil1.od_pros30 = v-od_prs30_usd.
       t-repfil1.prc_pros30 = v-prc_prs30_usd.
       t-repfil1.pen30 = v-pen30_usd.
       t-repfil1.com30 = v-com30_usd.
       t-repfil1.od_pros = v-od_prs_usd.
       t-repfil1.prc_pros = v-prc_prs_usd.
       t-repfil1.pen = v-pen_usd.
       t-repfil1.com = v-com_usd.
     end.
  end.
end.

/*find first t-repfil2 no-lock no-error.
if avail t-repfil2 then do:*/
  put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr></tr><tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td rowspan = 2>Просроченные кредиты</td>" skip.

  do i = 1 to 3:
    put stream rep unformatted "<td colspan = 3>просрочка на " dates[i] format "99.99.9999" "</td>" skip.
  end.
  put stream rep unformatted "<td colspan = 3>Разница </td></tr>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.
  do i = 1 to 4:
    put stream rep unformatted "<td>USD</td><td>KZT</td><td>Количество</td>" skip.
  end.
  put stream rep unformatted "</tr>" skip.

for each txb where ((txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1 and v-sel > 1) or v-sel = 1) and txb.consolid = true no-lock break by txb.info:
/*else for each txb where txb.txb = v-bank no-lock. */

  /*for each t-repfil2 no-lock break by t-repfil2.bank:
    if first-of(t-repfil2.bank) then do:
      find first txb where txb.bank = t-repfil2.bank no-lock no-error.*/
      put stream rep unformatted
      "<tr style=""font-size:xx-small"" align=""center""><td>" txb.info "</td>" skip.
      do i = 1 to 3:
         /*find first b-repfil2 where b-repfil2.bank = t-repfil2.bank and b-repfil2.dtrep = dates[i] no-lock no-error.*/
         find first b-repfil2 where b-repfil2.bank = txb.bank and b-repfil2.dtrep = dates[i] no-lock no-error.
         if avail b-repfil2 then put stream rep unformatted
          "<td>" replace(trim(string(b-repfil2.sum_usd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
          "<td>" replace(trim(string(b-repfil2.sum_kzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
          "<td>" b-repfil2.amt "</td>" skip.
         else put stream rep unformatted
          "<td>" replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
          "<td>" replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
          "<td>" 0 "</td>" skip.

         if i = 2 then do:
           if avail b-repfil2 then do:
             v-sum_kzt2 = b-repfil2.sum_kzt.
             v-sum_usd2 = b-repfil2.sum_usd.
             v-amt2 = b-repfil2.amt.
           end.
           else do:
             v-sum_kzt2 = 0.
             v-sum_usd2 = 0.
             v-amt2 = 0.
           end.
         end.
         if i = 3 then do:
            if avail b-repfil2 then
              put stream rep unformatted
              "<td>" replace(trim(string(b-repfil2.sum_usd - v-sum_usd2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
              "<td>" replace(trim(string(b-repfil2.sum_kzt - v-sum_kzt2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
              "<td>" b-repfil2.amt - v-amt2 "</td>" skip.
            else
              put stream rep unformatted
              "<td>" replace(trim(string(0 - v-sum_usd2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
              "<td>" replace(trim(string(0 - v-sum_kzt2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
              "<td>" 0 - v-amt2 "</td>" skip.

           put stream rep unformatted "</tr>" skip.

         end.
      end.
    end.
put stream rep unformatted "</tr></table>" skip.
  /*end.*/
/*end.*/
find first t-repfil1 where t-repfil1.crc = 1 no-lock no-error.
if avail t-repfil1 then do:
  put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr></tr><tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td rowspan = 2>Просроченный долг в KZT</td>" skip
  "<td colspan = 10>"dat format "99.99.9999" "</td>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td colspan = 5>до 30 дней</td>" skip
  "<td colspan = 5>свыше 30 дней</td></tr>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td></td>" skip
  "<td>ОД</td>" skip
  "<td>%%</td>" skip
  "<td>Пеня</td>" skip
  "<td>Комиссия</td>" skip
  "<td>Итого</td>" skip
  "<td>ОД</td>" skip
  "<td>%%</td>" skip
  "<td>Пеня</td>" skip
  "<td>Комиссия</td>" skip
  "<td>Итого</td>" skip.
  for each txb where ((txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1 and v-sel > 1) or v-sel = 1) and txb.consolid = true no-lock break by txb.info:
  /*for each t-repfil1 where t-repfil1.crc = 1 no-lock break by t-repfil1.bank:*/
  find first t-repfil1 where t-repfil1.crc = 1 and t-repfil1.bank = txb.info no-lock no-error.
  if avail t-repfil1 then do:
    accumulate t-repfil1.od_pros30 (TOTAL).
    accumulate t-repfil1.prc_pros30 (TOTAL).
    accumulate t-repfil1.pen30 (TOTAL).
    accumulate t-repfil1.com30  (TOTAL).
    accumulate t-repfil1.od_pros (TOTAL).
    accumulate t-repfil1.prc_pros (TOTAL).
    accumulate t-repfil1.pen (TOTAL).
    accumulate t-repfil1.com  (TOTAL).
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>" t-repfil1.bank "</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.prc_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.pen30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros30 + t-repfil1.prc_pros30 + t-repfil1.pen30 + t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.prc_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.pen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros + t-repfil1.prc_pros + t-repfil1.pen + t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.
  end.
  else do:
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>" txb.info "</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.

  end.
  end.
  if v-sel = 1 then do:
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>Консолидированный</td>" skip
    "<td>"replace(trim(string(ACCUM total t-repfil1.od_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.prc_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.pen30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string((ACCUM total t-repfil1.od_pros30) + (ACCUM total t-repfil1.prc_pros30) + (ACCUM total t-repfil1.pen30) + (ACCUM total t-repfil1.com30), "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.od_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.prc_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.pen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string((ACCUM total t-repfil1.od_pros) + (ACCUM total t-repfil1.prc_pros) + (ACCUM total t-repfil1.pen) + (ACCUM total t-repfil1.com), "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.
  end.
end.

find first t-repfil1 where t-repfil1.crc = 2 no-lock no-error.
if avail t-repfil1 then do:
  put stream rep unformatted
  "<tr></tr><tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td rowspan = 2>Просроченный долг в USD</td>" skip
  "<td colspan = 10>" dat format "99.99.9999" "</td>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td colspan = 5>до 30 дней</td>" skip
  "<td colspan = 5>свыше 30 дней</td></tr>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td></td>" skip
  "<td>ОД</td>" skip
  "<td>%%</td>" skip
  "<td>Пеня</td>" skip
  "<td>Комиссия</td>" skip
  "<td>Итого (без штрафов)</td>" skip
  "<td>ОД</td>" skip
  "<td>%%</td>" skip
  "<td>Пеня</td>" skip
  "<td>Комиссия</td>" skip
  "<td>Итого</td>" skip.
  for each txb where ((txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1 and v-sel > 1) or v-sel = 1) and txb.consolid = true no-lock break by txb.info:
  find first t-repfil1 where t-repfil1.crc = 2 and t-repfil1.bank = txb.info no-lock no-error.
  if avail t-repfil1 then do:
  /*for each t-repfil1 where t-repfil1.crc = 2 no-lock break by t-repfil1.bank:*/
    accumulate t-repfil1.od_pros30 (TOTAL).
    accumulate t-repfil1.prc_pros30 (TOTAL).
    accumulate t-repfil1.pen30 (TOTAL).
    accumulate t-repfil1.com30  (TOTAL).
    accumulate t-repfil1.od_pros (TOTAL).
    accumulate t-repfil1.prc_pros (TOTAL).
    accumulate t-repfil1.pen (TOTAL).
    accumulate t-repfil1.com  (TOTAL).
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>" t-repfil1.bank "</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.prc_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.pen30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros30 + t-repfil1.prc_pros30 + t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.prc_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.pen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(t-repfil1.od_pros + t-repfil1.prc_pros + t-repfil1.pen + t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.
  end.
  else do:
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>" txb.info "</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td>" skip
    "<td>"replace(trim(string(0, "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.

  end.
  end.
  if v-sel = 1 then do:
    put stream rep unformatted
    "<tr style=""font-size:xx-small"" align=""center"">" skip
    "<td>Консолидированный</td>" skip
    "<td>"replace(trim(string(ACCUM total t-repfil1.od_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.prc_pros30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.pen30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.com30, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string((ACCUM total t-repfil1.od_pros30) + (ACCUM total t-repfil1.prc_pros30)  + (ACCUM total t-repfil1.com30), "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.od_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.prc_pros, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.pen, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string(ACCUM total t-repfil1.com, "->>>>>>>>>>>9.99")),".",",")"</td>" skip.
    put stream rep unformatted
    "<td>"replace(trim(string((ACCUM total t-repfil1.od_pros) + (ACCUM total t-repfil1.prc_pros) +  (ACCUM total t-repfil1.com), "->>>>>>>>>>>9.99")),".",",")"</td></tr>" skip.
  end.
  put stream rep unformatted "</table>" skip.
end.

hide all no-pause.
/*put stream rep unformatted "</table>" skip.*/
{html-end.i "stream rep"}
output stream rep close.
unix silent cptwin test.html excel.

