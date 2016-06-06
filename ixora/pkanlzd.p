/* pkanlzd.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Анализ портфеля потреб. кредитов в динамике
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
        19/08/2004 madiyar
 * CHANGES
        31/08/2004 madiyar - забыл раскомментарить cptwin
        01/09/2004 madiyar - выдавались два одинаковых отчета - исправил
        03/09/2004 madiyar - исправил ошибку - иногда выдавалась неправильная валюта обеспечения
        24/07/2006 madiyar - добавил колонку "Начисленные и не погашенные проценты"
        26/07/2006 madiyar - отчет немного скривился, подправил
        11/08/2006 madiyar - выданные за период
        22/09/2006 madiyar - добавил ответственного менеджера
        16/04/2007 madiyar - разбивка на программы МКО
        28/11/2008 galina - данные с разбивкой по программам берем из хранилища
        02/12/2008 galina - изменила ыормат вывода сумм и колличества для динамики за период (числа могут быть отрицательные)
        15/12/2008 galina - добавила для кредитов ФЛ подсчет провизий 2,3,4 категории
                            исправила надписи у провизий
                            исправила расчет процентной доли в кред.портфеле для провизий
        30/12/2008 galina - переделала для формирования push-отчета
        08/01/2009 galina - исправила путаницу в филиалах 
        02/02/2009 galina - исправила подсчет итоговой суммы и количества для динамики выданных кредитов
        07/04/2009 galina - в отчете по залоговым не выводим погашенные кредиты
        14.05.2009 galina - убрала строки Исполнитель и Дата, не выводим провизии
        04.06.2009 galina - находим курс валюты crchis по полю rdt
*/

def input parameter p-reptype as char.
def input parameter p-dt as date.
def input parameter p-fname as char.
{mainhead.i}

{comm-txb.i}
def new shared temp-table wrkmain no-undo
  field datot       as   date
  field segm        as   char
  field bank        as   char
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field grp         as   int
  field crc         like lon.crc
  field opnamt      as   deci
  field sumvyd      as   deci
  field sumvyd_crc  as   deci /*выданная сумма в валюте кредита*/
  field ostatok     as   deci
  field ostatok_kzt as   deci
  field prosr_od    as   deci
  field prc         as   deci
  field prosr_prc   as   deci
  field pred_prc    as   deci
  field bal_acc     as   deci
  field prosr_day   as   integer
  field prem        as   deci
  field rdt         as   date
  field lastpaid_dt as   date
  field nextpog_dt  as   date
  field duedt       as   date
  field obesp_name  as   char
  field obesp_sum   as   deci
  field obesp_crc   like lon.crc
  field rezervprc   as   deci
  field rezerv_form as   deci
  field srok        as   deci
  field ofc         as   char /* ответственный менеджер */
  index ind is primary datot segm bank.

def new shared temp-table wrkobesp no-undo
  field cif         like lon.cif
  field lon         like lon.lon
  field obesp_name  as   char
  field obesp_sum   as   deci
  field obesp_crc   like lon.crc
  index indo is primary cif lon.

def temp-table wrk1 no-undo
  field nn        as integer
  field name      as char
  field sumkzt    as deci
  field sumusd    as deci
  field number    as integer
  field mshare     as deci
  field mshare2    as char
  index ind1 is primary nn.

def temp-table wrk2 no-undo
  field segm      as char
  field crccode   as char
  field datot     as date
  field sumkzt    as deci
  field sumcrc    as deci
  field number    as integer
  index ind2 is primary crccode segm datot descending.

def temp-table wrk3 no-undo
  field sts_name as char
  field sum as deci extent 4
  field num as integer extent 4
  /*index ind3 is primary sts_name*/.

def temp-table wrk4 no-undo
  field segm_name    as char
  field prosr_do30   as deci extent 2
  field prosr_30-90  as deci extent 2
  field prosr_90more as deci extent 2.

def new shared temp-table wrkvyd no-undo
    field datot like lon.rdt
    field segm as char
    field name as char
    field sum as deci
    field sum_crc as deci
    field crc as char
    field kol as integer
    index main is primary segm datot.

def var usrnm as char no-undo.
def stream rep.
def var dat as date no-undo.
def var bdat as date no-undo.
def var coun as integer no-undo.
def var wrkcrccode as char no-undo.
def var sums as decimal no-undo extent 5.
def new shared var krport as deci no-undo extent 2.
krport = 0.
def new shared var dates as date no-undo extent 5.
def var krport_potreb as deci no-undo extent 2.
def var cur_usd as deci no-undo.
def var krport2_sum as deci no-undo.
def var krport2_num as int no-undo.
def var vyd_sum as deci no-undo.
def var vyd_sum_crc as deci no-undo. /*в валюте кредита*/
def var vyd_num as int no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-bank as char.

def var vdate as integer.
def var vmont as integer.
def var vyear as integer.
def var vquar as integer.
def var v-exist1 as char.   
def var v-exist2 as char.
def var vfname as char.
def var v-banklist as char.
def var v-sel as integer.
def var v-bankname as char.

if p-reptype <> "rep" then do:
  dat = p-dt.
end.


if p-reptype = "rep" then do:
   dat = g-today.
   update dat label ' Укажите дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.
end.

bdat = dat.
dates[1] = dat.
do i = 2 to 5:
  if day(bdat) <> 1 then bdat = date(month(bdat),1,year(bdat)).
  else do:
    if month(bdat) = 1 then bdat = date(12,1,year(bdat) - 1).
    else bdat = date(month(bdat) - 1,1,year(bdat)).
  end.
  dates[i] = bdat.
end.

if p-reptype = "rep" then do:
   vdate = DAY (dat).
   vmont = MONTH (dat).
   vyear = YEAR (dat).
   vquar = 0.
   case vmont:
        when 1 OR 
        when 2 OR 
        when 3 then vquar = 1.
        
        when 4 OR 
        when 5 OR 
        when 6 then vquar = 2.

        when 7 OR 
        when 8 OR 
        when 9 then vquar = 3.

        when 10 OR 
        when 11 OR 
        when 12 then vquar = 4.
   end.
 
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
   if v-sel = 1 then vfname = "/data/reports/push/bmkb/" + "pkanlzdkon" + "-" + string(vyear) + "-" + string(vmont) + "-" + string(vquar) + "-" + string(vdate) + ".html".  
   else do:
     find first txb where txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1 and txb.consolid = true no-lock no-error. 
     vfname = "/data/reports/push/b" + entry(3,txb.path,'/' ) + "/pkanlzd" + "-" + string(vyear) + "-" + string(vmont) + "-" + string(vquar) + "-" + string(vdate) + ".html". 
   end.
   
   input through value( "find " + (entry(1,vfname,'.') + "1." + entry(2,vfname,'.')) + ";echo $?").
   repeat:
     import unformatted v-exist1.
   end.
   input through value( "find " + (entry(1,vfname,'.') + "2." + entry(2,vfname,'.')) + ";echo $?").
   repeat:
     import unformatted v-exist2.
   end.
   if v-exist1 = "0" and v-exist2 = "0" then do:
      unix silent cptwin value(entry(1,vfname,'.') + "1." + entry(2,vfname,'.')) excel.
      unix silent cptwin value(entry(1,vfname,'.') + "2." + entry(2,vfname,'.')) excel.
      return.
   end.    
end.

if p-reptype = "txb" or (v-sel > 1 and p-reptype = "rep")then do:
   v-bank = comm-txb().
   if connected ("txb") then disconnect "txb".
   find first comm.txb where ((p-reptype = "txb" and comm.txb.bank = v-bank )or (p-reptype = "rep" and comm.txb.txb = integer(trim(entry(1,entry(v-sel,v-banklist,"|")," "))) - 1)) and comm.txb.consolid = true no-lock.
   connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
   if p-reptype = "rep" then message "Формируется отчет...".
   run pkanlzd2.
   v-bankname = comm.txb.name.
   if connected ("txb") then disconnect "txb".
end.   

if p-reptype = "all" or (v-sel = 1 and p-reptype = "rep") then do:
  if p-reptype = "rep" then message "Формируется отчет...".
  {r-branch.i &proc = "pkanlzd2"}
   v-bankname = "Консолидированно".   
end.

if (p-reptype = "rep" and v-exist1 <> "0") or p-reptype <> "rep" then do:

  if p-reptype = "rep" then output stream rep to value(entry(1,vfname,'.') + "1." + entry(2,vfname,'.')).
  else output stream rep to value(entry(1,p-fname,'.') + "1." + entry(2,p-fname,'.')).

  put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.  
/*  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip*/
 put stream rep unformatted
    "<center><b>Кредитный портфель по физическим лицам на " dat format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td><BR><BR>пп</td>" skip
    "<td><BR>Код<BR>заемщика</td>" skip
    "<td><BR><BR>Наименование заемщика</td>" skip
    "<td><BR>Валюта<BR>займа</td>" skip
    "<td><BR>Одобренная<BR>сумма</td>" skip
    "<td>Сумма<BR>остатка<BR>займа</td>" skip
    "<td>Сумма<BR>просроч<BR>займа</td>" skip
    "<td>Начисл. и<br>не погаш.<br>%%</td>" skip
    "<td>Сумма<BR>просроч<BR>%%</td>" skip
    "<td><BR>Предоплата<BR>%%</td>" skip
    "<td>Сумма<BR>на тек<BR>счете</td>" skip
    "<td><BR>%<BR>ставка</td>" skip
    "<td>Дата<BR>выдачи<BR>займа</td>" skip
    "<td>Дата<BR>последней<BR>проплаты</td>" skip
    "<td>Дата<BR>погашения<BR>по графику</td>" skip
    "<td>Дата<BR>погашения<BR>займа</td>" skip
    "<td><BR>Наименование<BR>обеспечения</td>" skip
    "<td><BR>Валюта<BR>обеспечения</td>" skip
    "<td><BR>Сумма<BR>обеспечения</td>" skip
    "<td><BR>Резерв<BR>%%</td>" skip
    "<td>Сформированная<BR>сумма<BR>резервов</td>" skip
    "<td><BR><BR>Срок</td>" skip
    "<td><BR>Ответств.<BR>менеджер</td>" skip
    "</tr>" skip.

  coun = 1.

  for each wrkmain where wrkmain.datot = dat and wrkmain.segm <> '01' and wrkmain.segm <> '02' and wrkmain.segm <> '03' no-lock
                     break by wrkmain.segm by wrkmain.crc by wrkmain.bank:
    if first-of(wrkmain.segm) then do:
      find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrkmain.segm no-lock no-error.
      if avail codfr then put stream rep unformatted "<tr><td colspan=23 bgcolor=""#9BCDFF""><b>" codfr.name[1] "</b></td></tr>" skip.
    end.
    if first-of(wrkmain.crc) then do:
      find first crc where crc.crc = wrkmain.crc no-lock no-error.
      wrkcrccode = crc.code.
      sums = 0.
    end.
    if wrkmain.ostatok + wrkmain.prosr_od + wrkmain.prosr_prc + wrkmain.prc = 0 then next.
    put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrkmain.cif "</td>" skip
    "<td>" wrkmain.klname "</td>" skip
    "<td>" wrkcrccode "</td>" skip
    "<td>" replace(string(wrkmain.opnamt, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.ostatok, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.prosr_od, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.prc, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.prosr_prc, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.pred_prc, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.bal_acc, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.prem, ">>9.99"),'.',',') "</td>" skip
    "<td>" wrkmain.rdt "</td>" skip
    "<td>" wrkmain.lastpaid_dt "</td>" skip
    "<td>" wrkmain.nextpog_dt "</td>" skip
    "<td>" wrkmain.duedt "</td>" skip
    "<td>" wrkmain.obesp_name "</td>" skip.
    find first crc where crc.crc = wrkmain.obesp_crc no-lock no-error.
    put stream rep unformatted
    "<td>" crc.code "</td>" skip
    "<td>" replace(string(wrkmain.obesp_sum, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.rezervprc, ">>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrkmain.rezerv_form, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" "</td>" skip
    "<td>" wrkmain.ofc "</td>" skip
    "</tr>" skip.
    coun = coun + 1.
    sums[1] = sums[1] + wrkmain.ostatok.
    sums[2] = sums[2] + wrkmain.prosr_od.
    sums[3] = sums[3] + wrkmain.prosr_prc.
    sums[4] = sums[4] + wrkmain.pred_prc.
    sums[5] = sums[5] + wrkmain.rezerv_form.
  
    for each wrkobesp where wrkobesp.cif = wrkmain.cif and wrkobesp.lon = wrkmain.lon no-lock:
      put stream rep unformatted
      "<tr>" skip
      "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>" skip
      "<td></td><td></td><td></td><td></td>" skip
      "<td>" wrkobesp.obesp_name "</td>" skip.
      find first crc where crc.crc = wrkobesp.obesp_crc no-lock no-error.
      put stream rep unformatted
      "<td>" crc.code "</td>" skip
      "<td>" replace(string(wrkobesp.obesp_sum, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td></td><td></td><td></td>" skip
      "</tr>" skip.
    end.
  
    if last-of(wrkmain.crc) then do:
      put stream rep unformatted
      "<tr style=""font:bold"">" skip
      "<td></td><td></td>" skip
      "<td>Итого по " wrkcrccode "</td>" skip
      "<td></td><td></td>" skip
      "<td>" replace(string(sums[1], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td>" replace(string(sums[2], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(string(sums[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td>" replace(string(sums[4], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>" skip
      "<td>" replace(string(sums[5], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
      "<td></td><td></td>" skip
      "</tr>" skip.
    end.
    if last-of(wrkmain.segm) then do:
      put stream rep unformatted "<tr></tr>" skip.
    end.
  end. /* for each wrkmain */

  put stream rep unformatted "</table></body></html>".
  output stream rep close.
  v-exist1 = "0".
end.

if (p-reptype = "rep" and v-exist2 <> "0") or p-reptype <> "rep" then do:
  create wrk1.
  wrk1.nn = 1.
  wrk1.name = "Кредитный портфель".
  wrk1.sumkzt = krport[1].
  find last crchis where crchis.crc = 2 and crchis.rdt < dat no-lock no-error.
  cur_usd = crchis.rate[1].
  wrk1.sumusd = krport[1] / cur_usd.
  wrk1.number = krport[2].
  wrk1.mshare = 0.
  wrk1.mshare2 = "валюте баланса".

  i = 3.
  krport_potreb = 0.

  def var summa_pr as deci extent 3.
  def var kol_pr as deci extent 3.
  for each crc no-lock:
    for each codfr where codfr.codfr = "lnsegm" no-lock:
      if codfr.code = '07' then next. /* пропускаем кредиты юр.лиц */
      do j = 1 to 5:
        krport2_sum = 0. krport2_num = 0.
        vyd_sum = 0. vyd_num = 0.
        summa_pr = 0. kol_pr = 0.
        vyd_sum_crc = 0.
        for each wrkmain where wrkmain.crc = crc.crc and wrkmain.segm = codfr.code and wrkmain.datot = dates[j] no-lock:
     
          krport2_sum = krport2_sum + wrkmain.ostatok_kzt.
          if wrkmain.ostatok_kzt > 0 then krport2_num = krport2_num + 1.

          vyd_sum = vyd_sum + wrkmain.sumvyd.
          vyd_sum_crc = vyd_sum_crc + wrkmain.sumvyd_crc.
          if wrkmain.sumvyd > 0 then vyd_num = vyd_num + 1.
        /* для таблицы просрочек wrk4 */
          if j = 1 then do:
            if wrkmain.prosr_day > 0 and wrkmain.prosr_day < 30 then do:
              summa_pr[1] = summa_pr[1] + wrkmain.ostatok_kzt.
              kol_pr[1] = kol_pr[1] + 1.
            end.
            if wrkmain.prosr_day >= 30 and wrkmain.prosr_day < 90 then do:
              summa_pr[2] = summa_pr[2] + wrkmain.ostatok_kzt.
              kol_pr[2] = kol_pr[2] + 1.
            end.
            if wrkmain.prosr_day >= 90 then do:
              summa_pr[3] = summa_pr[3] + wrkmain.ostatok_kzt.
              kol_pr[3] = kol_pr[3] + 1.
            end.
          end.
        end. /* для таблицы просрочек wrk4 - end */
    
        create wrk2.
        wrk2.segm = codfr.code.
        wrk2.datot = dates[j].
        wrk2.sumkzt = vyd_sum.
        wrk2.crccode = crc.code.
        wrk2.sumcrc = vyd_sum_crc.
        wrk2.number = vyd_num.
        if vyd_sum_crc = 0 then do:
          delete wrk2.
        end.    
        if j = 1 and summa_pr[1] + summa_pr[2] + summa_pr[3] > 0 then do:
          create wrk4.
          wrk4.segm_name = codfr.name[1].
          wrk4.prosr_do30[1] = summa_pr[1].
          wrk4.prosr_do30[2] = kol_pr[1].
          wrk4.prosr_30-90[1] = summa_pr[2].
          wrk4.prosr_30-90[2] = kol_pr[2].
          wrk4.prosr_90more[1] = summa_pr[3].
          wrk4.prosr_90more[2] = kol_pr[3].
        end.
    
        if j = 1 and krport2_sum > 0 then do:
          create wrk1.
          wrk1.nn = i.
          wrk1.name = codfr.name[1].
          wrk1.sumkzt = krport2_sum.
          wrk1.sumusd = krport2_sum / cur_usd.
          wrk1.number = krport2_num.
          wrk1.mshare = 0.
          wrk1.mshare2 = "сумме потреб. кредитов".
          i = i + 1.
          krport_potreb[1] = krport_potreb[1] + krport2_sum.
          krport_potreb[2] = krport_potreb[2] + krport2_num.
        end.
      end. /* do i = 1 to 5 */
    end. /* for each codfr */
  end. /*for each crc*/

  create wrk1.
  wrk1.nn = 2.
  wrk1.name = "Потребительские кредиты".
  wrk1.sumkzt = krport_potreb[1].
  wrk1.sumusd = krport_potreb[1] / cur_usd.
  wrk1.number = krport_potreb[2].
  wrk1.mshare = krport_potreb[1] / krport[1] * 100.
  wrk1.mshare2 = "сумме кред. портфеля".

  for each wrk1:
    if wrk1.nn > 2 then wrk1.mshare = wrk1.sumkzt / krport_potreb[1] * 100.
  end.

  if p-reptype = "rep" then output stream rep to value(entry(1,vfname,'.') + "2." + entry(2,vfname,'.')).
  else output stream rep to value(entry(1,p-fname,'.') + "2." + entry(2,p-fname,'.')).

  put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
 /* find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip*/
  put stream rep unformatted    
    "<center><b>Анализ потребительских кредитов в динамике на " dat format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Наименование</td>" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Сумма в USD</td>" skip
    "<td>Количество</td>" skip
    "<td colspan=""2"">Удельный вес (%) к:</td>" skip
    "</tr>" skip.

  for each wrk1 no-lock:
    put stream rep unformatted
    "<tr" if wrk1.nn = 2 then " style=""font:bold"">" else ">" skip.
    put stream rep unformatted
    "<td>" wrk1.name "</td>" skip
    "<td>" replace(replace(trim(string(wrk1.sumkzt, ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" replace(replace(trim(string(wrk1.sumusd, ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" wrk1.number "</td>" skip
    "<td>" replace(string(wrk1.mshare, ">>9.99"),'.',',') "</td>" skip
    "<td>" wrk1.mshare2 "</td>" skip
    "</tr>" skip.
  end. /* for each wrk1 */

  put stream rep unformatted "</table><BR><BR>".

  def var wrk2sums as deci extent 5.
  def var wrk2nums as int extent 5.
  def var wrk2sums_itog as deci extent 5.
  def var wrk2nums_itog as int extent 5.
  def var checksum as deci.
  def var bsum as deci no-undo extent 5.
  def var bnum as integer no-undo extent 5.
  def var clist as char.
   
  for each wrkvyd no-lock break by wrkvyd.segm:
    if first-of(wrkvyd.segm) then do:
      if lookup(wrkvyd.segm,clist) = 0 then do:
        if clist <> '' then clist = clist + ','.
        clist = clist + wrkvyd.segm.
      end.
    end.
    
  end.
    
  for each crc no-lock:
    do i = 1 to 5:
      do j = 1 to num-entries(clist):
        find first wrkvyd where wrkvyd.crc = crc.code and wrkvyd.segm = entry(j,clist) no-lock no-error.
        if avail wrkvyd then do:
          find first wrkvyd where wrkvyd.crc = crc.code and wrkvyd.segm = entry(j,clist) and wrkvyd.datot = dates[i] no-error.
          if not avail wrkvyd then do:
            create wrkvyd.
            wrkvyd.segm = entry(j,clist).
            find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrkvyd.segm no-lock no-error.
            if avail codfr then wrkvyd.name = codfr.name[1].
            wrkvyd.datot = dates[i].
            wrkvyd.crc = crc.code.
          end.
        end.
      end.
    end.
  end.

  /*wrk2sums_itog = 0. wrk2nums_itog = 0.*/
  for each wrk2 no-lock break by wrk2.crccode by wrk2.segm:
    if first-of(wrk2.crccode) then do:
      wrk2sums_itog = 0. wrk2nums_itog = 0.
       put stream rep unformatted
       "ДИНАМИКА РОСТА ВЫДАННЫХ КРЕДИТОВ:" skip
       "<table border=1 cellpadding=0 cellspacing=0>" skip
       "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
       "<td rowspan=""2"">Наименование</td>" skip.
       do i = 1 to 5:
         put stream rep unformatted "<td colspan=""2"">" dates[i] format "99/99/9999" "</td>" skip.
       end.

       put stream rep unformatted "</tr>" skip
       "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.

       do i = 1 to 5:
         put stream rep unformatted
         "<td>Сумма в " wrk2.crccode "</td>" skip
         "<td>Количество</td>" skip.
       end.
       put stream rep unformatted "</tr>" skip.
    end.
    
    if first-of(wrk2.segm) then do:
       checksum = 0. wrk2sums = 0. wrk2nums = 0.
       i = 1.
    end.
  
    wrk2sums[i] = wrk2.sumcrc.
    wrk2nums[i] = wrk2.number.
    checksum = checksum + wrk2.sumcrc.
    i = i + 1.
  
    if last-of(wrk2.segm) then do:
      if checksum > 0 then do:
        find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk2.segm no-lock no-error.
        put stream rep unformatted "<tr>" skip
              "<td>" if avail codfr then codfr.name[1] else "" "</td>" skip.
        do j = 1 to 5:
          put stream rep unformatted
           "<td>" replace(replace(trim(string(wrk2sums[j], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
           "<td>" wrk2nums[j] "</td>" skip.
          wrk2sums_itog[j] = wrk2sums_itog[j] + wrk2sums[j].
          wrk2nums_itog[j] = wrk2nums_itog[j] + wrk2nums[j].
        end.
        put stream rep unformatted "</tr>" skip.
      end.
    end.
    if last-of(wrk2.crccode) then do:
      put stream rep unformatted
      "<tr style=""font:bold"">" skip
      "<td>ИТОГО</td>" skip.
      do i = 1 to 5:
         put stream rep unformatted
         "<td>" replace(replace(trim(string(wrk2sums_itog[i], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
         "<td>" wrk2nums_itog[i] "</td>" skip.
      end.
      put stream rep unformatted "</tr>" skip.

      put stream rep unformatted "</table><BR><BR>".
    
      bsum = 0. bnum = 0.
      put stream rep unformatted
                  "ДИНАМИКА РОСТА ВЫДАННЫХ КРЕДИТОВ ЗА ПЕРИОД:" skip
                  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td></td>" skip.
      do i = 1 to 5:
        put stream rep unformatted "<td align=""center"" colspan=""2"">" dates[i] "</td>" skip.
      end.

      for each wrkvyd where wrkvyd.crc = wrk2.crccode no-lock break by wrkvyd.segm by wrkvyd.datot desc:
        if first-of(wrkvyd.segm) then do:
           i = 1.
           put stream rep unformatted "</tr>" skip
                 "<td>" wrkvyd.name "</td>" skip.
        end.
        put stream rep unformatted
         "<td>" replace(replace(trim(string(wrkvyd.sum_crc,'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') "</td>" skip
         "<td>" wrkvyd.kol "</td>" skip.
        bsum[i] = bsum[i] + wrkvyd.sum_crc.
        bnum[i] = bnum[i] + wrkvyd.kol.
        i = i + 1.
      end. /* for each wrkvyd */

      put stream rep unformatted "</tr>" skip.

      put stream rep unformatted
                  "<tr style=""font:bold"">" skip
                  "<td>ИТОГО</td>" skip.
      do i = 1 to 5:
        put stream rep unformatted
        "<td>" replace(replace(trim(string(bsum[i],'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') "</td>" skip
        "<td>" bnum[i] "</td>" skip.
      end.

      put stream rep unformatted "</tr></table><br><br>" skip.

    end. /*if last-of(wrk2.crccode)*/
   
  end. /* for each wrk2 */

  def var psum as deci extent 4.
  def var pkol as integer extent 4.

  for each lonstat no-lock use-index lonstat:
    psum = 0. pkol = 0.
    for each wrkmain where wrkmain.datot = dat and wrkmain.rezervprc = lonstat.prc no-lock:
      case wrkmain.segm:
        when '01' then do: psum[1] = psum[1] + wrkmain.rezerv_form. if wrkmain.rezerv_form > 0 then  pkol[1] = pkol[1] + 1. end.
        when '02' then do: psum[2] = psum[2] + wrkmain.rezerv_form. if wrkmain.rezerv_form > 0 then pkol[2] = pkol[2] + 1. end.
        when '03' then do: psum[3] = psum[3] + wrkmain.rezerv_form. if wrkmain.rezerv_form > 0 then pkol[3] = pkol[3] + 1. end.
        otherwise do: psum[4] = psum[4] + wrkmain.rezerv_form. if wrkmain.rezerv_form > 0 then pkol[4] = pkol[4] + 1. end.
      end.
    end.
    if pkol[1] + pkol[2] + pkol[3] + pkol[4] > 0 then do:
      create wrk3.
      wrk3.sts_name = lonstat.apz + " - " + string(lonstat.prc,">>9") + "%".
      do i = 1 to 4:
         wrk3.sum[i] = psum[i].
         wrk3.num[i] = pkol[i].
      end.
    end.
  end. /* for each lonstat */

 /* put stream rep unformatted
    "СОЗДАННЫЕ ПРОВИЗИИ:" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=""2"">Наименование</td>" skip
    "<td colspan=""2"">Стандартный</td>" skip
    "<td colspan=""2"">Льготный</td>" skip
    "<td colspan=""2"">ИП</td>" skip
    "<td colspan=""2"">Остальные</td>" skip
    "<td colspan=""2"">Итого</td>" skip
    "<td colspan=""2"">Доля в портфеле (%)</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Количество</td>" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Количество</td>" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Количество</td>" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Количество</td>" skip
    "<td>Сумма в KZT</td>" skip
    "<td>Количество</td>" skip
    "<td>По сумме</td>" skip
    "<td>По количеству</td>" skip
    "</tr>" skip.

  psum = 0. pkol = 0.
  for each wrk3 no-lock:
      put stream rep unformatted
        "<tr>" skip
        "<td>" wrk3.sts_name "</td>" skip.
    
      do i = 1 to 4:
         put stream rep unformatted
         "<td>" replace(replace(trim(string(wrk3.sum[i], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
         "<td>" wrk3.num[i] "</td>" skip.
      end.
    
      put stream rep unformatted
        "<td>" replace(replace(trim(string(wrk3.sum[1] + wrk3.sum[2] + wrk3.sum[3] + wrk3.sum[4], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
        "<td>" wrk3.num[1] + wrk3.num[2] + wrk3.num[3] + wrk3.num[4] "</td>" skip
        "<td>" replace(string((wrk3.sum[1] + wrk3.sum[2] + wrk3.sum[3] + wrk3.sum[4]) / krport_potreb[1] * 100, ">>9.99"),'.',',') "</td>" skip
        "<td>" replace(string((wrk3.num[1] + wrk3.num[2] + wrk3.num[3] + wrk3.num[4]) / krport_potreb[2] * 100, ">>9.99"),'.',',') "</td>" skip
        "</tr>" skip.
    
      do i = 1 to 4:
         psum[i] = psum[i] + wrk3.sum[i].
         pkol[i] = pkol[i] + wrk3.num[i].
      end.
  end.*/ /* for each wrk3 */

/*  put stream rep unformatted
  "<tr style=""font:bold"">" skip
  "<td>ИТОГО</td>" skip
  "<td>" replace(replace(trim(string(psum[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[1] "</td>" skip
  "<td>" replace(replace(trim(string(psum[2], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[2] "</td>" skip
  "<td>" replace(replace(trim(string(psum[3], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[3] "</td>" skip
  "<td>" replace(replace(trim(string(psum[4], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[4] "</td>" skip
  "<td>" replace(string((psum[1] + psum[2] + psum[3] + psum[4]) / krport_potreb[1] * 100, ">>9.99"),'.',',') "</td>" skip
  "<td>" replace(string((pkol[1] + pkol[2] + pkol[3] + pkol[4]) / krport_potreb[2] * 100, ">>9.99"),'.',',') "</td>" skip
  "<td></td><td></td>" skip
  "</tr>" skip.

  put stream rep unformatted "</table><BR><BR>".*/

  put stream rep unformatted
    "ПРОСРОЧЕННЫЕ КРЕДИТЫ:" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=""2"">Наименование</td>" skip
    "<td colspan=""3"">Просрочка до 30</td>" skip
    "<td colspan=""3"">Просрочка от 30 до 90</td>" skip
    "<td colspan=""3"">Просрочка свыше 90</td>" skip
    "<td colspan=""3"">Итого</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Сумма долга</td>" skip
    "<td>Количество</td>" skip
    "<td>Уд. вес (%)</td>" skip
    "<td>Сумма долга</td>" skip
    "<td>Количество</td>" skip
    "<td>Уд. вес (%)</td>" skip
    "<td>Сумма долга</td>" skip
    "<td>Количество</td>" skip
    "<td>Уд. вес (%)</td>" skip
    "<td>Сумма долга</td>" skip
    "<td>Количество</td>" skip
    "<td>Уд. вес (%)</td>" skip
    "</tr>" skip.

  psum = 0. pkol = 0.
  for each wrk4 no-lock:
    put stream rep unformatted
    "<tr>" skip
    "<td>" wrk4.segm_name "</td>" skip
    "<td>" replace(replace(trim(string(wrk4.prosr_do30[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" wrk4.prosr_do30[2] "</td>" skip
    "<td>" replace(string(wrk4.prosr_do30[1] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
    "<td>" replace(replace(trim(string(wrk4.prosr_30-90[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" wrk4.prosr_30-90[2] "</td>" skip
    "<td>" replace(string(wrk4.prosr_30-90[1] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
    "<td>" replace(replace(trim(string(wrk4.prosr_90more[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" wrk4.prosr_90more[2] "</td>" skip
    "<td>" replace(string(wrk4.prosr_90more[1] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
    "<td>" replace(replace(trim(string(wrk4.prosr_do30[1] + wrk4.prosr_30-90[1] + wrk4.prosr_90more[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
    "<td>" wrk4.prosr_do30[2] + wrk4.prosr_30-90[2] + wrk4.prosr_90more[2] "</td>" skip
    "<td>" replace(string((wrk4.prosr_do30[1] + wrk4.prosr_30-90[1] + wrk4.prosr_90more[1]) / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
    "</tr>" skip.
  
    psum[1] = psum[1] + wrk4.prosr_do30[1].
    pkol[1] = pkol[1] + wrk4.prosr_do30[2].
    psum[2] = psum[2] + wrk4.prosr_30-90[1].
    pkol[2] = pkol[2] + wrk4.prosr_30-90[2].
    psum[3] = psum[3] + wrk4.prosr_90more[1].
    pkol[3] = pkol[3] + wrk4.prosr_90more[2].
  end. /* for each wrk4 */

  put stream rep unformatted
  "<tr style=""font:bold"">" skip
  "<td>ИТОГО</td>" skip
  "<td>" replace(replace(trim(string(psum[1], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[1] "</td>" skip
  "<td>" replace(string(psum[1] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
  "<td>" replace(replace(trim(string(psum[2], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[2] "</td>" skip
  "<td>" replace(string(psum[2] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
  "<td>" replace(replace(trim(string(psum[3], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[3] "</td>" skip
  "<td>" replace(string(psum[3] / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
  "<td>" replace(replace(trim(string(psum[1] + psum[2] + psum[3], ">>>,>>>,>>>,>>>,>>9.99")),',',' '),'.',',') "</td>" skip
  "<td>" pkol[1] + pkol[2] + pkol[3] "</td>" skip
  "<td>" replace(string((psum[1] + psum[2] + psum[3]) / krport_potreb[1] * 100 , ">>9.99"),'.',',') "</td>" skip
  "</tr>" skip.

  put stream rep unformatted "</body></html>".
  output stream rep close.
  v-exist2 = "0".
end.
if p-reptype = "rep" then do:
  hide message no-pause.
  if v-exist1 = "0" then unix silent cptwin value(entry(1,vfname,'.') + "1." + entry(2,vfname,'.')) excel.
  if v-exist2 = "0" then unix silent cptwin value(entry(1,vfname,'.') + "2." + entry(2,vfname,'.')) excel.
end.  

