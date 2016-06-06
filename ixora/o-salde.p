/* o-salde.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	    Оборотно-сальдовая ведомость, развернутая с остатками по субсчетам
		консолидированная
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	o-salde1.p
 * MENU
        Перечень пунктов Меню Прагмы
	12-15
 * AUTHOR
       15/07/10 aigul - на основе r-salde.p
 * CHANGES
       15/07/10 aigul - создание отчета на основе r-salde.p
       08.10.2013 dmitriy - ТЗ 1913
 * BASES
     COMM BANK
*/

{mainhead.i}

/*Переменные****************************************************/
def new shared var vasof  as date.
def new shared var vasof2 like vasof.

def new shared var vasof_f  as date.
def new shared var vasof_f2 like vasof_f.


def new shared var v-crc  like crc.crc.
def new shared var vglacc as char format "x(6)".
def new shared var v-withprc as logi.
/***************************************************************/

/*Временные таблицы*********************************************/

def new shared temp-table t-gl /*временная таблица для сбора данных по счетам ГК*/
	field gl like gl.gl /*счет ГК*/
	field des like gl.des /*Название ГК*/
	index gl is primary unique gl.

def new shared temp-table t-glcrc
	field gl like gl.gl /*счет ГК*/
	field crc like crc.crc /*Валюта*/
	field amt as dec format "zzz,zzz,zzz,zzz.99-" /*сумма в валюте счета, зависит от валюты*/
	field amtkzt as dec format "zzz,zzz,zzz,zzz.99-" /*Сумма в валюте счета конвертированная в тенге*/

    field amt_f as dec format "zzz,zzz,zzz,zzz.99-"
	field amtkzt_f as dec format "zzz,zzz,zzz,zzz.99-"
    field dam as dec format "zzz,zzz,zzz,zzz.99-"
    field cam as dec format "zzz,zzz,zzz,zzz.99-"
	field damkzt as dec format "zzz,zzz,zzz,zzz.99-"
    field camkzt as dec format "zzz,zzz,zzz,zzz.99-"


	index gl is primary gl.

def new shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
	field gl  like t-gl.gl  /*счет ГК*/
	field acc like aaa.aaa  /*субсчет ГК*/
	field cif as char format "x(20)"  /*Название клиента*/
    field cifname as char /*Наименование клиента*/
	field geo as char format "x(3)"  /*ГЕО код*/
	field crc like crc.crc  /*валюта субсчета*/
	field ecdivis like sub-cod.ccode /*сектор отраслей экономики клиента*/
	field secek like sub-cod.ccode /*сектор экономики клиента*/ /* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690.*/
	field rdt like aaa.regdt /*дата открытия счета*/
	field duedt like arp.duedt /*дата закрытия счета*/
	field rate like aaa.rate /*процентная ставка по счету, если есть*/
	field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
	field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/

    field amt_f like t-glcrc.amt_f
	field amtkzt_f like t-glcrc.amtkzt_f
    field dam like t-glcrc.dam
	field damkzt like t-glcrc.damkzt
    field cam like t-glcrc.cam
	field camkzt like t-glcrc.camkzt
    field banks as char
    field v-level as integer
	field kurs like crchis.rate[1] /*курс конвертации*/

    field kurs_f like crchis.rate[1]

    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field lev12 as deci
    field lev2_f as deci /*остаток на 2-ом уровне*/
    field lev2kzt_f as deci /*остаток на 2-ом уровне в kzt*/
    field lev11_f as deci /*остаток на 11-ом уровне*/
    field lev12_f as deci
    field des as char
    field kurs_d as deci

	index gl is primary gl.




/***************************************************************/

/***************************************************************/
find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
    if avail sysc then  do:
        vasof2 = sysc.daval.
        vasof = vasof2.

        vasof_f2 = sysc.daval.
        vasof_f = vasof_f2.

    end.
    else do:
        message  "Внимание! Не найден GLDATE!!!".
        pause 100.
        return.
    end.
v-withprc = no.
update vasof_f label "Введите начальную дату" validate (vasof_f <> ? and vasof_f <= vasof_f2, "Неверная дата!") skip
       with row 9 centered no-box side-labels frame vasfff. /*вводим дату отчета*/

update vasof label "Введите конечную дату" validate (vasof <> ? and vasof <= vasof2, "Неверная дата!") skip
       /*v-withprc label "Учитывать остатки на 2 и 11 уровнях?"*/
       with row 9 centered no-box side-labels frame vasfff. /*вводим дату отчета*/


hide frame vasfff. /*скрыть фрейм для даты*/

update v-crc label "Введите валюту"  validate(can-find(crc where crc.crc eq v-crc), "Валюта с таким номеров не найдена!") with centered row 9 side-label no-box frame crc.


/*ввести счет/счета ГК*/
vglacc = "".
update vglacc label "Введите счет Г/К или нажмите ENTER для всех счетов" with side-labels centered row 9 no-box frame glgl.
hide frame glgl.

if length(vglacc,"CHARACTER") ne 6 and vglacc ne "" then do:
	vglacc = "".
	message "Неверный формат счета Г/К!!! Продолжаю для всех счетов".
	pause 5.
	hide message.
end.
/***************************************************************/

/***Бегаем по фелиалам*****************************/
{r-brfilial.i &proc = "o-salde1 (comm.txb.bank)" }
/**************************************************/


/*Формирование файла для печати*****************************************************************************************/
output to value ("o-salde.htm").
{html-title.i}
find first cmp no-lock no-error.
    put unformatted
      "<P style=""font-size:x-small"">" cmp.name "</P>" skip
      "<P align=""center"" style=""font:bold;font-size:small"">ОСТАТКИ ПО СЧЕТАМ Г/К ЗА  " vasof_f " - " vasof ".<br>Время создания: " + string(time,"HH:MM:SS") + "</P>" skip
      "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""50%"">" skip.


for each t-gl no-lock break by t-gl.gl.
 	if first-of (t-gl.gl) then do:
		put unformatted
		        "<TR align=""center"" style=""font:bold;background:deepskyblue "">" skip
		        "<TD>&nbsp</TD>"
			    "<TD><font size=1 >Г/К</TD>"
		        "<TD><font size=1 >НАЗВАНИЕ</TD>"
		        "<TD><font size=1 >ВАЛЮТА</TD>"
		        "<TD><font size=1 2>СУММА В ВАЛЮТЕ <br>СЧЕТА</TD>"
		        "<TD><font size=1 >СУММА КОНВЕРТ. <br> В ТЕНГЕ</TD>"
		        "<TD >&nbsp</TD>"
		        "<TD >&nbsp</TD>"
		        "<TD >&nbsp</TD>"

                "<TD colspan=4>Обороты</TD>"
                "<TD colspan=4>Обороты в тенге</TD>"
                "<TD >&nbsp</TD>"
                "<TD >&nbsp</TD>"
                "<TD colspan=4>Остатки на уровнях на " vasof_f "</TD>"
                "<TD colspan=4>Остатки на уровнях за " vasof "</TD>"
                "</TR>" skip.
		for each t-glcrc where t-glcrc.gl = t-gl.gl no-lock break by t-glcrc.gl by t-glcrc.crc.
			if first-of (t-glcrc.gl) then do:
 				put unformatted
				        "<tr>
                        <TD>&nbsp</TD>
                        <td align =left><font size=1>" t-gl.gl "</td>"
					    "<td><font size=1>" t-gl.des "</td>"
					    "<td><font size=1>" t-glcrc.crc "</td>"
		        		"<td><font size=1>" replace(trim(string(t-glcrc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
					    "<td><font size=1>" replace(trim(string(t-glcrc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                        "</tr>" skip.
			end.
			else
   				put unformatted "<tr><td>&nbsp</td>"
                 		        "<TD>&nbsp</TD>"
                                "<TD>&nbsp</TD>"
					            "<td><font size=1>" t-glcrc.crc "</td>"
		        		        "<td><font size=1>" replace(trim(string(t-glcrc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
					            "<td><font size=1>" replace(trim(string(t-glcrc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
				                "</tr>" skip.
		    end.
	    end.

        for each t-acc where t-acc.gl = t-gl.gl no-lock break by t-acc.gl by t-acc.fil by t-acc.acc by t-acc.crc BY t-acc.BANKS.
        accumulate t-acc.amtkzt (TOTAL by t-acc.gl) t-acc.amtkzt_f (TOTAL by t-acc.gl) t-acc.damkzt (TOTAL by t-acc.gl) t-acc.camkzt (TOTAL by t-acc.gl).
            IF FIRST-OF (t-acc.gl) THEN DO:
                FIND FIRST TXB WHERE TXB.CONSOLID AND TXB.BANK = t-acc.BANKS NO-LOCK NO-ERROR.
                    IF AVAIL TXB THEN put unformatted
                        "<TR align=""center"" style=""font:bold;background:gainsboro "">"
				        "<TD><font size=1>Филиал</TD>"
					    "<TD><font size=1>Счет</TD>"
		        		"<TD><font size=1>Клиент</TD>"
                        "<TD><font size=1>Наименование клиента</TD>"
				        "<TD><font size=1>Валюта</TD>"
				        "<TD><font size=1>Сектор отраслей <br> экономики</TD>"
				        "<TD><font size=1>Сектор <br> экономики</TD>"
					    "<TD><font size=1>Дата <br> открытия </TD>"
					    "<TD><font size=1>Дата <br> закрытия </TD>"
					    "<TD><font size=1>Ставка<br>(%)</TD>"
                        "<TD><font size=1>Остаток на начало даты </TD>"
                        "<TD><font size=1>Обороты по ДТ </TD>"
                        "<TD><font size=1>Обороты по КТ </TD>"
                        "<TD><font size=1>Остаток на конец даты </TD>"
                        "<TD><font size=1>Остаток на начало даты <br> в тенге </TD>"
                        "<TD><font size=1>Обороты по ДТ <br> в тенге</TD>"
                        "<TD><font size=1>Обороты по КТ <br> в тенге</TD>"
                        "<TD><font size=1>Остаток на конец даты <br> в тенге </TD>"
                        "<TD><font size=1>Курсовые изменения </TD>"
   					    "<TD><font size=1>Гео код </TD>"
                        "<TD><font size=1 >Начисл. %% (2 ур)</TD>"
                        "<TD><font size=1 >Начисл. %% (2 ур в тенге)</TD>"
                        "<TD><font size=1>Начисл. %% (11 ур)</TD>"
                        "<TD><font size=1>Получ. %% (12 ур)</TD>"
                        "<TD><font size=1 >Начисл. %% (2 ур)</TD>"
                        "<TD><font size=1 >Начисл. %% (2 ур в тенге)</TD>"
                        "<TD><font size=1>Начисл. %% (11 ур)</TD>"
                        "<TD><font size=1>Получ. %% (12 ур)</TD>"
                        "</TR>" skip.
            END.
 	    put unformatted     "<tr><td align = left><font size=1>" t-acc.fil "</td>"
                            "<td align = right><font size=1>`" t-acc.acc "</td>"
		                    "<td><font size=1>" t-acc.cif "</td>"
                            "<td><font size=1>" t-acc.cifname "</td>"
				            "<td><font size=1>" t-acc.crc "</td>"
				            "<td><font size=1>" t-acc.ecdivis "</td>"
				            "<td><font size=1>" t-acc.secek "</td>"/* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690. */
		                    "<td><font size=1>" t-acc.rdt "</td>"
 	     			        "<td><font size=1>" t-acc.duedt "</td>"
				            "<td><font size=1>" replace(trim(string(t-acc.rate, "->>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.amt_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.dam,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.cam,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.amtkzt_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.damkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.camkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" t-acc.kurs_d "</td>"
                            "<td><font size=1>`" t-acc.geo "</td>"  skip
                            "<td><font size=1>" replace(trim(string(t-acc.lev2_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
                            "<td><font size=1>" replace(trim(string(t-acc.lev2kzt_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
                            "<td><font size=1>" replace(trim(string(t-acc.lev11_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
   				            "<td><font size=1>" replace(trim(string(t-acc.lev12_f,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "<td><font size=1>" replace(trim(string(t-acc.lev2,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
                            "<td><font size=1>" replace(trim(string(t-acc.lev2kzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
                            "<td><font size=1>" replace(trim(string(t-acc.lev11,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
   				            "<td><font size=1>" replace(trim(string(t-acc.lev12,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                            "</tr>"  skip.
		    if last-of (t-acc.gl) then
			        put unformatted "<tr align=""center"" style=""font:bold;background:gainsboro "">"
                    "<td><font size=1>ИТОГО по счету Г/К " t-acc.gl " в тенге :</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.amtkzt_f, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                    "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.damkzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                    "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.camkzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                    "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.amtkzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<TD>&nbsp</TD>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<td>&nbsp</td>"
                    "<TD>&nbsp</TD>"
                    "</tr>" skip .

	        end.
    end.
put unformatted "</table>" skip.
{html-end.i " "}
output close .
hide all.
unix silent cptwin value("o-salde.htm") excel.
