/* r-deljl.p
 * MODULE
	Внутренний аудит
 * DESCRIPTION
	Формирование списка удаленных транзакций за указанную дату
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-6-3-2 
 * AUTHOR
        30.12.2003 valery
 * CHANGES
        07/05/2004 madiar - добавил вывод причины удаления транзакции deljh.del
*/
{global.i}

def var dt as date label "Введите дату отбора (ДД.ММ.ГГ.):".
def var v-i like deljl.jh.
def var v-crc like crc.code.
def var v-nom as int.
def var v-depart as char.
def var file1 as char format "x(20)".
def var v-dat as date.
DEF var dd AS int .
DEF var mm AS int .
DEF var yy AS int.
def var v-m as date.
def var reason_str as char.

def temp-table t-table
  field dtTime as char
  field nomer like deljl.jh
  field AccGl like deljl.gl
  field acc like deljl.acc
  field dam like deljl.dam
  field cam like deljl.cam
  field rem as char
  field crc like v-crc
  field ispl as char
  field dep as char
  field reason as char.

{get-dep.i}

set dt.

v-dat = g-today .
dd = day(v-dat) .
mm = month(v-dat) .
yy = year(v-dat) .
file1 = "30days" + string(dd,"99") + string(mm,"99") + string(yy,"9999" + ".html") .
display "......Ж Д И Т Е ......."  with row 12 frame ww centered .
pause 0 .

output to value(file1).

{html-title.i}

find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">Удаленные транзакции за " dt ".</br>Время создания: " + string(time,"HH:MM:SS") + "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
put unformatted
      "<TR align=""center"" style=""font:bold;background:deepskyblue "">" skip
	"<TD>Дата, время</TD>" skip
        "<TD>Номер транзакции</TD>" skip
        "<TD>Сч. гл. книги</TD>" skip
        "<TD>Счет</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>Содержание</TD>" skip
        "<TD>Вал.</TD>" skip
        "<TD>Исполнитель</TD>" skip
        "<TD>Департамент</TD>" skip
        "<TD>Причина удаления</TD>" skip
        "</TR>" skip.


for each deljl where (deljl.jdt = dt) no-lock by deljl.jh. 

v-nom = get-dep(entry(3,deljl.bywho," "), deljl.jdt).
find first ppoint where ppoint.depart = v-nom no-lock no-error.
if avail ppoint then do:
   v-depart = ppoint.name.
end.
v-nom = integer(entry(1,deljl.bywho," ")).
find crc where crc.crc = v-nom use-index crc no-lock no-error.
if  avail crc then do:
    v-crc = crc.code.
end.

find first deljh where deljh.jh = deljl.jh no-lock no-error.

	find last ofcprofit where  ofcprofit.ofc = entry(3,deljl.bywho," ") and ofcprofit.regdt <= v-m  use-index ofcreg no-lock no-error.
 	if not avail ofcprofit then do:
 		find first ofcprofit where ofcprofit.ofc = entry(3,deljl.bywho," ") use-index ofcreg no-lock no-error.
	end.
	  find first codfr where codfr.code = ofcprofit.profitcn and codfr.codfr = 'sproftcn' no-lock no-error.
            if avail codfr then v-depart = codfr.name[1].
			   else v-depart = ''.  
					        create t-table.
						assign t-table.dtTime = string(deljl.jdt) + " " + string(deljl.bytim ,"HH:MM:SS")
   							t-table.nomer = deljl.jh
							t-table.AccGl = deljl.gl
							t-table.acc = deljl.acc
							t-table.dam = deljl.dam
							t-table.cam = deljl.cam
							t-table.rem = deljl.rem[1] 
							t-table.crc = v-crc
							t-table.ispl = entry(3,deljl.bywho," ")
 						    t-table.dep = v-depart
 						    t-table.reason = deljh.del.



end.

v-i = 1.
for each t-table no-lock break by nomer.

reason_str = "".

if  first-of(nomer) then do:
  v-i = - v-i.
  reason_str = t-table.reason.
end.

put  unformatted "<tr valign=top style=""background:" if v-i = 1 then "lightyellow" else "white" """>" skip.

	put unformatted
		"<td>" t-table.dtTime "</td>" skip
		"<td>" t-table.nomer "</td>" skip 
		"<td>" t-table.AccGl  "</td>" skip
 		"<td>" if t-table.acc = '' then '&nbsp;' else t-table.acc "</td>" skip
		"<td align=right>" t-table.dam format "z,zzz,zzz,zzz,zz9.99" "</td>" skip
		"<td align=right>" t-table.cam format "z,zzz,zzz,zzz,zz9.99" "</td>" skip
		"<td>" t-table.rem "</td>" skip
		"<td>" t-table.crc "</td>" skip
		"<td>" t-table.ispl "</td>" skip
		"<td>" t-table.dep "</td>" skip
		"<td>" reason_str "</td></tr>" skip.


end.

put unformatted "</table>" skip.



{html-end.i " "}



output close . 
hide frame ww . 
hide all.
unix silent cptwin value(file1) iexplore.
