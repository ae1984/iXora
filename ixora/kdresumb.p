
/* kdresumb.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Сводный отчет по досье заемщика
 * RUN
        kdresum
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-5-2
 * AUTHOR
        30/09/2005 madiyar - скопировал с изменениями из kdresum1
 * CHANGES
        13/10/2005 madiyar - изменения в фин. результатах
        01/12/2005 madiyar - изменения в фин. результатах, исправил ошибку в активах
        22/06/2006 madiyar - в качестве даты образования выводим дату первичного образования (kdcif.urdt1)
    05/09/06   marinav - добавление индексов
*/

define shared var g-ofc    like txb.ofc.ofc.
define shared var g-today  as date.
{kd.i}

define var god as inte.
define buffer jl2 for txb.jl.
define var summa as deci.
define var v-sum as deci format '->>>,>>>,>>>,>>9.99' extent 8.
define var i as inte init 1.
define var inf as char init 0 extent 2.
define var v-descr as char.
define var v-obes as char.
define var bilance as decimal.
define var bilancepl as decimal.
define var v-dt as date.

def temp-table temp_jl
    field tjh like txb.jl.jh
    field tgl like txb.gl.gl
    field sumjl like txb.jl.dam
    index tgl tjh tgl.

def temp-table temp_cr
    field bnk_name as char
    field bnk_prod as char
    field crc like txb.crc.crc
    field opnamt as deci
    field prem as deci
    field dt_rg as date
    field dt_pf as date
    field dt_pd as date
    field ost as deci
    field vznos as deci
    field obes as char
    field dinfo as char
    index dt_rg dt_rg descending.

define var date1 as char.
define var sum1 as deci.
define var date2 as char.
define var sum2 as deci.
define var sum3 as deci.
/* define var sum4 as deci. */
define var v-statdescr as char.

def var v-ofc as char.

find first kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
if not avail kdlon then do:
   message skip " Заявка N" s-kdlon "не найдена !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
end.

find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
if not avail kdcif then do:
   message skip " Клиент N" kdlon.kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
end.

def var v-type as char.
v-type = kdcif.manager.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out unformatted skip.
           
put stream m-out unformatted "<html><head><title>TEXAKABANK:</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>".
put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""3"" style=""border-collapse: collapse"">" skip
           "<tr>" skip
           "<td align=""left""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></td>" skip
           "<td colspan=2 align=""right""><h3>АО TEXAKABANK</h3></td></tr>" skip
           "<tr><td colspan=3 align=""right""><h3>Кредитный департамент</h3></td></tr>" skip
           "<tr><td colspan=3 align=""center""><h3>Заключение по проекту</h3></td></tr>" skip
           "</table><br><br>" skip.

find txb.ofc where txb.ofc.ofc = kdlon.who no-lock no-error.
v-ofc = entry(1, txb.ofc.name, " ").
if num-entries(txb.ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, txb.ofc.name, " "), 1, 1) + ".".
if num-entries(txb.ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, txb.ofc.name, " "), 1, 1) + ".".

put stream m-out unformatted "<h4> Подготовлено : "  v-ofc "</h4>" skip
           "<h4> Дата : " g-today format "99/99/9999" "</h4>" skip
           "<h3> 1. Информация по кредиту</h3><br>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""3"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr>" skip
                 "<td><b> 1.1. Заемщик:</b></td>" skip
                 "<td>" trim(kdcif.prefix) " " trim(kdcif.name) "</td></tr>" skip.

if v-type = '1' or v-type = '2' then do: /* Физ, ЧП */
  put stream m-out unformatted "<tr>"
               "<td> Уд. личности </td>"
               "<td> " kdcif.docs[1] "</td>"
               "</tr>" skip.
  put stream m-out unformatted "<tr>"
               "<td> РНН </td>"
               "<td>" kdcif.rnn "</td>"
               "</tr>" skip.
  put stream m-out unformatted "<tr>"
               "<td> Адрес по месту регистрации:  </td>"
               "<td> " kdcif.addr[1] "</td>"
               "</tr>" skip.
  put stream m-out unformatted "<tr>"
               "<td> Адрес по месту проживания:  </td>"
               "<td>" kdcif.addr[2] "</td>"
               "</tr>" skip.
  put stream m-out unformatted "<tr>"
               "<td>  Телефон </td>"
               "<td>" kdcif.tel "</td>"
               "</tr>" skip.
  find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = kdcif.ecdivis no-lock no-error.
  put stream m-out unformatted "<tr>"
               "<td> Отрасль  </td>"
               "<td>" txb.codfr.name[1] "</td>"
               "</tr>" skip.
end. /* Физ, ЧП */
else do: /* юр */
  find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = kdcif.ecdivis no-lock no-error.
   put stream m-out unformatted "<tr>"
               "<td> Отрасль  </td>"
               "<td>" txb.codfr.name[1] "</td>"
               "</tr>"  skip.
   put stream m-out unformatted "<tr>"
               "<td> Юридический адрес:  </td>"
               "<td>" kdcif.addr[1] "</td>"
               "</tr>"  skip.
   put stream m-out unformatted "<tr>"
               "<td> Фактический адрес:  </td>"
               "<td>" kdcif.addr[2] "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr>"
               "<td>  Дата образования </td>"
               "<td align=""left"">" if kdcif.urdt1 <> ? then kdcif.urdt1 else kdcif.urdt "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr>"
               "<td>  Телефон </td>"
               "<td>" kdcif.tel "</td>"
               "</tr>" skip.

   put stream m-out unformatted "<tr>"
               "<td>  Учредители / Акционеры </td>"
               "<td></td></tr>" skip.

   for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif no-lock.
      put stream m-out unformatted "<tr>"
                       "<td> - " kdaffil.name "</td>"
                       "<td>" kdaffil.amount format '>>9.99%' "</td>"
                       "</tr>" skip.
   end.
   
   put stream m-out unformatted "<tr>"
               "<td>  Руководитель " kdcif.job[1] "</td>"
               "<td>" kdcif.chief[1] "</td>"
               "</tr>" skip.

   put stream m-out unformatted "<tr>"
               "<td> Количество сотрудников </td>"
               "<td align=""left"">" kdcif.sotr format ">>>>9" "</td>"
               "</tr>" skip.
end. /* юр */

put stream m-out unformatted "</table><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<b> 1.2. Аффилированные компании </b><br>" skip.
  put stream m-out unformatted "<table border=""1"" cellpadding=""3"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
  
  for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif no-lock.
     put stream m-out unformatted "<tr valign=""top"">"
               "<td>" kdaffil.name "</td>"
               "<td>" kdaffil.affilate "</td>"
               "<td>" kdaffil.info[1] "</td>"
               "</tr>" skip.
  end.
end.

put stream m-out unformatted "</table><br>" skip.

find first txb.cif where txb.cif.jss = kdcif.rnn no-lock no-error.
if avail txb.cif then do:
  find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
  if avail kdaffil then do:
     put stream m-out unformatted
                "<b>1.3. Взаимоотношения с банками<br>" skip
                 "Дата открытия счета в TXB : " txb.cif.regdt format "99/99/9999" "<br><br>" skip.

/* Текущие и сберегат счета клиента */

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock .
          v-sum[1] = v-sum[1] + decimal(entry(2,kdaffil.info[1])) / 1000.
          v-sum[2] = v-sum[2] + decimal(entry(4,kdaffil.info[1])).
          v-sum[3] = v-sum[3] + decimal(entry(6,kdaffil.info[1])).
          v-sum[4] = v-sum[4] + decimal(entry(8,kdaffil.info[1])).
end.
  put stream m-out unformatted "<b>1.3.1. Счета в банках.<BR><BR>Полный среднемесячный кредитовый оборот по счетам.</b><br>" skip.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> KZT, тыс. тенге</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> USD</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> RUR</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> EURO</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td></tr>" skip.

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock.
            put stream m-out unformatted
               "<tr align=""right"">" skip
               "<td align=""left"">" kdaffil.name "</td>" skip
               "<td>" replace(trim(string(deci(entry(2, kdaffil.info[1])) / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string((deci(entry(2, kdaffil.info[1]))/ 1000 / v-sum[1] * 100), "->>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(4, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(4, kdaffil.info[1])) / v-sum[2] * 100, "->>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(6, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(6, kdaffil.info[1])) / v-sum[3] * 100, "->>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(8, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(8, kdaffil.info[1])) / v-sum[4] * 100, "->>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
end.
put stream m-out unformatted
   "<tr align=""right"">" skip
   "<td align=""left""> ИТОГО </td>" skip
   "<td>" replace(trim(string(v-sum[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
   "<td>100%</td>" skip
   "<td>" replace(trim(string(v-sum[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
   "<td>100%</td>" skip
   "<td>" replace(trim(string(v-sum[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
   "<td>100%</td>" skip
   "<td>" replace(trim(string(v-sum[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
   "<td>100%</td></tr>" skip.

put stream m-out unformatted "</table><br><br>" skip.

assign v-sum[1] = 0 v-sum[2] = 0 v-sum[3] = 0 v-sum[4] = 0.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  and kdaffil.code = '09' and kdaffil.name matches '*TEXAKABANK*' no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<b>Чистый среднемесячный кредитовый оборот по счетам в Texakabank.</b><br>" skip.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> KZT, тыс. тенге</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> USD</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> RUR</td>" skip
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> EURO</td></tr>" skip.

  put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" kdaffil.name "</td>" skip
               "<td>" replace(trim(string(deci(entry(2, kdaffil.info[3])) / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(4, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(6, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(entry(8, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr></table><br><br>" skip.
end. /* if avail kdaffil */

  put stream m-out unformatted "<b>1.3.2. Остатки на счетах.</b><br>" skip.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip
                  "</tr>" skip.

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock:
   put stream m-out unformatted
      "<tr align=""right"">" skip
      "<td align=""left""><b>" kdaffil.name "</b></td>" skip
      "<td></td></tr>" skip.
   repeat i = 1 to num-entries(kdaffil.info[2]) by 2:
            put stream m-out unformatted "<tr align=""right"">" skip
               "<td  align=""left"">" entry(i , kdaffil.info[2]) "</td>" skip
               "<td>" replace(trim(string(deci(entry(i + 1, kdaffil.info[2])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
    end.
end.

put stream m-out "</table><br><br>".

put stream m-out "<b>Среднедневной компенсационный остаток по текущим счетам в TEXAKABANK, тенге (за послед. 3 месяца)</b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '16' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock no-error.
if not avail kdaffil then do:

   define var v-list as char init '1,2,4,11'.   /*'KZT,USD,RUB,EUR'.*/
   define var v-crc as char format 'x(15)' extent 5.
   define var d1 as date.
   define var d2 as date.
   def var vyear as inte.
   def var vmonth as inte.
   def var vday as inte.
   def var mdays as inte.

   repeat i = 1 to num-entries(v-list):
        v-sum[i] =0.
   end.
   create kdaffil.
   assign kdaffil.bank = s-ourbank
          kdaffil.code = '16'
          kdaffil.kdcif = s-kdcif
          kdaffil.kdlon = s-kdlon
          kdaffil.who = g-ofc
          kdaffil.whn = g-today.
          kdaffil.name = "АО TEXAKABANK".
     find current kdaffil no-lock no-error.

     vyear = year(kdlon.regdt).
     vmonth = month(kdlon.regdt) - 3.
     vday = day(kdlon.regdt).
     if vmonth <= 0 then do:
        vmonth = vmonth + 12. vyear = vyear - 1.
     end.
     run mondays(vmonth,vyear,output mdays).
     if vday > mdays then vday = mdays.
     d1 = date(vmonth,vday,vyear).

   repeat i = 1 to num-entries(v-list):
   find last txb.crchis where txb.crchis.crc = inte(entry(i,v-list)) and txb.crchis.regdt le kdlon.regdt no-lock no-error.
   if avail txb.crchis then do:
     v-crc[i] = txb.crchis.code.
     v-sum[i] = 0.
     for each txb.lgr where txb.lgr.led eq "DDA" or txb.lgr.led eq "SAV" no-lock, each
        txb.aaa of txb.lgr where txb.aaa.cif = s-kdcif and txb.aaa.crc = txb.crchis.crc no-lock.
       
       repeat d2 = d1 to kdlon.regdt.
         find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt le d2 no-lock no-error.
         if avail txb.aab then v-sum[i] = v-sum[i] + txb.aab.bal.
       end.
       
     end.
     v-sum[i] = v-sum[i] / (kdlon.regdt - d1).
 
     find current kdaffil exclusive-lock no-error.
     if kdaffil.info[1] = ''
     then kdaffil.info[1] = v-crc[i]  + ',' + string(v-sum[i]).
     else kdaffil.info[1] = kdaffil.info[1] + ',' + v-crc[i] + ',' + string(v-sum[i]).
     find current kdaffil no-lock no-error.
                         
   end.
   end.
end. /* if not avail kdaffil */
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip
                  "</tr>" skip.

    repeat i = 1 to num-entries(kdaffil.info[1]) by 2:
            put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" entry(i, kdaffil.info[1]) "</td>" skip
               "<td>" replace(trim(string(deci(entry(i + 1, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
    end.
  put stream m-out unformatted "</table></br><br>".

/* Доходность клиента **/
/* комиссионные*/

put stream m-out unformatted "<b>1.3.3.  Доходы в TXB по клиенту, тыс. тенге </b><br>" skip.

sum1 = 0. sum2 = 0. sum3 = 0. /* sum4 = 0. */
find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '07' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
   assign
      date1 = entry(1,kdaffil.info[1])
      sum1 = deci(entry(2,kdaffil.info[1]))
      date2 = entry(3,kdaffil.info[1])
      sum2 = deci(entry(4,kdaffil.info[1])).
      sum3 = deci(entry(6,kdaffil.info[1])).
     /* sum4 = amountz * (sum3 + ratez) / 12 * srokz. */

  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center""></td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" date1 format 'x(4)' "</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" date2 format 'x(4)' "</td>" skip
                  "</tr>" skip.
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""> Комиссионные доходы, тыс. тенге</td>" skip
               "<td>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
end.
else
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""> Комиссионные доходы, тыс. тенге</td>" skip
               "<td> </td>" skip
               "<td> </td>" skip
               "</tr>" skip.

/* кредитные */

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '08' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.

if avail kdaffil then do:
  assign
      date1 = entry(1,kdaffil.info[1])
      sum1 = deci(entry(2,kdaffil.info[1]))
      date2 = entry(3,kdaffil.info[1])
      sum2 = deci(entry(4,kdaffil.info[1])).
  
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""> Доходы по кредитованию, тыс. тенге </td>" skip
               "<td>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
end.
else
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""> Доходы по кредитованию, тыс. тенге</td>" skip
               "<td> </td>" skip
               "<td> </td>" skip
               "</tr>" skip.
put stream m-out unformatted "</table><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""><tr align=""right"">" skip
               "<td align=""left""> Прогнозируемая доходность по СПФ (% годовых) </td>" skip
               "<td>" replace(trim(string(sum3, "->>>>9.9999")),".",",") "</td>" skip
               "</tr>" skip.
  /* 12/05/2004 madiar
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Всего доходность за период финансирования клиента, тенге </td>"
               "<td> " replace(trim(string(sum4 / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td></td>"
               "</tr>" */
put stream m-out unformatted "</table><br><br>" skip.

  end. /* if avail kdaffil */
end. /* if avail txb.cif */

/*Кредитная история*/

define var sumost as deci init 0.
define var sumvznos as deci init 0.

for each txb.lon where txb.lon.cif = s-kdcif no-lock:

  run atl-dat1 (txb.lon.lon, kdlon.regdt, 4, output bilance).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = txb.lon.gua no-lock no-error.
  if avail bookcod then v-descr = bookcod.name. else v-descr = 'Не определен'.
  v-dt = ?.  /*дата погашения*/
  if bilance = 0 then do:
    find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat <= kdlon.regdt no-lock no-error.
    if avail txb.lnsch then v-dt = txb.lnsch.stdat.
  end.
  find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 no-lock no-error.
  find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 no-lock no-error.
  v-obes = "".
  for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
    find first txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
    if v-obes <> "" then v-obes = v-obes + "; ".
    v-obes = v-obes + entry(1,txb.lonsec1.prm,"&") + ", " + trim(txb.crc.code) + trim(string(txb.lonsec1.secamt, ">>>>>>>>>>9.99")).
  end.
  
  create temp_cr.
  assign
    temp_cr.bnk_name = "TEXAKABANK"
    temp_cr.bnk_prod = v-descr
    temp_cr.crc = txb.lon.crc
    temp_cr.opnamt = txb.lon.opnamt
    temp_cr.prem = txb.lon.prem
    temp_cr.dt_rg = txb.lon.rdt
    temp_cr.dt_pf = v-dt
    temp_cr.dt_pd = txb.lon.duedt
    temp_cr.ost = bilance
    temp_cr.vznos = txb.lnsch.stval + txb.lnsci.iv-sc
    temp_cr.obes = v-obes
    temp_cr.dinfo = "".
  
end. /* for each txb.lon */

for each kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.code = '03' no-lock:
  create temp_cr.
  assign
    temp_cr.bnk_name = kdaffil.name
    temp_cr.bnk_prod = entry(2,kdaffil.info[1],'|')
    temp_cr.crc = inte(entry(4,kdaffil.info[1],'|'))
    temp_cr.opnamt = deci(entry(3,kdaffil.info[1],'|'))
    temp_cr.prem = deci(entry(5,kdaffil.info[1],'|'))
    temp_cr.dt_rg = date(entry(6,kdaffil.info[1],'|'))
    temp_cr.dt_pf = date(entry(7,kdaffil.info[1],'|'))
    temp_cr.dt_pd = date(entry(8,kdaffil.info[1],'|'))
    temp_cr.ost = deci(entry(9,kdaffil.info[1],'|'))
    temp_cr.vznos = deci(entry(10,kdaffil.info[1],'|'))
    temp_cr.obes = entry(11,kdaffil.info[1],'|')
    temp_cr.dinfo = entry(12,kdaffil.info[1],'|').
end. /* for each kdaffil */

find first temp_cr where temp_cr.ost = 0 no-lock no-error.
if avail temp_cr then do:
put stream m-out unformatted "<b>1.3.4. Кредитная история  </b><br>" skip.
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование банка</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Банковский продукт</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Одобрен-<BR>ный лимит</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ставка %%</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата возник-<BR>новения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата погашения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Текущий<BR>остаток</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Взнос<BR>по обяза-<BR>тельству</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Обеспечение</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Доп.<BR>информация</td></tr>" skip.
put stream m-out unformatted "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"">по факту</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"">по договору</td>" skip
                 "</tr>" skip.

for each temp_cr where temp_cr.ost = 0 no-lock:
  find first txb.crc where txb.crc.crc = temp_cr.crc no-lock no-error.
  put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" temp_cr.bnk_name "</td>" skip
               "<td>" temp_cr.bnk_prod "</td>" skip
               "<td>" replace(trim(string(temp_cr.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td>" replace(trim(string(temp_cr.prem, "->>>>9.99")),".",",")  "</td>" skip
               "<td>" temp_cr.dt_rg "</td>" skip
               "<td>" temp_cr.dt_pf "</td>" skip
               "<td>" temp_cr.dt_pd "</td>" skip
               "<td>" replace(trim(string(temp_cr.ost, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td>" replace(trim(string(temp_cr.vznos, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td align=""left"">" temp_cr.obes "</td>" skip
               "<td>" temp_cr.dinfo "</td>" skip
               "</tr>" skip.
end.
put stream m-out unformatted "</table><br><br>" skip.
end. /* if avail temp_cr */

find first temp_cr where temp_cr.ost > 0 no-lock no-error.
if avail temp_cr then do:

put stream m-out unformatted "<b>1.3.5. Текущие обязательства</b><br>" skip.
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование банка</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Банковский продукт</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Одобрен-<BR>ный лимит</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ставка %%</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата возник-<BR>новения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата погашения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Текущий<BR>остаток</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Взнос<BR>по обяза-<BR>тельству</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Обеспечение</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Доп.<BR>информация</td></tr>" skip.
put stream m-out unformatted "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по факту</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по договору</td>"
                 "</tr>" skip.

for each temp_cr where temp_cr.ost <> 0 no-lock:
  find first txb.crc where txb.crc.crc = temp_cr.crc no-lock no-error.
  put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" temp_cr.bnk_name "</td>" skip
               "<td>" temp_cr.bnk_prod "</td>" skip
               "<td>" replace(trim(string(temp_cr.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td>" replace(trim(string(temp_cr.prem, "->>>>9.99")),".",",")  "</td>" skip
               "<td>" temp_cr.dt_rg "</td>" skip
               "<td>" temp_cr.dt_pf "</td>" skip
               "<td>" temp_cr.dt_pd "</td>" skip
               "<td>" replace(trim(string(temp_cr.ost, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td>" replace(trim(string(temp_cr.vznos, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
               "<td align=""left"">" temp_cr.obes "</td>" skip
               "<td>" temp_cr.dinfo "</td>" skip
               "</tr>" skip.
  sumost = sumost + temp_cr.ost * txb.crc.rate[1].
  sumvznos = sumvznos + temp_cr.vznos * txb.crc.rate[1].
end.

put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""> ИТОГО </td>" skip
               "<td></td><td></td><td></td><td></td><td></td><td></td>" skip
               "<td>" replace(trim(string(sumost, "->>>>>>>>>>>9.99")),".",",") " KZT</td>" skip
               "<td>" replace(trim(string(sumvznos, "->>>>>>>>>>>9.99")),".",",") " KZT</td>" skip
               "<td></td><td></td>" skip
               "</tr></table><br><br>" skip.

end. /* if avail temp_cr */

put stream m-out unformatted "<b>1.3.6. Кредиты руководителя и учредителей</b><br>" skip.
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Заемщик</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Одобренный лимит</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Дата возник-<BR>новения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Дата<BR>погашения</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Текущий<BR>остаток</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" >Просрочка</td>" skip
                 "</tr>" skip.

def temp-table t-ln
  field cif like kdcif.kdcif
  field name as char
  index main is primary cif ASC.

  if kdcif.chief[1] <> "" and kdcif.chief[1] <> " " then do:
    find first txb.cif where caps(txb.cif.name) matches "*" + caps(kdcif.chief[1]) + "*" no-lock no-error.
    if avail txb.cif then do:
       for each txb.cif where caps(txb.cif.name) matches "*" + caps(kdcif.chief[1]) + "*" and not can-find(t-ln where t-ln.cif = txb.cif.cif) no-lock.
          create t-ln.
          assign t-ln.name = caps(txb.cif.name)
                 t-ln.cif = txb.cif.cif.
       end.
    end.
  end.
  
  for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif no-lock.
    if kdaffil.name <> "" and kdaffil.name <> " " then do:
       for each txb.cif where caps(txb.cif.name) matches "*" + caps(kdaffil.name) + "*" and not can-find(t-ln where t-ln.cif = txb.cif.cif) no-lock.
          create t-ln.
          assign t-ln.name = caps(txb.cif.name)
               t-ln.cif = txb.cif.cif.
       end.
    end.
  end.
  
  for each t-ln, each txb.lon where txb.lon.cif = t-ln.cif no-lock .

      run atl-dat1 (txb.lon.lon, kdlon.regdt, 4, output bilance).
      
      if bilance = 0 then next.
      bilancepl = 0.   /* На тек день по графику погашения */
      for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0 and txb.lnsch.stdat le kdlon.regdt no-lock:
           bilancepl = bilancepl + txb.lnsch.stval.
      end.
      bilancepl = txb.lon.opnamt - bilancepl. /* долг по графику , который должен остаться*/
      bilancepl = bilance - bilancepl.
      if bilancepl < 0 then bilancepl = 0.

      find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
      
      put stream m-out unformatted "<tr align=""right"">" skip
                   "<td align=""left"">" t-ln.name "</td>" skip
                  "<td>" replace(trim(string(txb.lon.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
                  "<td>" txb.lon.rdt "</td>" skip
                  "<td>" txb.lon.duedt "</td>" skip
                  "<td> " replace(trim(string(bilance, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
                  "<td> " replace(trim(string(bilancepl, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
                  "</tr>" skip.
      
  end.
  put stream m-out unformatted "</table><br><br>" skip.

put stream m-out unformatted "<b>1.4. Описание бизнеса </b><br>" skip.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.code = '11' no-lock no-error.
if avail kdaffil then do:
  define var v-desbis as char extent 2.
  put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
  put stream m-out unformatted
                    "<tr><td><b>Описание бизнеса заемщика</td></tr>" skip
                    "<tr align=""left""><td colspan=5> " kdaffil.info[3] "</td></tr>" skip.
   put stream m-out unformatted "</table><br><br>" skip.
   v-desbis[1] = kdaffil.info[5].
   v-desbis[2] = kdaffil.info[6].
end.

/**********************************************************************************/
put stream m-out unformatted "<b>1.5. Анализ финансового состояния</b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '18' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock no-error.
if avail kdaffil then do:

def var v-datold like txb.bal_cif.rdt.
assign v-datold = kdaffil.datres[1] v-dt = kdaffil.datres[2].

def var sum1sum2 like txb.bal_cif.amount.
def var sumold1 like txb.bal_cif.amount.
def var sumold2 like txb.bal_cif.amount.
def var sumold3 like txb.bal_cif.amount.
def var sum1sum2old like txb.bal_cif.amount.


/****Переменные для коэффициентов *************/
define var v_tl as deci. /*текущая ликвидность*/
define var v_tl1 as deci.
define var v_otmz as deci. /*оборачиваемость тмз*/
define var v_okz as deci. /*оборачиваемость кред зад-ти*/
define var v_odz as deci. /*оборачиваемость деб зад-ти*/
define var v_vp as deci. /*валовая прибыль*/
define var v_cp as deci. /*чистая прибыль*/

define var a-lon like txb.bal_cif.amount extent 9.
define var a-lonold like txb.bal_cif.amount extent 9.
define var p-lon like txb.bal_cif.amount extent 5.
define var p-lonold like txb.bal_cif.amount extent 5.

define var itog as deci extent 4.

find last txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '02' use-index cif-rdt no-lock no-error.

if avail txb.bal_cif then do:

    a-lonold = 0. a-lon = 0. p-lonold = 0. p-lon = 0. itog = 0.
    
    find first txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '02' use-index cif-rdt no-lock no-error.
    if avail txb.bal_cif then do:
      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '02' use-index nom no-lock:
          if i <= extent(a-lonold) then a-lonold[i] = txb.bal_cif.amount.
          i = i + 1.
      end.
    end.
    
    i = 1.
    for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt
        and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '02' use-index nom no-lock:
        if i <= extent(a-lon) then a-lon[i] = txb.bal_cif.amount.
        i = i + 1.
    end.
    
    i = 1.
    for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt
        and txb.bal_cif.nom begins 'p' and txb.bal_cif.rem[1] = '02' use-index nom no-lock:
        if i <= extent(p-lon) then p-lon[i] = txb.bal_cif.amount.
        i = i + 1.
    end.
    
    i = 1.
    for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold
        and txb.bal_cif.nom begins 'p' and txb.bal_cif.rem[1] = '02' use-index nom no-lock:
        if i <= extent(p-lonold) then p-lonold[i] = txb.bal_cif.amount.
        i = i + 1.
    end.
    
    do i = 1 to extent(a-lonold):
      itog[1] = itog[1] + a-lonold[i].
      itog[2] = itog[2] + a-lon[i].
    end.
    do i = 1 to extent(p-lonold):
      itog[3] = itog[3] + p-lonold[i].
      itog[4] = itog[4] + p-lon[i].
    end.
    
    put stream m-out unformatted "<b>1.5.1. Балансовый отчет (тыс.тенге)</b><br>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Актив</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold format "99/99/9999" "</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt format "99/99/9999" "</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Пассив</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold format "99/99/9999" "</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt format "99/99/9999" "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ТЕКУЩИЕ АКТИВЫ</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[1] + a-lonold[2] + a-lonold[3] + a-lonold[4] + a-lonold[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[1] + a-lon[2] + a-lon[3] + a-lon[4] + a-lon[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[1] + p-lonold[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[1] + p-lon[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Денежные средства (касса, р/с, д/с на валют. счете, д/с в пути)</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>Краткоср. кредиторская задолженность</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Дебиторская задолж. (счета к получ., задолж. покупателей, авансы выданные, проч. дебит задолж)</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>Краткоср. кредиты банков</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ТМЗ (товары, материалы, готовая продукция)</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Товары в пути</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Прочие</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ДОЛГОСРОЧНЫЕ АКТИВЫ</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[6] + a-lonold[7] + a-lonold[8], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[6] + a-lon[7] + a-lon[8], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[3] + p-lonold[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[3] + p-lon[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Основные средства (остат. ст-сть)</td>" skip
                  "<td>" replace(trim(string(a-lonold[6], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>" replace(trim(string(a-lon[6], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>Кредиторская задолженность (долгоср. кредиты + отсроченные налоги)</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Инвестиции</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>Долгосрочные кредиты банков</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Долгосрочная дебиторская задолженность</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[8], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[8], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "<td></td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Прочие (незав. стр-во, немат. активы)</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lonold[9], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(a-lon[9], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>СОБСТВЕННЫЙ КАПИТАЛ</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lonold[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(p-lon[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ВСЕГО</td>" skip
                  "<td align=""right"">" replace(trim(string(itog[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(itog[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td>ВСЕГО</td>" skip
                  "<td align=""right"">" replace(trim(string(itog[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(itog[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted "</table><br><br>".
    
end. /* if avail txb.bal_cif */

 find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '17' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock no-error.
 if avail kdaffil then do:
   put stream m-out unformatted kdaffil.info[1] "<br><br>" skip.
 end.


/****/
define var z-lon like txb.bal_cif.amount extent 8.
define var v-nm as integer.
if year(v-dt) = year(v-datold) then v-nm = month(v-dt) - month(v-datold).
else v-nm = month(v-dt) - month(v-datold) + 12 * (year(v-dt) - year(v-datold)).

 put stream m-out unformatted "<b>1.5.4. Отчет о финансовых результатах (тыс.тенге)</b><br>" skip.
 
   i = 1.
   for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt
            and txb.bal_cif.nom begins 'z' and txb.bal_cif.rem[1] = '02' no-lock break by txb.bal_cif.rdt.
     if i <= extent(z-lon) then z-lon[i] = txb.bal_cif.amount.
     i = i + 1.
     /*
     create wrk.
     assign wrk.v-dat = txb.bal_cif.rdt
            wrk.code = txb.bal_cif.nom
            wrk.v-sum = txb.bal_cif.amount.
     if txb.bal_cif.nom = 'z01' then sum1 = txb.bal_cif.amount.
     if txb.bal_cif.nom = 'z02' then sum2 = txb.bal_cif.amount.
     if last-of (txb.bal_cif.rdt) then do:
         create wrk.
         assign wrk.v-dat =  txb.bal_cif.rdt
                wrk.code = 'z022'
                wrk.v-sum = (sum1 / sum2 - 1) * 100.
         sum1 = 0. sum2 = 0.
     end.
     */
   end.

 /*шапка*/

       put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
               "<tr style=""font:bold"">" skip
               "<td bgcolor=""#C0C0C0"" align=""center""></td>" skip
               "<td bgcolor=""#C0C0C0"" align=""center""> " v-datold format "99/99/9999" " - " v-dt format "99/99/9999" "</td>" skip
               "<td bgcolor=""#C0C0C0"" align=""center"">Среднемесячный<BR>показатель</td>" skip
               "</tr>" skip.

/*данные*/
       
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Выручка от реализации продукции</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[1] / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Себестоимость реализованной продукции</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[2] / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Маржа (%%)</td>" skip
                  "<td align=""right"">" replace(trim(string((z-lon[1] - z-lon[2]) / z-lon[2] * 100, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string((z-lon[1] - z-lon[2]) / z-lon[2] * 100 / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Валовый доход</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[1] - z-lon[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string((z-lon[1] - z-lon[2]) / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Расходы всего</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[3] / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.

    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Расходы по выплате корпоративного подоходного налога</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[4] / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.

    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ЧИСТАЯ ПРИБЫЛЬ</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[1] - z-lon[2] - z-lon[3] - z-lon[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string((z-lon[1] - z-lon[2] - z-lon[3] - z-lon[4]) / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>Взнос по кредиту</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[5] / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted
                  "<tr>" skip
                  "<td>ЧИСТЫЙ ОСТАТОК</td>" skip
                  "<td align=""right"">" replace(trim(string(z-lon[1] - z-lon[2] - z-lon[3] - z-lon[4] - z-lon[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "<td align=""right"">" replace(trim(string((z-lon[1] - z-lon[2] - z-lon[3] - z-lon[4] - z-lon[5]) / v-nm, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                  "</tr>" skip.
    
    put stream m-out unformatted "</table><br><br>" skip.
       
    put stream m-out unformatted "<b>1.5.7. Анализ коэффициентов</b><br>" skip.
    
    v_tl = (a-lon[1] + a-lon[2] + a-lon[3] + a-lon[4] + a-lon[5]) / (p-lon[1] + p-lon[2]).
    v_tl1 = (a-lonold[1] + a-lonold[2] + a-lonold[3] + a-lonold[4] + a-lonold[5]) / (p-lonold[1] + p-lonold[2]).
    v_otmz = (v-dt - v-datold) / (z-lon[2] * 2 / (a-lonold[3] + a-lon[3])).
    v_okz = (v-dt - v-datold) / (z-lon[2] * 2 / (p-lonold[1] + p-lon[1])).
    v_okz = (v-dt - v-datold) / (z-lon[1] * 2 / (a-lonold[2] + a-lon[2])).
    v_vp = (z-lon[1] - z-lon[2]) / z-lon[1]. /* Валовый доход / Выручка */
    v_cp = (z-lon[1] - z-lon[2] - z-lon[3] - z-lon[4]) / z-lon[1]. /* Чистая прибыль / Выручка */
    
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование показателя</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold "</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt "</td>" skip
                  "</tr>" skip.
  put stream m-out unformatted "<tr><td>Текущая ликвидность</td>" skip
                   "<td align=""right"">" replace(trim(string(v_tl1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td align=""right"">" replace(trim(string(v_tl, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td>Оборачиваемость ТМЗ (в днях)</td>" skip
                   "<td></td>" skip
                   "<td align=""right"">" replace(trim(string(v_otmz, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td>Оборачиваемость кредитовой задол-ти (в днях)</td>" skip
                   "<td></td>" skip
                   "<td align=""right"">" replace(trim(string(v_okz, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td>Оборачиваемость дебиторской задол-ти (в днях)</td>" skip
                   "<td></td>" skip
                   "<td align=""right"">" replace(trim(string(v_odz, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td>Коэффициент валовой прибыли</td>" skip
                   "<td></td>" skip
                   "<td align=""right"">" replace(trim(string(v_vp, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td>Коэффициент чистой прибыли</td>" skip
                   "<td></td>" skip
                   "<td align=""right"">" replace(trim(string(v_cp, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.

  put stream m-out unformatted "</table><br><br>" skip.
  find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '18' no-lock no-error.
  put stream m-out unformatted kdaffil.info[2] "<br><br>" skip.

end. /* if avail kdaffil */
/**********************************************************************************/
/*Запрашиваемые условия*/

put stream m-out unformatted "<b><h3>2. Запрашиваемые условия</h3></b>" skip.

  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = type_lnz no-lock no-error.

   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Тип обязательства </td>"
               "<td> " type_lnz + '    ' + bookcod.name format 'x(40)' "</td></tr>" skip.

   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Сумма кредита </td>"
               "<td align=""right""> " amountz "</td>"
               "</tr>" skip.
   find first txb.crc where txb.crc.crc = kdlon.crcz no-lock no-error.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Валюта кредита </td>"
               "<td align=""right"">  " txb.crc.code "</td></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Ставка вознагр (% годовых) </td>"
               "<td align=""right""> " ratez format '>>9.99%' "</td></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Период кредитования (мес) </td>"
               "<td align=""right""> " string(srokz) + "  месяцев" format 'x(20)' "</td></tr>" skip.

  find first txb.codfr where txb.codfr.codfr = "lntgt" and txb.codfr.code = kdlon.goalz no-lock.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Цель кредитования </td>"
               "<td> " txb.codfr.name[1] format 'x(40)' "</td></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Возврат основного долга </td>"
               "<td> " repayz  format 'x(100)' "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Возврат вознаграждения </td>"
               "<td> " repay%z  format 'x(40)' "</td>"
               "</tr>" skip.
  put stream m-out unformatted "</table><br><br>" skip.


put stream m-out unformatted "<b><h3>3. Описание проекта</h3></b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '05' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
  put stream m-out unformatted
              "<tr><td><b>Описание проекта</td></tr>" skip
              "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip
              "</table><br><br>" skip.
end.

put stream m-out unformatted "<b><h3>4. Информация об обеспечении</h3></b><br>" skip.


def var s-full as char.
def var s-use as char.
def var s-land as char.
def var l-num as integer.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '20' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<b><h4>4.1. Предлагаемое обеспечение</b><br>" skip.
  v-descr = kdaffil.info[3].
  define buffer b-crc for txb.crc.
  find first b-crc where b-crc.crc = kdlon.crcz no-lock no-error.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Тип обеспечения</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Описание</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Собственник</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Общ.пл.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Пол.пл.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Зем.уч.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Месторасположение</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Аудиторская<BR>оценка</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Оценка<br>менеджера</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Коэф-т<BR>ликв-ти</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Залоговая<BR>стоимость</td>" skip
                  "</tr>" skip.

   sum1 = 0. sum2 = 0.
   for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '20' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock:
     find first txb.lonsec where txb.lonsec.lonsec = kdaffil.lonsec no-lock no-error.
     find first txb.crc where txb.crc.crc = kdaffil.crc no-lock no-error.
     s-full = entry(1,kdaffil.info[4],'^').
     if num-entries(kdaffil.info[4],'^') > 1 then s-use = entry(2,kdaffil.info[4],'^'). else s-use = ''.
     if num-entries(kdaffil.info[4],'^') > 2 then s-land = entry(3,kdaffil.info[4],'^'). else s-land = ''.
     put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" lonsec.des format 'x(40)' "</td>" skip
               "<td align=""left"">" kdaffil.info[1] "</td>" skip
               "<td align=""left"">" kdaffil.name "</td>" skip
               "<td align=""left"">" s-full "</td>" skip
               "<td align=""left"">" s-use "</td>" skip
               "<td align=""left"">" s-land "</td>" skip
               "<td align=""left"">" kdaffil.info[5] "</td>" skip
               "<td>" txb.crc.code "</td>" skip
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(kdaffil.info[6]),".",",") "</td>" skip
               "<td>" replace(trim(string(deci(kdaffil.info[2]), "->>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(kdaffil.amount_bank, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount * txb.crc.rate[1] / b-crc.rate[1].
     sum2 = sum2 + kdaffil.amount_bank * txb.crc.rate[1] / b-crc.rate[1].
   end.
   
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""><b>ИТОГО</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
               "<td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
               "</tr>" skip.
   
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Покрытие основного долга</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum1 / kdlon.amountz * 100, "->>>>9.99%")),".",",") "</b></td>" skip
               "<td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum2 / kdlon.amountz * 100, "->>>>9.99%")),".",",") "</b></td>" skip
               "</tr>" skip.
   
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Покрытие ОД и вознаграждения</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum1 / ((kdlon.amountz * kdlon.ratez * kdlon.srokz / 1200) + kdlon.amountz) * 100, "->>>>9.99%")),".",",") "</b></td>" skip
               "<td></td> <td></td>" skip
               "<td><b>" replace(trim(string(sum2 / ((kdlon.amountz * kdlon.ratez * kdlon.srokz / 1200) + kdlon.amountz) * 100, "->>>>9.99%")),".",",") "</b></td>" skip
               "</tr>" skip.
   
   put stream m-out unformatted "</table><br><br>" skip.
   put stream m-out unformatted "<h5>" v-descr "</h5><br><br>" skip.
end. /* if avail kdaffil */

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '19' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<b><h4>4.2. Сравнительный анализ рынка недвижимости</h4></b><br>" skip.
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Тип обеспечения</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Описание</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Месторасположение</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Общ.пл.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Пол.пл.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Зем.уч.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость<BR>за 1 кв.м.</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Источник<br>информации</td>" skip
                  "</tr>" skip.

   sum1 = 0. l-num = 0.
   for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '19' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock:
     find first txb.lonsec where txb.lonsec.lonsec = kdaffil.lonsec no-lock no-error.
     s-full = entry(1,kdaffil.info[4],'^').
     if num-entries(kdaffil.info[4],'^') > 1 then s-use = entry(2,kdaffil.info[4],'^'). else s-use = ''.
     if num-entries(kdaffil.info[4],'^') > 2 then s-land = entry(3,kdaffil.info[4],'^'). else s-land = ''.
     put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" lonsec.des format 'x(40)' "</td>" skip
               "<td align=""left"">" kdaffil.info[1] "</td>" skip
               "<td align=""left"">" kdaffil.info[5] "</td>" skip
               "<td align=""left"">" s-full "</td>" skip
               "<td align=""left"">" s-use "</td>" skip
               "<td align=""left"">" s-land "</td>" skip
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(kdaffil.amount / deci(s-full), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""left"">" kdaffil.name "</td>" skip
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount / deci(s-full).
     l-num = l-num + 1.
   end.
   
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""right"" colspan=7><b>Средняя стоимость за 1 кв.м.</b></td>" skip
               "<td><b>" replace(trim(string(sum1 / l-num, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
               "<td></td>" skip
               "</tr>" skip.
   
   put stream m-out unformatted "</table><br><br>" skip.
end. /* if avail kdaffil */

put stream m-out unformatted "<b><h3>5. Классификация обязательства в соответствии с требованиями НБРК</h3></b><br>" skip.

find first kdlonkl where kdlonkl.bank = kdlon.bank and kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon no-lock no-error.
if avail kdlonkl then do:
  put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Критерии клас-ции</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Классификация</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Баллы</td>" skip
                  "</tr>" skip.
  sum1 = 0. sum2 = 0.
  for each kdlonkl where kdlonkl.bank = kdlon.bank and kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon no-lock:
     find first kdklass where kdklass.type = 1 and kdklass.kod = kdlonkl.kod no-lock no-error.
     put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left"">" kdklass.name format 'x(40)' "</td>" skip
               "<td align=""left"">" kdlonkl.valdesc format 'x(40)' "</td>" skip
               "<td>" replace(trim(string(kdlonkl.rating, "->>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
     sum1 = sum1 + kdlonkl.rating.
  end.
  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
  if avail bookcod then v-statdescr = bookcod.name.
  
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""><b>Итого</td>" skip
               "<td align=""left""><b>" v-statdescr format 'x(40)' "</td>" skip
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""left""><b>Предполагаемый процент резервирования по данному обязательству</td>" skip
               "<td><b>" deci(bookcod.info[1]) format '>>>9.99%' "</td>" skip
               "<td><b>" replace(trim(string(kdlon.amountz * deci(bookcod.info[1]) / 100, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
   put stream m-out unformatted "</table><br><br>" skip.
end. /* if avail kdlonkl */

put stream m-out unformatted "<b>6. Резюме </b><br>" skip.
find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '21' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then
   put stream m-out unformatted "<h5>" kdaffil.info[1] "</h5><br><br>" skip.
   put stream m-out unformatted "<h5>Считаю возможным одобрить кредит на следующих условиях:</h5><br>" skip.
   
   put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Сумма кредита </td>" skip
               "<td align=""right""> " kdlon.amount "</td>" skip
               "</tr>" skip.
   find first txb.crc where txb.crc.crc = kdlon.crc no-lock no-error.
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Валюта кредита </td>" skip
               "<td align=""right"">  " txb.crc.code "</td></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Ставка вознагр (% годовых) </td>" skip
               "<td align=""right""> " kdlon.rate format '>>9.99%' "</td></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Период кредитования (мес) </td>" skip
               "<td align=""right""> " string(kdlon.srok) + "  месяцев" format 'x(20)' "</td></tr>" skip.
   
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Возврат основного долга </td>" skip
               "<td> " kdlon.repay  format 'x(100)' "</td>" skip
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""left"">" skip
               "<td>Возврат вознаграждения </td>" skip
               "<td>" kdlon.repay%  format 'x(40)' "</td>" skip
               "</tr>" skip.
  put stream m-out unformatted "</table><br><br>" skip.

put stream m-out unformatted "<h4>Менеджер : __________________________ "  v-ofc "</h4>" skip
                             "<h4>Согласовано :<br>Директор Кредитного Департамента : __________________________ </h4>" skip.
put stream m-out unformatted "</table></body></html>" skip.

output stream m-out close.
unix silent cptwin rpt.html excel.
