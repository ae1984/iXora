/* obm_rst1.p
 * MODULE
	   Обменные	операции
 * DESCRIPTION
	   Печать реестра купленной	и проданной	валюты
 * RUN
	   Вызов из	п меню без параметров
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
		3-1-8
 * AUTHOR
		31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES

		02/06/03	nataly	  было добавлено	условие	для	проводок где gl	= 100200 для кассиров РЕИЗа
		18.08.2003	marinav	  Выводить остатки на начало	и конец	дня, даже если не было проводок
							  по	к.-л. валютам
							  Убран запрос на ввод кассиром своих остатков валюты. Это делается
							  только	старшим	кассиром в п 3-2-11
		21.08.2003 marinav	  Добавился номер распоряжения по курсам
		18.09.2003 nadejda	  убран 8-й столбец
		23.09.2003 nadejda	  добавлена обработка кассы в обменном пункте 100300
		20.10.2003 nadejda  - ВСЕГДА	берем ФИО, независимо от суммы
		08.12.2003 nadejda  - изменила формат вывода	номера строки с	zz на zzzz
		09.08.2004 kanat    - раньше	если выводить время	транзакции - то	транзакции шли вразброс	- что очень	неправильно
							  отдельной колонкой	выведено время транзакций, проводки	кассиров в разрезе РКО упорядочены по времени.
		31.08.2004 dpuchkov	- добавил отображение удаленных	транзакций
		07.10.2004 dpuchkov	- изменил группировку по tim
		19.10.2005 dpuchkov	- добавил отображение даты документа из	отдельного поля
		09.06.2006 u00121	- из за	того что курсы вводимые	Администраторами АБПК после	закрытия стали "съезжать" по времени на	сутки
						      т.к. перевод АБПК на следующий опер.день происходит	еще	в текущем реальном дне,	а при создании записи в	crchis дата	указывается	следующего дня а время текущего	дня	- добавлен
						      еще	один параметр в	условие	поиска . Теперь	записи из crchis будут искатья только те, которые были созданы до 21:00	часов, т.е.	после этого	времени	должно считаться что курсы не
						      могут меняться в принципе. Примечание, если	когда-нибудь кто-нибудь	все	таки решится и переведет закрытие опердня на online, пусть он учтет	данную особенность формирования	этого
						      реестра.
		21.06.2006 u00121	- Закомментарил	строки "if substr(tmp_jdoc.tj_fio, 1,7)	<> "введена" then",	т.к. из	за этого не	правильно удалялась	запись из t_totsub,	что	приводило к	ошибкам	в формировании реестра
		17/03/08  amrinav   - при поиске find last добавила	дату, при расчете суммы	procedure CheckAmt не затирается дата
		04.04.08  ьфкштфм   - убран расчет на	конец дня согл ТЗ 302 от 04.04.08
		29.10.2008 id00024  - Менеджеры печатают	два	экземпляра путем нажатия на	кнопку печать двух раз.	По аномальным явлениям при повторной печати	заголовок съезжает в право.	Поэтому	я добавил пустую строку	в начале.
		30.01.2009 id00209  - нумерация распоряжений, изменил формат	реестра.
		18/03/09 marinav    - добавлена календарная дата проводки
		04/04/2009 madiyar  - расширил поле для номеров распоряжений
		09/04/2009 madiyar  - при наличии удаленных транзакций выдавал ошибку; исправил
		30/04/2009 madiyar  - номера	распоряжений - выводятся один раз и	переносятся	на следующую строку
		12/08/2010 galina   - поправила вывод	ФИО	и удостоверяющих данных
		02/09/2010 galina   - поправила вывод	даты выдачи	удост.документа
		10.11.10   marinav  - добавление	названия СП, логина	кассира, в шапке показываются все курсы	за сегодня,	даже если не было оборотов
		18.11.2010 marinav  - добавлены последние курсы предыдущего дня
		20.02.2012 aigul    - вывод в реестр обменные платежи счета ГК	100500
        27.04.2012 aigul    - исправила вывод ФИО для сумм больше 10000 долларов
        24.07.2012 damir    - добавил LISTNUM,view_HTM,CR_TEMP(сохранение данных в temp-table T-WORD). Изменение формата вывода в WORD Реестра.
        09.08.2012 damir    - выходила мелкая ошибка, устранил.
        17.08.2012 damir    - изменения в процедуре LISTNUM.
        01.10.2012 damir    - добавлена шапка в реестр, т.е. если больше 2-х листов WORD. На основании С.З. от 06.09.2012...
        04.10.2012 id01143(sayat) - добавил вывод наименования вида документа удостоверяющего личность (ТЗ 1527)
        12.10.2012 damir    - добавления номеров страниц,которые настраиваются менеджерами, изменения связанные с Т.З. внедренное 24.07.2012...
        19.10.2012 id01143(sayat) - добавил вывод 4-й части fio (дата выдачи документа УЛ) (устранение замечания по ТЗ 1527)
        05.11.2012 damir    - убрал menu-prt. На основании С.З. от 05.11.2012.
        08.11.2012 damir    - Внедрено Т.З. № 1482.
        10.12.2012 Lyubov   - исправлены ошибки, некорректно рассчитывалась сумма в долларах => не выводились данные по клиенту
        02/04/2013 Luiza    - ТЗ 1761 суммы обменных операций  п.м. 15.1.2, 15.1.3, 15.4 по счету  ГК 100500
        14/05/2013 Luiza    - ТЗ 1838 данные из миникарточки при обмене наличности >= 1000$
        15/05/2013 Luiza    - ТЗ 1826 расширение формата для курса 3 знака после запятой
        18/09/2013 Luiza    - ТЗ 2091 нумерация листов
        12/11/2013 Luiza    - *ТЗ 2191 формат вывода номеров распоряжений
*/

{functions-def.i}
{global.i}
{cashrep.i}

/*g-ofc	= "id00189".*/
/*g-ofc	= "id00498".*/

/*define var g-ofc	  like ofc.ofc initial "denis".
define var g-today	as date	initial	"02/25/02".*/

/*define var oldg-ofc like ofc.ofc.*/
define var tg-today	as date.
define var mpage-size as integer init 64.

def	var	fio	as char.
def	var	pwidth as int init 138.
def	var	pwidth2	as int init	136.
def	var	fsymb as char.
define buffer b_exch_lst for exch_lst.
define variable	symb1 as integer extent	5 init [16,32,47,61,75].
define variable	symb2 as integer extent	7 init [6,30,38,60,79,99,118].
define variable	mycount	as integer.
define variable	prevbrate as deci .
define variable	prevsrate as deci.
define variable	cur_line as	integer.
define variable	cur_page as	integer.
define variable	i as integer.
define buffer bcrc for crc.
define variable	prev_rated as deci init	0 extent 11.
define variable	prev_ratec as deci init	0 extent 11.
define variable	new_rec	as logical.
define buffer b-crc	for	crc.

def	var	nrasp as char no-undo init ''.

define temp-table tot_sum no-undo
	field ts_crc like crc.crc
	field ts_dam like jl.dam
	field ts_damkzt	like jl.dam
	field ts_cam like jl.cam
	field ts_camkzt	like jl.cam
	index icrc is primary ts_crc /*ts_dc*/.

define temp-table tmp_jdoc no-undo
	field tj_docnum	as integer format "zzz"
	field tj_fio	like fio
	field tj_code	like crc.code
	field tj_dc		like jl.dc
	field tj_amt	like jl.dam
	field tj_amtkzt	like jl.dam
	field tj_rate as deci
	field tj_date as date
	field tj_time as integer
	field tj_ofc  as char
	field tj_jh	  as integer
	index idocnum  is primary tj_docnum.

define temp-table tmp_rateD	no-undo
	field tr_date	as date
	field tr_rate	as deci
	field tr_crc	like crc.crc.

define temp-table tmp_rateC	no-undo
	field tr_date	as date
	field tr_rate	as deci
	field tr_crc	like crc.crc.

define temp-table tmp_rateDO no-undo
	field tr_date	as date
	field tr_rate	as deci
	field tr_crc	like crc.crc.

define temp-table tmp_rateCO no-undo
	field tr_date	as date
	field tr_rate	as deci
	field tr_crc	like crc.crc.

/* курсы, которые уже вывелись в шапке */
define temp-table tmpD no-undo
	field tr_rate as deci
	field tr_crc  like crc.crc.

define temp-table tmpC no-undo
	field tr_rate as deci
	field tr_crc  like crc.crc.

define var rate_cnt	as integer.
define var rate_c as integer.
define var rate_d as integer.

define temp-table t_totsub no-undo
	field tt_crc  like crc.crc
	field tt_code like tj_code
	field tt_dc	  like jl.dc
	field tt_rate as deci
	field tt_amt	 like jl.dam.

define temp-table t_ofc	no-undo
  field	to_ofc like	g-ofc.

def temp-table T-WORD
    field i    as inte
    field ch1  as char
    field ch2  as char
    field ch3  as char
    field ch4  as char
    field ch5  as char
    field ch6  as char
    field ch7  as char
    field ch8  as char
    field COLS as logi.

def buffer btmp     for tmp_jdoc.
def buffer b-T-WORD for T-WORD.
/********/
def	var	v-length as	integer	no-undo.
def	var	ii as integer no-undo.

def	var	v-sum as decimal.
def var k     as inte.
def var l     as inte.
def var j     as inte.
def var s     as inte.
def var f     as inte.
def var q     as inte.
def var v-Pag as logi.

def	stream v-out.
def	stream v-out2.

def	var	v-file	as char	init "Rep1.htm".
def	var	v-file2	as char	init "Rep2.htm".
def	var	v-inputfile	as char	init "/data/export/reportdel.htm".
def	var	v-str		as char.

/**/
procedure get_page:
	find first b_exch_lst where	b_exch_lst.ofc_list	matches	("*" + g-ofc + "*")	no-lock	no-error.
	cur_page = b_exch_lst.page_num.
end	procedure.

procedure put_page:
	for	each b_exch_lst	where b_exch_lst.ofc_list matches ("*" + g-ofc + "*"):
		b_exch_lst.page_num	= cur_page.
	end.
end	procedure.

procedure add_line:
define input parameter	a as integer.
	cur_line = cur_line	+ a.
	if cur_line	= mpage-size - 3 then do:
		put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")".
		put	skip(1)	"Подпись кассира __________" "Лист N "	at 100 /*cur_page*/	format "zzzzz" skip.
		page.
		put	skip(1).
		cur_line = 1.
		/*cur_page = cur_page	+ 1.*/
		run	view_header(false).
	end.
end	procedure.

function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
    define buffer bcrc1 for crchis.
    define buffer bcrc2 for crchis.

    if d1 = 10.01.08 or d1 = 12.01.08 then do:
        if c1 <> c2 then do:
            find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
            find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
            return sum * bcrc1.rate[1] / bcrc2.rate[1].
        end.
        else return sum.
    end.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
        return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.

procedure get_fio:
	define input parameter famt	like jl.dam.
    def var viddoc as char.
    viddoc = "".
	if trim(joudoc.vidpassp) <> "" then do:
        find first codfr where codfr.codfr = 'kfmFUd' and codfr.code = joudoc.vidpassp no-lock no-error.
        if avail codfr then viddoc = codfr.name[1].
        else viddoc = "".
    end.
	/* 20.10.2003 nadejda */
	if trim(joudoc.info	+ viddoc + joudoc.passp)	= "" then fio =	"".
	else do:
		fio	= trim(joudoc.info)	+ ";" + trim(viddoc) + ";" +	trim(joudoc.passp).
		if	string(joudoc.passpdt) <> ?	then fio = fio + ';' + string(joudoc.passpdt).
	end.
end	procedure.

procedure add_to_TS:
	define input param namt	like jl.dam.
	define input param nrate as	deci.

	find tot_sum where ts_crc =	jl.crc	no-error.
	if not avail tot_sum then do:
		create tot_sum.
			ts_crc = jl.crc.
	end.
	if jl.dc = "d" then	do:
		ts_dam = ts_dam	+ namt.
		ts_damkzt =	ts_damkzt +	namt * nrate.

		find tmp_rateD where tmp_rateD.tr_date = jl.whn	and	tmp_rateD.tr_rate =	nrate no-error.
		if not avail tmp_rateD then	do:
			create tmp_rateD.
				tmp_rateD.tr_date =	jl.whn.
				tmp_rateD.tr_rate =	nrate.
				tmp_rateD.tr_crc = crc.crc.
		end.
	end.
	else do:
		ts_cam = ts_cam	+ namt.
		ts_camkzt =	ts_camkzt +	namt * nrate.
		find tmp_rateC where tmp_rateC.tr_date = jl.whn	and	tmp_rateC.tr_rate =	nrate no-error.
		if not avail tmp_rateC then	do:
			create tmp_rateC.
				tmp_rateC.tr_date =	jl.whn.
				tmp_rateC.tr_rate =	nrate.
				tmp_rateC.tr_crc = crc.crc.
		end.
	end.
end	procedure.

procedure CheckAmt:
	if exch_lst.whn	< tg-today then	do:
		output to terminal.
		find first bcrc	where bcrc.crc = exch_lst.crc.
		find current exch_lst exclusive-lock.
		exch_lst.whn = tg-today.
		exch_lst.camt =	exch_lst.bamt.
		find current exch_lst no-lock.
	end.
	else do:
		output to terminal.
		find current exch_lst exclusive-lock.
		exch_lst.camt =	exch_lst.bamt.
		find current exch_lst no-lock.
	end.
end	procedure.

mycount	= 0.
prevbrate =	0.
prevsrate =	0.

tg-today = g-today.

update "Введите	дату отчета: " tg-today	no-label.

/*if DAY(tg-today) = 1 then do:
	for	each exch_lst where	exch_lst.ofc_list matches ("*" + g-ofc + "*"):
		exch_lst.page_num =	1.
	end.
end.*/

find first exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	no-lock	no-error.
if not avail exch_lst then do:
	message	"Ваш логин отсутствует в списке	кассиров" skip "обменного пункта" view-as alert-box	title "".
	leave.
end.

find first ppoint where	ppoint.depart =	exch_lst.depart	no-lock	no-error.

REPEAT i = 1 TO NUM-ENTRIES(exch_lst.ofc_list):
	create t_ofc.
	t_ofc.to_ofc = ENTRY(i,exch_lst.ofc_list).
END.

mycount	= 1.


/*********Собрать все курсы*******************/
for	each tcrc where	whn	= tg-today and tcrc.dtime =	32400.
          create tmp_rateD.
		  tmp_rateD.tr_date	= tg-today.
		  tmp_rateD.tr_rate	= tcrc.rate[2].
		  tmp_rateD.tr_crc = tcrc.crc.

		  create tmp_rateC.
		  tmp_rateC.tr_date	= tg-today.
		  tmp_rateC.tr_rate	= tcrc.rate[3].
		  tmp_rateC.tr_crc = tcrc.crc.
end.
for	each crchis	where regdt	= tg-today and crchis.crc ne 5 no-lock.
	find tmp_rateD where tmp_rateD.tr_crc =	crchis.crc and tmp_rateD.tr_date = tg-today	and	tmp_rateD.tr_rate =	crchis.rate[2] no-error.
	if not avail tmp_rateD then	do:
          create tmp_rateD.
		  tmp_rateD.tr_date	= tg-today.
		  tmp_rateD.tr_rate	= crchis.rate[2].
		  tmp_rateD.tr_crc = crchis.crc.
	end.
	find tmp_rateC where tmp_rateC.tr_crc =	crchis.crc and tmp_rateC.tr_date = tg-today	and	tmp_rateC.tr_rate =	crchis.rate[3] no-error.
	if not avail tmp_rateC then	do:
          create tmp_rateC.
		  tmp_rateC.tr_date	= tg-today.
		  tmp_rateC.tr_rate	= crchis.rate[3].
		  tmp_rateC.tr_crc = crchis.crc.
	end.
end.

/****************************/

for	each joudoc	where can-find (t_ofc no-lock where	t_ofc.to_ofc = joudoc.who) and	joudoc.whn = tg-today no-lock break	by joudoc.tim.
    /*по удаленным транзакциям*/
	for	each jh	where jh.jdt = joudoc.whn  and jh.ref =	joudoc.docnum  and substr(party,12,7) =	"deleted" no-lock:
		for	each deljl where  deljl.jh = jh.jh and	deljl.jdt =	joudoc.whn no-lock.
			if deljl.who = joudoc.who and  integer(substr(deljl.bywho, 1, 3)) <> 1 and (deljl.gl = 100100  or deljl.gl = 100200	or deljl.gl	= 100300) and substring(deljl.rem[1],1,5) =	"Обмен"	then do:
				find last crc where	crc.crc	= integer(substr(deljl.bywho, 1, 3)) no-lock no-error.
				if deljl.dc	= "d" and deljl.dam	<> 0 then do:
					create tmp_jdoc.
					assign tmp_jdoc.tj_docnum =	 mycount
						tmp_jdoc.tj_fio	   = trim("введена ошибочно;")
						tmp_jdoc.tj_dc	   = deljl.dc
						tmp_jdoc.tj_code   = crc.code
						tmp_jdoc.tj_amt	   = deljl.dam
						tmp_jdoc.tj_amtkzt = deljl.dam * brate
						tmp_jdoc.tj_rate   = brate
						tmp_jdoc.tj_date   =  jh.whn
						tmp_jdoc.tj_time   =  jh.tim
						tmp_jdoc.tj_ofc	   = deljl.who
						tmp_jdoc.tj_jh	   = deljl.jh.
				end.
				if deljl.dc	= "c" and deljl.cam	<> 0 then do:
					create tmp_jdoc.
					assign tmp_jdoc.tj_docnum =	 mycount
						tmp_jdoc.tj_fio	   = trim("введена ошибочно;")
						tmp_jdoc.tj_dc	   = deljl.dc
						tmp_jdoc.tj_code   = crc.code
						tmp_jdoc.tj_amt	   = deljl.cam
						tmp_jdoc.tj_amtkzt = deljl.cam * srate
						tmp_jdoc.tj_rate   = srate
						tmp_jdoc.tj_date   =  jh.whn
						tmp_jdoc.tj_time   = jh.tim
						tmp_jdoc.tj_ofc	   = deljl.who
						tmp_jdoc.tj_jh	   = deljl.jh.
				end.
				mycount	= mycount +	1.
			end.
		end.
	end.
	for	each jl	where jl.jh = joudoc.jh and jl.jdt = joudoc.whn no-lock.
        if (jl.gl =	100100	or jl.gl = 100200 or jl.gl = 100300	or jl.gl = 100500) and substring(jl.rem[1],1,5)	= "Обмен" and jl.who = joudoc.who and jl.crc <>	1 then do:
            find last jh where	jh.jh =	jl.jh no-lock no-error.
			find last crc where	crc.crc	= jl.crc no-lock no-error.
			if jl.dc = "d" and jl.dam <> 0 then	do:
				run	add_to_TS(jl.dam, brate).
				run	get_fio(jl.dam).
				if jl.crc <> 2 then v-sum = crc-crc-date(jl.dam, jl.crc, 2, joudoc.whn).
				else v-sum = jl.dam.
                find first tmp_jdoc where tmp_jdoc.tj_jh = jl.jh and tmp_jdoc.tj_dc = jl.dc and tmp_jdoc.tj_code   = crc.code no-error.
                if not available tmp_jdoc then do:
                    create tmp_jdoc.
                    assign tmp_jdoc.tj_docnum =	mycount.
                        if v-sum >= 1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                        tmp_jdoc.tj_dc	   = jl.dc.
                        tmp_jdoc.tj_code   = crc.code.
                        tmp_jdoc.tj_amt	   = jl.dam.
                        tmp_jdoc.tj_amtkzt = jl.dam	* brate.
                        tmp_jdoc.tj_rate   = brate.
                        tmp_jdoc.tj_date   =  jh.whn.
                        tmp_jdoc.tj_time   =	 jh.tim.
                        tmp_jdoc.tj_ofc	   = jl.who.
                        tmp_jdoc.tj_jh	   = jl.jh.
			    end.
                else do:
                    if jl.crc <> 2 then do:
                        if crc-crc-date(jl.dam, jl.crc, 2, joudoc.whn) + crc-crc-date(tmp_jdoc.tj_amt, jl.crc, 2, joudoc.whn) >= 1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                    end.
                    else do:
                        if v-sum + tmp_jdoc.tj_amt >= 1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                    end.
                    tmp_jdoc.tj_amt	   = tmp_jdoc.tj_amt + jl.dam.
                    tmp_jdoc.tj_amtkzt = tmp_jdoc.tj_amtkzt  + (jl.dam	* brate).
                end.
            end.
			if jl.dc = "c" and jl.cam <> 0 then	do:
				run	add_to_TS(jl.cam, srate).
				run	get_fio(jl.cam).

				if jl.crc <> 2 then	v-sum = crc-crc-date(jl.cam, jl.crc, 2, joudoc.whn).
				else v-sum = jl.cam.
                find first tmp_jdoc where tmp_jdoc.tj_jh = jl.jh and tmp_jdoc.tj_dc = jl.dc and tmp_jdoc.tj_code   = crc.code no-error.
                if not available tmp_jdoc then do:
                    create tmp_jdoc.
                    assign tmp_jdoc.tj_docnum =	mycount.
                        if v-sum >=	1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                        tmp_jdoc.tj_dc	   = jl.dc.
                        tmp_jdoc.tj_code   = crc.code.
                        tmp_jdoc.tj_amt	   = jl.cam.
                        tmp_jdoc.tj_amtkzt = jl.cam	* srate.
                        tmp_jdoc.tj_rate   = srate.
                        tmp_jdoc.tj_date   =  jh.whn.
                        tmp_jdoc.tj_time   =  jh.tim.
                        tmp_jdoc.tj_ofc	   = jl.who.
                        tmp_jdoc.tj_jh	   = jl.jh.
			    end.
                else do:
                    if jl.crc <> 2 then	do:
                        if crc-crc-date(jl.cam, jl.crc, 2, joudoc.whn) + crc-crc-date(tmp_jdoc.tj_amt, jl.crc, 2, joudoc.whn) >= 1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                    end.
                    else do:
                        if v-sum + tmp_jdoc.tj_amt >= 1000 then tmp_jdoc.tj_fio = fio.
                        else tmp_jdoc.tj_fio = "".
                    end.
                    tmp_jdoc.tj_amt	   = tmp_jdoc.tj_amt + jl.cam.
                    tmp_jdoc.tj_amtkzt = tmp_jdoc.tj_amtkzt  + (jl.cam	* srate).
                end.
            end.
			mycount	= mycount +	1.
		end.
	end.
end.

mycount	= 1.
for	each tmp_jdoc where	tmp_jdoc.tj_amt	> 0	break by tmp_jdoc.tj_date by tmp_jdoc.tj_time:
	tmp_jdoc.tj_docnum = mycount.
	mycount	= mycount +	1.
end.

find first tot_sum where tot_sum.ts_crc	= 2	no-lock	no-error.
if not avail tot_sum and can-find (exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	and	exch_lst.crc = 2 ) then	do:
	create tmp_jdoc.
	assign tmp_jdoc.tj_docnum =	1
		tmp_jdoc.tj_fio	   = " "
		tmp_jdoc.tj_dc	   = "d"
		tmp_jdoc.tj_code   = "USD"
		tmp_jdoc.tj_amt	   = 0
		tmp_jdoc.tj_amtkzt = 0
		tmp_jdoc.tj_rate   = 0.
	create tot_sum.
	assign tot_sum.ts_crc =	2
		tot_sum.ts_dam = 0
		tot_sum.ts_damkzt =	0
		tot_sum.ts_cam	  =	0
		tot_sum.ts_camkzt =	0.
end.

find first tot_sum where tot_sum.ts_crc	= 4	no-lock	no-error.
if not avail tot_sum and can-find (exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	and	exch_lst.crc = 4 ) then	do:
	create tmp_jdoc.
	assign tmp_jdoc.tj_docnum =	1
		tmp_jdoc.tj_fio	   = " "
		tmp_jdoc.tj_dc	   = "d"
		tmp_jdoc.tj_code   = "RUB"
		tmp_jdoc.tj_amt	   = 0
		tmp_jdoc.tj_amtkzt = 0
		tmp_jdoc.tj_rate   = 0.
	create tot_sum.
	assign tot_sum.ts_crc =	4
		tot_sum.ts_dam = 0
		tot_sum.ts_damkzt =	0
		tot_sum.ts_cam	  =	0
		tot_sum.ts_camkzt =	0.
end.

find first tot_sum where tot_sum.ts_crc	= 3	no-lock	no-error.
if not avail tot_sum and can-find (exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	and	exch_lst.crc = 3 ) then	do:
	create tmp_jdoc.
	assign tmp_jdoc.tj_docnum =	1
		tmp_jdoc.tj_fio	   = " "
		tmp_jdoc.tj_dc	   = "d"
		tmp_jdoc.tj_code   = "EUR"
		tmp_jdoc.tj_amt	   = 0
		tmp_jdoc.tj_amtkzt = 0
		tmp_jdoc.tj_rate   = 0.
	create tot_sum.
	assign tot_sum.ts_crc =	3
		tot_sum.ts_dam = 0
		tot_sum.ts_damkzt =	0
		tot_sum.ts_cam	  =	0
		tot_sum.ts_camkzt =	0.
end.


output to rpt1.img .
output stream v-out	 to	value(v-file).
output stream v-out2 to	value(v-file2).

input from value(v-inputfile).
repeat:
	import unformatted v-str.
	v-str =	trim(v-str).
	put	stream v-out unformatted v-str.
end.
input close.

procedure View_Header:

    define input parameter ct as logical.
	if ct then run get_page.
	find first cmp no-lock no-error.
	put	skip.
	put	string(tg-today,"99/99/9999") +	", " + string( time, "HH:MM:SS"	) +	", " + trim( cmp.name )	format "x("	+ string(pwidth) +
    ")" skip.
    if avail ppoint then put ppoint.name format "x("	+ string(pwidth) + ")" skip
    FirstLine( 2, 1	) format "x(" +	string(pwidth) + ")" skip(1).
	put	fill( "-", pwidth )	format "x("	+ string(pwidth) + ")"	skip.

	put	"  Дата	 |"	"Вид " "|" at symb1[1] fill( "_", 8	) format "x(8)"	 "Остатки валюты" at 25	fill( "_", 8 ) format "x(8)"  "|" at symb1[3] fill(	"_", 11	) format "x(11)"  "Курс" at	59 fill( "_", 80 ) format "x(80)" "|" skip.
	put	"		 |валюты"  "|" at symb1[1] "На начало дня" at 18
			 "|" at	symb1[2] "На конец дня"	at 34
			 "|" at	symb1[3] "Покупки" at 51
			 "|" at	symb1[4] "Продажи" at 65
			 "|" at	symb1[5] "Номер	и дата"	at 85 "|" at 131
			 skip.
	put	"		 |"	 "|" at	symb1[1] "|" at	symb1[2] "|" at	symb1[3] "|" at	symb1[4] "|" at	symb1[5] "распоряжения руководителя" at	80 "|" at 131 skip.
	put	fill( "-", pwidth )	format "x("	+ string(pwidth) + ")"	skip.

	find first exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	and	exch_lst.crc = 1 no-lock no-error.
	if not avail exch_lst then message "Вашего логина нет в	списке кассиров" skip "Проверьте настройки в п.4.2.2" view-as alert-box	title "Ошибка".
	else nrasp = trim(exch_lst.numr).

	run	CheckAmt.

    /*убран расчет	на конец дня согл ТЗ 302 от	04.04.08
	find current exch_lst exclusive-lock.
	for	each tot_sum no-lock:
		exch_lst.camt =	exch_lst.camt -	tot_sum.ts_damkzt.
		exch_lst.camt =	exch_lst.camt +	tot_sum.ts_camkzt.
	end.
	find current exch_lst no-lock.*/

	find last b-crc	where b-crc.crc	= 1	no-lock	no-error.

    put	tg-today "|	" b-crc.code
		"|"	at symb1[1]	exch_lst.bamt  format "zzz,zz9.99-"	at 19
		"|"	at symb1[2]	exch_lst.camt  format "zzz,zz9.99-"	at 35
		"|"	at symb1[3]
		"|"	at symb1[4]
		"|"	at symb1[5]	nrasp format "x(41)" at	78 if nrasp	<> '' then string(tg-today,'99/99/99') else	'' at 122 "|" at 131 skip.

	if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else nrasp = ''.

	cur_line = 10.

	/* sasco */
	for	each tmp_rateDO: delete	tmp_rateDO.	end.
	for	each tmp_rateCO: delete	tmp_rateCO.	end.

	for	each tmp_rateD:
		create tmp_rateDO.
		buffer-copy	tmp_rateD to tmp_rateDO.
	end.

	for	each tmp_rateC:
		create tmp_rateCO.
		buffer-copy	tmp_rateC to tmp_rateCO.
	end.

	for	each tot_sum no-lock:
		find last exch_lst where ( exch_lst.crc	= tot_sum.ts_crc and exch_lst.ofc_list matches ("*"	+ g-ofc	+ "*") ) no-lock no-error.
		if not avail exch_lst then message "Проверьте настройки	в п.4.2.2" view-as alert-box title "Ошибка".
		find last b-crc	where b-crc.crc	= tot_sum.ts_crc no-lock no-error.
		if g-today = tg-today then do:
			find last b-crc	where b-crc.crc	= tot_sum.ts_crc no-lock no-error.
			prevbrate =	b-crc.rate[2].
			prevsrate =	b-crc.rate[3].
		end.
		else do:
			find last crchis where b-crc.crc = crchis.crc and crchis.rdt <=	tg-today /*and crchis.tim <	75600*/	no-lock	no-error. /*u00121 09/06/06	*/
			prevbrate =	crchis.rate[2].
			prevsrate =	crchis.rate[3].
		end.

		run	CheckAmt.
		/*	 убран расчет на конец дня согл	ТЗ 302 от 04.04.08
		find current exch_lst exclusive-lock.
		exch_lst.camt =	exch_lst.camt +	tot_sum.ts_dam.
		exch_lst.camt =	exch_lst.camt -	tot_sum.ts_cam.
		find current exch_lst no-lock.*/

        put	tg-today "|	" b-crc.code
			"|"	at symb1[1]	exch_lst.bamt  format "zzz,zz9.99-"	at 19
			"|"	at symb1[2]	exch_lst.camt  format "zzz,zz9.99-"	at 35
			"|"	at symb1[3]	prevbrate format "z,zz9.999"	at 52			  /*!!!!!!!!!!!!!!!!!!!!!!!!!! */
			"|"	at symb1[4]	prevsrate format "z,zz9.999"	at 66
			"|"	at symb1[5]	nrasp format "x(41)" at	78 if nrasp	<> '' then string(tg-today,'99/99/99') else	'' at 122 "|" at 131 skip.
		run	add_line(1).

		if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else nrasp = ''.

		find last tmp_rateDO where tmp_rateDO.tr_rate =	prevbrate and tmp_rateDO.tr_crc	= b-crc.crc	no-lock	no-error.
		if avail tmp_rateDO	then delete	tmp_rateDO.

		find tmp_rateCO	where tmp_rateCO.tr_rate = prevsrate and tmp_rateCO.tr_crc = b-crc.crc no-lock no-error.
		if avail tmp_rateCO	then delete	tmp_rateCO.

		rate_d = 0.
		rate_c = 0.

		/* количество курсов покупки и продажи */
		for	each tmp_rateDO	where tmp_rateDO.tr_crc	= b-crc.crc	no-lock:
			rate_d = rate_d	+ 1.
		end.
		for	each tmp_rateCO	where tmp_rateCO.tr_crc	= b-crc.crc:
			rate_c = rate_c	+ 1.
		end.

		rate_cnt = rate_d.
		if rate_c >	rate_d then	rate_cnt = rate_c.

		find first tmp_rateDO where	tmp_rateDO.tr_crc =	b-crc.crc no-error.
		find first tmp_rateCO where	tmp_rateCO.tr_crc =	b-crc.crc no-error.

		do rate_d =	1 to rate_cnt:
			if avail(tmp_rateDO) and avail(tmp_rateCO) then
			if tmp_rateDO.tr_rate =	? and tmp_rateCO.tr_rate = ? then do:
				find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
				find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
				next.
			end.

            if avail tmp_rateDO	then do:
				if tmp_rateDO.tr_rate <> ?	or tmp_rateDO.tr_rate =	0
				then put tmp_rateDO.tr_date	.
			end.
			else /*if avail	tmp_rateCO then	if tmp_rateCO.tr_rate <> ? then*/ put tmp_rateCO.tr_date .
			put	"|"
				"|"	at symb1[1]
				"|"	at symb1[2]
				"|"	at symb1[3].
			if avail tmp_rateDO	then if	tmp_rateDO.tr_rate <> ?	then put tmp_rateDO.tr_rate	format "z,zz9.999" at 52.
			put	"|"	at symb1[4].
			if avail tmp_rateCO	then if	tmp_rateCO.tr_rate <> ?	then put tmp_rateCO.tr_rate	format "z,zz9.999" at 66.
			put	"|"	at symb1[5]	nrasp format "x(41)" at	78 if nrasp	<> '' then string(tg-today,'99/99/99') else	'' at 122 "|" at 131 skip.

			if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else nrasp = ''.

			run	add_line(1).

			find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
			find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
		end.
	end.

	put	fill( "-", pwidth )	format "x("	+ string(pwidth) + ")"	skip(1).
	run	add_line(2).

	put	padc("РЕЕСТР",pwidth," ") format "x(" +	string(pwidth) + ")" skip
		padc("купленной	и проданной	иностранной	валюты",pwidth," ")	format "x("	+ string(pwidth) + ")" skip
		padc("за " + string(tg-today) ,	pwidth," ")	format "x("	+ string(pwidth) + ")" skip(1).
	put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
	put	"|"	"|"	at symb2[1]
		"Ф.И.О.	N и	серия"	at symb2[1]	+ 1
		"|"	at symb2[2]	"Наим."	at symb2[2]	+ 1	"|"	at symb2[3]
	fill( "_", 35 )	format "x(35)"				   "Сумма валюты"	   at symb2[3] + 36
	fill( "_", 32 )	format "x(32)"
		"|"	at symb2[7]	"|"	at 136 skip.
	put	"|"	"N"					at 2
		"|"	at symb2[1]
		"документа"			at symb2[1]	+ 1
		"|"	at symb2[2]
		"валюты"			at symb2[2]	+ 1
		"|"	at symb2[3]
	fill( "_", 17 )	format "x(17)" "Куплено"		   at symb2[3] + 18
	fill( "_", 16 )	format "x(16)"
		"|"	at symb2[5]
	fill( "_", 16 )	format "x(16)" "Продано"		   at symb2[5] + 17
	fill( "_", 16 )	format "x(15)"
		"|"	at symb2[7]	"|"	at 136 skip.
	put	"|"	"п/п"				at 2 "|" at	symb2[1]
		"удостоверяющего"	at symb2[1]	+ 1
		"|"	at symb2[2]	"|"	at symb2[3]
		"в валюте"			at symb2[3]	+ 1	"|"	at symb2[4]
		"эквивалент"		at symb2[4]	+ 1	"|"	at symb2[5]
		"в валюте"			at symb2[5]	+ 1	 "|" at	symb2[6]
		"эквивалент"		at symb2[6]	+ 1	 "|" at	symb2[7]  "|" at 136  skip.
	put	"|"	 "|" at	symb2[1] "личность клиента"	 at	symb2[1] + 1
		"|"	at symb2[2]	"|"	at symb2[3]	"|"	at symb2[4]
		"в тенге"			at symb2[4]	+ 1	 "|" at	symb2[5] "|" at	symb2[6]
		"в тенге"			at symb2[6]	+ 1	 "|" at	symb2[7] "	 Дата, время   |"
	skip.
	put	 fill( "-",	pwidth2	) format "x(" +	string(pwidth) + ")"  skip.
	run	add_line(10).
end	procedure.

procedure view_HTM.
    def input parameter p-Table as logi.
    def input parameter p-Num as inte.

    if p-Table and p-Num = 1 then do:
        k = 0.
        run get_page.
    end.

    find first cmp no-lock no-error.

    put stream v-out unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream v-out unformatted
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD>" string(tg-today,"99/99/9999") +	", " + string( time, "HH:MM:SS"	) +	", " + trim( cmp.name ) "</TD>" skip
        "</TR>" skip.
    if avail ppoint then put stream v-out unformatted
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD>" ppoint.name "</TD>" skip
        "</TR>" skip.
    put stream v-out unformatted
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD>" FirstLine( 2, 1	) "</TD>" skip
        "</TR>" skip.
    put stream v-out unformatted
        "</TABLE>" skip.

    k = k + 3.

    put stream v-out unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream v-out unformatted
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD rowspan=2>Дата</TD>" skip
        "<TD rowspan=2>Вид валюты</TD>" skip
        "<TD colspan=2>Остатки валюты</TD>" skip
        "<TD colspan=3>Курс</TD>" skip
        "</TR>" skip
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD>На начало дня</TD>" skip
        "<TD>На конец дня</TD>" skip
        "<TD>Покупки</TD>" skip
        "<TD>Продажи</TD>" skip
        "<TD>Номер и дата распоряжения руководителя</TD>" skip
        "</TR>" skip.

    k = k + 2.

    find first exch_lst	where exch_lst.ofc_list	matches	("*" + g-ofc + "*")	and	exch_lst.crc = 1 no-lock no-error.
	if not avail exch_lst then message "Вашего логина нет в	списке кассиров" skip "Проверьте настройки в п.4.2.2" view-as alert-box	title "Ошибка".
	else nrasp = trim(exch_lst.numr).

	run	CheckAmt.

    find last b-crc	where b-crc.crc	= 1	no-lock	no-error.

    put stream v-out unformatted
        "<TR style=""font-size:9.0pt"">" skip
        "<TD>" string(tg-today,"99/99/9999") "</TD>" skip
        "<TD>" b-crc.code "</TD>" skip.
    if avail exch_lst then put stream v-out unformatted
        "<TD>" string(exch_lst.bamt,"zzz,zz9.99-") "</TD>" skip
        "<TD>" string(exch_lst.camt,"zzz,zz9.99-") "</TD>" skip.
    else put stream v-out unformatted
        "<TD>" "</TD>" skip
        "<TD>" "</TD>" skip.
    put stream v-out unformatted
        "<TD>" "</TD>" skip
        "<TD>" "</TD>" skip.
    if nrasp <> "" then put stream v-out unformatted
        "<TD>" substring(nrasp,1,41) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
        string(tg-today,'99/99/99') "</TD>" skip.
    else put stream v-out unformatted
        "<TD></TD>" skip.
    put stream v-out unformatted
        "</TR>" skip.

    k = k + 1.

        if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else  nrasp = ''.

    for	each tmp_rateDO: delete	tmp_rateDO.	end.
	for	each tmp_rateCO: delete	tmp_rateCO.	end.

	for	each tmp_rateD:
		create tmp_rateDO.
		buffer-copy	tmp_rateD to tmp_rateDO.
	end.

	for	each tmp_rateC:
		create tmp_rateCO.
		buffer-copy	tmp_rateC to tmp_rateCO.
	end.

    for	each tot_sum no-lock:
        find last exch_lst where ( exch_lst.crc	= tot_sum.ts_crc and exch_lst.ofc_list matches ("*"	+ g-ofc	+ "*") ) no-lock no-error.
        if not avail exch_lst then message "Проверьте настройки	в п.4.2.2" view-as alert-box title "Ошибка".
        find last b-crc	where b-crc.crc	= tot_sum.ts_crc no-lock no-error.
        if g-today = tg-today then do:
            find last b-crc	where b-crc.crc	= tot_sum.ts_crc no-lock no-error.
            prevbrate =	b-crc.rate[2].
            prevsrate =	b-crc.rate[3].
        end.
        else do:
            find last crchis where b-crc.crc = crchis.crc and crchis.rdt <=	tg-today /*and crchis.tim <	75600*/	no-lock	no-error. /*u00121 09/06/06	*/
            prevbrate =	crchis.rate[2].
            prevsrate =	crchis.rate[3].
        end.

        run	CheckAmt.

        put stream v-out unformatted
            "<TR style=""font-size:9.0pt"">" skip
            "<TD>" string(tg-today,"99/99/9999") "</TD>" skip
            "<TD>" b-crc.code "</TD>" skip.
        if avail exch_lst then put stream v-out unformatted
            "<TD>" string(exch_lst.bamt,"zzz,zz9.99-") "</TD>" skip
            "<TD>" string(exch_lst.camt,"zzz,zz9.99-") "</TD>" skip.
        else put stream v-out unformatted
            "<TD>" "</TD>" skip
            "<TD>" "</TD>" skip.
        put stream v-out unformatted
            "<TD>" string(prevbrate,"z,zz9.999") "</TD>" skip
            "<TD>" string(prevsrate,"z,zz9.999") "</TD>" skip.
        if nrasp <> "" then put stream v-out unformatted
            "<TD>" substring(nrasp,1,41) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + string(tg-today,'99/99/99') "</TD>" skip.
        else put stream v-out unformatted
            "<TD></TD>" skip.
        put stream v-out unformatted
            "</TR>" skip.

        k = k + 1.

        if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else  nrasp = ''.

        find last tmp_rateDO where tmp_rateDO.tr_rate =	prevbrate and tmp_rateDO.tr_crc	= b-crc.crc	no-lock	no-error.
        if avail tmp_rateDO	then delete	tmp_rateDO.

        find tmp_rateCO	where tmp_rateCO.tr_rate = prevsrate and tmp_rateCO.tr_crc = b-crc.crc no-lock no-error.
        if avail tmp_rateCO	then delete	tmp_rateCO.

        rate_d = 0.
        rate_c = 0.

        /* количество курсов покупки и продажи */
        for	each tmp_rateDO	where tmp_rateDO.tr_crc	= b-crc.crc	no-lock:
            rate_d = rate_d	+ 1.
        end.
        for	each tmp_rateCO	where tmp_rateCO.tr_crc	= b-crc.crc:
            rate_c = rate_c	+ 1.
        end.

        rate_cnt = rate_d.
        if rate_c >	rate_d then	rate_cnt = rate_c.

        find first tmp_rateDO where	tmp_rateDO.tr_crc =	b-crc.crc no-error.
        find first tmp_rateCO where	tmp_rateCO.tr_crc =	b-crc.crc no-error.

        do rate_d =	1 to rate_cnt:
            if avail(tmp_rateDO) and avail(tmp_rateCO) then
            if tmp_rateDO.tr_rate =	? and tmp_rateCO.tr_rate = ? then do:
                find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
                find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
                next.
            end.

            put stream v-out unformatted
                "<TR style=""font-size:9.0pt"">" skip.
            if avail(tmp_rateDO) then do:
                if (tmp_rateDO.tr_rate <> ? or tmp_rateDO.tr_rate = 0) then put stream v-out unformatted
                    "<TD>" string(tmp_rateDO.tr_date) "</TD>" skip.
                else put stream v-out unformatted
                    "<TD></TD>" skip.
            end.
            else if avail tmp_rateCO then do:
                if tmp_rateCO.tr_date <> ? then put stream v-out unformatted
                    "<TD>" tmp_rateCO.tr_date "</TD>" skip.
                else put stream v-out unformatted
                    "<TD></TD>" skip.
            end.
            else put stream v-out unformatted
                "<TD></TD>" skip.

            put stream v-out unformatted
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip.
            if avail tmp_rateDO	then do:
                if tmp_rateDO.tr_rate <> ?	then put stream v-out unformatted
                    "<TD>" string(tmp_rateDO.tr_rate,"z,zz9.999") "</TD>" skip.
                else put stream v-out unformatted
                    "<TD></TD>" skip.
            end.
            else put stream v-out unformatted
                "<TD></TD>" skip.

            if avail tmp_rateCO	then do:
                if tmp_rateCO.tr_rate <> ?	then put stream v-out unformatted
                    "<TD>" string(tmp_rateCO.tr_rate,"z,zz9.999") "</TD>" skip.
                else put stream v-out unformatted
                    "<TD></TD>" skip.
            end.
            else put stream v-out unformatted
                "<TD></TD>" skip.

            if nrasp <> "" then put stream v-out unformatted
                "<TD>" substring(nrasp,1,41) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + string(tg-today,'99/99/99') "</TD>" skip.
            else put stream v-out unformatted
                "<TD></TD>" skip.
            put stream v-out unformatted
                "</TR>" skip.

            k = k + 1.

        if length(nrasp) > 41 then nrasp = substring(nrasp,42).	else  nrasp = ''.

            find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
            find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
        end.
    end.

    put stream v-out unformatted
            "</TABLE>" skip.

    put stream v-out unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream v-out unformatted
            "<TR align=center style=""font-size:9.0pt""><B>" skip
            "<TD>Реестр</TD>" skip
            "</B></TR>" skip
            "<TR align=center style=""font-size:9.0pt""><B>" skip
            "<TD>купленной и проданной наличной иностранной валюты</TD>" skip
            "</B></TR>" skip
            "<TR align=center style=""font-size:9.0pt""><B>" skip
            "<TD>за " string(tg-today,"99/99/9999")"</TD>" skip
            "</B></TR>" skip.

    put stream v-out unformatted
            "</TABLE>" skip.

    k = k + 3.

    put stream v-out unformatted
        "<style type=""text/css"">".

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""1"" bordercolor=""white""  cellspacing=""0"" cellpadding=""0"" style=""border-bottom:1px solid #FFFFFF;
        border-right:1px solid #FFFFFF;"">" skip.

    put stream v-out unformatted
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD rowspan=3 width=0.5%>№ <br> п/п</TD>" skip
        "<TD rowspan=3 width=26%>Ф.И.О. № и серия документа <br> удостоверяющего личность <br> клиента</TD>" skip
        "<TD rowspan=3 width=1%>Наим <br> вал</TD>" skip
        "<TD colspan=4>Сумма валюты</TD>" skip
        "<TD rowspan=3 width=21%>Дата, время</TD>" skip
        "</TR>" skip
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD colspan=2>Куплено</TD>" skip
        "<TD colspan=2>Продано</TD>" skip
        "</TR>" skip
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD width=12%>в валюте</TD>" skip
        "<TD width=12%>в тенге</TD>" skip
        "<TD width=12%>в валюте</TD>" skip
        "<TD width=12%>в тенге</TD>" skip
        "</TR>" skip.
    k = k + 3.
end procedure.

run	view_header(true).
run view_HTM(true,1).

procedure CR_TEMP.
    def input parameter p-logi as logi.

    def input parameter p-ch1 as char.
    def input parameter p-ch2 as char.
    def input parameter p-ch3 as char.
    def input parameter p-ch4 as char.
    def input parameter p-ch5 as char.
    def input parameter p-ch6 as char.
    def input parameter p-ch7 as char.
    def input parameter p-ch8 as char.

    l = l + 1.

    create T-WORD.
    T-WORD.i    = l.
    T-WORD.ch1  = p-ch1.
    T-WORD.ch2  = p-ch2.
    T-WORD.ch3  = p-ch3.
    T-WORD.ch4  = p-ch4.
    T-WORD.ch5  = p-ch5.
    T-WORD.ch6  = p-ch6.
    T-WORD.ch7  = p-ch7.
    T-WORD.ch8  = p-ch8.
    T-WORD.COLS = p-logi.
end.

l = 0.
for	each crc no-lock:
	find first tmp_jdoc	where tmp_jdoc.tj_dc = "d" and tmp_jdoc.tj_code	= crc.code no-lock no-error.
	if avail tmp_jdoc then prev_rated[crc.crc] = tmp_jdoc.tj_rate.
	find first tmp_jdoc	where tmp_jdoc.tj_dc = "c" and tmp_jdoc.tj_code	= crc.code no-lock no-error.
	if avail tmp_jdoc then prev_ratec[crc.crc] = tmp_jdoc.tj_rate.
end.

for	each tmp_jdoc where	tmp_jdoc.tj_amt	> 0	break by tmp_jdoc.tj_date by tmp_jdoc.tj_time:
	find last crc where	crc.code = tmp_jdoc.tj_code	no-lock	no-error.
	find first t_totsub	where t_totsub.tt_crc =	crc.crc	and	t_totsub.tt_dc	= tmp_jdoc.tj_dc and t_totsub.tt_rate =	tmp_jdoc.tj_rate no-error.
	new_rec	= false.
	if not avail t_totsub then if substr(tmp_jdoc.tj_fio, 1,7) <> "введена"	then do:
		create t_totsub.
		assign t_totsub.tt_crc = crc.crc
			t_totsub.tt_dc	= tmp_jdoc.tj_dc
			t_totsub.tt_rate = tmp_jdoc.tj_rate
			t_totsub.tt_code = tmp_jdoc.tj_code
			t_totsub.tt_amt	= tmp_jdoc.tj_amt.
		new_rec	= true.
	end.
	if new_rec = false then	do:
		if substr(tmp_jdoc.tj_fio, 1,7)	<> "введена" then t_totsub.tt_amt =	t_totsub.tt_amt	+ tmp_jdoc.tj_amt.
	end.
	else if	substr(tmp_jdoc.tj_fio,	1,7) <>	"введена" then do:
		if (t_totsub.tt_dc = "d" and prev_rated[crc.crc] <>	t_totsub.tt_rate) then do:
			put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
			run	add_line(1).
			find first t_totsub	where t_totsub.tt_dc = "d" and prev_rated[crc.crc] = t_totsub.tt_rate and t_totsub.tt_crc =	crc.crc	no-error.
			if avail t_totsub then do:

                run CR_TEMP(yes,"Итого по курсу " + string(t_totsub.tt_rate,"zzzzz9.999"),"",tt_code,string(tt_amt,"zzz,zzz,zzz,zz9.99"),
                string(tt_amt *	tt_rate,"zzz,zzz,zzz,zz9.99"),"","","").

                put	"| Итого по	курсу "	+ string(t_totsub.tt_rate,"zzzzz9.999") "|" at	symb2[2] tt_code		  format "x(4)"	 at	symb2[2] + 1
					"|"	at symb2[3]	tt_amt format "zzz,zzz,zzz,zz9.99" at symb2[3] + 1 "|" at symb2[4] tt_amt *	tt_rate	format "zzz,zzz,zzz,zz9.99"	at symb2[4]	+ 1
					"|"	at symb2[5]	"|"	at symb2[6]	"|"	at symb2[7]	"|"	at 136 skip.
					delete t_totsub.
				run	add_line(1).
				put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
				run	add_line(1).
			end.
		end.
		else if	(t_totsub.tt_dc	= "c" and prev_ratec[crc.crc] <> t_totsub.tt_rate) then	do:
			put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
			run	add_line(1).
			find first t_totsub	where t_totsub.tt_dc = "c" and prev_ratec[crc.crc] = t_totsub.tt_rate and t_totsub.tt_crc =	crc.crc	no-error.
			if avail t_totsub then do:

                run CR_TEMP(yes,"Итого по курсу " + string(t_totsub.tt_rate,"zzzzz9.999"),"",tt_code,"","",string(tt_amt,"zzz,zzz,zzz,zz9.99"),
                string(tt_amt *	tt_rate,"zzz,zzz,zzz,zz9.99"),"").

                put	"| Итого по	курсу "	+ string(t_totsub.tt_rate,"zzzzz9.999") "|" at	symb2[2] tt_code		  format "x(4)"	 at	symb2[2] + 1
					"|"	at symb2[3]	"|"	at symb2[4]	"|"	at symb2[5]	tt_amt			 format	"zzz,zzz,zzz,zz9.99" at	symb2[5] + 1
					"|"	at symb2[6]	tt_amt * tt_rate format	"zzz,zzz,zzz,zz9.99" at	symb2[6] + 1 "|" at	symb2[7]  "|" at 136 skip.
				delete t_totsub.
				run	add_line(1).
				put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
				run	add_line(1).
			end.
		end.
	end.
	if tmp_jdoc.tj_dc =	"d"	then prev_rated[crc.crc] = tmp_jdoc.tj_rate.
	else prev_ratec[crc.crc] = tmp_jdoc.tj_rate.
	if tmp_jdoc.tj_dc =	"d"	then do:
        FIO = "".
        FIO = trim(CAPS(entry(1,tj_fio,";"))).
        if num-entries(tj_fio,";") >= 2 then FIO = FIO + " " + trim(CAPS(replace(entry(2,tj_fio,";"),","," "))).
        if num-entries(tj_fio,";") >= 3 then FIO = FIO + " " + trim(CAPS(replace(entry(3,tj_fio,";"),","," "))).
        if num-entries(tj_fio,";") >= 4 then FIO = FIO + " " + trim(CAPS(replace(entry(4,tj_fio,";"),","," "))).

        run CR_TEMP(no,string(tj_docnum),substr(FIO,1,18),tj_code,string(tj_amt,"zzz,zzz,zzz,zz9.99"),string(tj_amtkzt,"zzz,zzz,zzz,zz9.99"),
        "","",string(tmp_jdoc.tj_date,"99/99/9999") + " " + string(tj_time,"HH:MM:SS") + " " + tmp_jdoc.tj_ofc).

        if length(FIO) > 18	then do:
            ii = 0.
            repeat:
				ii = ii	+ 1.
                if trim(substr(FIO,(18 * ii) + 1,18)) <> "" then do:
                    run CR_TEMP(no,"",substr(FIO,(18 * ii) + 1,18),"","","","","","").
                end.
				if trim(substr(FIO,(18 * ii) + 1,18)) = "" then leave.
            end.
        end.

        put	"|"	 tj_docnum format "zzzz"  "|" at symb2[1].
		put	substr(entry(1,tj_fio,";"),1,20) format	"x(20)"	at symb2[1]	+ 1	"|"	at symb2[2]	tj_code		format "x(4)"  at symb2[2] + 1
				"|"	at symb2[3]	 tj_amt			  format "zzz,zzz,zzz,zz9.99" at symb2[3] +	1
				"|"	at symb2[4]	 tj_amtkzt		  format "zzz,zzz,zzz,zz9.99" at symb2[4] +	1
				"|"	at symb2[5]	"|"	at symb2[6]	"|"	at symb2[7]	 tmp_jdoc.tj_date "	" string(tj_time,"HH:MM:SS") " " tmp_jdoc.tj_ofc "|" skip.

		if length(entry(1,tj_fio,";")) > 20	then do:
			v-length = length(entry(1,tj_fio,";")) - 20.
			ii = 0.
			repeat:
				ii = ii	+ 1.
				put	"|"	"|"	at symb2[1]	substr(entry(1,tj_fio,";"),(20 * ii) + 1,20) at	symb2[1] + 1 format	"x(20)"
					"|"	at symb2[2]
					"|"	at symb2[3]
					"|"	at symb2[4]
					"|"	at symb2[5]
					"|"	at symb2[6]
					"|"	at symb2[7]	 "|" at	136	skip.
				 v-length =	v-length - 20.
				 if	v-length < 20 then leave.
			end.
		end.

		if substr(tj_fio, 1, 7)	<> "введена" then do:
			if tj_fio <> ""	then do:
                put	"|"	"|"	at symb2[1]	entry(2,tj_fio,";")	at symb2[1]	+ 1	format "x(20)"
					"|"	at symb2[2]
					"|"	at symb2[3]
					"|"	at symb2[4]
					"|"	at symb2[5]
					"|"	at symb2[6]
					"|"	at symb2[7]	 "|" at	136	skip.

				if length(entry(2,tj_fio,";")) > 20	then do:
					v-length = length(entry(2,tj_fio,";")) - 20.
					ii = 0.
					repeat:
						ii = ii	+ 1.
                        put	"|"	"|"	at symb2[1]	substr(entry(2,tj_fio,";"),(20 * ii) + 1,20) at	symb2[1] + 1 format	"x(20)"
							"|"	at symb2[2]
							"|"	at symb2[3]
							"|"	at symb2[4]
							"|"	at symb2[5]
							"|"	at symb2[6]
							"|"	at symb2[7]	 "|" at	136	skip.
						 v-length =	v-length - 20.
						 if	v-length < 20 then leave.
					end.
				end.
				if num-entries(tj_fio,";") > 2 then do:
                    put	"|"	"|"	at symb2[1]	entry(3,tj_fio,";")	at symb2[1]	+ 1	format "x(20)"
							"|"	at symb2[2]
							"|"	at symb2[3]
							"|"	at symb2[4]
							"|"	at symb2[5]
							"|"	at symb2[6]
							"|"	at symb2[7]	 "|" at	136	skip.
                end.
				run	add_line(1).
			end.
		end.
		run	add_line(1).
	end.
	else do:
        FIO = "".
        FIO = trim(CAPS(entry(1,tj_fio,";"))).
        if num-entries(tj_fio,";") >= 2 then FIO = FIO + " " + trim(CAPS(replace(entry(2,tj_fio,";"),","," "))).
        if num-entries(tj_fio,";") >= 3 then FIO = FIO + " " + trim(CAPS(replace(entry(3,tj_fio,";"),","," "))).
        if num-entries(tj_fio,";") >= 4 then FIO = FIO + " " + trim(CAPS(replace(entry(4,tj_fio,";"),","," "))).

        run CR_TEMP(no,string(tj_docnum),substr(FIO,1,18),tj_code,"","",string(tj_amt,"zzz,zzz,zzz,zz9.99"),string(tj_amtkzt,"zzz,zzz,zzz,zz9.99"),
        string(tmp_jdoc.tj_date,"99/99/9999") + " " + string(tj_time,"HH:MM:SS") + " " + tmp_jdoc.tj_ofc).

        if length(FIO) > 18	then do:
            ii = 0.
            repeat:
				ii = ii	+ 1.
                if trim(substr(FIO,(18 * ii) + 1,18)) <> "" then do:
                    run CR_TEMP(no,"",substr(FIO,(18 * ii) + 1,18),"","","","","","").
                end.
				if trim(substr(FIO,(18 * ii) + 1,18)) = "" then leave.
            end.
        end.

        put	"|"	 tj_docnum format "zzzz" "|" at	symb2[1].
		put	entry(1,tj_fio,";")	format "x(20)" at symb2[1] + 1
			"|"	at symb2[2]	tj_code	 format	"x(4)"	at symb2[2]	+ 1
			"|"	at symb2[3]	 "|" at	symb2[4] "|" at	symb2[5] tj_amt			  format "zzz,zzz,zzz,zz9.99" at symb2[5] +	1 "|" at symb2[6]
			tj_amtkzt		 format	"zzz,zzz,zzz,zz9.99" at	symb2[6] + 1 "|" at	symb2[7]
			tmp_jdoc.tj_date " " string(tj_time,"HH:MM:SS")	" "	tmp_jdoc.tj_ofc	"|"	skip.
			if length(entry(1,tj_fio,";")) > 20	then do:
				v-length = length(entry(1,tj_fio,";")) - 20.
				ii = 0.
				repeat:
					ii = ii	+ 1.
                    put	"|"	"|"	at symb2[1]	substr(entry(1,tj_fio,";"),(20 * ii) + 1,20) at	symb2[1] + 1 format	"x(20)"
						"|"	at symb2[2]
						"|"	at symb2[3]
						"|"	at symb2[4]
						"|"	at symb2[5]
						"|"	at symb2[6]
						"|"	at symb2[7]	 "|" at	136	skip.
					 v-length =	v-length - 20.
					 if	v-length < 20 then leave.
				end.
			end.

		if substr(tj_fio, 1, 7)	<> "введена" then do:
			if tj_fio <> ""	then do:
                put	"|"	"|"	at symb2[1]	entry(2,tj_fio,";")	at symb2[1]	+ 1	format "x(20)"
					"|"	at symb2[2]
					"|"	at symb2[3]
					"|"	at symb2[4]
					"|"	at symb2[5]
					"|"	at symb2[6]
					"|"	at symb2[7]	"|"	at 136	skip.
				if length(entry(2,tj_fio,";")) > 20	then do:
					v-length = length(entry(2,tj_fio,";")) - 20.
					ii = 0.
					repeat:
						ii = ii	+ 1.
						put	"|"	"|"	at symb2[1]	substr(entry(2,tj_fio,";"),(20 * ii) + 1,20) at	symb2[1] + 1 format	"x(20)"
							"|"	at symb2[2]
							"|"	at symb2[3]
							"|"	at symb2[4]
							"|"	at symb2[5]
							"|"	at symb2[6]
							"|"	at symb2[7]	 "|" at	136	skip.
						 v-length =	v-length - 20.
						 if	v-length < 20 then leave.
					end.
				end.
				if num-entries(tj_fio,";") > 2 then	put	"|"	"|"	at symb2[1]	entry(3,tj_fio,";")	at symb2[1]	+ 1	format "x(20)"
							"|"	at symb2[2]
							"|"	at symb2[3]
							"|"	at symb2[4]
							"|"	at symb2[5]
							"|"	at symb2[6]
							"|"	at symb2[7]	 "|" at	136	skip.

				run	add_line(1).
			end.
		end.
		run	add_line(1).
	end.
end.

put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.
run	add_line(1).

/* Вывод промежуточных остатков	в конце	распечатки */
for	each t_totsub:
   if t_totsub.tt_dc = "d" then	do:
	   run add_line(1).

       run CR_TEMP(yes,"Итого по курсу " + string(t_totsub.tt_rate,"zzzzz9.999"),"",tt_code,string(tt_amt,"zzz,zzz,zzz,zz9.99"),
       string(tt_amt *	tt_rate,"zzz,zzz,zzz,zz9.99"),"","","").

       put "| Итого	по курсу " string(t_totsub.tt_rate,"zzzzz9.999")
		   "|" at symb2[2]
		   tt_code			format "x(4)"  at symb2[2] + 1
		   "|" at symb2[3]
		   tt_amt			format "zzz,zzz,zzz,zz9.99"	at symb2[3]	+ 1
		   "|" at symb2[4]
		   tt_amt *	tt_rate	format "zzz,zzz,zzz,zz9.99"	at symb2[4]	+ 1
		   "|" at symb2[5] "|" at symb2[6] "|" at symb2[7]	"|"	at 136
	   skip.
	   delete t_totsub.
	   run add_line(1).
	   put fill( "-", pwidth2 )	format "x("	+ string(pwidth) + ")"	skip.
	   run add_line(1).
   end.
   else	if t_totsub.tt_dc =	"c"	then do:
	   run add_line(1).

       run CR_TEMP(yes,"Итого по курсу " + string(t_totsub.tt_rate,"zzzzz9.999"),"",tt_code,"","",string(tt_amt,"zzz,zzz,zzz,zz9.99"),
       string(tt_amt *	tt_rate,"zzz,zzz,zzz,zz9.99"),"").

       put "| Итого	по курсу " + string(t_totsub.tt_rate,"zzzzz9.999")
		   "|" at symb2[2]
		   tt_code			format "x(4)"  at symb2[2] + 1
		   "|" at symb2[3]
		   "|" at symb2[4]
		   "|" at symb2[5]
		   tt_amt			format "zzz,zzz,zzz,zz9.99"	at symb2[5]	+ 1
		   "|" at symb2[6]
		   tt_amt *	tt_rate	format "zzz,zzz,zzz,zz9.99"	at symb2[6]	+ 1
		   "|" at symb2[7]	"|"	at 136
	   skip.
	   delete t_totsub.
	   run add_line(1).
	   put fill( "-", pwidth2 )	format "x("	+ string(pwidth) + ")"	skip.
	   run add_line(1).
   end.
end.

for	each tot_sum where tot_sum.ts_dam +	tot_sum.ts_cam > 0 no-lock:
	find crc where crc.crc = tot_sum.ts_crc	no-lock	no-error.

    run CR_TEMP(yes,"Всего","",crc.code,string(tot_sum.ts_dam,"zzz,zzz,zzz,zz9.99"),string(tot_sum.ts_damkzt,"zzz,zzz,zzz,zz9.99"),
    string(tot_sum.ts_cam,"zzz,zzz,zzz,zz9.99"),string(tot_sum.ts_camkzt,"zzz,zzz,zzz,zz9.99"),"").

    put	"| " "Всего	 " "|" at symb2[2] crc.code	at symb2[2]	+ 1	"|"	at symb2[3]
		tot_sum.ts_dam	  format "zzz,zzz,zzz,zz9.99"  at symb2[3] + 1 "|" at symb2[4]
		tot_sum.ts_damkzt format "zzz,zzz,zzz,zz9.99"  at symb2[4] + 1 "|" at symb2[5]
		tot_sum.ts_cam	  format "zzz,zzz,zzz,zz9.99"  at symb2[5] + 1 "|" at symb2[6]
		tot_sum.ts_camkzt format "zzz,zzz,zzz,zz9.99"  at symb2[6] + 1 "|" at symb2[7]
		 "|" at	136
	skip.

    run	add_line(1).
end.

j = 1. s = 0.

for each T-WORD no-lock break by T-WORD.i:

    v-Pag = no.

    if T-WORD.COLS then do:
        if T-WORD.ch1 matches "*Всего*" then put stream v-out unformatted
            "<TR style=""font-size:9.0pt;font:bold"">" skip.
        else put stream v-out unformatted
            "<TR style=""font-size:9.0pt"">" skip.
        put stream v-out unformatted
            "<TD colspan=2>" T-WORD.ch1 "</TD>" skip
            "<TD>" T-WORD.ch3 "</TD>" skip
            "<TD>" T-WORD.ch4 "</TD>" skip
            "<TD>" T-WORD.ch5 "</TD>" skip
            "<TD>" T-WORD.ch6 "</TD>" skip
            "<TD>" T-WORD.ch7 "</TD>" skip
            "<TD>" T-WORD.ch8 "</TD>" skip
            "</TR>" skip.
    end.
    else do:
        put stream v-out unformatted
            "<TR style=""font-size:9.0pt"">" skip
            "<TD>" T-WORD.ch1 "</TD>" skip
            "<TD>" T-WORD.ch2 "</TD>" skip
            "<TD>" T-WORD.ch3 "</TD>" skip
            "<TD>" T-WORD.ch4 "</TD>" skip
            "<TD>" T-WORD.ch5 "</TD>" skip
            "<TD>" T-WORD.ch6 "</TD>" skip
            "<TD>" T-WORD.ch7 "</TD>" skip
            "<TD>" T-WORD.ch8 "</TD>" skip
            "</TR>" skip.
    end.

    k = k + 1.

    find b-T-WORD where b-T-WORD.i = T-WORD.i + 1 no-lock no-error.
    if avail b-T-WORD then v-Pag = yes.

    run LISTNUM.
end.
find first T-WORD no-lock no-error.
if not available T-WORD then run LISTNUM.

procedure LISTNUM:
    if k = 66 * j + (s * 3) then do:

        cur_page = cur_page	+ 1.

        put stream v-out unformatted
            "<TR align=left style=""font-size:9.0pt"">" skip
            "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">Подпись кассира_______&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;лист №" string(cur_page) "</TD>" skip
            "</TR>" skip.

        k = k + 1.
        j = j + 1.
        s = s + 1.

        find b-T-WORD where b-T-WORD.i = T-WORD.i + 1 no-lock no-error.
        if avail b-T-WORD then do:
            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt;"">" skip
                "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">&nbsp;</TD>" skip
                "</TR>" skip
                "<TR align=left style=""font-size:9.0pt;"">" skip
                "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">&nbsp;</TD>" skip
                "</TR>" skip.

            k = k + 2.
        end.

        put stream v-out unformatted
            "</TABLE>" skip.

        if avail b-T-WORD then run view_HTM(false,0). /*Шапка реестра, требования НБРК*/
    end.

    if not v-Pag then do:
        if k < 66 then do:
            f = k.

            nextrec:
            repeat:
                f = f + 1.

                put stream v-out unformatted
                    "<TR align=left style=""font-size:9.0pt;"">" skip
                    "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">&nbsp;&nbsp;&nbsp;</TD>" skip
                    "</TR>".

                k = k + 1.

                if f = 66 * j then leave nextrec.
            end.

            cur_page = cur_page	+ 1.

            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">Подпись кассира_______&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;лист №" string(cur_page) "</TD>" skip
                "</TR>".

            k = k + 1.
        end.
        else if k > 69 * s and k < 69 * j then do:
            f = k.

            nextrec:
            repeat:
                f = f + 1.

                put stream v-out unformatted
                    "<TR align=left style=""font-size:9.0pt;"">" skip
                    "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">&nbsp;&nbsp;&nbsp;</TD>" skip
                    "</TR>".

                k = k + 1.

                if f = (67 * j) + (s * 2 - 1) then leave nextrec.
            end.

            cur_page = cur_page	+ 1.

            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=8 style=""border-left:1px solid #FFFFFF;border-top:1px solid #FFFFFF;"">Подпись кассира_______&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;лист №" string(cur_page) "</TD>" skip
                "</TR>" skip.

            k = k + (s * 2).
        end.
        put stream v-out unformatted
            "</TABLE>" skip.
    end.
end procedure.

put	fill( "-", pwidth2 ) format	"x(" + string(pwidth) +	")"	 skip.

if cur_line	< mpage-size then put skip(mpage-size -	cur_line - 1).

put	"Подпись кассира __________" "Лист N "	at 100 /*cur_page*/	format "zzzzz".
/*cur_page = cur_page	+ 1.*/

output	close.
output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

if v-norep = yes then unix silent cptwin value(v-file2) winword.

run	put_page.

/*pause 0	before-hide.
run	menu-prt( "rpt1.img" ).
pause before-hide.*/

{functions-end.i}
