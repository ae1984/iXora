/* r-doxras.p
 * MODULE
        Доходы - расходы
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-doxr1.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-9-1-16-2
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	14.09.2000 r-doxras.p Доходы и расходы банка посл.изменения 02.02.2000
	03/12/02 программа циклила в процедуре fgl из-за неверных настроек ГК 415400  и gl.gl ne 499900, у котрых totlev  = 0.
        24.02.2004 nadejda - увеличен формат округления сумм до 2 знаков после запятой
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	04.10.2004 u00121 - отчет переделан для консолидации, возможен выбор отдельно по филиалам, основная программа теперь в r-doxr1.p
	04.08.2006 u00121 - Добавлены no-undo, добавленны индексы во временные таблицы, из-за неправильной настройки типов счетов, отчеты циклился на Астане и Уральск - типы счетов проставлены как на Алмате
*/


{global.i}
def shared stream   m-out.
def shared stream   r-err.
def shared stream   m-xls.

def shared var      v-dat      as date no-undo.

def shared var prz as deci no-undo.
def var      o-gl       like txb.gl.gl no-undo.
def var      o-des      like txb.gl.des no-undo.
def var      o-sub      like txb.sub-cod.ccode no-undo.
def buffer   a-glday    for txb.glday.

def shared var      b11         as decimal no-undo.
def shared var      a11         as decimal no-undo.
def var      b1         as decimal no-undo.
def var      a1         as decimal no-undo.


/******************Основной temp-файл*******************/
def shared temp-table temp no-undo
    field pr    as char format 'x(1)'
    field kl    like txb.sub-cod.ccode
    field gl    like txb.gl.gl
    field gl1   like txb.gl.gl
    field des   like txb.gl.des
    field amt1  as deci 
    field amt2  as deci 
    field amt3  as deci 
    field amt4  as deci 
    index idx0-temp pr kl gl .
/*******************************************************/

def shared temp-table r5922Temp no-undo
	field kod like txb.codfr.code
	field name like txb.codfr.name[1]
	field dan like txb.r5922.dan
	index idx0-r5922Temp dan.


def shared var date1 as date no-undo.
def shared var date2 as date no-undo.

find last txb.cmp no-lock no-error.

display '   Ждите...   (' txb.cmp.name format "x(30)" ")"  with no-labels row 5 frame ww centered . pause 0.

find last txb.crchis where rdt le date1 and crc = 2 no-lock no-error.
/********************************************************************************************************************************************************/
/* формирование основного temp-файла */
for each txb.gl where (txb.gl.type = 'R' or txb.gl.type = 'E')  and txb.gl.totlev = 1 and txb.gl.gl <> 499980 and txb.gl.gl <> 599980  no-lock.
	create temp.
		temp.pr = if txb.gl.type = 'R' then '1' else '2'.
		temp.gl = txb.gl.gl.
		find txb.sub-cod where txb.sub-cod.acc = string(txb.gl.gl) and txb.sub-cod.sub = 'gld' and txb.sub-cod.d-cod = 'kldr' no-lock no-error.
		if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then do:              
			temp.kl = txb.sub-cod.ccode.
			temp.gl1 = txb.gl.gl.
			temp.des = left-trim(txb.gl.des).
		end.
		else 
		do:

			run fgl(txb.gl.gl,output o-gl,output o-des, output o-sub).
			temp.kl = o-sub.
			temp.gl1 = o-gl.
			temp.des = left-trim(o-des).  
		end.
		find last txb.glday where txb.glday.gl = temp.gl and txb.glday.gdt le date1 and txb.glday.crc = 1 no-lock no-error.
		if avail txb.glday then 
		do:
			temp.amt1 = txb.glday.bal .
			temp.amt2 = txb.glday.bal / txb.crchis.rate[1].
		end.
		if month(date1) = 1 then
			temp.amt3 = temp.amt1.
		else 
		do:
			find last a-glday where a-glday.gl = txb.glday.gl and a-glday.gdt <= date2 and a-glday.crc = 1 no-lock no-error.
			if avail a-glday then 
				temp.amt3 = temp.amt1 - a-glday.bal.
			else 
				temp.amt3 = temp.amt1.
		end.
		temp.amt4 = temp.amt3 / txb.crchis.rate[1] .
	displ temp.pr  temp.gl temp.des with overlay no-labels centered row 15 1 down title "Сбор данных по счетам Г/К". pause 0.
end.
/********************************************************************************************************************************************************/

/***********************************************************/

	find last txb.glday where txb.glday.gl = 174000 and txb.glday.gdt le date1 and  txb.glday.crc = 1 no-lock no-error. 
	if avail txb.glday then do.
		a1 = txb.glday.bal / txb.crchis.rate[1].
		find last txb.glday where txb.glday.gl = 174000 and txb.glday.gdt le date1 and  txb.glday.crc eq 2 no-lock no-error.
		if avail txb.glday then 
			a11 = a11 + round((a1 + txb.glday.bal) / 1000,2).

	end.      

	find last txb.glday where txb.glday.gl = 174100 and txb.glday.gdt le date1 and  txb.glday.crc = 1 no-lock no-error.
	if avail txb.glday then do.
		b1 = txb.glday.bal / txb.crchis.rate[1].
		find last txb.glday where txb.glday.gl = 174100 and txb.glday.gdt le date1 and  txb.glday.crc eq 2 no-lock no-error.
		if avail txb.glday then
		b11 = b11 + round((b1 + txb.glday.bal) / 1000,2).
	end.
/***********************************************************/

/***********************************************************/
if prz = 2 then do.  /* ввод расходов по счету 592200 */
   def var otv as logical.
   find last txb.cmp no-lock no-error.
   run yn('Внимание!','Вам необходима',' корректировка направлений расходов по счету 592200?', txb.cmp.name ,output otv).
   if otv then run vvr.
end.

			for each txb.r5922 where txb.r5922.dan <> 0 no-lock.
				accum dan (total).
				find txb.codfr where txb.codfr.codfr = 'kl592200' and txb.codfr.code = txb.r5922.kod no-lock no-error.
				find r5922Temp where r5922Temp.kod = txb.codfr.code no-error.
				if not avail r5922Temp then do:
					create r5922Temp.
					r5922Temp.kod = txb.codfr.code.
					r5922Temp.name = txb.codfr.name[1].
					r5922Temp.dan = txb.r5922.dan.
				end.
				else
				do:
					r5922Temp.dan = r5922Temp.dan + txb.r5922.dan.
				end.
			end. 
/***********************************************************/
/***********************************************************/
/* поиск сводных счетов (не 1-го уровня), участв.в отчете **/
Procedure fgl. 
def  input   parameter  v-gl   like txb.gl.gl.
def  output  parameter  o-gl   like txb.gl.gl.
def  output  parameter  o-des  like txb.gl.des init ' '.
def  output  parameter  o-sub  like txb.sub-cod.ccode init ' '.
def  var                v-ok   as log.
def  buffer             b      for txb.gl.
	v-ok = no.
	repeat while v-ok = no.

		find b where b.gl eq v-gl no-lock no-error.
		if not avail b then do. 
			put stream m-out 'Внимание! Не найден счет  ' v-gl skip. 
			v-ok = yes.
		end.
		else do.
			find txb.sub-cod where txb.sub-cod.acc = string(txb.gl.gl) and txb.sub-cod.sub = 'gld' and txb.sub-cod.d-cod = 'kldr' no-lock no-error.
			find txb.sub-cod where txb.sub-cod.acc = string(b.gl) and txb.sub-cod.sub = 'gld'and txb.sub-cod.d-cod = 'kldr' no-lock no-error.
			if avail txb.sub-cod and txb.sub-cod.ccode ne 'msc' then do:               
				v-ok = yes.
				o-gl = b.gl.
				o-des = b.des.
				o-sub = txb.sub-cod.ccode.
			end.
			else do: 
				v-gl = b.totgl. 
			end.  
			if v-gl = 499990 or v-gl = 599990 then do. 
				v-ok = yes.   
				o-gl = v-gl.
			end.
		end.
	end.
end procedure.
/***********************************************************/


procedure vvr.
for each codfr where codfr.codfr = 'kl592200' and codfr.code ne 'msc' no-lock.
    find r592200 where r592200.kod = codfr.code  no-error.
    if not avail r592200 then do.
       create r592200.
       kod = codfr.code.
    end.   
    displ kod label 'Код'
          codfr.name[1] label 'Назначение'
          dan label 'Сумма '  with frame vv centered.
    update dan with frame vv.
end.
hide frame vv.
end procedure.
