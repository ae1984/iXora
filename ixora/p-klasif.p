/* P-klasif.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредитного портфеля
 * RUN
        r-klasif
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        
 * INHERIT
        r-klasif2(input datums)
 * MENU
        PUSH
 * AUTHOR
        10/04/06   marinav - переделан на PUSH отчет из r-klasif - ежемесячно 1 числа
 * CHANGES
 	03.07.06 - u00121 	- в таблицу wrk добавил опцию no-undo, т.к. в вызываемой этой программой r-klasif2 у таблици тоже был no-undo - как результат PUSH-отчет не работал
 			        - добавил индексы в таблицу wrk1
 			        - в for each`ах, внутри которых не изменялись данные проставил no-lock
 			        - после create запись данных в новую таблицу сделал через assign
 			        - в for each по таблице lonstat добавлен no-lock, в нутри выборки ни одна запись не меняется
        21/07/2006 MARINAV - требования КИК
        31/10/2006 madiyar - теперь формируется еще и консолидированный пуш
        01/11/2006 madiyar - в отчете были слишком длинные строки, дорисовал skip-ов
*/

def shared var g-today as date.
def new shared var v-reptype as integer no-undo.
def var v-repname as char no-undo extent 4.
v-repname[1] = "юр".
v-repname[2] = "физ".
v-repname[3] = "БД".
v-repname[4] = "все".

{push.i}
def var coun as int init 1.
def var dayc1 as int init 0.
def var dayc2 as int init 0.
define variable datums  as date format '99/99/9999' label 'На'.
define variable v-sum1 as decimal extent 5 format '->>>,>>>,>>9.99'.
define variable v-sum2 as decimal extent 5 format '->>>,>>>,>>9.99'.
define variable v-sum3 as decimal extent 5 format '->>>,>>>,>>9.99'.
define var i as inte.
define var vfname1 as char.

vfname1 = substr(vfname ,1 , index(vfname, '.html') - 1 ) + "-r" + substr(vfname, index(vfname, '.html')) .

datums = vdt - 1.

def new shared temp-table wrk no-undo
    field num    as inte
    field lon    like bank.lon.lon
    field cif    like bank.lon.cif
    field name   like bank.cif.name
    field rdt    as inte
    field regdt  like bank.lon.rdt
    field ddt like bank.lon.rdt
    field grp like bank.lon.grp
    field opnamt like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field balansi like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field sts    like bank.lonstat.prc
    field bal1   like bank.lon.opnamt  /*Нач доходы*/
    field balprci like bank.lon.opnamt  /*в т.ч. индексация*/
    field bal11   like bank.lon.opnamt  /*Пол доходы*/
    field bal2   like bank.lon.opnamt   /* Провизии необ  */
    field bal3   like bank.lon.opnamt  /* Провизии начис*/
    field kod    as   inte  /* Обесп*/
    field crcz    as   inte  /* Обесп*/
    field v-name as char
    field v-addr as char
    field v-zal as char
    field bal4   like bank.lon.opnamt
    field ecdiv  as char
    field lntreb as char
    index ind1 is primary sts rdt lon name desc
    index ind2 cif kod.

def temp-table wrkc like wrk.

define temp-table wrk1 no-undo
  field type as inte     /*тип Стандарт Субстандарт Безнадеж*/
  field sts  like bank.lonstat.prc  /*статус 0, 5, 10, 15, 20, 25,50, 100*/
  field rdt  as inte                /* год выдачи*/
  field type1 as inte             /* тип 1- сумма кредита 2- необх провизии 3-создан провизии 4-обеспечение */
  field bal1  like bank.lon.opnamt
  index idx1 rdt
  index idx2 rdt sts type1
  index idx3 sts type1 rdt.
 
def var v-am1 as decimal init 0.
def var v-am2 as decimal init 0.
def var v-am3 as decimal init 0.

def var v-cur  as deci init 1.
def var v-curd as deci.
def var v-cure as deci.
def var v-curr as deci.

if datums = g-today then do:
  find first crc where crc.crc = 2 no-lock no-error.
  if avail crc then v-curd = crc.rate[1].
  find first crc where crc.crc = 11 no-lock no-error.
  if avail crc then v-cure = crc.rate[1].
  find first crc where crc.crc = 4 no-lock no-error.
  if avail crc then v-curr = crc.rate[1].
end.

if datums < g-today then do:
  find last crchis where crchis.crc = 2 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-curd = crchis.rate[1].
  find last crchis where crchis.crc = 11 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-cure = crchis.rate[1].
  find last crchis where crchis.crc = 4 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-curr = crchis.rate[1].
end.

define stream m-out.
find first cmp no-lock no-error.

def var j as integer no-undo.

do j = 1 to 4:
    
    v-sum1 = 0. v-sum2 = 0. v-sum3 = 0.
    
    if j <> 4 then do:
      /*
      j=1 и j=2 - юр и физ собираются в таблице wrkc
      j=3 - БД собирается в wrk и при j=4 все записи из wrkc сливаются с БД в wrk
      */
      for each wrk: delete wrk. end.
      v-reptype = j.
      {r-branch.i &proc = "r-klasif2(input datums)"}
      
      if j = 1 or j = 2 then do:
        for each wrk: create wrkc. buffer-copy wrk to wrkc. end.
      end.
      
    end.
    else do:
      for each wrkc: create wrk. buffer-copy wrkc to wrk. end.
    end.
    
    output stream m-out to value(entry(1,vfname,'.') + '-rep' + string(j,"9") + '.' + entry(2,vfname,'.')).
    
    put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    
    
    put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
    
    
    put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip.
    
    put stream m-out unformatted "<tr align=""center""><td><h3>Классификация кредитного портфеля за " string(datums) " (" v-repname[j] ")</h3></td></tr><br><br>" skip.
    
           put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr style=""font:bold"">" skip
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>П/п</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Номер</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование заемщика</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Отрасль</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Год выдачи кредита</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата выдачи</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата окончания</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Группа</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Сумма по договору</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Остаток долга</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Индексация ОД<BR>в тыс.тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>% ставка</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Начисленные доходы</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Индексация %<BR>в тыс.тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Полученные доходы</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Статус</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Необходимая сумма провизий</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Фактически сформированные провизии</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan=5>Обеспечение</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>КИК</td>" skip
                      "</tr>" skip.
    
           put stream m-out unformatted "<tr style=""font:bold"">" skip
                      "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">В валюте кредита</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">В тыс тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">В валюте кредита</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">в тыс тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">в тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">в тыс тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">в тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">в тыс тенге</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">Код</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">наименование</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">адрес</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">залогодатель</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"">сумма в тыс тенге</td>" skip
                      "</tr>" skip.
    
    for each wrk no-lock break by wrk.sts by wrk.rdt by wrk.lon by wrk.name  desc.
    
      find crc where crc.crc = wrk.crc no-lock no-error.
          
          v-cur = 1.
          if wrk.crc = 2 then v-cur = v-curd.
          if wrk.crc = 11 then v-cur = v-cure.
          if wrk.crc = 4 then v-cur = v-curr.
    
            put stream m-out unformatted "<tr align=""right"">" skip
                   "<td align=""center""> " coun "</td>"
                   "<td align=""left""> " wrk.cif "</td>"
                   "<td align=""left""> " wrk.name format "x(60)" "</td>"
                   "<td align=""left""> " wrk.ecdiv "</td>"
                   "<td> " wrk.rdt format '>>>9' "</td>"
                   "<td> " wrk.regdt "</td>"
                   "<td> " wrk.ddt "</td>"
                   "<td> " wrk.grp "</td>"
                   "<td> " crc.code format 'x(3)' "</td>"
                   "<td> " replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.balans * v-cur / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.balansi * v-cur / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.prem, "->>9.99%")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.bal1 * v-cur / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.balprci * v-cur / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.bal11, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " wrk.sts format '->>9' "</td>"
                   "<td> " replace(trim(string(wrk.balans * v-cur * wrk.sts / 100, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.balans * v-cur * wrk.sts / 100000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(wrk.bal3 / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " wrk.kod format '->>>9' "</td>" 
                   "<td align=""left""> " wrk.v-name "</td>" 
                   "<td align=""left""> " wrk.v-addr "</td>" 
                   "<td align=""left""> " wrk.v-zal "</td>" 
                   "<td> " replace(trim(string(wrk.bal4 / 1000, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td align=""left""> " wrk.lntreb "</td>" skip
                   "</tr>" skip.
          v-sum1[1] = v-sum1[1] + wrk.balans * v-cur.
          v-sum1[2] = v-sum1[2] + wrk.bal1 * v-cur.
          v-sum1[3] = v-sum1[3] + wrk.balans * v-cur * wrk.sts / 100.
          v-sum1[4] = v-sum1[4] + wrk.bal3.
          v-sum1[5] = v-sum1[5] + wrk.bal4.
          coun = coun + 1.
    
        if last-of (wrk.rdt) then do:
           put stream m-out unformatted
                     "<tr align=""left"">" skip
                     "<td></td><td></td><td><b> ИТОГО " wrk.rdt format '>>>9' " год </b></td> <td></td> <td></td> <td></td>"
                     "<td></td> <td></td> <td></td> <td></td> <td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum1[1] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum1[2] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum1[3] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum1[4] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum1[5] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                     "</tr>" skip.
           v-sum2[1] = v-sum2[1] + v-sum1[1].
           v-sum2[2] = v-sum2[2] + v-sum1[2].
           v-sum2[3] = v-sum2[3] + v-sum1[3].
           v-sum2[4] = v-sum2[4] + v-sum1[4].
           v-sum2[5] = v-sum2[5] + v-sum1[5].
    
           find first wrk1 where wrk1.rdt = wrk.rdt no-error.
           if not avail wrk1 then do:
           repeat i = 1 to 4.
           for each lonstat no-lock.
    	       create wrk1.
    	       assign
            	      wrk1.sts = lonstat.prc
    	              wrk1.type = 2
            	      wrk1.rdt = wrk.rdt
    	              wrk1.type1 = i.
    	       if wrk.sts = 0 then wrk1.type = 1.
    	       if wrk.sts = 100 then wrk1.type = 3.
    
           end.
           end.
           end.
           find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 1 no-lock no-error.
           if avail wrk1 then wrk1.bal1 = v-sum1[1].
           find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 2 no-lock no-error.
           if avail wrk1 then wrk1.bal1 = v-sum1[3].
           find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 3 no-lock no-error.
           if avail wrk1 then wrk1.bal1 = v-sum1[4].
           find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 4 no-lock no-error.
           if avail wrk1 then wrk1.bal1 = v-sum1[5].
    
           v-sum1[1] = 0.
           v-sum1[2] = 0.
           v-sum1[3] = 0.
           v-sum1[4] = 0.
           v-sum1[5] = 0.
    
        end.
        if last-of (wrk.sts) then
        do:
           put stream m-out unformatted
                     "<tr align=""left"">" skip
                     "<td></td><td></td><td><b> ИТОГО по статусу " wrk.sts " </b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum2[1] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum2[2] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum2[3] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum2[4] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                     "<td align=""right""><b>" replace(trim(string(v-sum2[5] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                     "</tr>" skip.
           v-sum3[1] = v-sum3[1] + v-sum2[1].
           v-sum3[2] = v-sum3[2] + v-sum2[2].
           v-sum3[3] = v-sum3[3] + v-sum2[3].
           v-sum3[4] = v-sum3[4] + v-sum2[4].
           v-sum3[5] = v-sum3[5] + v-sum2[5].
           v-sum2[1] = 0.
           v-sum2[2] = 0.
           v-sum2[3] = 0.
           v-sum2[4] = 0.
           v-sum2[5] = 0.
        end.
    end.
    
    put stream m-out unformatted
           "<tr align=""left"">" skip
           "<td></td><td></td><td><b> ИТОГО </b></td> <td></td> <td></td> <td></td> <td></td><td></td> <td></td><td></td><td></td>"
           "<td align=""right""><b>" replace(trim(string(v-sum3[1] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
           "<td align=""right""><b>" replace(trim(string(v-sum3[2] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
           "<td align=""right""><b>" replace(trim(string(v-sum3[3] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td>"
           "<td align=""right""><b>" replace(trim(string(v-sum3[4] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
           "<td align=""right""><b>" replace(trim(string(v-sum3[5] / 1000, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
           "</tr>" skip.
    
    put stream m-out unformatted "</table></body></html>" skip.
    output stream m-out close.
    
    output stream m-out to value(entry(1,vfname1,'.') + '-rep' + string(j,"9") + '.' + entry(2,vfname1,'.')).
    
    /*шапка*/
    put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip.
    
    put stream m-out unformatted "<tr align=""center""><td><h3>Сведения по кредитам, выданным и непогашенным за " string(datums) " (" v-repname[v-reptype]
                     "</h3></td></tr><br><br>" skip.
    
    put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr style=""font:bold"">" skip
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan = ""2""> Группа кредита</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan = ""2""> Задолженность по кредитам</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan = ""6""> Задолженность по кредитам</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan = ""2"">Необходимая сумма резервов</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan = ""6""> Необходимая сумма резервов</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" rowspan = ""2""> Сформированная сумма резервов</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" colspan = ""6""> Сформированная сумма резервов</td>" skip
                      "</tr>" skip.
    
    for each wrk1 no-lock break by wrk1.rdt.
      if first-of (wrk1.rdt) then
        put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center""> " wrk1.rdt format '>>>9' "</td>".
    end.
    for each wrk1 no-lock break by wrk1.rdt.
      if first-of (wrk1.rdt) then
        put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center""> " wrk1.rdt format '>>>9' "</td>".
    end.
    for each wrk1 no-lock break by wrk1.rdt.
      if first-of (wrk1.rdt) then
        put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center""> " wrk1.rdt format '>>>9' "</td>".
    end.
    
    put stream m-out unformatted "</tr>" .
    /******************************************/
    
    /**Данные***/
    
    for each wrk1 no-lock where wrk1.type1 ne 4 break by wrk1.sts by wrk1.type1 by wrk1.rdt .
        
    	if first-of (wrk1.sts) then put stream m-out unformatted "<tr align=""right""><td align=""center""> " wrk1.sts "</td>" skip.
    	if first-of (wrk1.type1) then put stream m-out unformatted "<td> </td>" skip.
        
    	put stream m-out unformatted "<td> " replace(trim(string(wrk1.bal1, "->>>>>>>>9")), ".", ",") "</td>" skip.
        
    	if last-of (wrk1.sts) then put stream m-out unformatted "</tr>" skip.
        
    end.
    
    put stream m-out unformatted "</table>" skip.
    
    
    /*шапка*/
    put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip.
    
    put stream m-out unformatted "<tr align=""center""><td><h3>Классификация кредитов за " string(datums) "</h3></td></tr><br><br>" skip.
    
    put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr style=""font:bold"">" skip
                      "<td bgcolor=""#C0C0C0"" align=""center"" > Группа кредита</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" > Всего сумма основного долга</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" > Задолженность по кредитам</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" > Необходимая сумма резервов</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" > Сформированная сумма резервов</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" > стоимость обеспечения</td>" skip
                      "</tr>" skip.
    
    
    /**Данные***/
    
    v-sum1[1] = 0.
    v-sum1[2] = 0.
    v-sum1[3] = 0.
    v-sum1[4] = 0.
    for each wrk1 no-lock break by wrk1.sts by wrk1.type1.
        
    	if first-of (wrk1.sts) then put stream m-out unformatted "<tr align=""right""><td align=""center""> " wrk1.sts "</td>" skip.
        
    	if wrk1.type1 = 1 then v-sum1[1] = v-sum1[1] + wrk1.bal1.
    	if wrk1.type1 = 2 then v-sum1[2] = v-sum1[2] + wrk1.bal1.
    	if wrk1.type1 = 3 then v-sum1[3] = v-sum1[3] + wrk1.bal1.
    	if wrk1.type1 = 4 then v-sum1[4] = v-sum1[4] + wrk1.bal1.
        
    	if last-of (wrk1.sts) then do:
    	   put stream m-out unformatted "<td> " replace(trim(string(v-sum1[1], "->>>>>>>>>>>9")), ".", ",") "</td>" skip
                         "<td> " replace(trim(string(v-sum1[1], "->>>>>>>>>>>9")), ".", ",") "</td>" skip
                         "<td> " replace(trim(string(v-sum1[2], "->>>>>>>>>>>9")), ".", ",") "</td>" skip
                         "<td> " replace(trim(string(v-sum1[3], "->>>>>>>>>>>9")), ".", ",") "</td>" skip
                         "<td> " replace(trim(string(v-sum1[4], "->>>>>>>>>>>9")), ".", ",") "</td>" skip.
    	   v-sum1[1] = 0.
    	   v-sum1[2] = 0.
    	   v-sum1[3] = 0.
    	   v-sum1[4] = 0.
    	   put stream m-out unformatted "</tr>" skip.
    	end.
    
    end.
    
    put stream m-out unformatted "</table></body></html>" skip.
    
    output stream m-out close.
end. /* do j = 1 to 4 */

vres = yes.

