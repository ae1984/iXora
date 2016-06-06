/* r_mop.p
 * MODULE
        Кредитный модуль 
 * DESCRIPTION
        Выгрузка данных по кредитам в состему Налоговой отчетности
        d1 надо указать дату последнего дня месяца
        Все данные по кредитам переведены в тенге по курсу даты отчета 
 * RUN
        
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-mop2
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        13.10.03  marinav
 * CHANGES
	21.01.04 valery убраны колонки "Номер банковского счета" "ВидВалюты" "Сумма Обеспечения"
			добавлены "БИК" "Номер доп договора" Дата доп договора"
			"Сумма займа по договору" теперь в валюте на день договора
			"Начисленная сумма вознаграждения" и "Полученная сумма вознаграждения" - теперь в тенге по курсу на дату поступления 
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	24/05/2004 valery 	название графы "Пролангация займа" изменено на "Дата пролангации займа"
				дабавлена графа "ПРИМЕЧАНИЕ", в которой указывается буквенный код валюты займа по догвору
				при этом делается запись "Займ выдан в ..."
        24/10/2006 Natalya D. - добавлены данные по физ.лицам.
*/
{global.i}

def new shared var d1 as date.
def new shared var coun as int.
define var repname as char no-undo.
define var nom as inte no-undo.
define var i as inte no-undo.
def var v-bankbik as char no-undo.
def var v-bal    as deci no-undo.
def var v-bal1   as deci no-undo.
def var v-bal2   as deci no-undo.
def var v-prem1  as deci no-undo.
def var v-prem2  as deci no-undo.
def var v-tbal   as deci no-undo.
def var v-tbal1  as deci no-undo.
def var v-tbal2  as deci no-undo.
def var v-tprem1 as deci no-undo.
def var v-tprem2 as deci no-undo.
def var v-vcount as int  no-undo.

def new shared temp-table wrk no-undo
    field nn     as inte
    field name   like bank.cif.name
    field cif    like bank.cif.cif
    field lon    like bank.lon.lon
    field grp    like bank.lon.grp
    field fiz    as   char 
    field rnn    like bank.cif.jss
    field dog    as   char
    field dogdt  as   date
    field crc    as    char  
    field rdt    as   date
    field duedt  as   date
    field balans like bank.lon.opnamt
    field balans1 like bank.lon.opnamt
    field balans2 like bank.lon.opnamt
    field prem   like bank.lon.prem
    field prem1  like bank.lon.opnamt
    field prem2  like bank.lon.opnamt
    field balans3 like bank.lon.opnamt
    field dlong  as   date
    field garant as   char
    field balgar like   bank.lon.opnamt 
    field proviz like   bank.lon.opnamt
    field nulls as   char
    index idx1 fiz
    index idx2 grp.

coun = 1.
d1 = date(month(g-today),1,year(g-today)) - 1.
update d1 label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .


define new shared stream m-out.
output stream m-out to rpt.html.

{html-title.i &stream = "stream m-out"}

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">" skip. 

put stream m-out "<tr align=""center""><td><h3>Расшифровка кредитного портфеля на "
                 string(d1) "</h3></td></tr><br><br>" skip.
 put stream m-out "<br><br><tr></tr>".

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">БИК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование юр.лица</td>"                  
/*                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ном договора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата договора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ном. доп. договора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата доп. договора</td>"
/*                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"   */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи займа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма займа по договору</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Выданная сумма займа, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Погашенная сумма займа, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ставка вознаграждения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленная сумма вознаграждения, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Полученная сумма вознаграждения, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма пролонгированного займа, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата пролонгации займа</td>" /*valery*/
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид обеспечения</td>"
/*                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма обеспечения</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Провизия, тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Погашено</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Примечание</td></tr>" skip. /*valery 24/05/04*/

/*run r_mop1 (input d1).*/
{r-branch.i &proc = "r_mop2 (input d1)"}
/*{r-brfilial.i &proc = "r_mop2 (input d1)"}*/
coun = 0.

for each longrp where substr(string(longrp.stn),1,1) = '1' no-lock:
   assign v-bal = 0 v-bal1 = 0 v-bal2 = 0 v-prem1 = 0 v-prem2 = 0 v-vcount = 0.
   for each wrk where wrk.fiz = '1' and wrk.grp = longrp.longrp no-lock break by wrk.grp.
      
      v-vcount = v-vcount + 1.
         ACCUMULATE wrk.lon (COUNT by wrk.grp).
         accumulate wrk.balans (total by wrk.grp).
         accumulate wrk.balans1 (total by wrk.grp).
         accumulate wrk.balans2 (total by wrk.grp).
         accumulate wrk.prem1 (total by wrk.grp).
         accumulate wrk.prem2 (total by wrk.grp).
      if last-of(wrk.grp) then do:   
         v-bal = accum total by wrk.grp wrk.balans.
         v-bal1 = accum total by wrk.grp wrk.balans1.       
         v-bal2 = accum total by wrk.grp wrk.balans2.
         v-prem1 = accum total by wrk.grp wrk.prem1.
         v-prem2 = accum total by wrk.grp wrk.prem2.  
         /*v-vcount = accum count by wrk.grp wrk.lon.*/             
         v-tbal = v-tbal + accum total by wrk.grp wrk.balans.
         v-tbal1 = v-tbal1 + accum total by wrk.grp wrk.balans1.
         v-tbal2 = v-tbal2 + accum total by wrk.grp wrk.balans2.
         v-tprem1 = v-tprem1 + accum total by wrk.grp wrk.prem1.
         v-tprem2 = v-tprem2 + accum total by wrk.grp wrk.prem2.                  
      end.
   end.
   put stream m-out unformatted "<tr align=""right"">"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0"" align=""left"">" string(longrp.longrp) + ' ' + longrp.des format "x(30)" "</td>"               
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td> " replace(trim(string(v-bal, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-bal2, "->>>>>>>>>>>9.99")),".",",")"</td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td> " replace(trim(string(v-prem1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-prem2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td bgcolor=""#C0C0C0""></td>"
               "<td> " v-vcount "</td></tr>" skip.
   v-vcount = 0 .    
end.

  put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
               "<td></td>"
               "<td></td>"
               "<td align=""left""> ФИЗИЧЕСКИЕ ЛИЦА </td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td> " replace(trim(string(v-tbal, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-tbal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-tbal2, "->>>>>>>>>>>9.99")),".",",")"</td>"
               "<td></td>"
               "<td> " replace(trim(string(v-tprem1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(v-tprem2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td></tr>" skip.

for each wrk where wrk.fiz = '2' no-lock by wrk.cif :
 coun = coun + 1.
 wrk.nn = coun. 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " wrk.nn "</td>"
               "<td align=""center""> `" wrk.lon "</td>"               
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " '`' wrk.rnn format 'x(12)' "</td>"
               "<td> " '`' wrk.dog format "x(15)" "</td>"
               "<td> " wrk.dogdt  "</td>"
               "<td> </td>"
               "<td> </td>"

               "<td> " wrk.rdt "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans2, "->>>>>>>>>>>9.99")),".",",")"</td>"
               "<td> " wrk.prem format '>9.99%' "</td>"
               "<td> " replace(trim(string(wrk.prem1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.prem2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans3, "->>>>>>>>>>>9.99")),".",",") "</td>". 

if wrk.dlong <> ? then
   put stream m-out unformatted 
				"<td> " wrk.dlong "</td>".
   else 
   put stream m-out unformatted 	
				"<td></td>".
   put stream m-out unformatted  
               "<td align=""left""> " trim(wrk.garant) format 'x(200)' "</td>" 
               "<td> " replace(trim(string(wrk.proviz, "->>>>>>>>>>>9.99")),".",",") "</td>" 
               "<td> " wrk.nulls "</td>" 
               "<td> Займ выдан в " wrk.crc "</td></tr>" 
               skip.

end.

put stream m-out "</table>" .
output stream m-out close.
unix silent cptwin rpt.html excel. 

/*** Сделать файл для загрузки - попадает на C:/ ****************/

repname = substr(string(d1),4,2) + substr(string(d1),7).
output to rpt.img.
put unformatted "<document type=""d120.02"" version=""1"" part="""" id="""" mgdid="""" refer="""" maildate="""" floppy="""" mail="""">" skip.
put unformatted "<form_11>" skip.

/*Находим БИК банка */
{sysc.i}
v-bankbik = get-sysc-cha ("clecod").


for each wrk where wrk.fiz = '2' break by nn.
  if ((wrk.nn - 1) mod 19) = 0 then run mon_beg (wrk.nn / 19 + 1).

   put unformatted "<row>" skip.
   put unformatted "<form11_1>" wrk.nn "</form11_1>" skip.
   put unformatted "<form11_2>" v-bankbik "</form11_2>" skip.
   put unformatted "<form11_3>" replace(substr(trim(wrk.name),1,40),'&','&amp;') "</form11_3>" skip.
/*   put unformatted "<form11_3>" wrk.lon "</form11_3>" skip. */
   put unformatted "<form11_4>" wrk.rnn "</form11_4>" skip.
   put unformatted "<form11_5>" wrk.dog "</form11_5>" skip.
   put unformatted "<form11_6>" wrk.dogdt format "99.99.9999" "</form11_6>" skip.
   put unformatted "<form11_7></form11_7>" skip.
   put unformatted "<form11_8></form11_8>" skip.
/*   put unformatted "<form11_7>" wrk.crc "</form11_7>" skip. */
   put unformatted "<form11_9>" wrk.rdt format "99.99.9999" "</form11_9>" skip.
   put unformatted "<form11_10>" wrk.duedt format "99.99.9999" "</form11_10>" skip.
   put unformatted "<form11_11>" trim(string(wrk.balans, "->>>>>>>>>>>9.99")) "</form11_11>" skip.
   put unformatted "<form11_12>" trim(string(wrk.balans1, "->>>>>>>>>>>9.99")) "</form11_12>" skip.
   put unformatted "<form11_13>" trim(string(wrk.balans2, "->>>>>>>>>>>9.99")) "</form11_13>" skip.
   put unformatted "<form11_14>" wrk.prem "</form11_14>" skip.
   put unformatted "<form11_15>" trim(string(wrk.prem1, "->>>>>>>>>>>9.99")) "</form11_15>" skip.
   put unformatted "<form11_16>" trim(string(wrk.prem2, "->>>>>>>>>>>9.99")) "</form11_16>" skip.
   put unformatted "<form11_17>" trim(string(wrk.balans3, "->>>>>>>>>>>9.99")) "</form11_17>" skip.
   put unformatted "<form11_18>" wrk.dlong format "99.99.9999" "</form11_18>" skip.
   put unformatted "<form11_19>" trim(wrk.garant) "</form11_19>" skip.
/*   put unformatted "<form11_19>" trim(string(wrk.balgar, "->>>>>>>>>>>9.99")) "</form11_19>" skip. */
   put unformatted "<form11_20>" trim(string(wrk.proviz, "->>>>>>>>>>>9.99")) "</form11_20>" skip.
   put unformatted "<form11_21>" wrk.nulls "</form11_21>" skip.
   put unformatted "<form11_22></form11_22>" skip.
   put unformatted "<form11_23>Займ выдан в "wrk.crc "</form11_23>" skip. /*valery 24/05/04*/
   put unformatted "</row>" skip.

  if (wrk.nn mod 19) = 0 then run mon_end.
end.
repeat i = (wrk.nn mod 19) + 1  to 19.
  run mon_dop.
end.

run mon_end.
put unformatted "</form_11>" skip.
put unformatted "</document>" skip.

output close.

unix silent value ("koi2utf rpt.img " + repname + ".mop ").
unix silent value ("rcp " + repname + ".mop " + " `askhost`:C:/").
unix silent value ("rm " + repname + ".mop").



procedure mon_beg.
   define input parameter v-nom as inte.
   put unformatted "<sheet>" skip.
   put unformatted "<page_12 cvsid="""">" skip.
   put unformatted "<osn>1</osn>" skip.
   put unformatted "<corr>0</corr>" skip.
   put unformatted "<n_s>" string(v-nom) "</n_s>" skip.
   put unformatted "<rnn>600900050984</rnn>" skip.
   put unformatted "<name>АО TEXAKABANK</name>" skip.
   put unformatted "<p_month>" string(month(d1)) "</p_month>" skip.
   put unformatted "<p_year>" string(year(d1)) "</p_year>" skip.
   put unformatted "<n_s1>" string(v-nom) "</n_s1>" skip.
   put unformatted "<rnn1>600900050984</rnn1>" skip.
   put unformatted "<name1>АО TEXAKABANK</name1>" skip.
   put unformatted "<p_month1></p_month1>" skip.
   put unformatted "<p_year1>" string(year(d1)) "</p_year1>" skip.
   put unformatted "<n_s2>" string(v-nom) "</n_s2>" skip.
   put unformatted "<rnn2>600900050984</rnn2>" skip.
   put unformatted "<name2>АО TEXAKABANK</name2>" skip.
   put unformatted "<p_month2></p_month2>"  skip.
   put unformatted "<p_year2>" string(year(d1)) "</p_year2>" skip.
   put unformatted "<rowset>" skip.
end.

procedure mon_end.
   put unformatted "</rowset>" skip.
   put unformatted "<fiohead></fiohead>" skip.
   put unformatted "<fiocount></fiocount>" skip.
/*   put unformatted "<fioface></fioface>" skip. */
   put unformatted "<docnumer></docnumer>" skip.
   put unformatted "<code></code>" skip.
   put unformatted "<fiohead1></fiohead1>" skip.
/*   put unformatted "<fiocount1></fiocount1>" skip. */
   put unformatted "<fioface1></fioface1>" skip.
   put unformatted "<docnumer1></docnumer1>" skip.
   put unformatted "<fiohead2></fiohead2>" skip.
   put unformatted "<fiocount2></fiocount2>" skip.
   put unformatted "<fioface2></fioface2>" skip.
   put unformatted "<docnumer2></docnumer2>" skip.
   put unformatted "<numreg></numreg>" skip.
   put unformatted "<dareg></dareg>" skip.
   put unformatted "<numreg1></numreg1>" skip.
/*   put unformatted "<dareg1></dareg1>" skip. */
   put unformatted "<numreg2></numreg2>" skip.
   put unformatted "<dareg2></dareg2>" skip.
   put unformatted "</page_12>" skip.
   put unformatted "</sheet>" skip.
end.

procedure mon_dop.
   put unformatted "<row>" skip.
   put unformatted "<form11_1></form11_1>" skip.
   put unformatted "<form11_2></form11_2>" skip.
   put unformatted "<form11_3></form11_3>" skip.
/*   put unformatted "<form11_3></form11_3>" skip. */
   put unformatted "<form11_4></form11_4>" skip.
   put unformatted "<form11_5></form11_5>" skip.
   put unformatted "<form11_6></form11_6>" skip.
   put unformatted "<form11_7></form11_7>" skip.
   put unformatted "<form11_8></form11_8>" skip.
/*   put unformatted "<form11_7></form11_7>" skip.*/
   put unformatted "<form11_9></form11_9>" skip.
   put unformatted "<form11_10></form11_10>" skip.
   put unformatted "<form11_11>0</form11_11>" skip.
   put unformatted "<form11_12>0</form11_12>" skip.
   put unformatted "<form11_13>0</form11_13>" skip.
   put unformatted "<form11_14>0</form11_14>" skip.
   put unformatted "<form11_15>0</form11_15>" skip.
   put unformatted "<form11_16>0</form11_16>" skip.
   put unformatted "<form11_17>0</form11_17>" skip.
   put unformatted "<form11_18></form11_18>" skip.
   put unformatted "<form11_19></form11_19>" skip.
/*   put unformatted "<form11_19>0</form11_19>" skip. */
   put unformatted "<form11_20>0</form11_20>" skip.
   put unformatted "<form11_21></form11_21>" skip.
   put unformatted "<form11_22></form11_22>" skip. 
   put unformatted "<form11_23></form11_23>" skip. /*valery 24/05/04*/
   put unformatted "</row>" skip.
end.
