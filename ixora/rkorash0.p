/* rkorash0.p
 * MODULE
        Расходы по СПФ за указанный период
 * DESCRIPTION
        Отчет по расходам сберкасс.
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
        07/04/04 madiar
 * CHANGES
        30/04/04 madiar - Поменял массивы на временную таблицу
                          добавил вывод табельных номеров кассиров по каждому СПФ
        20/09/04 kanat - убрал вывод сотрудников в конце отчета
        31/05/05 kanat - исправил мааааленькую ошибку, из-за которой выводились не все СПФ
        10/10/05 madiar - поменял перечисление больших СПФ на поиск в справочнике
*/


{mainhead.i}
/*{functions-def.i}*/
{get-dep.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

define variable ar_grp as integer extent 8 initial [ 1, 3, 4, 5, 6, 7,  8,  9  ].

def stream rep.
def var usrnm as char.
def var ar as int init 0.
def var ii as int init 0.
def var usdrate as decimal.
def var depmissed as char init "".

def temp-table tbl
    field dep like ppoint.depart
    field depsalary_ar as deci
    field depsocnalog_ar as deci
    field depsum_ar as deci
    field depcount_np_ar as int
    field depcom_ar as deci
    field dep_os_ar as deci
    field dep_osrem_ar as deci
    field cashiers as char.

define temp-table ttax like tax
    field dep like ppoint.depart.
define temp-table tcommpl like commonpl
    field dep like ppoint.depart.
define temp-table payment like p_f_payment
    field dep like ppoint.depart.

def var dt11 as date.
def var dt22 as date.
def var vmc1 as integer.
def var vmc2 as integer.
def var vgod1 as integer.
def var vgod2 as integer.
def var vgod as integer.
/*def var cashier_lst as char init "".*/
def var cashier_num as int init 0.
def var dept as int init 0.

/*def var v-name as char.*/

def var v-depart as char init ''.
find sysc where sysc.sysc = 'depart' no-lock no-error.
if avail sysc then v-depart = sysc.chval.

dt11 = g-today.
dt22 = g-today.

update dt11 format '99/99/9999' label " Начальная дата " 
       dt22 format '99/99/9999' label " Конечная дата " 
with centered frame df.

hide frame df.

message "Формируется отчет...".

/* курс на конец запрашиваемого периода */

find last crchis where crchis.rdt <= dt22 and crchis.crc = 2 no-lock no-error.
if avail crchis then usdrate = crchis.rate[1].

/* salary & soc nalog */

vmc1 = month(dt11).
vmc2 = month(dt22).
vgod1 = year(dt11).
vgod2 = year(dt22).

for each ppoint no-lock:
/*  v-name = ppoint.name.*/
  
  /* отсечь большие департаменты */
  if lookup(string(ppoint.depart),v-depart) = 0 then next.
  
  create tbl.
  assign
    tbl.dep = ppoint.depart
    tbl.depsalary_ar = 0
    tbl.depsocnalog_ar = 0
    tbl.depsum_ar = 0
    tbl.depcount_np_ar = 0
    tbl.depcom_ar = 0
    tbl.dep_os_ar = 0
    tbl.dep_osrem_ar = 0
    tbl.cashiers = "".
  
  for each tn where tn.kateg = "СЛУЖАЩИЕ" no-lock:
    find first ofc-tn where ofc-tn.tn = tn.tn no-lock no-error.
    if avail ofc-tn then do:
      find last ofchis where ofchis.ofc = ofc-tn.ofc and ofchis.regdt < dt11 no-lock no-error.
      if avail ofchis and ofchis.depart = ppoint.depart then do:
        if tbl.cashiers <> "" then tbl.cashiers = tbl.cashiers + ",".
        tbl.cashiers = tbl.cashiers + tn.tn.
      end.
    end.
    else do:
      if lookup(tn.tn + " : " + tn.uzv,depmissed) = 0 then do:
        if depmissed <> "" then depmissed = depmissed + ",".
        depmissed = depmissed + tn.tn + " : " + tn.uzv.
      end.
    end.
  end.
  
  cashier_num = num-entries(tbl.cashiers).
  if cashier_num = 0 then next.
  
  if vgod1 <> vgod2 then do:
    
    vmc1 = month(dt11). vmc2 = 12. vgod = vgod1.
    
    do ii = 1 to cashier_num:
      for each tekrg where tekrg.god = vgod and tekrg.mc >= vmc1 and tekrg.mc <= vmc2 and tekrg.sch < 180 and tekrg.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate tekrg.summa (total).
      end.
      tbl.depsalary_ar = tbl.depsalary_ar + accum total tekrg.summa.
      
      for each nalog where nalog.god = vgod and nalog.mc >= vmc1 and nalog.mc <= vmc2 and nalog.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate nalog.sumstr (total).
      end.
      tbl.depsocnalog_ar = tbl.depsocnalog_ar + accum total nalog.sumstr.
    end.
    
    vmc1 = 1. vmc2 = month(dt22). vgod = vgod2.
    
    do ii = 1 to cashier_num:
      for each tekrg where tekrg.god = vgod and tekrg.mc >= vmc1 and tekrg.mc <= vmc2 and tekrg.sch < 180 and tekrg.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate tekrg.summa (total).
      end.
      tbl.depsalary_ar = tbl.depsalary_ar + accum total tekrg.summa.
      
      for each nalog where nalog.god = vgod and nalog.mc >= vmc1 and nalog.mc <= vmc2 and nalog.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate nalog.sumstr (total).
      end.
      tbl.depsocnalog_ar = tbl.depsocnalog_ar + accum total nalog.sumstr.
    end.
    
  end.
  else do:
  
  vmc1 = month(dt11). vmc2 = month(dt22). vgod = vgod1.
    
    do ii = 1 to cashier_num:
      for each tekrg where tekrg.god = vgod and tekrg.mc >= vmc1 and tekrg.mc <= vmc2 and tekrg.sch < 180 and tekrg.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate tekrg.summa (total).
      end.
      tbl.depsalary_ar = tbl.depsalary_ar + accum total tekrg.summa.
      
      for each nalog where nalog.god = vgod and nalog.mc >= vmc1 and nalog.mc <= vmc2 and nalog.tn = entry(ii, tbl.cashiers) no-lock:
        accumulate nalog.sumstr (total).
      end.
      tbl.depsocnalog_ar = tbl.depsocnalog_ar + accum total nalog.sumstr.
      
    end.
  
  end.

  /* ---- Основные средства ---------------- */
  
  for each ast where ast.attn = "A" + string(ppoint.depart, "99") and ast.rdt >= dt11 and ast.rdt <= dt22 no-lock:
    tbl.dep_os_ar = tbl.dep_os_ar + ast.icost.
  end.

end. /* for each ppoint */

/* ---- Основные средства - ремонт ---------------- */

for each astjln where astjln.atrx = "r1" and astjln.ajdt >= dt11 and astjln.ajdt <= dt22 no-lock:
  find first ast where ast.ast = astjln.aast no-lock no-error.
  if available ast then
    if ast.attn begins "A" then do:
      ii = integer(substring(ast.attn,2,2)).
      find tbl where tbl.dep = ii no-error.
      if avail tbl then tbl.dep_osrem_ar = tbl.dep_osrem_ar + astjln.aamt.
    end.
end.

/* ----------------- доходы ----------------------- */

/* налоговые платежи */

for each tax where tax.txb = seltxb and date >= dt11 and date <= dt22 and duid = ? no-lock:
    create ttax.
      buffer-copy tax to ttax.
      ttax.dep = get-dep(tax.uid, tax.date).
  end.

find first ttax no-lock no-error.
if available ttax then
  FOR EACH ttax NO-LOCK BREAK BY ttax.dep:
    accumulate ttax.sum (sub-total by ttax.dep).
    accumulate ttax.sum (sub-count by ttax.dep).
    accumulate ttax.comsum (sub-total by ttax.dep).
    if last-of(ttax.dep) and lookup(string(ttax.dep),v-depart) = 0 then do:
      find tbl where tbl.dep = ttax.dep no-error.
      if avail tbl then do:
        tbl.depsum_ar = tbl.depsum_ar + (accum sub-total by ttax.dep ttax.sum).
        tbl.depcount_np_ar = tbl.depcount_np_ar + (accum sub-count by ttax.dep ttax.sum).
        tbl.depcom_ar = tbl.depcom_ar + (accum sub-total by ttax.dep ttax.comsum).
      end.
    end.
  end.

/* стандиаг */

do ar = 1 to 7:
  for each commonpl where txb = seltxb and date >= dt11 and date <= dt22 and deluid = ? and commonpl.grp = ar_grp[ar] no-lock use-index datenum:
    create tcommpl.
    buffer-copy commonpl to tcommpl.
    tcommpl.dep = get-dep(commonpl.uid, commonpl.date).
  end.
end.

find first tcommpl no-lock no-error.
if available tcommpl then
  for each tcommpl no-lock break by tcommpl.dep by tcommpl.arp:
    accumulate tcommpl.sum (sub-total by tcommpl.dep by tcommpl.arp).
    accumulate tcommpl.comsum (sub-total by tcommpl.dep by tcommpl.arp).
    if last-of(tcommpl.arp) and lookup(string(tcommpl.dep),v-depart) = 0 then do:
      /*find first commonls where commonls.txb = seltxb and commonls.arp = tcommpl.arp and commonls.type = tcommpl.type and commonls.visible = yes no-lock no-error.*/
      find tbl where tbl.dep = tcommpl.dep no-error.
      if avail tbl then do:
        tbl.depsum_ar = tbl.depsum_ar + (accum sub-total by tcommpl.arp tcommpl.sum).
        tbl.depcom_ar = tbl.depcom_ar + (accum sub-total by tcommpl.arp tcommpl.comsum).
        /*depcom1_ar[tcommpl.dep] = depcom1_ar[tcommpl.dep] + (accum sub-total by tcommpl.arp tcommpl.sum) * commonls.comprc.*/
      end.
    end.
  end.

/* пенсионные */

for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date >= dt11 
     and p_f_payment.date <= dt22 and p_f_payment.deluid = ? no-lock:
  create payment.
  buffer-copy p_f_payment to payment.
  payment.dep = get-dep(p_f_payment.uid, p_f_payment.date).
end.

find first payment no-lock no-error.
if available payment then
  FOR EACH payment NO-LOCK BREAK BY payment.dep:
    if last-of(payment.dep) and lookup(string(payment.dep),v-depart) = 0 then do:
      define buffer paycod for payment.
        find first paycod where paycod.dep = payment.dep /* and (paycod.cod = 100 or paycod.cod = 200)*/ no-lock no-error.
        if available paycod then do:
          for each paycod where paycod.dep = payment.dep /* and (paycod.cod = 100 or paycod.cod = 200)*/ no-lock:
            accumulate paycod.amt (total).
            accumulate paycod.amt (count).
            accumulate paycod.comiss (total).
          end.
          find tbl where tbl.dep = payment.dep no-error.
          if avail tbl then do:
            tbl.depsum_ar = tbl.depsum_ar + (accum total paycod.amt).
            tbl.depcount_np_ar = tbl.depcount_np_ar + (accum count paycod.amt).
            tbl.depcom_ar = tbl.depcom_ar + (accum total paycod.comiss).
          end.
        end.
    end.
  end.

hide message no-pause.

/* вывод в файл  */

output stream rep to reprkoexp.htm.

put stream rep unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE></TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 6" skip
   "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
  "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
  "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
  "<center><font size=+1><b>Отчет по расходам сберкасс</b></font><BR>" skip
  "за период с " dt11 FORMAT "99/99/9999" " по " dt22 FORMAT "99/99/9999" "<BR><BR>" skip
  "Курс USD на конец периода " usdrate "</center><BR>" skip
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<col span=13>" skip
  "<tr>" skip
  "<td width=200><center><b>Сберкасса</b></center></td>" skip
  "<td width=100><center><b>Расходы по з/п кассиров</b></center></td>" skip
  "<td width=100><center><b>Соцналог</b></center></td>" skip
  "<td width=100><center><b>Комм. услуги</b></center></td>" skip
  "<td width=100><center><b>Аренда</b></center></td>" skip
  "<td width=100><center><b>Охрана и сигнализация</b></center></td>" skip
  "<td width=100><center><b>Канцелярские</b></center></td>" skip
  "<td width=100><center><b>Инкассация</b></center></td>" skip
  "<td width=100><center><b>КЦМР</b></center></td>" skip
  "<td width=100><center><b>ИТОГО</b></center></td>" skip
  "<td width=100><center><b>Основные средства</b></center></td>" skip
  "<td width=100><center><b>Ремонт</b></center></td>" skip
  "<td width=100><center><b>ВСЕГО</b></center></td>" skip
  "<td width=100><center><b>Список кассиров</b></center></td>" skip
  "</tr>" skip.

def var allsalary as deci init 0.
def var allsocn as deci init 0.
def var allinkass as deci init 0.
def var allkcmr as deci init 0.
def var allos as deci init 0.
def var allosrem as deci init 0.

for each tbl:
   if tbl.depsalary_ar <> 0 or tbl.depsocnalog_ar <> 0 or tbl.depsum_ar <> 0 or tbl.depcount_np_ar <> 0 or tbl.dep_os_ar <> 0 or tbl.dep_osrem_ar <> 0 then do:
 
     find first ppoint where ppoint.dep = tbl.dep.
     if available ppoint then do:
        allsalary = allsalary + tbl.depsalary_ar.
        allsocn = allsocn + tbl.depsocnalog_ar.
        allinkass = allinkass + tbl.depsum_ar * 0.0003.
        allkcmr = allkcmr + tbl.depcount_np_ar / 1.5 * 4.
        allos = allos + tbl.dep_os_ar.
        allosrem = allosrem + tbl.dep_osrem_ar.
        put stream rep unformatted
          "<tr>" skip
          "<td>" ppoint.name "</td>" skip
          "<td>" replace( trim( string( round(tbl.depsalary_ar / usdrate, 2) ) ),".",",") "</td>" skip
          "<td>" replace( trim( string( round(tbl.depsocnalog_ar / usdrate, 2) ) ),".",",") "</td>" skip
          "<td></td>" skip "<td></td>" skip "<td></td>" skip "<td></td>" skip
          "<td>" replace( trim( string( round(tbl.depsum_ar * 0.0003 / usdrate, 2) ) ),".",",") "</td>" skip
          "<td>" replace( trim( string( round(tbl.depcount_np_ar / 1.5 * 4 / usdrate, 2) ) ),".",",") "</td>" skip
          "<td></td>" skip
          "<td>" replace( trim( string( round(tbl.dep_os_ar / usdrate, 2) ) ),".",",") "</td>" skip
          "<td>" replace( trim( string( round(tbl.dep_osrem_ar / usdrate, 2) ) ),".",",") "</td>" skip
          "<td></td>" skip
          "<td>" tbl.cashiers "</td>" skip
          "</tr>" skip.
     end. /* if avail */
 
   end. /* if depsalary */
   
end. /* for each tbl */

put stream rep unformatted
    "<tr>" skip
    "<td><b>ВСЕГО</b></td>" skip
    "<td><b>" replace( trim( string( round(allsalary / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allsocn / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b></b></td>" skip "<td><b></b></td>" skip "<td><b></b></td>" skip "<td><b></b></td>" skip
    "<td><b>" replace( trim( string( round(allinkass / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allkcmr / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b></b></td>" skip
    "<td><b>" replace( trim( string( round(allos / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allosrem / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b></b></td>" skip
    "</tr>" skip
    "</table><BR><BR>" skip.
/*    
put stream rep unformatted
  "<center><font size=+1><b>Сотрудники, не внесенные в таблицу ofc-tn</b></font></center><BR><BR>" skip.

do ar = 1 to num-entries(depmissed):

      put stream rep unformatted
        ar ". " entry(ar,depmissed) "<BR>" skip.

end.
*/

{html-end.i}
output stream rep close.
unix silent cptwin reprkoexp.htm excel.
