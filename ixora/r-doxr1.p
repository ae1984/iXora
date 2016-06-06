/* r-doxr1.p
 * MODULE
        Доходы - расходы
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        
 * SCRIPT
	r-brfilial.i
 * INHERIT
        r-doxras.p
 * MENU
        8-9-1-16-2
 * AUTHOR
        04.10.2004 u00121
 * CHANGES
	04.10.2004 u00121 - отчет переделан для консолидации, возможен выбор отдельно по фелиалам
	04.08.2006 u00121 - добавлены no-undo, добавлены индексы во временные таблицы (время формирования консолидированного отчета при load averages ~16 равно 26 сек.)
*/

{global.i}
{functions-def.i}
{u-2-d.p}

def var hostmy   as char format 'x(15)' no-undo.
def var ipaddr   as char format 'x(15)' no-undo.

def new shared temp-table r5922Temp no-undo
	field kod like codfr.code
	field name like codfr.name[1]
	field dan like r5922.dan
	index idx0-r5922Temp dan.


def var      ii         as decimal init 0 no-undo.
def var      a1         as decimal no-undo.
def var      a2         as decimal no-undo.
def var      a3         as decimal no-undo.
def var      a4         as decimal no-undo.
def var      b1         as decimal no-undo.
def new shared var      b11         as decimal no-undo.
def new shared var      a11         as decimal no-undo.

def new shared stream   m-out .
def new shared stream   r-err .
def new shared stream   m-xls .
def new shared var prz as deci no-undo.

def new shared var date1 as date no-undo.
def new shared var date2 as date no-undo.

def buffer   a-cls      for bank.cls.
def buffer   b-cls      for bank.cls.

def new shared var      v-dat      as date no-undo.
def var v-today as date no-undo.


/******************Основной temp-файл*******************/
def new shared temp-table temp  no-undo
    field pr    as char format 'x(1)'
    field kl    like sub-cod.ccode
    field gl    like gl.gl
    field gl1   like gl.gl
    field des   like gl.des
    field amt1  as deci 
    field amt2  as deci 
    field amt3  as deci 
    field amt4  as deci
    index idx0-temp pr kl gl .

def temp-table temp_itog no-undo
    field pr    as char format 'x(1)'
    field kl    like sub-cod.ccode
    field gl    like gl.gl
    field gl1   like gl.gl
    field des   like gl.des
    field amt1  as deci 
    field amt2  as deci 
    field amt3  as deci 
    field amt4  as deci 
    index idx0-temp_itog gl gl1
    index idx1-temp_itog pr kl gl1.

/*******************************************************/

/* если файл не пуст... */
   def var  iii    as integer no-undo.  
   def var  rr     as char no-undo.
   def var  rr1    as char no-undo.
   def var  sumd2  as deci no-undo.
   def var  sumd4  as deci no-undo.
   def var  sumd21 as deci no-undo.
   def var  sumd41 as deci no-undo.
   def var  sumr2  as deci no-undo.
   def var  sumr4  as deci no-undo.

   def temp-table temp1  no-undo
       field   i-gl  like gl.gl
       field   z-gl  like gl.gl
       index idx0-temp1 i-gl.
   	
   def temp-table temp2 no-undo
       field   pr    as char format 'x(1)'
       field   kl    like sub-cod.ccode
       field   gl1   like gl.gl
       field   des   like gl.des
       field   amt2  as deci
       field   amt4  as deci 
       index idx0-temp2 pr kl gl1.
/************************/


/****************************************************************************************************************************************/
/*******************************************************  дата отчета *******************************************************************/
/****************************************************************************************************************************************/
find last bank.cls no-lock no-error.
v-today = if available bank.cls then bank.cls.cls + 1 else today.
v-dat = date(month(v-today),1,year(v-today)).
update v-dat label ' Укажите дату (первое число месяца)' format '99/99/9999'          validate(v-dat ge 02/01/2000 and v-dat le v-today,
       "Дата должна быть в пределах от 01/02/2000 до текущего дня")
       skip with side-label row 5 centered frame dat .
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

/* последний закрытый день месяца */ 
find last a-cls where a-cls.whn lt v-dat no-lock no-error.
if available cls then date1 = a-cls.whn.

/* последний закрытый день предыдущего месяца */
find last b-cls where b-cls.whn lt date(month(date1),1,year(date1))        no-lock no-error.
if available cls then date2 = b-cls.whn.



/****************************************************************************************************************************************/
/******************************************************* форма отчета *******************************************************************/
/****************************************************************************************************************************************/
def button  btn1  label "Вспомогательная форма".
def button  btn2  label "Окончательная форма  ".
def button  btn3  label "Выход ".
def frame   frame1 skip(1) btn1 btn2 btn3 with centered title "Сделайте выбор:" row 5 .

on choose of btn1,btn2,btn3 do:
   if self:label = "Вспомогательная форма" then prz = 1.
   else
     if self:label = "Окончательная форма  " then prz=2.
     else prz = 3.
end.
enable all with frame frame1.
wait-for choose of btn1, btn2, btn3.
if prz = 3 then return.
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/


/****************************************************************************************************************************************/
/******************************************************* Вид отчета *********************************************************************/
/************************************************ консолидированный/раздельный **********************************************************/
output stream m-out to rpt.img.
output stream r-err to err.img.

{r-brfilial.i &proc = "r-doxras"}
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

for each temp no-lock .
	find last temp_itog where temp_itog.gl = temp.gl and temp_itog.gl1 = temp.gl1 no-error.
	if not avail temp_itog then do:
		create temp_itog.
		assign
                 temp_itog.pr	= temp.pr
                 temp_itog.kl   = temp.kl 
                 temp_itog.gl   = temp.gl
                 temp_itog.gl1  = temp.gl1
                 temp_itog.des  = temp.des
                 temp_itog.amt1 = temp.amt1
                 temp_itog.amt2 = temp.amt2
                 temp_itog.amt3 = temp.amt3
                 temp_itog.amt4 = temp.amt4.
	end.	
	else
	do:
		assign
                 temp_itog.pr	= temp.pr
                 temp_itog.kl   = temp.kl
                 temp_itog.des  = temp.des
                 temp_itog.amt1 = temp_itog.amt1 + temp.amt1
                 temp_itog.amt2 = temp_itog.amt2 + temp.amt2
                 temp_itog.amt3 = temp_itog.amt3 + temp.amt3
                 temp_itog.amt4 = temp_itog.amt4 + temp.amt4.
	end.
end.


find last crchis where rdt le date1 and crc = 2 no-lock no-error.
/********************************************************************************************************************************************************/
/* если файл не пуст... */
find first temp_itog no-lock no-error.
if avail temp_itog then 
do: /* поиск счетов, кот. не показываются отд.строчками, а вливаются в др.счета */
	/****************************************************************/
	find sysc where sysc.sysc = 'gldr'  no-error . /* Бал.счета для группировки Д-Р*/
	if avail sysc then 
	do:
		iii = 0.
		repeat on error undo, leave:
			iii = iii + 1.
			rr = "".
			rr = entry(iii,sysc.chval) no-error. /*вырезаем очередной счет из списка*/
			if rr = "" or rr = ? then leave. /*если пустой "счет" - выходим*/
			if iii modulo 2 <> 0 then 
			do:
				create temp1.
				temp1.i-gl = integer(rr).
				rr1 =rr.
			end.
			else 
			do:
				find first temp1 where temp1.i-gl = integer(rr1) no-lock no-error.
				if avail temp1 then temp1.z-gl = integer(rr).
			end.
		end.
	end. /*if avail sysc*/
	/****************************************************************/

	/****************************************************************/
	for each temp1 no-lock.  /* замена счетов */
		find first temp_itog where temp_itog.gl = temp1.i-gl no-lock no-error.
		if avail temp_itog then 
			temp_itog.gl1 = temp1.z-gl.

		find last gl where gl.gl = temp1.z-gl no-lock no-error.
		if avail gl then 
			temp_itog.des = left-trim(gl.des).
	end.
	/****************************************************************/

	/****************************************************************/
	/* печать */
	put stream m-out skip
		FirstLine( 1, 1 ) format 'x(89)' skip(1)
		'                      '
		'ДОХОДЫ И РАСХОДЫ  на ' date(month(v-dat),1,year(v-dat)) format '99.99.9999' '  г.' skip(1)
		'Курс $ '  crchis.rate[1]  format 'zzz9.99' skip(1)
		FirstLine( 2, 1 ) format 'x(89)' skip.
	put stream m-out  fill( '-', 89 ) format 'x(89)' skip.
        	if prz = 1 then 
			put stream m-out ' N  Счет     Наименование                              за месяц           нараст.итогом' 
				skip 'п/п                     статей                     в тыс.тг  в тыс.$    в тыс.тг  в тыс.$'
				skip.
		else 
			put stream m-out
				' N  Счет     Наименование                            За месяц    Нараст.итогом  Будущего' skip
				'п/п                     статей                      %%    тыс.$    %%   тыс.$   периода'
				skip.

	put stream m-out  
		fill( '-', 89 ) format 'x(89)' skip.

	/****************************************************************/
	/* вспомогательная форма */
	if prz = 1 then do.
		for each temp_itog break by temp_itog.pr by temp_itog.kl by temp_itog.gl1. /* есть счета, у кот.не проставлен классификатор kldr */
			/****************************************************************/
			if temp_itog.kl = ' ' and (amt1 <> 0 or amt3 <> 0) then 
				put stream m-out  '   ' temp_itog.gl ' ' temp_itog.des
				round(temp_itog.amt3 / 1000,2) format 'zzz,zz9.99-'
				round(temp_itog.amt4 / 1000,2) format 'zz,zz9.99-'
				round(temp_itog.amt1 / 1000,2) format 'z,zzz,zz9.99-'
				round(temp_itog.amt2 / 1000,2) format 'zzz,zz9.99-' skip.
				accum temp_itog.amt1 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
				temp_itog.amt2 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
				temp_itog.amt3 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
				temp_itog.amt4 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1).
			/****************************************************************/

			/****************************************************************/
			if first-of(temp_itog.pr) then 
			do:
				put stream m-out skip(1) space(20)
					if temp_itog.pr = '1' then 'ДОХОДЫ' else 'РАСХОДЫ' skip.
				ii = 0.
			end. 
			/****************************************************************/
		
			/****************************************************************/
			if first-of(temp_itog.kl) and temp_itog.kl ne ' ' then 
			do:
				ii = ii + 1.
				find codfr where codfr.codfr = 'kldr' and codfr.code = temp_itog.kl no-lock no-error. 
				put stream m-out skip(1) 
					ii format '99'  space (8)
					codfr.name[1] format 'x(35)' skip(1).
			end.
			/****************************************************************/

			/****************************************************************/
			if last-of(temp_itog.gl1) and temp_itog.kl ne ' ' then 
			do:
				a1 = accum total by temp_itog.gl1 temp_itog.amt3.
				a2 = accum total by temp_itog.gl1 temp_itog.amt4.
				a3 = accum total by temp_itog.gl1 temp_itog.amt1.
				a4 = accum total by temp_itog.gl1 temp_itog.amt2.
				put stream m-out  
					if a3 eq a1 and a3 <> 0 and month(date1) <> 1  then ' *' + string(temp_itog.gl1,'999999')        
					else '  ' + string(temp_itog.gl1,'999999')          
					'  '
					temp_itog.des 
					round(a1 / 1000,2) format 'zzz,zz9.99-'
					round(a2 / 1000,2) format 'zz,zz9.99-' 
					round(a3 / 1000,2) format 'z,zzz,zz9.99-'
					round(a4 / 1000,2) format 'zzz,zz9.99-' skip.
			end.
			/****************************************************************/

			/****************************************************************/
			if last-of(temp_itog.pr) then 
			do:
				a1 = accum total by temp_itog.pr temp_itog.amt3.
				a2 = accum total by temp_itog.pr temp_itog.amt4.
				a3 = accum total by temp_itog.pr temp_itog.amt1.
				a4 = accum total by temp_itog.pr temp_itog.amt2.
				put stream m-out space(10)
					'ИТОГО ' space(34)
					round(a1 / 1000,2) format 'zzz,zz9.99-'
					round(a2 / 1000,2) format 'zz,zz9.99-'
					round(a3 / 1000,2) format 'z,zzz,zz9.99-'
					round(a4 / 1000,2) format 'zzz,zz9.99-' skip(1).
			end.
			/****************************************************************/
		end.
	end. /* конец печати вспомогат.формы */
	/****************************************************************/

	/****************************************************************/
	/* окончательная форма */
	if prz = 2 then 
	do:  
		output stream m-xls to xls.img.
		put stream m-xls date(month(v-dat),1,year(v-dat)) ';' crchis.rate[1] format 'zz9.99' skip.

		/****************************************************************/	
		/* формирование temp2 */
		for each temp_itog break by temp_itog.pr by temp_itog.kl by temp_itog.gl1. /* есть счета, у кот.не проставлен классификатор kldr */     
			/****************************************************************/
			if temp_itog.kl = ' ' and (amt1 <> 0 or amt3 <> 0) then 
			do:
				put stream m-out  '   '
					temp_itog.gl ' ' 
					temp_itog.des
					round(temp_itog.amt3 / 1000,2) format 'zzz,zz9.99-'
					round(temp_itog.amt4 / 1000,2) format 'zz,zz9.99-'
					round(temp_itog.amt1 / 1000,2) format 'z,zzz,zz9.99-'
					round(temp_itog.amt2 / 1000,2) format 'zzz,zz9.99-' skip. 
				put stream m-xls ';'
					temp_itog.gl ';'
					u-2-d(temp_itog.des) ';'
					round(temp_itog.amt3 / 1000,2) format 'zzz,zz9.99-' ';'
					round(temp_itog.amt4 / 1000,2) format 'zz,zz9.99-'  ';'
					round(temp_itog.amt1 / 1000,2) format 'z,zzz,zz9.99-' ';'
					round(temp_itog.amt2 / 1000,2) format 'zzz,zz9.99-' skip.
			end.
			/****************************************************************/
			accum temp_itog.amt1 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
			temp_itog.amt2 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
			temp_itog.amt3 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1)
			temp_itog.amt4 (total by temp_itog.pr by temp_itog.kl by temp_itog.gl1).

			/****************************************************************/
			if last-of(temp_itog.gl1) and temp_itog.kl ne ' ' then 
			do:
				a1 = accum total by temp_itog.gl1 temp_itog.amt3.
				a3 = accum total by temp_itog.gl1 temp_itog.amt1.
				create temp2.
				assign
					temp2.pr = temp_itog.pr
					temp2.kl = temp_itog.kl
					temp2.gl1 = temp_itog.gl1
					temp2.des = if a3 eq a1 and a3 <> 0 and month(date1) <> 1  then '*' + temp_itog.des else temp_itog.des
					temp2.amt2 = accum total by temp_itog.gl1 temp_itog.amt4
					temp2.amt4 =  accum total by temp_itog.gl1 temp_itog.amt2
					temp2.amt2 = round(temp2.amt2 / 1000,2)
					temp2.amt4 = round(temp2.amt4 / 1000,2).

			end.
			/****************************************************************/
	
			/****************************************************************/
			if last-of(temp_itog.kl) and temp_itog.kl ne ' ' then 
			do:
				create temp2.
				assign
					temp2.pr = temp_itog.pr
					temp2.kl = temp_itog.kl
					temp2.amt2 = accum total by temp_itog.kl temp_itog.amt4
					temp2.amt4 = accum total by temp_itog.kl temp_itog.amt2
					temp2.amt2 = round(temp2.amt2 / 1000,2)
					temp2.amt4 = round(temp2.amt4 / 1000,2).
				find codfr where codfr.codfr = 'kldr' and codfr.code = temp2.kl no-lock no-error.
					temp2.des = codfr.name[1].       

				if temp2.kl = '1-' then 
				do:
					sumd21 = temp2.amt2.
					sumd41 = temp2.amt4.
				end. 
			end.
			/****************************************************************/

			/****************************************************************/
			if last-of(temp_itog.pr) then 
			do:
				a2 = accum total by temp_itog.pr temp_itog.amt4.
				a4 = accum total by temp_itog.pr temp_itog.amt2.
				if temp_itog.pr = '1' then 
				do:
					sumd2 = round(a2 / 1000,2).
					sumd4 = round(a4 / 1000,2).
				end.
				else 
				do:
					sumr2 = round(a2 / 1000,2).
					sumr4 = round(a4 / 1000,2).
				end.
			end.
			/****************************************************************/
	
		end. /* конец формирование temp2 */
		/****************************************************************/

		/****************************************************************/
		/* печать temp2 */
		for each temp2 break by temp2.pr by temp2.kl by temp2.gl1.
			/****************************************************************/
			if first-of(temp2.pr) then 
			do:
				put stream m-out skip(1) space(20)
				if temp2.pr = '1' then 'ДОХОДЫ' else 'РАСХОДЫ' skip.
					put stream m-xls 
						';;'
					if temp2.pr = '1' then u-2-d('ДОХОДЫ') 
					else u-2-d('РАСХОДЫ') skip.                 
					ii = 0.
			end.
			/****************************************************************/

			/****************************************************************/
			if first-of(temp2.kl) then 
			do:
				ii = ii + 1.
				if temp2.kl = '1-' then 
				do:
					put stream m-out skip(1)
						ii format '99'  space (7)
						temp2.des
						space(28)
						temp2.amt4 format 'zzz,zz9.99-'
						skip(1).
					put stream m-xls 
						ii format '99' ';;'
						u-2-d(temp2.des) format 'x(40)'  
						';;;;;'
						temp2.amt4 format 'zzz,zz9.99-' skip. 
				end.
				else 
				do:
					put stream m-out skip(1)
						ii format '99'  space (7)
						temp2.des
						if temp2.pr = '1' then 
							round(temp2.amt2 / (sumd2 - sumd21) * 100, 1)
						else 
							round(temp2.amt2 / sumr2 * 100, 1) format 'zz9.99-'
						temp2.amt2 format 'zz,zz9.99-'
						if temp2.pr = '1' then   
							round(temp2.amt4 / (sumd4 - sumd41) * 100, 1)
						else 
							round(temp2.amt4 / sumr4 * 100, 1) format 'zz9.99-'
						temp2.amt4 format 'zzz,zz9.99-'
						skip(1).
					put stream m-xls 
						ii format '99' ';;'
						u-2-d(temp2.des) format 'x(40)' ';'
						if temp2.pr = '1' then
							round(temp2.amt2 / (sumd2 - sumd21) * 100, 1) 
						else 
							round(temp2.amt2 / sumr2 * 100, 1) format 'zz9.99-'
						';' 
						temp2.amt2 format 'zz,zz9.99-' ';'
						if temp2.pr = '1' then
							round(temp2.amt4 / (sumd4 - sumd41) * 100, 1) 
						else 
							round(temp2.amt4 / sumr4 * 100, 1) format 'zz9.99-'
						';'
						temp2.amt4 format 'zzz,zz9.99-' skip.
				end.
			end.
			/****************************************************************/

			/****************************************************************/
			if temp2.gl1 eq 0 then next.
			/****************************************************************/

			/****************************************************************/
			if temp2.kl = '1-' then 
			do:
				put stream m-out '  '
					temp2.gl1 
					if temp2.des begins '*' then temp2.des else ' ' + temp2.des format 'x(41)' space(28)
			                temp2.amt4 format 'zzz,zz9.99-' skip.
			        put stream m-xls ';'
        			       temp2.gl1 ';'
			               if temp2.des begins '*' then u-2-d(temp2.des) 
			               else u-2-d(' ' + temp2.des) format 'x(41)' ';'
			               ';;;;'
			               temp2.amt4 format 'zzz,zz9.99-' skip.
		        end.
			else 
			do:
				put stream m-out '  ' 
					temp2.gl1 
					if temp2.des begins '*' then temp2.des else ' ' + temp2.des format 'x(41)' '      '
						temp2.amt2 format 'zz,zz9.99-' '     '
						temp2.amt4 format 'zzz,zz9.99-' skip.
				put stream m-xls ';'
					temp2.gl1 ';'
					if temp2.des begins '*' then u-2-d(temp2.des) 
					else u-2-d(' ' + temp2.des) format 'x(41)'
					';;'
					temp2.amt2 format 'zz,zz9.99-' ';;'
					temp2.amt4 format 'zzz,zz9.99-' skip.
			end.
			/****************************************************************/

			/****************************************************************/
			if last-of(temp2.pr) then 
			do:
				put stream m-out space(9) 'ИТОГО ' space(36)  '100' .
				put stream m-xls ';;' u-2-d('ИТОГО') ';100;'. 
				if temp2.pr = '1' then do.
					put stream m-out 
						' '
						sumd2 - sumd21 format 'zz,zz9.99-'
						'  100'
						sumd4 - sumd41 format 'zzz,zz9.99-' 
						sumd41 format 'zzz,zz9.99-' skip.
					put stream m-xls
						sumd2 - sumd21 format 'zz,zz9.99-'
						';100;'
						sumd4 - sumd41 format 'zzz,zz9.99-'  ';'
						sumd41 format 'zzz,zz9.99-' skip
						';' skip.
				end.
				else do.
					put stream m-out
						' '
						sumr2 format 'zz,zz9.99-'
						'  100'
						sumr4 format 'zzz,zz9.99-' skip.
					put stream m-xls
						sumr2 format 'zz,zz9.99-'
						';100;'
						sumr4 format 'zzz,zz9.99-' skip
						';' skip.
				end.
			end.
			/****************************************************************/
		end. /* конец печать temp2 */
		/* итоговые строки */
		put stream m-out skip(1) space(9)
			'ВСЕГО ДОХОДОВ                          ' space(7)
			sumd2  format  'zz,zz9.99-'
			'      '
			sumd4  format  'zz,zz9.99-'
			sumd41 format  'zz,zz9.99-' skip.
		put stream m-xls ';' skip
			';;'
			u-2-d('ВСЕГО ДОХОДОВ                          ') format 'x(40)'
			';;'
			sumd2  format 'zz,zz9.99-' ';;'
			sumd4  format 'zzz,zz9.99-' ';'
			sumd41 format 'zzz,zz9.99-' skip.
		put stream m-out skip space(9)
			'ВСЕГО РАСХОДОВ                         ' space(7)
			sumr2 format  'zz,zz9.99-'
			'      '
			sumr4  format  'zz,zz9.99-' skip.
		put stream m-xls 
			';;'
			u-2-d('ВСЕГО РАСХОДОВ                         ') format 'x(40)'
			';;'
			sumr2  format 'zz,zz9.99-' ';;'
			sumr4  format 'zzz,zz9.99-' skip.
		put stream m-out skip space(9)
			'ДОХОД, ОСТАВШИЙСЯ В РАСПОРЯЖЕНИИ БАНКА ' space(7)  
			sumd2 - sumd21 - sumr2 format 'zz,zz9.99-'
			'     '
			sumd4 - sumd41 - sumr4 format 'zzz,zz9.99-'
			sumd41 format 'zz,zz9.99-'skip. 
		put stream m-xls  
			';;'
			u-2-d('ДОХОД, ОСТАВШИЙСЯ В РАСПОРЯЖЕНИИ БАНКА ') format 'x(40)'
			';;'
			sumd2 - sumd21 - sumr2 format 'zz,zz9.99-' ';;'
			sumd4 - sumd41 - sumr4 format 'zzz,zz9.99-' ';'
			sumd41 format 'zzz,zz9.99-' skip.



		a11 = a11 + b11.
		put stream m-out skip(1) space(9)
			'ДОХОДЫ, НАЧИСЛЕННЫЕ, НО НЕПОЛУЧЕННЫЕ '  
			skip
			space(9)
			'ПО КРЕДИТАМ ' skip
			'   за ' year(date1)  format '9999' ' год' space (64) sumd41 format 'zzz,zz9.99-'skip
			'   за ' year(date1) - 1 format '9999' ' год' space (64) a11 - sumd41 format 'zzz,zz9.99-'skip.
		put stream m-xls ';' skip
			';;'
			u-2-d('ДОХОДЫ, НАЧИСЛЕННЫЕ, НО НЕПОЛУЧЕННЫЕ ') format 'x(40)' 
			skip
			';;'
			u-2-d('ПО КРЕДИТАМ ') format 'x(40)' skip
			';;'
			u-2-d('за')
			year(date1)  format '9999'
			u-2-d(' год')
			';;;;;'
			sumd41 format 'zzz,zz9.99-'skip
			';;'
			u-2-d('за')
			year(date1) - 1 format '9999'
			u-2-d(' год')
			';;;;;'
			a11 - sumd41 format 'zzz,zz9.99-'skip.
		put stream m-out skip(1) space(9)
			'ВСЕГО'
			space(64)
			a11 format 'zzz,zz9.99-' skip(2).
		put stream m-xls ';' skip
			';;'
			u-2-d('ВСЕГО')
			';;;;;'
			a11 format 'zzz,zz9.99-' skip(2).
			/******************************************************************************************************/	
			for each r5922Temp where r5922Temp.dan <> 0 no-lock.
				accum r5922Temp.dan (total).
				put stream m-out  space(9) r5922Temp.name r5922Temp.dan skip.
				put stream m-xls  ';;' u-2-d(r5922Temp.name) format 'x(40)' ';' r5922Temp.dan skip.
			end. 
			/******************************************************************************************************/
		put stream m-out skip(1) space(9)
			'Всего' space (20)
			accum total r5922Temp.dan skip.
		put stream m-xls ';'skip
			';;'
			u-2-d('ВСЕГО') format 'x(40)' ';'
			accum total r5922Temp.dan skip.
	end.  /* конец формирования окончательная форма */

end. /* коенец если файл не пуст... */
/********************************************************************************************************************************************************/




output stream m-out close.
output stream r-err close.
output stream m-xls close.
if not g-batch then do:
	pause 0 before-hide.
	run menu-prt( 'rpt.img' ).
	pause before-hide.
end.
            
{functions-end.i}

if prz = 2 then do.
	input through askhost.
	repeat:
		import hostmy.
	end.
	input close.
        input through value( 'resolveip -s ' + hostmy ).
	repeat:
		import ipaddr.
	end.
	input close.
	input through value("rcp xls.img " + ipaddr + ":C:/doxras.img" ).
end.


