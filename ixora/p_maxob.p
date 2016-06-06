/* r-maxob.p
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        PUSH-отчет по оборотам клиентов
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
        30/03/05 sasco
 * CHANGES
        06/04/05 sasco Добавил вывод названия подразделения (ppoint) вместо номера
        03/07/06 u00121 - добавил опцию no-undo во все переменные и временные таблици
*/

/*
   #9632 - квадрат
   #9650 - пирамида вверх
   #9660 - пирамида вниз
   
*/

{global.i}
{push.i}

{get-ppoint.i}

vres = no.

{gl-utils.i}

def stream m-out.
def var v-dat      as date	no-undo.
def var fdate      as date	no-undo.
def var tdate      as date	no-undo.
def var amt1       as deci	no-undo.
def var oldcrc     as deci initial 0	no-undo.
def var ii         as deci initial 0	no-undo.
def var oldval     as char	no-undo.
def var kolm       as deci initial 1	no-undo.
def var v-cam like jl.cam	no-undo.
def var v-camo like jl.cam	no-undo.

define variable vpoint as int	no-undo.
define variable vdep as int	no-undo.


define variable d0 as date	no-undo.
define variable d1 as date	no-undo.

define variable maxc as int initial 0	no-undo.
define variable curc as int initial 0	no-undo.


def temp-table temp no-undo
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
    field prizamt as character initial "2"
    index idx_tmp is primary crc prizamt amt1.    
 

v-dat = vd1.

if month(v-dat) > 1 then 
do:
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

for each aaa no-lock where aaa.gl = 220310:
    if aaa.sta = "C" then next.
    maxc = maxc + 1.
end.

find last crchis where crchis.rdt le tdate and crchis.crc = 2 no-lock no-error.

oldcrc = 0.
for each aaa where  aaa.sta <> 'C' and   aaa.gl = 220310  no-lock use-index gl break by aaa.crc :

    find cif where cif.cif = aaa.cif no-lock no-error.
    if not avail cif then next.

    curc = curc + 1.

    /* выберем юридические... */
    find first sub-cod where  sub-cod.d-cod = 'clnsts' and  sub-cod.ccode = '0' and  sub-cod.sub   = 'cln' and sub-cod.acc   = string( aaa.cif )  no-lock no-error.
    if not avail sub-cod then next.
    
    /* пропустим исключения... */
    find first sub-cod where sub-cod.d-cod = 'clndop' and sub-cod.sub   = 'cln' and  sub-cod.acc   = string( aaa.cif ) no-lock no-error.
    if avail sub-cod and sub-cod.ccode = '1' then next.
    
    find crc where crc.crc eq aaa.crc no-lock no-error.
    find crc-new where crc-new.crc eq aaa.crc no-lock no-error.
    
    v-cam = 0.
    v-camo = 0.

    for each jl where jl.jdt ge fdate and jl.jdt le tdate  and jl.acc = aaa.aaa and jl.gl = aaa.gl no-lock.
        if not(jl.rem[1] begins 'O/D protect') and not(jl.rem[1] begins 'O/D payment')
           then do:
                v-cam = v-cam + jl.cam.
                if jl.jdt >= d0 and jl.jdt <= d1 then v-camo = v-camo + jl.cam.
           end.
    end.
    if v-cam / kolm < crc-new.max-ob then next.
    
    create temp.
    assign
	    temp.aaa  = aaa.aaa
	    temp.cif  = aaa.cif
	    temp.crc  = crc.crc
	    temp.code = crc.code.
    if temp.crc = 1 then do:
       temp.amt1 = round(v-cam / kolm / 1000,0) .
       temp.amt2 = round(v-cam / kolm / crchis.rate[1] / 1000,2) .
       temp.amt3 = round(v-cam / 1000,0) .
       temp.amt4 = round(v-cam / crchis.rate[1] / 1000,2) .
       temp.amt5 = round (v-camo / 1000, 0).
       temp.amt6 = round (v-camo / 1000 / crchis.rate[1], 0).
    end.
    else do:
	    temp.amt1 = 0.
	    temp.amt2 = round(v-cam / kolm / 1000,2) .
	    temp.amt3 = 0.
	    temp.amt4 = round(v-cam / 1000,2) .                
	    temp.amt5 = 0.
	    temp.amt6 = round (v-camo / 1000, 0).
    end.    
    if temp.amt5 <> 0 or temp.amt6 <> 0 then temp.prizamt = "1".

    if cif.jame <> '' then do :
       vpoint =  integer(cif.jame) / 1000 - 0.5 .
       vdep = integer(cif.jame) - vpoint * 1000.
    end. else do :
      find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
      vpoint = ofchis.point. 
      vdep = ofchis.dep.
    end.
    temp.rko = vdep.

end.                                                                             



output stream m-out to value(vfname).

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
'</TR>' skip.

put stream m-out unformatted 
'<tr align="center" bgcolor="#C0C0C0">'
'<td> тыс.тг. </td><td> тыс.$. </td>'
'<td> тыс.тг. </td><td> тыс.$. </td>'
'<td> тыс.тг. </td><td> тыс.$. </td>'
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
               '</tr>' skip.


put stream m-out unformatted "</table>".

{html-end.i "stream m-out"}

output stream m-out close.

vres = yes.

