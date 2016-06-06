
/* kdresum1.p
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
        15.03.2004 marinav   вынесено из kdresum
 * CHANGES
        30/04/2004 madiyar - Работа с досье филиалов в ГБ, подключение к bank филиала для чтения данных
                             Отредактировал заголовки для компактности отчета
        05/05/2004 madiyar - Исправил ошибку - вместо "перспектив развития" выводилась "конкурентоспособность"
        12/05/2004 madiyar - Добавил расчет итоговых сумм в разделе "1.4 Описание бизнеса" для поставщиков и потребителей
                              по столбцам "Сумма" и "Оплачено по контракту"
                             В разделе "1.3.3 Доходы в TXB по клиенту" убрал строку "Всего доходность за период финансирования клиента, тенге"
                             Разделил таблицу 1.3.1. по оборотам на счетах клиента на две - по полным и чистым оборотам.
                             Добавился пункт 1.3.5 - Текущие обязательства (в кредитной истории остались только погашенные кредиты)
                             В пунктах 1.3.4 и 1.3.5 добавилась колонка "Обеспечение"
        19/05/2004 madiyar - Исправил ошибки - если есть два досье разных филиалов с одинаковым кодом досье, то подтягивались неверные данные.
                             Вставил проверку - поиск кредитов по именам учредителей и рук-ля происходит только если соотв. поля в kdaffil не пустые.
        24/05/2004 madiyar - Изменил формулы расчета коэффициентов ROE и ROA.
        08/06/2004 madiyar - Исправил ошибку - при наличии двух и более досье у одного клиента выводилась прогнозируемая доходность всегда из
                             первого досье.
        15/07/2004 madiyar - При наличии фин.рез-тов на две и более дат неправильно рассчитывались среднемесячные показатели
                             Из таблицы по фин.рез-там убрал столбец "Итого" - повторяет данные по фин.рез-там на последнюю дату
        10/09/2004 madiyar - Расчет покрытия кредита обеспечением - появлялась ошибка, если валюта запроса отличалась от одобренной
                             валюты. Исправил
        08/12/2004 madiyar - Изменил расчет маржи в отчете о фин. рез-тах (и исправил расчет среднемесячной маржи - раньше обрабатывалась как все другие суммы)
        30/09/2005 madiyar - своя р-ха для бизнес-кредитов
                             активы, пассивы, рез-ты - для обычных кредитов
        24/04/2006 madiyar - небольшие изменения
        25/04/2006 madiyar - небольшие изменения в формате отчета
        04/05/2006 madiyar - в оборотах съехала табличка, исправил; в анализе коэффициентов заменил "Собственный капитал" на "Чистый капитал"
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

find first kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
if not avail kdlon then do:   
   message skip " Заявка N" s-kdlon "не найдена !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
end.

if kdlon.manager = '02' then do: /* бизнес-кредит */
  run kdresumb.
  return.
end.

find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
 if not avail kdcif then do:
   message skip " Клиент N" kdlon.kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out skip.
           
put stream m-out unformatted "<html><head><title>TEXAKABANK:</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>".
put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""3"" style=""border-collapse: collapse"">". 
put stream m-out unformatted "<tr><td align=""left""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif"">"
                 "</td></tr>" skip.
put stream m-out unformatted "<tr><td align=""right""><h3>АО TEXAKABANK<br></td></tr>" skip.
                 
put stream m-out unformatted "<tr><td align=""right""><h3>Кредитный департамент<br><br><br></td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td><h3> Заключение по проекту <br><br></td></tr>" skip.


find txb.ofc where txb.ofc.ofc = kdlon.who no-lock no-error.
v-ofc = entry(1, txb.ofc.name, " ").
if num-entries(txb.ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, txb.ofc.name, " "), 1, 1) + ".".
if num-entries(txb.ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, txb.ofc.name, " "), 1, 1) + ".".

  put stream m-out unformatted "<tr align=""left""><td><h4> Подготовлено : "  v-ofc format 'x(30)' "</td></tr>".
  put stream m-out unformatted "<tr align=""left""><td><h4> Дата : " g-today "</td></tr>". 
  put stream m-out unformatted "<tr></tr><tr align=""left""><td><h3> 1. Информация по кредиту <br><br></td></tr><br>".


  put stream m-out unformatted "<br><tr><td><table border=""0"" cellpadding=""3"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr>"
                  "<td align=""left""><b> 1.1. Заемщик:</b></td>"
                  "<td colspan=2 align=""left""> " kdcif.name format "x(60)" "</td></tr>"
                  skip.

  find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = kdcif.ecdivis no-lock no-error.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Отрасль  </td>"
               "<td colspan=2 align=""left""> " txb.codfr.name[1] format "x(60)"  "</td>"
               "</tr>"  skip.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Юридический адрес:  </td>"
               "<td colspan=2 align=""left""> " kdcif.addr[1] format "x(60)" "</td>"
               "</tr>"  skip.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Фактический адрес:  </td>"
               "<td colspan=2 align=""left""> " kdcif.addr[2] format "x(60)"  "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">  Дата образования </td>"
               "<td align=""left""> " if kdcif.urdt1 <> ? then kdcif.urdt1 else kdcif.urdt  "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">  Телефон </td>"
               "<td colspan=2 align=""left""> " kdcif.tel format "x(20)" "</td>"
               "</tr>" skip.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">  Учредители / Акционеры </td>"
               "<td></td></tr>" skip.

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif no-lock.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> - " kdaffil.name format 'x(60)'"</td>"
               "<td align=""left""> " kdaffil.amount format '>>9.99%' "</td>"
               "</tr>" skip.
end.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">  Руководитель " kdcif.job[1] format 'x(30)' "</td>"
               "<td colspan=2 align=""left""> " kdcif.chief[1] format "x(50)" "</td>"
               "</tr>" skip.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Количество сотрудников </td>"
               "<td align=""left""> " kdcif.sotr format ">>>>9" "</td>"
               "</tr>" skip.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b> 1.2. Аффилированные компании </b></td>"
               "<td></td></tr>" skip.

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif no-lock.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name format 'x(60)'"</td>"
               "<td align=""left"">" kdaffil.affilate format 'x(200)'"</td>"
               "<td colspan=2 align=""left"">" kdaffil.info[1] format 'x(300)'"</td>"
               "<td></td></tr>" skip.
end.

   put stream m-out unformatted "<br><tr align=""right"">"
               "<td align=""left""><b>  1.3. Взаимоотношения с банками </td>"
               "<td></td></tr>" skip.

   find first txb.cif where txb.cif.jss = kdcif.rnn no-lock no-error.
   if avail txb.cif then 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Дата открытия счета в TXB </td>"
               "<td align=""left""> " txb.cif.regdt "</td>"
               "</tr>" skip.
   else
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Дата открытия счета в TXB </td>"
               "<td align=""left""> не обслуживается </td>"
               "</tr>" skip.

  put stream m-out unformatted "</table>".

/**Текущие и сберегат счета клиента*/

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock .
          v-sum[1] = v-sum[1] + decimal(entry(2,kdaffil.info[1])) / 1000.
          v-sum[2] = v-sum[2] + decimal(entry(4,kdaffil.info[1])).
          v-sum[3] = v-sum[3] + decimal(entry(6,kdaffil.info[1])).
          v-sum[4] = v-sum[4] + decimal(entry(8,kdaffil.info[1])).
end.
  put stream m-out unformatted "<br><b>1.3.1. Счета в банках.<BR><BR>Полный среднемесячный кредитовый оборот по счетам.  </b>" skip.
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Период</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> KZT, тыс. тенге</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> USD</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> RUR</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> EURO</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center"">Доля</td></tr>" skip.

for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock .
            put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name "</td>" 
               "<td>" if kdaffil.name matches '*TEXAKABANK*' then string(kdaffil.dat,"99/99/9999") + " - " + string(kdaffil.datres[1],"99/99/9999") else string(kdaffil.dat,"99/99/9999") + " - " + string(kdaffil.rdt,"99/99/9999") "</td>" 
               "<td>" replace(trim(string(deci(entry(2, kdaffil.info[1])) / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((deci(entry(2, kdaffil.info[1]))/ 1000 / v-sum[1] * 100), "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(entry(4, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(entry(4, kdaffil.info[1])) / v-sum[2] * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(entry(6, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(entry(6, kdaffil.info[1])) / v-sum[3] * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(entry(8, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>" 
               "<td>" replace(trim(string(deci(entry(8, kdaffil.info[1])) / v-sum[4] * 100, "->>>>9.99")),".",",") "</td>" skip.
end.
put stream m-out unformatted "<tr align=""right"">"
   "<td align=""left""> ИТОГО </td>"
   "<td></td>"
   "<td>" replace(trim(string(v-sum[1], "->>>>>>>>>>>9.99")),".",",") "</td>"
   "<td>100%</td>"
   "<td>" replace(trim(string(v-sum[2], "->>>>>>>>>>>9.99")),".",",") "</td>"
   "<td>100%</td>"
   "<td>" replace(trim(string(v-sum[3], "->>>>>>>>>>>9.99")),".",",") "</td>"
   "<td>100%</td>"
   "<td>" replace(trim(string(v-sum[4], "->>>>>>>>>>>9.99")),".",",") "</td>"
   "<td>100%</td></tr>" skip.
  put stream m-out unformatted "</table>".
assign v-sum[1] = 0 v-sum[2] = 0 v-sum[3] = 0 v-sum[4] = 0.


find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '09' and kdaffil.name matches '*TEXAKABANK*' no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<br><b>Чистый среднемесячный кредитовый оборот по счетам в Texakabank.</b>" skip.
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Период</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> KZT, тыс. тенге</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> USD</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> RUR</td>"
                  "<td width=""100"" bgcolor=""#C0C0C0"" align=""center""> EURO</td>" skip.

            put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name "</td>"
               "<td>" if kdaffil.name matches '*TEXAKABANK*' then string(kdaffil.dat,"99/99/9999") + " - " + string(kdaffil.datres[1],"99/99/9999") else string(kdaffil.dat,"99/99/9999") + " - " + string(kdaffil.rdt,"99/99/9999") "</td>" 
               "<td> " replace(trim(string(deci(entry(2, kdaffil.info[3])) / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(deci(entry(4, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(deci(entry(6, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(deci(entry(8, kdaffil.info[3])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr></table>" skip.
end. /* if avail kdaffil */


  put stream m-out unformatted "<br><b>1.3.2. Остатки на счетах.  </b>" skip.
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование банка</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">На дату</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "</tr>" skip.


for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '09' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock .
   put stream m-out unformatted "<tr align=""right"">"
      "<td  align=""left""><b> " kdaffil.name format 'x(40)' "</b></td>" 
      "<td></td><td></td></tr>" skip.
    repeat i = 1 to num-entries(kdaffil.info[2]) by 2:
            put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> " entry(i , kdaffil.info[2]) "</td>" 
               "<td>" if kdaffil.name matches '*TEXAKABANK*' then string(kdaffil.datres[1],"99/99/9999") else  string(kdaffil.rdt,"99/99/9999") "</td>"
               "<td> " replace(trim(string(deci(entry(i + 1, kdaffil.info[2])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    end.
end.
  put stream m-out unformatted "</table>".

put stream m-out unformatted "<br><b> Среднедневной компенсационный остаток по текущим счетам в TEXAKABANK, тенге</b>" skip.

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
        v-sum[i] = 0.
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
   
   put stream m-out unformatted ", за " d1 format "99/99/9999" " - " kdlon.regdt format "99/99/9999" skip.
   
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
end.
put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "</tr>" skip.

    repeat i = 1 to num-entries(kdaffil.info[1]) by 2:
            put stream m-out unformatted "<tr align=""right"">"
               "<td  align=""left""> " entry(i , kdaffil.info[1]) "</td>" 
               "<td> " replace(trim(string(deci(entry(i + 1, kdaffil.info[1])), "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    end.
  put stream m-out unformatted "</table>".

/* Доходность клиента **/
/* комиссионные*/

put stream m-out unformatted "<br><b> 1.3.3.  Доходы в TXB по клиенту, тыс. тенге </b>" skip.

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

  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" date1 format 'x(4)' "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" date2 format 'x(4)' "</td>"
                  "</tr>" skip.
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Комиссионные доходы, тыс. тенге</td>"
               "<td> " replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr> " skip.
end.
else 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Комиссионные доходы, тыс. тенге</td>"
               "<td> </td>"
               "<td> </td>"
               "</tr>" skip.

/* кредитные */

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '08' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.

if avail kdaffil then do:
  assign 
      date1 = entry(1,kdaffil.info[1])
      sum1 = deci(entry(2,kdaffil.info[1])) 
      date2 = entry(3,kdaffil.info[1])
      sum2 = deci(entry(4,kdaffil.info[1])). 
  
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Доходы по кредитованию, тыс. тенге </td>"
               "<td> " replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
end.
else 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Доходы по кредитованию, тыс. тенге</td>"
               "<td> </td>"
               "<td> </td>"
               "</tr>" skip.
  put stream m-out unformatted "</table>" skip.
  
  put stream m-out unformatted "<BR>" skip.

   put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""><tr align=""right"">"
               "<td align=""left""> Прогнозируемая доходность по СПФ (% годовых) </td>"
               "<td> " replace(trim(string(sum3, "->>>>9.9999")),".",",") "</td>"
               "</tr>" skip.
  /* 12/05/2004 madiar 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Всего доходность за период финансирования клиента, тенге </td>"
               "<td> " replace(trim(string(sum4 / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td></td>"
               "</tr>" */
   put stream m-out unformatted "</table> " skip.


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

put stream m-out unformatted "<br><b>1.3.4. Кредитная история  </b><br>" skip.
put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование банка</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Банковский продукт</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Одобрен-<BR>ный лимит</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ставка %%</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата возник-<BR>новения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата погашения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Текущий<BR>остаток</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Взнос<BR>по обяза-<BR>тельству</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Обеспечение</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Доп.<BR>информация</td></tr>" skip.
put stream m-out unformatted "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по факту</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по договору</td>"
                 "</tr>" skip.

for each temp_cr where temp_cr.ost = 0 no-lock:
  find first txb.crc where txb.crc.crc = temp_cr.crc no-lock no-error.
  put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" temp_cr.bnk_name "</td>"
               "<td>" temp_cr.bnk_prod "</td>"
               "<td>" replace(trim(string(temp_cr.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td>" replace(trim(string(temp_cr.prem, "->>>>9.99")),".",",")  "</td>"
               "<td>" temp_cr.dt_rg "</td>"
               "<td>" temp_cr.dt_pf "</td>"
               "<td>" temp_cr.dt_pd "</td>"
               "<td>" replace(trim(string(temp_cr.ost, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td>" replace(trim(string(temp_cr.vznos, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td align=""left"">" temp_cr.obes "</td>"
               "<td>" temp_cr.dinfo "</td>"
               "</tr>" skip.
end.
put stream m-out unformatted "</table> " skip.

put stream m-out unformatted "<br><b>1.3.5. Текущие обязательства</b><br>" skip.
put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование банка</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Банковский продукт</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Одобрен-<BR>ный лимит</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ставка %%</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата возник-<BR>новения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата погашения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Текущий<BR>остаток</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Взнос<BR>по обяза-<BR>тельству</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Обеспечение</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Доп.<BR>информация</td></tr>" skip.
put stream m-out unformatted "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по факту</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по договору</td>"
                 "</tr>" skip.

for each temp_cr where temp_cr.ost <> 0 no-lock:
  find first txb.crc where txb.crc.crc = temp_cr.crc no-lock no-error.
  put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" temp_cr.bnk_name "</td>"
               "<td>" temp_cr.bnk_prod "</td>"
               "<td>" replace(trim(string(temp_cr.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td>" replace(trim(string(temp_cr.prem, "->>>>9.99")),".",",")  "</td>"
               "<td>" temp_cr.dt_rg "</td>"
               "<td>" temp_cr.dt_pf "</td>"
               "<td>" temp_cr.dt_pd "</td>"
               "<td>" replace(trim(string(temp_cr.ost, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td>" replace(trim(string(temp_cr.vznos, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
               "<td align=""left"">" temp_cr.obes "</td>"
               "<td>" temp_cr.dinfo "</td>"
               "</tr>" skip.
  sumost = sumost + temp_cr.ost * txb.crc.rate[1].
  sumvznos = sumvznos + temp_cr.vznos * txb.crc.rate[1].
end.

put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> ИТОГО </td>"
               "<td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td>" replace(trim(string(sumost, "->>>>>>>>>>>9.99")),".",",") " KZT</td>"
               "<td>" replace(trim(string(sumvznos, "->>>>>>>>>>>9.99")),".",",") " KZT</td>"
               "<td></td>""<td></td>"
               "</tr></table>" skip.


put stream m-out unformatted "<br><b>1.3.6. Кредиты руководителя и учредителей  </b><br>" skip.
put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Заемщик</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Банковский продукт</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Одобрен-<BR>ный лимит</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ставка %%</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата возник-<BR>новения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата погашения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Текущий<BR>остаток</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Просрочка</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Взнос<BR>по обяза-<BR>тельству</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Обеспечение</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Доп.<BR>информация</td></tr>" skip.
put stream m-out unformatted "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по факту</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">по договору</td>"
                 "</tr>" skip.
      

def temp-table t-ln
  field cif like kdcif.kdcif
  field name as char
  index main is primary cif ASC.

  if kdcif.chief[1] <> "" and kdcif.chief[1] <> " " then do:
    find first txb.cif where caps(txb.cif.name) matches "*" + caps(kdcif.chief[1]) + "*" no-lock no-error.
    if avail txb.cif then do:
       for each txb.cif where caps(txb.cif.name) matches "*" + caps(kdcif.chief[1]) + "*" 
                 and not can-find(t-ln where t-ln.cif = txb.cif.cif) no-lock.
          create t-ln.
          assign t-ln.name = caps(txb.cif.name)
                 t-ln.cif = txb.cif.cif.
        end.
    end.
  end.

  for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif no-lock.
    if kdaffil.name <> "" and kdaffil.name <> " " then do:
       for each txb.cif where caps(txb.cif.name) matches "*" + caps(kdaffil.name) + "*" 
                 and not can-find(t-ln where t-ln.cif = txb.cif.cif) no-lock.
          create t-ln.
          assign t-ln.name = caps(txb.cif.name)
               t-ln.cif = txb.cif.cif.
        end.
    end.
  end.

  for each t-ln, each txb.lon where txb.lon.cif = t-ln.cif no-lock .
      
      if txb.lon.opnamt <= 0 then next.
      run lonbalcrc('lon',txb.lon.lon,kdlon.regdt,"1,7,13",no,lon.crc,output bilance).
      
      v-dt = ?.
      if bilance <= 0 then do:
        find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat <= kdlon.regdt no-lock no-error.
        if avail txb.lnsch then v-dt = txb.lnsch.stdat.
      end.
      
      run lonbalcrc('lon',txb.lon.lon,kdlon.regdt,"7,13,9,14",no,lon.crc,output bilancepl).
      
      v-obes = "".
      for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
        find first txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
        if v-obes <> "" then v-obes = v-obes + "; ".
        v-obes = v-obes + entry(1,txb.lonsec1.prm,"&") + ", " + trim(txb.crc.code) + trim(string(txb.lonsec1.secamt, ">>>>>>>>>>9.99")).
      end.
      
      find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
      find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 no-lock no-error.
      find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 no-lock no-error.
      
      put stream m-out unformatted "<tr align=""right"">"
                  "<td align=""left"">" t-ln.name "</td>"
                  "<td align=""left"">" if txb.lon.gua = "LO" then "Банковский заем" else "Кредитная линия" "</td>"
                  "<td>" replace(trim(string(txb.lon.opnamt, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
                  "<td>" replace(trim(string(txb.lon.prem, "->>9.99")),".",",") "</td>"
                  "<td>" txb.lon.rdt "</td>"
                  "<td>" v-dt "</td>"
                  "<td>" txb.lon.duedt "</td>"
                  "<td>" replace(trim(string(bilance, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
                  "<td>" replace(trim(string(bilancepl, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>"
                  "<td>" replace(trim(string(txb.lnsch.stval + txb.lnsci.iv-sc, "->>>>>>>>>>>9.99")),".",",") " " txb.crc.code "</td>" skip
                  "<td align=""left"">" v-obes "</td>" skip
                  "<td align=""left""></td>" skip
                  "</tr>" skip.
      
  end.
  put stream m-out unformatted "</table>".

put stream m-out unformatted "<br><b>1.4. Описание бизнеса </b><br>" skip.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.code = '11' no-lock no-error.
if avail kdaffil then do:
  define var v-desbis as char extent 2.
  put stream m-out unformatted "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
  put stream m-out unformatted
                    "<tr><td><b>Описание отрасли</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Конкуренты</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Описание бизнеса заемщика</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[3] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Инфраструктура бизнеса</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[4] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Конкурентоспособность заемщика</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[8] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Перспективы развития</td></tr>"
                    "<tr align=""left""><td colspan=5> " kdaffil.info[9] format 'x(2000)' "</td></tr>" skip.
   put stream m-out unformatted "</table>".
   v-desbis[1] = kdaffil.info[5].
   v-desbis[2] = kdaffil.info[6].
end.

define var v-sumvc as deci.
define var v-sums as deci.
define var v-sumopc as deci.
v-sumvc = 0. v-sums = 0. v-sumopc = 0.
for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '24' 
                         and kdaffil.kdcif = s-kdcif no-lock break by kdaffil.kdcif.
   if first-of (kdaffil.kdcif) then do:
      put stream m-out unformatted "<br><td></td><b> Информация о поставщиках <br>" skip.
      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">N</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Поставщик</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Контракт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Предмет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>платежа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Оплачено<BR>по<BR>контракту</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комментарии</td>"
                  "</tr>" skip.
     i = 1. 
   end. 
   find txb.crc where txb.crc.crc = kdaffil.crc no-lock no-error.
   put stream m-out unformatted "<tr align=""right"">"
               "<td>" i format '>>>>9' "</td>"
               "<td align=""left""> " kdaffil.name " </td>"
               "<td>" kdaffil.res "</td>"
               "<td>" kdaffil.dat "</td>"
               "<td>" kdaffil.info[1] format 'x(1000)'  "</td>"
               "<td> " replace(trim(string(kdaffil.amount), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td> " txb.crc.code "</td>"
               "<td> " kdaffil.info[2] format 'x(20)' "</td>" 
               "<td> " replace(trim(string(kdaffil.amount_bank), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td> " replace(trim(string(kdaffil.amount - kdaffil.amount_bank), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td>" kdaffil.info[3] format 'x(1000)'  "</td>"
               "</tr>" skip.
   i = i + 1.
   v-sumvc = v-sumvc + kdaffil.amount - kdaffil.amount_bank.
   v-sums = v-sums + kdaffil.amount.
   v-sumopc = v-sumopc + kdaffil.amount_bank.
   if last-of (kdaffil.kdcif) then do:
      put stream m-out unformatted "<tr align=""right"">"
                                   "<td></td><td></td><td></td><td></td><td></td>"
                                   "<td>" replace(trim(string(v-sums), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td></td><td></td>"
                                   "<td>" replace(trim(string(v-sumopc), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td>" replace(trim(string(v-sumvc), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td></td>" skip. 
      put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5> " v-desbis[1] format 'x(2000)' "</td></tr><br><br>" skip.
      put stream m-out unformatted "</table>".
   end. 

end.
v-sumvc = 0. v-sums = 0. v-sumopc = 0.
for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '25' 
                         and kdaffil.kdcif = s-kdcif no-lock break by kdaffil.kdcif.
   if first-of (kdaffil.kdcif) then do:
      put stream m-out unformatted "<br><td></td><b> Информация о потребителях <br>" skip.
      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">N</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Потребитель</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Контракт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Предмет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта платежа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Оплачено по контракту</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комментарии</td>"
                  "</tr>" skip.
     i = 1. 
   end. 
   find txb.crc where txb.crc.crc = kdaffil.crc no-lock no-error.
   put stream m-out unformatted "<tr align=""right"">"
               "<td>" i format '>>>>9' "</td>" 
               "<td align=""left""> " kdaffil.name " </td>"
               "<td>" kdaffil.res "</td>"
               "<td>" kdaffil.dat "</td>"
               "<td>" kdaffil.info[1] format 'x(1000)'  "</td>"
               "<td> " replace(trim(string(kdaffil.amount), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td> " txb.crc.code "</td>"
               "<td> " kdaffil.info[2] format 'x(20)' "</td>" 
               "<td> " replace(trim(string(kdaffil.amount_bank), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td> " replace(trim(string(kdaffil.amount - kdaffil.amount_bank), "->>>>>>>>>>>>.>>"),".",",") "</td>"
               "<td>" kdaffil.info[3] format 'x(1000)'  "</td>"
               "</tr>" skip.
   i = i + 1.
   v-sumvc = v-sumvc + kdaffil.amount - kdaffil.amount_bank.
   v-sums = v-sums + kdaffil.amount.
   v-sumopc = v-sumopc + kdaffil.amount_bank.
   if last-of (kdaffil.kdcif) then do:
      put stream m-out unformatted "<tr align=""right"">"
                                    "<td></td><td></td><td></td><td></td><td></td>"
                                   "<td>" replace(trim(string(v-sums), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td></td><td></td>"
                                   "<td>" replace(trim(string(v-sumopc), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td>" replace(trim(string(v-sumvc), "->>>>>>>>>>>>.>>"),".",",") "</td>"
                                   "<td></td>" skip. 
      put stream m-out "<br><tr></tr><tr align=""left""><td colspan=5> " v-desbis[2] format 'x(2000)' "</td></tr><br><br>" skip.
      put stream m-out "</table>".
   end. 

end.


/**********************************************************************************/
put stream m-out unformatted "<br><b>1.5. Анализ финансового состояния </b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '18'  and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock no-error.
if avail kdaffil then do:

def var v-datold like txb.bal_cif.rdt.
assign v-datold = kdaffil.datres[1] v-dt = kdaffil.datres[2]. 

def var sum1sum2 like txb.bal_cif.amount.
def var sumold1 like txb.bal_cif.amount.
def var sumold2 like txb.bal_cif.amount.
def var sumold3 like txb.bal_cif.amount.
def var sum1sum2old like txb.bal_cif.amount.


/****Переменные для коэффициентов *************/
define var v_sk as deci.  /*собств капитал*/
define var v_prib as deci.  /*прибыль*/
define var v_pribsr as deci. /*среднемес прибыль*/
define var v_ok1 as deci. /*оборотный капитал*/
define var v_tl1 as deci. /*текущая ликвидность*/
define var v_bl1 as deci. /*быстрая ликвидность*/
define var v_da1 as deci. /*Долг / Активы*/
define var v_dck1 as deci. /*Долг / Соб капитал*/
define var v_ok as deci. /*оборотный капитал*/
define var v_tl as deci. /*текущая ликвидность*/
define var v_bl as deci. /*быстрая ликвидность*/
define var v_da as deci. /*Долг / Активы*/
define var v_dck as deci. /*Долг / Соб капитал*/
define var v_os as deci. /*оборачиваемость счетов*/
define var v_otmz as deci. /*оборачиваемость тмз*/
define var v_okz as deci. /*оборачиваемость кред зад-ти*/
define var v_vp as deci. /*валовая прибыль*/
define var v_cp as deci. /*чистая прибыль*/
define var v_roe1 as deci. /*ROE*/
define var v_roa1 as deci. /*ROA*/
define var v_roe as deci. /*ROE*/
define var v_roa as deci. /*ROA*/

/*****************/

define var w-lon like txb.bal_cif.amount extent 27.
define var w-lonold like txb.bal_cif.amount extent 27.

find last txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt  
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '01' use-index cif-rdt no-lock no-error.

if avail txb.bal_cif then do:

    do i = 1 to extent(w-lonold):
         w-lonold[i] = 0.
    end.
    find first txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold  
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '01' use-index cif-rdt no-lock no-error.
    if avail txb.bal_cif then do:
      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold 
          and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '01' use-index nom no-lock:
          w-lonold[i] = txb.bal_cif.amount.
          i = i + 1.
      end.
    end.

    put stream m-out unformatted "<br><b>1.5.1. Балансовый отчет (тыс.тенге)</b><br>" skip.

    put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Актив</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Динамика<BR>статей<BR>актива</td></tr>" skip.

    
          do i = 1 to extent(w-lon):
             w-lon[i] = 0.
          end.
          i = 1.
          for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt 
              and txb.bal_cif.nom begins 'a' and txb.bal_cif.rem[1] = '01' use-index nom no-lock:
              w-lon[i] = txb.bal_cif.amount.
              i = i + 1.
          end.
    

       sumold1 = w-lonold[11] + w-lonold[12] + w-lonold[13] 
            + w-lonold[14] + w-lonold[15] + w-lonold[16]
            + w-lonold[17] + w-lonold[18] + w-lonold[19]
            + w-lonold[20] + w-lonold[21] + w-lonold[22]
            + w-lonold[23] + w-lonold[24] + w-lonold[25]
            + w-lonold[26] + w-lonold[27].
       sumold2 = w-lonold[3] + w-lonold[6] + w-lonold[7] 
             + w-lonold[8] + w-lonold[9] + w-lonold[10].
       sum1sum2old = sumold1 + sumold2.
       sum1 = w-lon[11] + w-lon[12] + w-lon[13] 
            + w-lon[14] + w-lon[15] + w-lon[16]
            + w-lon[17] + w-lon[18] + w-lon[19]
            + w-lon[20] + w-lon[21] + w-lon[22]
            + w-lon[23] + w-lon[24] + w-lon[25]
            + w-lon[26] + w-lon[27].
       sum2 = w-lon[3] + w-lon[6] + w-lon[7] 
             + w-lon[8] + w-lon[9] + w-lon[10].
       sum1sum2 = sum1 + sum2.
       v_ok = sum1.
       v_ok1 = sumold1.
       v_tl = sum1.
       v_tl1 = sumold1.
       v_bl = w-lon[16] + w-lon[17] + w-lon[23] + w-lon[24] + w-lon[25] + w-lon[26].
       v_bl1 = w-lonold[16] + w-lonold[17] + w-lonold[23] + w-lonold[24] + w-lonold[25] + w-lonold[26].
       v_da = sum1sum2.
       v_da1 = sum1sum2old.
       v_os = (w-lon[16] + w-lon[17] + w-lonold[16] + w-lonold[17]) / 2.
       v_otmz = (w-lonold[11] + w-lonold[12] + w-lonold[13] + w-lonold[14] + w-lonold[15] 
               + w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15]) / 2.
       v_roa = (sum1sum2 + sum1sum2old) / 2.

    put stream m-out unformatted "<tr>"
               "<td align=""left""> I.ТЕКУЩИЕ АКТИВЫ </td>"
               "<td>" replace(trim(string(sumold1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sumold1 / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(sum1 / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum1 - sumold1) / sum1 * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Касса и банковский счет </td>"
               "<td>" replace(trim(string(w-lonold[23] + w-lonold[24] + w-lonold[25] + w-lonold[26], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[23] + w-lonold[24] + w-lonold[25] + w-lonold[26]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[23] + w-lon[24] + w-lon[25] + w-lon[26], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[23] + w-lon[24] + w-lon[25] + w-lon[26]) / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(((w-lon[23] + w-lon[24] + w-lon[25] + w-lon[26]) - (w-lonold[23] + w-lonold[24] + w-lonold[25] + w-lonold[26])) / (w-lon[23] + w-lon[24] + w-lon[25] + w-lon[26]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Счета к получению </td>"
               "<td>" replace(trim(string(w-lonold[16] + w-lonold[17], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[16] + w-lonold[17]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[16] + w-lon[17], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[16] + w-lon[17]) / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(((w-lon[16] + w-lon[17]) - (w-lonold[16] + w-lonold[17])) / (w-lon[16] + w-lon[17]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Авансы выданные </td>"
               "<td>" replace(trim(string(w-lonold[20], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[20] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[20], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[20] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[20] - w-lonold[20]) / w-lon[20] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Товары в пути </td>"
               "<td>" replace(trim(string(w-lonold[15], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[15] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[15], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[15] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[15] - w-lonold[15]) / w-lon[15] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> ТМЗ </td>"
               "<td>" replace(trim(string(w-lonold[11] + w-lonold[12] + w-lonold[13] + w-lonold[14], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[11] + w-lonold[12] + w-lonold[13] + w-lonold[14]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14]) / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(((w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14]) - (w-lonold[11] + w-lonold[12] + w-lonold[13] + w-lonold[14])) / (w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Финансовые инвестиции </td>"
               "<td>" replace(trim(string(w-lonold[22], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[22] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[22], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[22] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[22] - w-lonold[22]) / w-lon[22] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Прочие текущие активы </td>"
               "<td>" replace(trim(string(w-lonold[18] + w-lonold[19] + w-lonold[21] + w-lonold[27], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[18] + w-lonold[19] + w-lonold[21] + w-lonold[27]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[18] + w-lon[19] + w-lon[21] + w-lon[27], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[18] + w-lon[19] + w-lon[21] + w-lon[27]) / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(((w-lon[18] + w-lon[19] + w-lon[21] + w-lon[27]) - (w-lonold[18] + w-lonold[19] + w-lonold[21] + w-lonold[27])) / (w-lon[18] + w-lon[19] + w-lon[21] + w-lon[27]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.

    put stream m-out unformatted "<tr>"
               "<td align=""left""> II.ДОЛГОСРОЧНЫЕ АКТИВЫ </td>"
               "<td>" replace(trim(string(sumold2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sumold2 / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(sum2 / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum2 - sumold2) / sum2 * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Основные средства </td>"
               "<td>" replace(trim(string(w-lonold[6], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[6] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[6], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[6] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[6] - w-lonold[6]) / w-lon[6] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Нематериальные активы </td>"
               "<td>" replace(trim(string(w-lonold[3], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[3] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[3], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[3] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[3] - w-lonold[3]) / w-lon[3] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Инвестиции </td>"
               "<td>" replace(trim(string(w-lonold[7], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[7] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[7], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[7] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[7] - w-lonold[7]) / w-lon[7] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Незавершенное строительство </td>"
               "<td>" replace(trim(string(w-lonold[9], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[9] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[9], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[9] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[9] - w-lonold[9]) / w-lon[9] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Прочие основные средства </td>"
               "<td>" replace(trim(string(w-lonold[8] + w-lonold[10] , "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[8] + w-lonold[10]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[8] + w-lon[10], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[8] + w-lon[10])/ sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[8] + w-lon[10] - w-lonold[8] - w-lonold[10]) / (w-lon[8] + w-lon[10]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> ВСЕГО </td>"
               "<td>" replace(trim(string(sum1sum2old , "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum1sum2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum1sum2 - sum1sum2old) / sum1sum2old * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.

    
    
    put stream m-out unformatted
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Пассив</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доля</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Динамика<BR>статей<BR>пассива</td></tr>" skip.

    
     do i = 1 to extent(w-lon):
        w-lon[i] = 0.
     end.
     i = 1.
     for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-dt 
         and txb.bal_cif.nom begins 'p' and txb.bal_cif.rem[1] = '01' use-index nom no-lock:
         w-lon[i] = txb.bal_cif.amount.
         i = i + 1.
     end.
    
     do i = 1 to extent(w-lonold):
         w-lonold[i] = 0.
     end.
     i = 1.
     for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt = v-datold 
         and txb.bal_cif.nom begins 'p' and txb.bal_cif.rem[1] = '01' use-index nom no-lock:
         w-lonold[i] = txb.bal_cif.amount.
         i = i + 1.
     end.
    

    sumold1 = w-lonold[17] + w-lonold[16] + w-lonold[22]                                       
         + w-lonold[11] + w-lonold[12] + w-lonold[13] + w-lonold[14] + w-lonold[15]
         + w-lonold[18] + w-lonold[19] + w-lonold[20] + w-lonold[21].                                                 
    sum1 = w-lon[17] + w-lon[16] + w-lon[22]                                       
         + w-lon[11] + w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15] 
         + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21].                                                 

    sumold2 = w-lonold[8] + w-lonold[9] + w-lonold[10].                                     
    sum2 = w-lon[8] + w-lon[9] + w-lon[10].                                     

    sumold3 = w-lonold[1] + w-lonold[2] + w-lonold[3] 
         + w-lonold[4] + w-lonold[6] + w-lonold[7].
    sum3 = w-lon[1] + w-lon[2] + w-lon[3] 
         + w-lon[4] + w-lon[6] + w-lon[7].
    sum1sum2old = sumold1 + sumold2 + sumold3.
    sum1sum2 = sum1 + sum2 + sum3.
    v_sk = sum3 - sumold3.
    v_ok = v_ok - sum1.
    v_ok1 = v_ok1 - sumold1.
    v_tl = v_tl / sum1.
    v_tl1 = v_tl1 / sumold1.
    v_bl = v_bl / sum1.
    v_bl1 = v_bl1 / sumold1.
    v_da = (sum1 + sum2) / v_da.
    v_da1 = (sumold1 + sumold2) / v_da1.
    v_dck = (sum1 + sum2) / sum3.
    v_dck1 = (sumold1 + sumold2) / sumold3.
    v_okz = (w-lonold[17] + w-lonold[22] + w-lon[17] + w-lon[22]) / 2.
    v_roe = (sum3 + sumold3) / 2. 

    put stream m-out unformatted "<tr>"
               "<td align=""left""> I.ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА </td>"
               "<td>" replace(trim(string(sumold1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sumold1 / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(sum1 / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum1 - sumold1) / sum1 * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Счета к оплате </td>"
               "<td>" replace(trim(string(w-lonold[17], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[17] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[17], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[17] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[17] - w-lonold[17]) / w-lon[17] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Авансы полученные </td>"
               "<td>" replace(trim(string(w-lonold[16], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[16] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[16], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[16] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[16] - w-lonold[16]) / w-lon[16] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Товарный кредит </td>"
               "<td>" replace(trim(string(w-lonold[22], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[22] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[22], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[22] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[22] - w-lonold[22]) / w-lon[22] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Кредиты (займы) </td>"
               "<td>" replace(trim(string(w-lonold[11], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[11] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[11], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[11] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[11] - w-lonold[11]) / w-lon[11] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Прочие текущие обязательства </td>"
               "<td>" replace(trim(string(w-lonold[12] + w-lonold[13] + w-lonold[14] + w-lonold[15] + w-lonold[18] + w-lonold[19] + w-lonold[20] + w-lonold[21] , "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[12] + w-lonold[13] + w-lonold[14] + w-lonold[15] + w-lonold[18] + w-lonold[19] + w-lonold[20] + w-lonold[21]) / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15] + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15] + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21]) / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15] + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21] - (w-lonold[12] + w-lonold[13] + w-lonold[14] + w-lonold[15] + w-lonold[18] + w-lonold[19] + w-lonold[20] + w-lonold[21])) / (w-lon[12] + w-lon[13] + w-lon[14] + w-lon[15] + w-lon[18] + w-lon[19] + w-lon[20] + w-lon[21]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> II.ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА </td>"
               "<td>" replace(trim(string(sumold2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sumold2 / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(sum2 / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum2 - sumold2) / sum2 * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Кредиты (займы) </td>"
               "<td>" replace(trim(string(w-lonold[8], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lonold[8] / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[8], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(w-lon[8] / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[8] - w-lonold[8]) / w-lon[8] * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> Прочие долгосрочные обязательства </td>"
               "<td>" replace(trim(string(w-lonold[9] + w-lonold[10], "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string((w-lonold[9] + w-lonold[10])/ sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(w-lon[9] + w-lon[10], "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string((w-lon[9] + w-lon[10])/ sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((w-lon[9] + w-lon[10] - (w-lonold[9] + w-lonold[10])) / (w-lon[9] + w-lon[10]) * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> III.СОБСТВЕННЫЙ КАПИТАЛ </td>"
               "<td>" replace(trim(string(sumold3, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sumold3 / sum1sum2old * 100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum3, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(sum3 / sum1sum2 * 100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum3 - sumold3) / sum3 * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
    put stream m-out unformatted "<tr>"
               "<td align=""left""> ВСЕГО </td>"
               "<td>" replace(trim(string(sum1sum2old , "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(100, "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(sum1sum2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(100, "->>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string((sum1sum2 - sum1sum2old) / sum1sum2old * 100, "->>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.

  put stream m-out unformatted "</table>".

    
end.

 find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '17' 
                          and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock no-error.
 if avail kdaffil then do:
   put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr><br><br>" skip.
 end.


 put stream m-out unformatted "<br><b>1.5.2. Расшифровка дебиторской и кредиторской задолженности (тыс.тенге)</b><br>" skip.

 find first kdaffil where  kdaffil.bank = kdlon.bank and kdaffil.code = '13' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock no-error.
 if avail kdaffil then do:
  v-descr = kdaffil.info[2].
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование дебитора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата возник-<BR>новения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>погашения </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Основание</td>"
                  "</tr>" skip.

     sum1 = 0.
     for each kdaffil where  kdaffil.bank = kdlon.bank and kdaffil.code = '13' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock .
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name format 'x(40)' "</td>"
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" kdaffil.datres[1] "</td>"
               "<td>" kdaffil.datres[2] "</td>"
               "<td align=""left"">" kdaffil.info[1] format 'x(100)' "</td>"
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount.
     end.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>ИТОГО</td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td></td>"
               "<td></td>"
               "<td ></td>"
               "</tr>" skip.
 put stream m-out unformatted "</table>".
 put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5> " v-descr format 'x(2000)' "</td></tr><br><br>" skip.
 end.

 find first kdaffil where  kdaffil.bank = kdlon.bank and kdaffil.code = '14' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock no-error.
 if avail kdaffil then do:
  v-descr = kdaffil.info[2].
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование кредитора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата возник-<BR>новения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>погашения </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Основание</td>"
                  "</tr>" skip.

     sum1 = 0.
     for each kdaffil where  kdaffil.bank = kdlon.bank and kdaffil.code = '14' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock .
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name format 'x(40)' "</td>"
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" kdaffil.datres[1] "</td>"
               "<td>" kdaffil.datres[2] "</td>"
               "<td align=""left"">" kdaffil.info[1] format 'x(100)' "</td>"
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount.
     end.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>ИТОГО</td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td></td>"
               "<td></td>"
               "<td ></td>"
               "</tr>" skip.

 put stream m-out unformatted "</table>".
 put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5> " v-descr format 'x(2000)' "</td></tr><br><br>" skip.
 end.


 put stream m-out unformatted "<br><b>1.5.3. Расшифровка основных средств (тыс.тенге)</b><br>" skip.

 find first kdaffil where  kdaffil.bank = kdlon.bank and kdaffil.code = '15' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock no-error.
 if avail kdaffil then do:
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование основного средства</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Описание</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Балансовая<BR>стоимость</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Рыночная<BR>стоимость</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Goodwill</td>"
                  "</tr>" skip.

     sum1 = 0. sum2 = 0.
     for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '15' and kdaffil.kdcif = s-kdcif and kdaffil.dat = v-dt no-lock .
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdaffil.name format 'x(70)' "</td>"
               "<td align=""left"">" kdaffil.info[1] format 'x(200)' "</td>"
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(kdaffil.amount_bank, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(kdaffil.amount_bank - kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount.
     sum2 = sum2 + kdaffil.amount_bank.
     end.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>ИТОГО</td>"
               "<td></td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td><b>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td><b>" replace(trim(string(sum2 - sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.

 put stream m-out unformatted "</table>".
 end.

/****/
def temp-table wrk
    field v-dat as date
    field code as char
    field v-sum as deci
    index code code index dat v-dat.

 put stream m-out unformatted "<br><b>1.5.4. Отчет о финансовых результатах (тыс.тенге)</b><br>" skip.
 
  
   for each txb.bal_cif where txb.bal_cif.cif = s-kdcif and txb.bal_cif.rdt > v-datold 
                      and txb.bal_cif.rdt <= v-dt and txb.bal_cif.nom begins 'z' and txb.bal_cif.rem[1] = '01' no-lock break by txb.bal_cif.rdt.
     create wrk.
     assign wrk.v-dat =  txb.bal_cif.rdt 
            wrk.code = txb.bal_cif.nom
            wrk.v-sum = txb.bal_cif.amount.
     if txb.bal_cif.nom = 'z01' then sum1 = txb.bal_cif.amount.
     if txb.bal_cif.nom = 'z02' then sum2 = txb.bal_cif.amount.
     if last-of (txb.bal_cif.rdt) then do:
         create wrk.
         assign wrk.v-dat =  txb.bal_cif.rdt 
                wrk.code = 'z022' /* маржа */
                wrk.v-sum = (sum1 / sum2 - 1) * 100.
         sum1 = 0. sum2 = 0.
     end.
   end.

 /*шапка*/

       put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
               "<td bgcolor=""#C0C0C0"" align=""center""> Период </td>".

       for each wrk break by wrk.v-dat.
          if first-of (wrk.v-dat) then put stream m-out  "<td bgcolor=""#C0C0C0"" align=""center""> " wrk.v-dat "</td>".
       end.

       /* put stream m-out  "<td bgcolor=""#C0C0C0"" align=""center"">ИТОГО</td>". */
       put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Средне-<BR>месячный<BR>показатель</td>".
       put stream m-out unformatted "</tr>" skip.

/*данные*/
       for each wrk break by wrk.code by wrk.v-dat.

       if first-of (wrk.code) then do:
          i = 0. sum1 = 0.
          find first kdspr where kdspr.nom = wrk.code no-lock no-error.
          if avail kdspr then put stream m-out "<tr><td align=""left""> " kdspr.name "</td>".
                         else i = 1.
       end.

       if i = 1 then next.
       put stream m-out unformatted "<td> " replace(trim(string(wrk.v-sum, "->>>>>>>>9.99")), ".", ",") "</td>".
       sum1 = /*sum1 + */ wrk.v-sum.

       if last-of (wrk.code) then do: 
               /* put stream m-out  "<td> " replace(trim(string(sum1, "->>>>>>>>9.99")), ".", ",") "</td>". */
               if wrk.code <> 'z022' then put stream m-out unformatted "<td> " replace(trim(string(sum1 / ((v-dt - v-datold) / 30), "->>>>>>>>9.99")), ".", ",") "</td>".
               else put stream m-out unformatted "<td> " replace(trim(string(sum1, "->>>>>>>>9.99")), ".", ",") "</td>".
               put stream m-out unformatted "</tr>" skip.
               if wrk.code = 'z14' then assign v_prib = sum1 v_pribsr = sum1 / ((v-dt - v-datold) / 30).  
               if wrk.code = 'z01' then v_os = (v-dt - v-datold) / (sum1 / v_os).
               if wrk.code = 'z02' then v_otmz = (v-dt - v-datold) / (sum1 / v_otmz).
               if wrk.code = 'z02' then v_okz = (v-dt - v-datold) / (sum1 / v_okz).
               if wrk.code = 'z01' then assign v_vp = sum1 v_cp = sum1.
               if wrk.code = 'z03' then v_vp = sum1 / v_vp.
               if wrk.code = 'z14' then v_cp = sum1 / v_cp.
               if wrk.code = 'z14' then v_roe = sum1 / v_roe.
               if wrk.code = 'z14' then v_roa = sum1 / v_roa.
       end.

       end.
 put stream m-out unformatted "</table>".


  find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '18' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon 
       no-lock no-error. 
  put stream m-out "<br><b>1.5.6. Cross checking </b><br>" skip.

  if avail kdaffil then do:
 /*пересчитать в валюте кредита*/
  find first txb.crc where txb.crc.crc = kdlon.crcz no-lock no-error.
  put stream m-out unformatted "<br><tr><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
  put stream m-out unformatted "<tr><td >Итого увеличение собственного капитала</td>"
                   "<td >" replace(trim(string(v_sk * 1000 / crc.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted  "<tr><td >Итого прибыль за анализируемый период</td>"
                   "<td >" replace(trim(string(v_prib * 1000 / crc.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted  "<tr><td >Разница</td>"
                   "<td >" replace(trim(string((v_sk - v_prib) * 1000 / crc.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted  "<tr><td >Среднемесячная прибыль</td>"
                   "<td >" replace(trim(string(v_pribsr * 1000 / crc.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted  "<tr><td >Взнос</td>"
                   "<td >" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" 
                   "</tr>" skip.
  put stream m-out unformatted  "<tr><td >Взнос / Среднемесячная прибыль</td>"
                   "<td >" replace(trim(string(kdaffil.amount / (v_pribsr * 1000 / crc.rate[1]), "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "</table>".
  put stream m-out unformatted  "<br><tr></tr><tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(1000)' "</td></tr><br><br>" skip.
  end.

  put stream m-out unformatted "<br><b>1.5.7. Анализ коэффициентов </b><br>" skip.

  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование показателя</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-datold "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" v-dt "</td>"
                  "</tr>" skip.
  put stream m-out unformatted "<tr><td>Чистый оборотный капитал</td>"
                   "<td >" replace(trim(string(v_ok1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td >" replace(trim(string(v_ok, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Текущая ликвидность</td>"
                   "<td >" replace(trim(string(v_tl1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td >" replace(trim(string(v_tl, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Быстрая ликвидность</td>"
                   "<td >" replace(trim(string(v_bl1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td >" replace(trim(string(v_bl, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Долг / Активы</td>"
                   "<td >" replace(trim(string(v_da1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td >" replace(trim(string(v_da, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Долг / СК</td>"
                   "<td >" replace(trim(string(v_dck1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td >" replace(trim(string(v_dck, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Оборачиваемость счетов к получению (в днях)</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_os, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Оборачиваемость ТМЗ (в днях)</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_otmz, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Оборачиваемость кредитовой задол-ти (в днях)</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_okz, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Коэффициент валовой прибыли</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_vp, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >Коэффициент чистой прибыли</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_cp, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >ROE</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_roe, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
  put stream m-out unformatted "<tr><td >ROA</td>"
                   "<td ></td>"
                   "<td >" replace(trim(string(v_roa, "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.

  put stream m-out unformatted "</table>".
  put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(1000)' "</td></tr><br><br>" skip.

end. /* if kdaffil.code = '18' avail        весь фин анализ */
/**********************************************************************************/
put stream m-out unformatted "<br><b>1.6. Репутация заемщика </b><br>" skip.

  find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '12' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock no-error.

  if avail kdaffil then do:

   find bookcod where bookcod.bookcod = "kdreput" and bookcod.code = kdaffil.resume no-lock no-error.

   put stream m-out unformatted  bookcod.name "<br>".
   put stream m-out unformatted   "Основание : ".
   put stream m-out unformatted  kdaffil.info[1] format 'x(1000)' "<br>" .

  end.
/*Запрашиваемые условия*/

put stream m-out unformatted "<br><b><h3>2 Запрашиваемые условия </b>" skip.

  put stream m-out unformatted "<br><tr><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = type_lnz no-lock no-error.

   put stream m-out unformatted "<tr align=""left"">"
               "<td> Тип обязательства </td>"
               "<td> " type_lnz + '    ' + bookcod.name format 'x(40)' "</td></tr>" skip.

   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Сумма кредита </td>"
               "<td align=""right""> " amountz "</td>"
               "</tr>" skip.
   find first txb.crc where txb.crc.crc = kdlon.crcz no-lock no-error.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Валюта кредита </td>"
               "<td align=""right"">  " txb.crc.code "</td></tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Ставка вознагр (% годовых) </td>"
               "<td align=""right""> " ratez format '>>9.99%' "</td></tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Период кредитования (мес) </td>"
               "<td align=""right""> " string(srokz) + "  месяцев" format 'x(20)' "</td></tr>" skip.

  find first txb.codfr where txb.codfr.codfr = "lntgt" and txb.codfr.code = kdlon.goalz no-lock.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Цель кредитования </td>"
               "<td> " txb.codfr.name[1] format 'x(40)' "</td></tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Возврат основного долга </td>"
               "<td> " repayz  format 'x(100)' "</td>"
               "</tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Возврат вознаграждения </td>"
               "<td> " repay%z  format 'x(40)' "</td>"
               "</tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Размер взноса </td>"
               "<td> "  "</td>"
               "</tr>" skip.
  put stream m-out unformatted "</table>".


put stream m-out unformatted "<br><b><h3> 3. Описание проекта </b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.kdcif = s-kdcif and kdaffil.code = '05' and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
  put stream m-out unformatted "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
   put stream m-out unformatted
                    "<tr><td><b>Описание проекта</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Опыт в подобных проектах</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Возможность реализации проекта</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[3] format 'x(2000)' "</td></tr>" skip.
   put stream m-out unformatted "</table>".
end.

put stream m-out unformatted "<br><b><h3> 4. Информация об обеспечении </b><br>" skip.

find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '20' 
                      and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then do:
  v-descr = kdaffil.info[3].
  define buffer b-crc for txb.crc.
  find first b-crc where b-crc.crc = kdlon.crcz no-lock no-error.
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Тип обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Описание</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Собственник</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Аудиторская<BR>оценка</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Коэф-т<BR>ликв-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Залоговая<BR>стоимость</td>"
                  "</tr>" skip.

     sum1 = 0. sum2 = 0.
     for each kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '20' 
                      and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock .
     find first txb.lonsec where txb.lonsec.lonsec = kdaffil.lonsec no-lock no-error.
     find first txb.crc where txb.crc.crc = kdaffil.crc no-lock no-error.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" lonsec.des format 'x(40)' "</td>"
               "<td align=""left"">" kdaffil.info[1] format 'x(500)' "</td>"
               "<td align=""left"">" kdaffil.name format 'x(40)' "</td>"
               "<td>" txb.crc.code "</td>"
               "<td>" replace(trim(string(kdaffil.amount, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(deci(kdaffil.info[2]), "->>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(kdaffil.amount_bank, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
     sum1 = sum1 + kdaffil.amount * txb.crc.rate[1] / b-crc.rate[1].
     sum2 = sum2 + kdaffil.amount_bank * txb.crc.rate[1] / b-crc.rate[1].
     end.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>ИТОГО</b></td><td></td><td></td><td></td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
               "<td></td>"
               "<td><b>" replace(trim(string(sum2, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
               "</tr>" skip.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Покрытие основного долга</b></td><td></td><td></td><td></td>"
               "<td><b>" replace(trim(string(sum1 / kdlon.amountz * 100, "->>>>9.99%")),".",",") "</b></td>"
               "<td></td>"
               "<td><b>" replace(trim(string(sum2 / kdlon.amountz * 100, "->>>>9.99%")),".",",") "</b></td>"
               "</tr>" skip.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Покрытие ОД и вознаграждения</b></td><td></td><td></td><td></td>"
               "<td><b>" replace(trim(string(sum1 / ((kdlon.amountz * kdlon.ratez * kdlon.srokz / 1200) + kdlon.amountz) * 100, "->>>>9.99%")),".",",") "</b></td>"
               "<td></td>"
               "<td><b>" replace(trim(string(sum2 / ((kdlon.amountz * kdlon.ratez * kdlon.srokz / 1200) + kdlon.amountz) * 100, "->>>>9.99%")),".",",") "</b></td>"
               "</tr>" skip.

 put stream m-out unformatted "</table>".
 put stream m-out unformatted "<br><tr></tr><tr align=""left""><td colspan=5><h5> " v-descr format 'x(2000)' "</td></tr><br><br>" skip.
end.


put stream m-out unformatted "<br><b><h3> 5. Классификация обязательства в соответствии с требованиями НБРК </b><br>" skip.

find first kdlonkl where kdlonkl.bank = kdlon.bank and kdlonkl.kdcif = s-kdcif and kdlonkl.kdlon = s-kdlon no-lock no-error.
if avail kdlonkl then do:
  put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Критерии клас-ции</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Классификация</td>"    
                  "<td bgcolor=""#C0C0C0"" align=""center"">Баллы</td>"
                  "</tr>" skip.
     sum1 = 0. sum2 = 0.
     for each kdlonkl where kdlonkl.bank = kdlon.bank and kdlonkl.kdcif = s-kdcif 
                     and kdlonkl.kdlon = s-kdlon no-lock.

     find first kdklass where kdklass.type = 1 and kdklass.kod = kdlonkl.kod no-lock no-error.  
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" kdklass.name format 'x(40)' "</td>"
               "<td align=""left"">" kdlonkl.valdesc format 'x(40)' "</td>"
               "<td>" replace(trim(string(kdlonkl.rating, "->>>>9.99")),".",",") "</td>"
               "</tr>" skip.
     sum1 = sum1 + kdlonkl.rating.
     end.
     find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
     if avail bookcod then v-statdescr = bookcod.name. 
    
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Итого</td>"
               "<td align=""left""><b>" v-statdescr format 'x(40)' "</td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>Предполагаемый процент резервирования по данному обязательству</td>"
               "<td><b>" deci(bookcod.info[1]) format '>>>9.99%' "</td>"
               "<td><b>" replace(trim(string(kdlon.amountz * deci(bookcod.info[1]) / 100, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.

 put stream m-out unformatted "</table>".
end.

put stream m-out unformatted "<br><b>6. Резюме </b><br>" skip.
find first kdaffil where kdaffil.bank = kdlon.bank and kdaffil.code = '21' 
                      and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-lock no-error.
if avail kdaffil then
   put stream m-out unformatted "<br><h5>" kdaffil.info[1] format 'x(200)' "<br>" skip.
   put stream m-out unformatted "<br><h5> Считаю возможным одобрить кредит на следующих условиях: <br>" skip.

  put stream m-out unformatted "<br><tr><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
   put stream m-out unformatted "<tr align=""left"">"
               "<td>  Сумма кредита </td>"
               "<td align=""right""> " kdlon.amount "</td>"
               "</tr>" skip.
   find first txb.crc where txb.crc.crc = kdlon.crc no-lock no-error.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Валюта кредита </td>"
               "<td align=""right"">  " txb.crc.code "</td></tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Ставка вознагр (% годовых) </td>"
               "<td align=""right""> " kdlon.rate format '>>9.99%' "</td></tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Период кредитования (мес) </td>"
               "<td align=""right""> " string(kdlon.srok) + "  месяцев" format 'x(20)' "</td></tr>" skip.

   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Возврат основного долга </td>"
               "<td> " kdlon.repay  format 'x(100)' "</td>"
               "</tr>" skip.
   put stream m-out unformatted  "<tr align=""left"">"
               "<td>  Возврат вознаграждения </td>"
               "<td> " kdlon.repay%  format 'x(40)' "</td>"
               "</tr>" skip.
  put stream m-out unformatted "</table>".

put stream m-out unformatted "<br><br><br><tr align=""left""><td><h4> Менеджер : __________________________ "  v-ofc format 'x(30)' "</td></tr>".
put stream m-out unformatted "</table></body></html>".

output stream m-out close.
unix silent cptwin rpt.html excel.
