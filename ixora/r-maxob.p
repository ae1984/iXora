/* r-maxob.p
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        Отчет по счетам со среднемесячным кредитовым оборотом больше crc.max-ob...
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
        31/12/99 pragma
 * CHANGES
       	07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       	18.11.2004 sasco добавил вывод оборотов за последний месяц
       	22.11.2004 sasco сделал новую сортировку по суммам
       	25.11.2004 sasco откорректировал сортировку по суммам для валюты
       	01.12.2004 sasco вывод в Excel
       	03.12.2004 sasco добавил номер СПФ
       	06.12.2004 sasco Сделал вывод номера СПФ
       	05.01.2005 sasco Исправил вывод подитогов по количествам треугольников :-)
      	06.04.2005 sasco Добавил вывод названия подразделения (ppoint) вместо номера
                         Вывод адреса, телефонов, руководителя 
	05.12.2005 u00121 поиск по jl раньше делался так: for each jl where jl.jdt ge fdate and jl.jdt le tdate, 
			  для более эффективного поиска необходимо запрос заключить в цикл по датам периода, и искать проводки уже по конкретной дате
        17.08.2006 Natalya D. - повторяющиеся запросы вывела в один и во временную таблицу. Убрала сортировку(break by) по aaa.crc, 
                                т.к. она не существенна, но значительно замедляет работу.
*/

/*
   #9632 - квадрат
   #9650 - пирамида вверх
   #9660 - пирамида вниз
   
*/

{global.i}                               
{msg-box.i}
{gl-utils.i}
{get-ppoint.i}

def var v-jdt as date no-undo.


def stream m-out.
def var v-dat      as date.
def var fdate      as date.
def var tdate      as date.
def var amt1       as deci.
def var oldcrc     as deci initial 0.
def var ii         as deci initial 0.
def var oldval     as char.
def var kolm       as deci initial 1.
def var v-cam like jl.cam.
def var v-camo like jl.cam.

define variable vpoint as int.
define variable vdep as int.


define variable d0 as date.
define variable d1 as date.

define variable maxc as int initial 0.
define variable curc as int initial 0.

/*
define variable cntl as int.
define variable cntr as int.
define variable alll as int.
define variable allr as int.
*/

def temp-table temp
    field aaa  like aaa.aaa
    field cif  like cif.cif
    field crc  like crc.crc
    field code like crc.code
    field amt1 as deci 
    field amt2 as deci 
    field amt3 as deci 
    field amt4 as deci
    field amt5 as deci
    field amt6 as deci
    field cntl as int
    field cntr as int
    field rko  as int
    field addr as char
    field phones as char
    field chief as char
    field prizamt as character initial "2"
    index idx_tmp is primary crc prizamt amt1
    .

def temp-table t-aaa
         field aaa like aaa.aaa
         field gl like aaa.gl
         field cif like aaa.cif 
         field crc like aaa.crc
         field addr1 as char
         field addr2 as char
         field tel as char
         field tlx as char
         field jame as char
         field prefix as char
         field sname as char.
def temp-table t-jl 
         field jh like jl.jh
         field jdt as date
         field gl like jl.gl
         field cam as deci
         field rem as char.      
 
 find last cls no-lock no-error.
 g-today = if available cls then cls.cls + 1 else today.

 v-dat = date(month(g-today),1,year(g-today)).
 update v-dat label ' Укажите дату (первое число месяца)' format '99/99/9999'         
        validate(v-dat ge 02/01/2000 and v-dat le g-today, 
        "Дата должна быть в пределах от 01/02/2000 до текущего дня")
        skip with side-label row 5 centered frame dat .
 display '   Ждите...   '  with row 5 frame ww centered .

if month(v-dat) > 1 then do:
   kolm = month(v-dat) - 1.
   fdate = date(1,1,year(v-dat)).
   tdate = date(month(v-dat),1,year(v-dat)) - 1.
end.   
else do:
   kolm = 12.
   fdate = date(1,1,year(v-dat) - 1).
   tdate = date(month(v-dat),1,year(v-dat)) - 1.
end.

d1 = tdate.
d0 = date(month(d1),1,year(d1)).
/***************************************************************************************************************************************************************/
for each aaa no-lock where aaa.gl = 220310 /*break by aaa.crc*/ :
    if aaa.sta = "C" then next.
    find cif where cif.cif = aaa.cif no-lock no-error.
    if not avail cif then next.
    /* выберем юридические... */
    find first sub-cod where sub-cod.d-cod = 'clnsts' and  sub-cod.ccode = '0' and sub-cod.sub   = 'cln' and sub-cod.acc   = string( aaa.cif ) no-lock no-error.
    if not avail sub-cod then next.
    
    /* пропустим исключения... */
    find first sub-cod where sub-cod.d-cod = 'clndop' and sub-cod.sub   = 'cln' and sub-cod.acc   = string( aaa.cif ) no-lock no-error.
    if avail sub-cod and sub-cod.ccode = '1' then next.
    maxc = maxc + 1.
    run SHOW-MSG-BOX ("Подсчет счетов " + aaa.aaa + " " + string (maxc)).
    create t-aaa.
    assign t-aaa.aaa = aaa.aaa
           t-aaa.gl  = aaa.gl
           t-aaa.cif = aaa.cif
           t-aaa.crc = aaa.crc
           t-aaa.addr1 = cif.addr[1]
           t-aaa.addr2 = cif.addr[2]
           t-aaa.tel = cif.tel
           t-aaa.tlx = cif.tlx
           t-aaa.jame = cif.jame
           t-aaa.prefix = cif.prefix
           t-aaa.sname = cif.sname.
end.
/* 
do v-jdt = fdate to tdate: 
		for each jl where jl.jdt = v-jdt and jl.gl = aaa.gl no-lock.
                 create t-jl.
                 assign t-jl.jh = jl.jh
                        t-jl.jdt = jl.jdt
                        t-jl.gl = jl.gl
                        t-jl.cam = jl.cam
                        t-jl.rem = jl.rem[1].		    
		end.
end.
*/
/***************************************************************************************************************************************************************/

find last crchis where crchis.rdt le tdate and crchis.crc = 2 no-lock no-error.

oldcrc = 0.



for each t-aaa /*where  aaa.gl = 220310  no-lock break by aaa.crc*/ no-lock :
    /*if aaa.sta = "C" then next.*/

    /*find cif where cif.cif = aaa.cif no-lock no-error.
    if not avail cif then next.*/

    curc = curc + 1.

    run SHOW-MSG-BOX (t-aaa.aaa + "... [ " + string (curc) + " из " + string (maxc) + " ]").

    /* выберем юридические... */
    /*find first sub-cod where sub-cod.d-cod = 'clnsts' and  sub-cod.ccode = '0' and sub-cod.sub   = 'cln' and sub-cod.acc   = string( aaa.cif ) no-lock no-error.
    if not avail sub-cod then next.*/
    
    /* пропустим исключения... */
    /*find first sub-cod where sub-cod.d-cod = 'clndop' and sub-cod.sub   = 'cln' and sub-cod.acc   = string( aaa.cif ) no-lock no-error.
    if avail sub-cod and sub-cod.ccode = '1' then next.*/
    
    find crc where crc.crc eq t-aaa.crc no-lock no-error.
    find crc-new where crc-new.crc eq t-aaa.crc no-lock no-error.
    
    v-cam = 0.
    v-camo = 0.

/*05/12/2005 u00121 поиск по jl раньше делался так: for each jl where jl.jdt ge fdate and jl.jdt le tdate , что приводило к потере индекса***********************
в таких случая должно быть полное соответсвие, т.е. прогресс не подключает индекс если ищют данные по периоду****************************************************/
/*для более эффективного поиска необходимо запрос заключить в цикл по датам периода, и искать проводки уже по конкретной дате*/
	do v-jdt = fdate to tdate: 
		for each jl where jl.jdt = v-jdt and jl.acc = t-aaa.aaa and jl.gl = t-aaa.gl no-lock.
		    displ string(v-jdt) label "собираю проводки по счету за..."  jl.jh no-label with side-label row 10 frame ww2 centered. pause 0.
			if not(jl.rem[1] begins 'O/D protect') and not(jl.rem[1] begins 'O/D payment') then 
			do:
				v-cam = v-cam + jl.cam.
				if jl.jdt >= d0 and jl.jdt <= d1 then 
					v-camo = v-camo + jl.cam.
			end.
		end.
	end.
/****************************************************************************************************************************************************************/

    if v-cam / kolm < crc-new.max-ob then next.
    
    create temp.                                 
    assign temp.aaa  = t-aaa.aaa
           temp.cif  = t-aaa.cif
           temp.addr = TRIM (TRIM (t-aaa.addr1) + " " + TRIM(t-aaa.addr2))
           temp.phones = TRIM (TRIM (t-aaa.tel) + " " + TRIM(t-aaa.tlx)).

    find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = t-aaa.cif and sub-cod.d-cod = 'clnchf' 
                       no-lock no-error.
    if avail sub-cod then temp.chief = TRIM (sub-cod.rcode).
                     else temp.chief = "".

    assign temp.crc  = crc.crc
           temp.code = crc.code.
    if temp.crc = 1 then do:

       assign temp.amt1 = round(v-cam / kolm / 1000,0) 
              temp.amt2 = round(v-cam / kolm / crchis.rate[1] / 1000,2) 
              temp.amt3 = round(v-cam / 1000,0) 
              temp.amt4 = round(v-cam / crchis.rate[1] / 1000,2) 
              temp.amt5 = round (v-camo / 1000, 0)
              temp.amt6 = round (v-camo / 1000 / crchis.rate[1], 0).
    end.
    else do:
    assign temp.amt1 = 0
           temp.amt2 = round(v-cam / kolm / 1000,2) 
           temp.amt3 = 0
           temp.amt4 = round(v-cam / 1000,2)                
           temp.amt5 = 0
           temp.amt6 = round (v-camo / 1000, 0).
    end.    
    if temp.amt5 <> 0 or temp.amt6 <> 0 then temp.prizamt = "1".

    if t-aaa.jame <> '' then do :
       vpoint =  integer(t-aaa.jame) / 1000 - 0.5 .
       vdep = integer(t-aaa.jame) - vpoint * 1000.
    end. else do :
      find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
      vpoint = ofchis.point. vdep = ofchis.dep.
    end.
    temp.rko = vdep.

end.                                                                             



    run SHOW-MSG-BOX ("Вывод в файл").


output stream m-out to rpt.html.
{html-start.i "stream m-out"}

put stream m-out unformatted skip 
'<H2>ОБОРОТЫ ПО СЧЕТАМ КЛИЕНТОВ на ' date(month(v-dat),1,year(v-dat)) format '99.99.9999' '</H2>' skip
'<H6>Курс $ ' XLS-NUMBER (crchis.rate[1]) '</H6>' skip.

put stream m-out unformatted
'<TABLE BORDER="1">'
'<TR bgcolor="#C0C0C0" align="CENTER">'
'<TD ROWSPAN="2"> &nbsp; </td>'
'<TD ROWSPAN="2"> Счет </td>'
'<TD ROWspan="2"> Наименование клиента </td>' 
'<TD ROWSPAN="2"> &nbsp; </td>'
'<TD ROWSPAN="2"> СПФ </td>'
'<td COLSPAN="2"> за последний месяц </td>'
'<td COLSPAN="2"> средние за месяц </td>'
'<td COLSPAN="2"> за период </td>'
'<td COLSPAN="3"> Контактная информация </td>'
'</TR>' skip.

put stream m-out unformatted 
'<tr align="center" bgcolor="#C0C0C0">'
'<td> тыс.тг. </td><td> тыс.$. </td>'
'<td> тыс.тг. </td><td> тыс.$. </td>'
'<td> тыс.тг. </td><td> тыс.$. </td>'
'<td> Адрес </td><td> Телефон(ы) </td><td> Руководитель </td>'
'</tr>' skip.

for each temp break by temp.crc by temp.prizamt by temp.amt1 descend by temp.amt2 descend:

    if temp.amt6 < temp.amt2 then temp.cntl = temp.cntl + 1.
                              else temp.cntr = temp.cntr + 1.

    accumulate temp.amt1 (sub-total by temp.crc).
    accumulate temp.amt1 (sub-total by temp.prizamt).
    accumulate temp.amt2 (sub-total by temp.crc).
    accumulate temp.amt2 (sub-total by temp.prizamt).
    accumulate temp.amt3 (sub-total by temp.crc).
    accumulate temp.amt3 (sub-total by temp.prizamt).
    accumulate temp.amt4 (sub-total by temp.crc).
    accumulate temp.amt4 (sub-total by temp.prizamt).
    accumulate temp.amt5 (sub-total by temp.crc).
    accumulate temp.amt5 (sub-total by temp.prizamt).
    accumulate temp.amt6 (sub-total by temp.crc).
    accumulate temp.amt6 (sub-total by temp.prizamt).

    accumulate temp.cntl (sub-total by temp.crc).
    accumulate temp.cntl (sub-total by temp.prizamt).
    accumulate temp.cntr (sub-total by temp.crc).
    accumulate temp.cntr (sub-total by temp.prizamt).

    accumulate temp.amt1 (total).
    accumulate temp.amt2 (total).
    accumulate temp.amt3 (total).
    accumulate temp.amt4 (total).
    accumulate temp.amt5 (total).
    accumulate temp.amt6 (total).

    accumulate temp.cntl (total).
    accumulate temp.cntr (total).
    
    put stream m-out  unformatted '<tr>'
    if temp.amt6 = temp.amt2 then '<td align="center"><font color="red">&#9632;</font></td>'
       else if temp.amt6 < temp.amt2 then '<td>&nbsp;</td>'
            else if (100 - (100 * temp.amt2 / temp.amt6)) <= 5 then '<td align="center"><font color="red">&#9632;</font></td>'
                 else '<td align="center"><font color="red">&#9650;</font></td>' skip.

    put stream m-out  unformatted '<td>' temp.aaa '</td>'.

    find cif where cif.cif eq temp.cif no-lock no-error.
    put stream m-out unformatted '<td>' trim(trim(cif.prefix) + " " + trim(cif.sname)) '</td>' skip.

    put stream m-out  unformatted
    if temp.amt6 >= temp.amt2 then '<td align="center">&nbsp;</td>'
       else if ((100 * temp.amt2 / temp.amt6) - 100) <= 5 then '<td align="center"><font color="blue">&#9632;</font></td>'
            else '<td align="center"><font color="blue">&#9660;</font></td>'.

    put stream m-out  unformatted '<td align="CENTER">&nbsp;' get-ppoint (temp.rko) '&nbsp;</td>'.

    if temp.crc = 1 then put stream m-out  unformatted '<td align="RIGHT">' XLS-NUMBER (temp.amt5) '</td>'.
                    else put stream m-out  unformatted '<td>  &nbsp; </td>'.
    put stream m-out  unformatted '<td align="RIGHT"> ' XLS-NUMBER (temp.amt6) '</td>' skip.

    if temp.crc = 1 then put stream m-out  unformatted '<td align="RIGHT">' XLS-NUMBER (temp.amt1) '</td>'.
                    else put stream m-out  unformatted '<td>  &nbsp; </td>'.
    put stream m-out  unformatted '<td align="RIGHT"> ' XLS-NUMBER (temp.amt2) '</td>' skip.

    if temp.crc = 1 then put stream m-out  unformatted '<td align="RIGHT">' XLS-NUMBER (temp.amt3) '</td>'.
                    else put stream m-out  unformatted '<td>  &nbsp; </td>'.
    put stream m-out unformatted '<td align="RIGHT"> ' XLS-NUMBER (temp.amt4) '</td>' skip.

    put stream m-out unformatted '<td align="RIGHT">&nbsp;' temp.addr '</td>' skip.
    put stream m-out unformatted '<td align="RIGHT">&nbsp;' temp.phones '</td>' skip.
    put stream m-out unformatted '<td align="RIGHT">&nbsp;' temp.chief '</td>' skip.

    put stream m-out unformatted '</tr>'.

    if last-of (temp.prizamt) then put stream m-out unformatted 
               '<tr bgcolor="#CDCDCD">'
               '<td align="center"> &nbsp; ' accum sub-total by temp.prizamt (temp.cntr) '</td>'
               '<td> &nbsp; </td>'
               '<td> ' if temp.prizamt = "1" then 'С ОБОРОТАМИ </td>' else 'БЕЗ ОБОРОТОВ </td>' 
               '<td align="center"> &nbsp; ' accum sub-total by temp.prizamt (temp.cntl) '</td>' skip
               '<td>&nbsp;</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt5)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt6)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt1)) '</td>' skip
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt2)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt3)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.prizamt (temp.amt4)) '</td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '</tr>' skip
               '<tr><td colspan= "11"> &nbsp; </td>' skip.

    if last-of (temp.crc) then put stream m-out unformatted 
               '<tr bgcolor="#C0C0C0">'
               '<td align="center"> &nbsp; ' accum sub-total by temp.crc (temp.cntr) '</td>'
               '<td> &nbsp; </td>'
               '<td> ИТОГО </td>' skip
               '<td align="center"> &nbsp; ' accum sub-total by temp.crc (temp.cntl) '</td>'
               '<td>&nbsp;</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt5)) '</td>' skip
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt6)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt1)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt2)) '</td>' skip
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt3)) '</td>'
               '<td align="RIGHT"> &nbsp; ' XLS-NUMBER (accum sub-total by temp.crc (temp.amt4)) '</td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '</tr>'
               '<tr><td colspan= "11"> &nbsp; </td>' skip.

end.        

put stream m-out unformatted 
               '<tr bgcolor="#C0C0C0">'
               '<td> &nbsp; ' accum total (temp.cntr) '</td>'
               '<td> &nbsp; </td>'
               '<td> ОБЩИЙ ИТОГ </td>' skip
               '<td> &nbsp; ' accum total (temp.cntl) '</td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt5)) '</td>' skip
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt6)) '</td>'
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt1)) '</td>'
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt2)) '</td>' skip
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt3)) '</td>'
               '<td> &nbsp; ' XLS-NUMBER (accum total (temp.amt4)) '</td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '<td> &nbsp; </td>'
               '</tr>' skip.


put stream m-out unformatted "</table>".

{html-end.i "stream m-out"}

output stream m-out close.

if not g-batch then do:
    pause 0 before-hide.                  
    unix silent cptwin rpt.html excel.
    pause before-hide.
end.
