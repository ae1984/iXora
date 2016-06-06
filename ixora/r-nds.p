/* r-nds.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Расчет НДС с заключительными проводками при закрытии месяца
 * RUN
        
 * CALLER
        dayclose.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        31.05.2001  
        30.07.2001 
        28.11.2002
        01.08.2003 nadejda - добавила вывод в файл названия филиала
        01.01.2004 nadejda - обработка отсутствия остатка по ГК (для первого расчета)
                             изменила ставку НДС - брать из sysc
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	27/07/2005 u00121 ТЗ ї 87 от 26/07/2005 строка Общий доход расчитывается за минусом счетов 470300,490000,492110
	15/09/2005 u00121 добавил к предыдущему ТЗ от 27/07/05 ї 87, чтобы проверял еще и на итоговый счет т.к. указанный счет может быть итоговым и тогда в отчет сумма не попадет
	02.11.2005 u00121 добавил второе поле примечания, т.к. изменился шаблон vnb0010
	25.07.2006 u00121 добавил обработку счета 435000 при расчете Общего дохода, по просьбе Ирины Ли
        10/10/06   marinav - убран update trxbal.pdam. Это делается в dcls27.
*/

{lgps.i}

def var gl-dox like gl.gl extent 2.
def var gl-nds like gl.gl.
def var arp-nds like arp.arp extent 2.
def var s-dox like glbal.bal /*as decimal*/ extent 11 init 0.
def var v-dam like glbal.dam extent 2 init 0.
def var v-cam like glbal.dam extent 2 init 0.
define variable rcode as integer.
define variable rdes as character.
define variable mes as character extent 12 init
       ["январь","февраль","март","апрель","май","июнь","июль",
        "август","сентябрь","октябрь","ноябрь","декабрь"].
define variable v-par as character.
define variable v-jh like jh.jh extent 3.
define shared variable g-today as date.
define shared variable doxnds as decimal.
define shared variable nds as decimal.
define shared variable s-target as date.



def temp-table wgl
    field gl like gl.gl.

def var ii as integer.
def var rr as char.
def var v-sum as decimal.


def stream m-log.

define stream m-out.
output stream m-out to nds2.pro.

def var v-nds% as decimal init 0.16.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then 
	v-nds% = sysc.deval.

find first cmp no-lock no-error.
	put stream m-out cmp.name skip(1).

put stream m-out ' Протокол расчета НДС за '  trim(mes[month(g-today)]) string(year(g-today)) format 'x(4)' ' года' skip 
'            (в тенге)'skip(1).

/* 1. доход */
find sysc where sysc.sysc = 'nds1' no-lock no-error.
if not avail sysc  then 
do.
	put stream  m-out "Не определен итоговый счет доходов (запись nds1) "
	"в таблице SYSC " skip .
	return.
end.

gl-dox[1] = sysc.inval.
find glbal where glbal.gl   eq  gl-dox[1] and glbal.crc  eq  1 no-lock no-error.
if not avail glbal  then 
do.
	put stream  m-out "Не найден остаток счета " string(gl-dox[1]) 
	" в таблице GLBAL " skip .
	return.
end.
s-dox[1] = glbal.bal.

/* 2. курсовая от переоценки инвалюты */
find sysc where sysc.sysc = 'nds2' no-lock no-error.
if not avail sysc  then 
do.
	put stream  m-out "Не определен счет курсовой от переоценки инвалюты "
	"(запись nds2) в таблице SYSC " skip .
	return.
end.

gl-dox[2] = sysc.inval.
find glbal where glbal.gl   eq  gl-dox[2] and glbal.crc  eq  1 no-lock no-error.
if not avail glbal  then 
do.
	put stream  m-out "Не найден остаток счета " string(gl-dox[2])
	" в таблице GLBAL " skip .
	return.
end.
s-dox[2] = glbal.bal.



def var s-doxD like glbal.bal extent 4 init 0. /*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005*/
def var s-doxK like glbal.bal extent 4 init 0. /*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005*/

for each jh no-lock where jh.jdt eq g-today and jh.post eq false, each jl no-lock of jh where jl.crc = 1.
	find last gl of jl no-lock no-error.
	if gl.type eq 'r' then 
	do.
		v-dam[1] = v-dam[1] + jl.dam.
		v-cam[1] = v-cam[1] + jl.cam.
		if gl.gl = gl-dox[2] then 
		do.
			v-dam[2] = v-dam[2] + jl.dam.
			v-cam[2] = v-cam[2] + jl.cam.
		end.
		if gl.totgl = 470300 or gl.gl = 470300 then /*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005*/ /*u00121 15/09/2005 добавил. чтобы проверял еще и на итоговый счет
													т.к. указанный счет может быть итоговым и тогда в отчет сумма не попадет*/
		do:
			s-doxD[1] = s-doxD[1] + jl.dam.
			s-doxK[1] = s-doxK[1] + jl.cam.
		end.
		if gl.totgl = 490000 or gl.gl = 490000 then /*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005*/
		do:
			s-doxD[2] = s-doxD[2] + jl.dam.
			s-doxK[2] = s-doxK[2] + jl.cam.
		end.
		if gl.totgl = 492110 or gl.gl = 492110 then /*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005*/
		do:
			s-doxD[3] = s-doxD[3] + jl.dam.
			s-doxK[3] = s-doxK[3] + jl.cam.
		end.

		if gl.totgl = 435000 or gl.gl = 435000 then /*u00121 25/07/2006*/
		do:
			s-doxD[4] = s-doxD[4] + jl.dam.
			s-doxK[4] = s-doxK[4] + jl.cam.
		end.

	end.
end.     


s-dox[1] = s-dox[1] + v-cam[1] - v-dam[1].
s-dox[2] = s-dox[2] + v-cam[2] - v-dam[2].

v-sum = 0.
find last glday where glday.gl eq gl-dox[1] and glday.crc eq 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
if avail glday  then 
	v-sum = glday.bal.

/* если месяц не январь */
if month(g-today) ne 1 then 
	s-dox[1] = s-dox[1] - v-sum.


/*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005******************************************************************************************************************************/
output stream m-log to nds2.log.
def var gl-iskl1 like glbal.bal extent 2 init 0. /*Сюда сохраняется сумма баланса на начало и конец месяца по счету 470300 - "Доходы от переоценки иностранной валюты"*/
def var gl-iskl2 like glbal.bal extent 2 init 0. /*Сюда сохраняется сумма баланса на начало и конец месяца по счету 490000 - "Штрафы, пени, неустойки"                */
def var gl-iskl3 like glbal.bal extent 2 init 0. /*Сюда сохраняется сумма баланса на начало и конец месяца по счету 492110 - "Излишне созданные провизии"             */
def var gl-iskl4 like glbal.bal extent 2 init 0. /*25.07.2006 u00121 Сюда сохраняется сумма баланса на начало и конец месяца по счету 435000 - "Расчеты с филиалами"  */

        /*************************************************************************************************************************************/
	/*Остаток на конец месяца по счету*/
	find glbal where glbal.gl = 470300 and glbal.crc = 1 no-lock no-error.
	if not avail glbal  then 
	do.
		put stream  m-out "Не найден остаток счета 470300 в таблице GLBAL " skip .
		return.
	end.
	gl-iskl1[1] = glbal.bal + (s-doxK[1] - s-doxD[1]).
	put stream  m-log unformatted "Остаток на конец месяца " + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 470300 " + string(gl-iskl1[1]) skip.
	/*Остаток на начало месяца*/
	find last glday where glday.gl = 470300 and glday.crc = 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
	if avail glday  then 
		gl-iskl1[2] = glday.bal.
	put stream  m-log unformatted  "Остаток на начало месяца "  + string(month(g-today)) + "/" + string(year(g-today)) + " по счету 470300 " + string(gl-iskl1[2]) skip.
		
        /*************************************************************************************************************************************/

        /*************************************************************************************************************************************/
	/*Остаток на конец месяца по счету*/
	find glbal where glbal.gl = 490000 and glbal.crc = 1 no-lock no-error.
	if not avail glbal  then 
	do.
		put stream  m-out "Не найден остаток счета 490000 в таблице GLBAL " skip .
		return.
	end.
	gl-iskl2[1] = glbal.bal + (s-doxK[2] - s-doxD[2]).
	put stream  m-log unformatted  "Остаток на конец месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 490000 "  + string(gl-iskl2[1]) skip.
	/*Остаток на начало месяца*/
	find last glday where glday.gl = 490000 and glday.crc = 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
	if avail glday  then 
		gl-iskl2[2] = glday.bal.
	put stream  m-log  unformatted "Остаток на начало месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 490000 "  + string(gl-iskl2[2]) skip.
        /*************************************************************************************************************************************/

        /*************************************************************************************************************************************/
	/*Остаток на конец месяца по счету*/
	find glbal where glbal.gl = 492110 and glbal.crc = 1 no-lock no-error.
	if not avail glbal  then 
	do.
		put stream  m-out "Не найден остаток счета 492110 в таблице GLBAL " skip .
		return.
	end.
	gl-iskl3[1] = glbal.bal + (s-doxK[3] - s-doxD[3]).
	put stream  m-log  unformatted "Остаток на конец месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 492110 "  + string(gl-iskl3[1]) skip.
	/*Остаток на начало месяца*/
	find last glday where glday.gl = 492110 and glday.crc = 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
	if avail glday  then 
		gl-iskl3[2] = glday.bal.
	put stream  m-log  unformatted "Остаток на начало месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 492110 "  + string(gl-iskl3[2]) skip.
        /*************************************************************************************************************************************/

        /*25.06.2006 u00121*******************************************************************************************************************/
	/*Остаток на конец месяца по счету*/
	find glbal where glbal.gl = 435000 and glbal.crc = 1 no-lock no-error.
	if not avail glbal  then 
	do.
		put stream  m-out "Не найден остаток счета 435000 в таблице GLBAL " skip .
		return.
	end.
	gl-iskl4[1] = glbal.bal + (s-doxK[4] - s-doxD[4]).
	put stream  m-log  unformatted "Остаток на конец месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 435000 "  + string(gl-iskl4[1]) skip.
	/*Остаток на начало месяца*/
	find last glday where glday.gl = 435000 and glday.crc = 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
	if avail glday  then 
		gl-iskl4[2] = glday.bal.
	put stream  m-log  unformatted "Остаток на начало месяца "  + string(month(g-today)) + "/"  + string(year(g-today)) + " по счету 435000 "  + string(gl-iskl4[2]) skip.
        /*************************************************************************************************************************************/

	/*Общий доход = Общий доход - Разница балансов на конец и начало месяца по 470300 - Разница балансов на конец и начало месяца по 490000 - Разница балансов на конец и начало месяца по 492110 - Разница балансов на конец и начало месяца по 435000*/
 	put stream  m-log  unformatted "Общий доход = " + string(s-dox[1]) + " - " 
 							+ string((gl-iskl1[1] - gl-iskl1[2])) + " - " 
 							+ string((gl-iskl2[1] - gl-iskl2[2])) + " - "  
 							+ string((gl-iskl3[1] - gl-iskl3[2])) + " - "  
 							+ string((gl-iskl4[1] - gl-iskl4[2])) skip.

	s-dox[1] = s-dox[1] 	- (gl-iskl1[1] - gl-iskl1[2]) 
				- (gl-iskl2[1] - gl-iskl2[2]) 
				- (gl-iskl3[1] - gl-iskl3[2]) 
				- (gl-iskl4[1] - gl-iskl4[2]).

	put stream  m-log  unformatted "Общий доход = " + string(s-dox[1]).
output stream m-log close.
/*u00121 27/07/2005 ТЗ ї 87 от 26/07/2005******************************************************************************************************************************/




v-sum = 0.
find last glday where glday.gl eq gl-dox[2] and glday.crc eq 1 and glday.gdt lt date(month(g-today),1,year(g-today)) no-lock  no-error.
if avail glday  then 
	v-sum = glday.bal.

s-dox[2] = v-sum - s-dox[2].

/* 3. списание основных средств */
find sysc where sysc.sysc = 'nds3' no-lock no-error.
if not avail sysc  then 
do.
	put stream  m-out "Не определены счет по списанию ОС (запись nds3) "
	"в таблице SYSC " skip .
	return.
end.

ii = 0.
repeat on error undo,leave:
	ii = ii + 1.
	rr = "".
	rr = entry(ii,sysc.chval) no-error.
	if rr = "" or rr = ? then leave.
	create wgl.
	wgl.gl = integer(rr).
end.     

for each wgl.
	for each jl where jl.jdt ge date(month(g-today),1,year(g-today)) and jl.crc = 1 and jl.gl = wgl.gl and jl.trx = 'ast0006' no-lock.
		s-dox[3] = s-dox[3] + jl.dam.
	end.
end.

put stream m-out ' 1. Стоимость списанных ОС                     ' 
	s-dox[3] format 'z,zzz,zzz,zz9.99' skip.

/* 4. общий доход */
s-dox[4] = s-dox[1].
put stream m-out ' 2. Общий доход                                '
	s-dox[4] format 'z,zzz,zzz,zz9.99' skip.

/* 5. облагаемый доход */
s-dox[5] = doxnds - nds.
put stream m-out ' 3. Облагаемый доход                           '
	s-dox[5] format 'z,zzz,zzz,zz9.99' skip.

/* 6. НДС полученный */
put stream m-out ' 4. НДС полученный                             '
	nds      format 'z,zzz,zzz,zz9.99' skip.



/* 7. удельный вес */
s-dox[7] = round(s-dox[5] / s-dox[4] * 100,2).
put stream m-out ' 5. Уд.вес облагаемого оборота(%)              '
	s-dox[7]  format 'z,zzz,zzz,zz9.99' skip.

/* 8. НДС уплаченный */
find sysc where sysc.sysc = 'nds4' no-lock no-error.
if not avail sysc  then 
do.
	put stream  m-out "Не определены счета НДС "
		"(запись nds4) в таблице SYSC " skip .
	return.
end.

ii = 0.
repeat on error undo,leave:
	ii = ii + 1.
	rr = "".
	rr = entry(ii,sysc.chval) no-error.
	if rr = "" or rr = ? then leave.
	if ii = 1 then 
		gl-nds = integer(rr).
	else 
		if ii = 2 then 
			arp-nds[1] = rr.
		else 
			arp-nds[2] = rr.
end.

find arp where arp.arp = arp-nds[1] no-lock no-error.
if not avail arp then 
do.
	put stream  m-out "Не найден счет-карточка ARP для НДС " skip .
	return.
end.


s-dox[8] = arp.dam[1] - arp.cam[1].
put stream m-out ' 6. НДС уплаченный                             '
	s-dox[8] format 'z,zzz,zzz,zz9.99' skip.



put stream m-out '   коррект. суммы зачета НДС (порча, списан)  '
	v-nds% * s-dox[3] * (-1)  format '->,>>>,>>>,>>9.99' skip.

s-dox[6] = s-dox[8] + v-nds% * s-dox[3] * (-1).
put stream m-out '   всего зачет                                '
	s-dox[6]  format '->,>>>,>>>,>>9.99' skip.



/* 9. НДС по удельному весу */
s-dox[9] = round((s-dox[8] + v-nds% * s-dox[3] * (-1)) * s-dox[7] / 100,2).
put stream m-out ' 7. НДС  по удельному весу                     '
	s-dox[9] format 'z,zzz,zzz,zz9.99' skip.

/* 10. НДС на смету */
s-dox[10] = (s-dox[8] - v-nds% * s-dox[3]) - s-dox[9].
put stream m-out ' 8. НДС на смету                               '
	s-dox[10] format 'z,zzz,zzz,zz9.99' skip.

/* 11. НДС в бюджет */
s-dox[11] = nds - s-dox[9].
put stream m-out ' 9. НДС в бюджет                              '
	s-dox[11] format '-z,zzz,zzz,zz9.99' skip.

/* 12. Проводки */
put stream m-out '10. Проводки ' skip(1)
	'NN  Назначение платежа   Транз.    Дебет     Кредит         Сумма ' skip(1). 


/* 12-1. НДС по списанным ОС */ 
if s-dox[3] <> 0 then 
do.
	v-par = string(v-nds% * s-dox[3])  + "^" +  "1" + "^" + string(gl-nds) + "^" + arp-nds[1] + "^" + "НДС по списанным ОС за " + mes[month(g-today)] + " месяц " + string(year(g-today)) + " года".

	run trxgen("vnb0002","^",v-par,"","",output rcode,output rdes, input-output v-jh[1]).

	if rcode <> 0 then 
	do :
		put stream m-out  " Ошибка 1 проводки (НДС по списанным ОС) " rcode skip.
		put stream m-out rdes format 'x(70)' skip  .
		return .
	end.
	put stream m-out "1. НДС по списанным ОС " v-jh[1] '    ' string(gl-nds) '  ' arp-nds[1] (v-nds% * s-dox[3]) format 'z,zzz,zzz,zz9.99' skip.
	do:
		find jh where jh.jh = v-jh[1] exclusive-lock.
		jh.sts = 6.
		for each jl where jl.jh = jh.jh exclusive-lock:
			jl.sts = 6.
		end.
	end.
end.

/* 12-2. НДС на смету */

v-par = string(s-dox[10])  + "^" + "1" + "^" + string(gl-nds) + "^" + arp-nds[1] + "^" + "НДС на смету за " + mes[month(g-today)] + " месяц " + string(year(g-today)) + " года".

run trxgen("vnb0002","^",v-par,"","",output rcode,output rdes, input-output v-jh[2]).
if rcode <> 0 then 
do :
	put stream m-out  " Ошибка 2 проводки (НДС на смету) " rcode  skip.
	put stream m-out rdes format 'x(70)' skip  .
	return .
end.

put stream m-out "2. НДС на смету        " v-jh[2] '    ' string(gl-nds) arp-nds[1] s-dox[10]      format 'z,zzz,zzz,zz9.99' skip.

do:
	find jh where jh.jh = v-jh[2] exclusive-lock.
	jh.sts = 6.
	for each jl where jl.jh = jh.jh exclusive-lock:
		jl.sts = 6.
	end.
end.
/* 12-3. Перенос сальдо */

for each arp where arp.arp = arp-nds[2] no-lock:
	if arp.cam[1] - arp.dam[1] - s-dox[9] < 0 then 
	do:
		s-dox[9] = arp.cam[1] - arp.dam[1].
	end.
end.    

v-par = string(s-dox[9])  + "^" + arp-nds[2] + "^" + arp-nds[1] + "^" + "Перенос сальдо за " + mes[month(g-today)] + " месяц " + string(year(g-today)) + " года" + "^" + "". /*02.11.2005 u00121 добавил второе поле примечания, т.к. изменился шаблон*/

run trxgen("vnb0010","^",v-par,"","",output rcode,output rdes, input-output v-jh[3]).
if rcode <> 0 then 
do :
	put stream m-out  " Ошибка 3 проводки (Перенос сальдо) " rcode skip.
	put stream m-out rdes format 'x(70)' skip.
	return .
end.

put stream m-out "3. Перенос сальдо      " v-jh[3] ' ' arp-nds[2]     ' ' arp-nds[1] s-dox[9]       format 'z,zzz,zzz,zz9.99' skip.
do:
	find jh where jh.jh = v-jh[3] exclusive-lock.
	jh.sts = 6.
	for each jl where jl.jh = jh.jh exclusive-lock:
		jl.sts = 6.
	end.
end.

put stream m-out skip(2)
"  Менеджер      ________________     "
"  Контролер     ________________      " skip.
output stream m-out close.

/* 12.3  Учет сделанных транзакций по карточкам ARP в таблице TRXBAL */

/*  10/10/06   marinav

def buffer b-trxbal for trxbal.
for each trxbal where trxbal.acc = arp-nds[1] or trxbal.acc = arp-nds[2] no-lock :
	if trxbal.dam ne trxbal.pdam or trxbal.cam ne trxbal.pcam then 
	do:
		find b-trxbal where recid(b-trxbal) eq recid(trxbal) exclusive-lock.
		b-trxbal.pdam = b-trxbal.dam.
		b-trxbal.pcam = b-trxbal.cam.
	end.
end.        
*/