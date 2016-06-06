/* r-salde.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	   Сальдовка развернутая с остатками по субсчетам
		консолидированная
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	r-salde1.p
 * MENU
        Перечень пунктов Меню Прагмы
	8-12-10
 * AUTHOR
        29/12/04 u00121
 * BASES
        BANK COMM
 * CHANGES
       09.09.05 nataly добавлен столбец "Гео код"
       02/07/09 marinav - добавлен филиал
       07/08/2009 madiyar - добавлены стобцы по процентам
       31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690.
                    + Изменены столбцы отчета:
                    - Сектор ОТРАСЛЕЙ экономики = sub-cod.d-cod = "ecdivis"
                    + Добавлены столбцы отчета:
                    - Сектор экономики = sub-cod.d-cod = "secek"
       05/08/2010 aigul - добавление информации о клиентах связанных с банком особыми отношениями
       09/12/2010 evseev - добавление столбца "Сумма по договору". В кредитах - сумма в договоре, в депозитах - сумма первого взноса.
       22/12/2010 evseev - добавление столбцов "основание" "условие обслуживания"
       11/03/2011 evseev - исправил ошибку отображения даты
       21.07.2011 ruslan - добавил опцию по счетам с нулевыми остатаками и изменил rate
       02/08/2011 evseev - добавил столбцы для вывода даты при пролонгации депозита
       24.09.2012 evseev - ТЗ-1368
       15/01/2013 Luiza  - добавила колонку код сегментации
       17.01.2013 evseev - ТЗ-1626
       21.01.2013 evseev - перекомпиляция
*/

{mainhead.i}

/*Переменные****************************************************/
def shared var v-gllist  as char.
def shared var v-isdialog  as logi.
def shared var v-print  as logi.
def shared var v-headgl  as logi.
def shared var v-okedall as char init "".

def shared var vasof  as date.
def  shared var vasof2 like vasof.
def  shared var v-crc  like crc.crc.
def  shared var vglacc as char format "x(6)".
def  shared var v-withprc as logi.
def  shared var v-withzero as logi.
/***************************************************************/

/*Временные таблицы*********************************************/
def  shared temp-table t-gl /*временная таблица для сбора данных по счетам ГК*/
	field gl like gl.gl /*счет ГК*/
	field des like gl.des /*Название ГК*/
	index gl is primary unique gl.

def  shared temp-table t-glcrc
	field gl like gl.gl /*счет ГК*/
	field crc like crc.crc /*Валюта*/
	field amt as dec format "zzz,zzz,zzz,zzz.99-" /*сумма в валюте счета, зависит от валюты*/
	field amtkzt as dec format "zzz,zzz,zzz,zzz.99-" /*Сумма в валюте счета конвертированная в тенге*/
	index gl is primary gl.

def  shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
	field gl  like t-gl.gl  /*счет ГК*/
	field acc like aaa.aaa  /*субсчет ГК*/
	field cif as char format "x(20)"  /*Название клиента*/
    field rnn as char format "x(12)"  /*РНН*/
	field geo as char format "x(3)"  /*ГЕО код*/
	field crc like crc.crc  /*валюта субсчета*/
	field ecdivis like sub-cod.ccode /*сектор отраслей экономики клиента*/
	field secek like sub-cod.ccode /*сектор экономики клиента*/ /* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690.*/
	field rdt like aaa.regdt /*дата открытия счета*/
	field duedt like arp.duedt /*дата закрытия счета*/

    field rdt1 as char /*пролонгация счета*/
    field duedt1 as char /*окончание действия счета*/

    field rate like aaa.rate /*процентная ставка по счету, если есть*/

    field opnamt like t-glcrc.amt /*сумма по договору*/

	field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
	field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/
	field kurs like crchis.rate[1] /*курс конвертации*/
    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field des as char
    field attrib as char /*признак bnkrel*/
    field uslov as char /*услоние обслуживания*/
    field osnov as char /*основание*/
    field clnsegm as char /* код сегментации */
    /*field krate like accr.rate ставка по счету на день загрузки отчета*/
	index gl is primary gl.
/***************************************************************/
{chbin.i}
/***************************************************************/
if  v-isdialog then do:
    find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
    if avail sysc then do:
        vasof2 = sysc.daval.
        vasof = vasof2.
    end.
    else do:
        message  "Внимание! Не найден GLDATE!!!".
        pause 100.
        return.
    end.
    v-withprc = no.
    update vasof label "Введите дату" validate (vasof <> ? and vasof <= vasof2, "Неверная дата!") skip
           v-withprc label "Учитывать остатки на 2 и 11 уровнях?" skip
           v-withzero label "Учитывать счета с нулевыми остатками"
           with row 9 centered no-box side-labels frame vasfff. /*вводим дату отчета*/

    hide frame vasfff. /*скрыть фрейм для даты*/
    update v-crc label "Введите валюту"  validate(can-find(crc where crc.crc eq v-crc), "Валюта с таким номеров не найдена!") with centered row 9 side-label no-box frame crc.


    /*ввести счет/счета ГК*/
    vglacc = "".
    update vglacc label "Введите счет Г/К или нажмите ENTER для всех счетов" with side-labels centered row 9 no-box frame glgl.
    hide frame glgl.
end.

if length(vglacc,"CHARACTER") ne 6 and vglacc ne "" then do:
	vglacc = "".
	message "Неверный формат счета Г/К!!! Продолжаю для всех счетов".
	pause 5.
	hide message.
end.
/***************************************************************/

/***Бегаем по филиалам*****************************/
{r-brfilial.i &proc = "r-salde1 (comm.txb.bank)" }
/**************************************************/
if v-okedall <> "" then do:
    output to t-acc-delete.csv.
    for each t-acc:
        if t-acc.gl = 220431 then t-acc.ecdivis = '9991'.
        if t-acc.gl = 223730 then t-acc.ecdivis = '9992'.
        if lookup(t-acc.ecdivis,v-okedall) = 0 then do:
           export delimiter ';' t-acc.
           delete t-acc.
        end.
    end.
end.


if v-print then do:
    output to value ("r-salde.htm").
    {html-title.i}
    find first cmp no-lock no-error.
    put unformatted "<P style=""font-size:x-small"">" cmp.name "</P>" skip
                    "<P align=""center"" style=""font:bold;font-size:small"">ОСТАТКИ ПО СЧЕТАМ Г/К ЗА  " vasof ".<br>Время создания: " + string(time,"HH:MM:SS") + "</P>" skip
                    "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""50%"">" skip.

    for each t-gl no-lock break by t-gl.gl.
        if v-headgl and first-of (t-gl.gl) then do:
            put unformatted
            "<TR align=""center"" style=""font:bold;background:deepskyblue "">" skip
            "<TD>&nbsp</TD>"
            "<TD><font size=1>Г/К</TD>"
            "<TD><font size=1>НАЗВАНИЕ</TD>"
            "<TD><font size=1>ВАЛЮТА</TD>"
            "<TD><font size=1>СУММА В ВАЛЮТЕ <br>СЧЕТА</TD>"
            "<TD><font size=1>СУММА КОНВЕРТ. <br> В ТЕНГЕ</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "<TD>&nbsp</TD>"
            "</TR>" skip.
            for each t-glcrc where t-glcrc.gl = t-gl.gl no-lock break by t-glcrc.gl by t-glcrc.crc.
                if first-of (t-glcrc.gl) then do:
                    put unformatted
                    "<tr><TD>&nbsp</TD>
                    <td align =left><font size=1>" t-gl.gl "</td>"
                    "<td><font size=1>" t-gl.des "</td>"
                    "<td><font size=1>" t-glcrc.crc "</td>"
                    "<td><font size=1>" replace(trim(string(t-glcrc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                    "<td><font size=1>" replace(trim(string(t-glcrc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "</tr>" skip.
                end.
                else
                    put unformatted "<tr><td>&nbsp</td>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<td><font size=1>" t-glcrc.crc "</td>"
                    "<td><font size=1>" replace(trim(string(t-glcrc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                    "<td><font size=1>" replace(trim(string(t-glcrc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD>"
                    "<TD>&nbsp</TD></tr>" skip.
            end.
        end.
        for each t-acc where t-acc.gl = t-gl.gl no-lock break by t-acc.gl by t-acc.fil by t-acc.acc by t-acc.crc.
            accumulate t-acc.amtkzt (TOTAL by t-acc.gl) t-acc.lev2kzt (TOTAL by t-acc.gl) t-acc.lev11 (TOTAL by t-acc.gl).
            if first-of (t-acc.gl) then do:
                put unformatted
                "<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
                "<TD><font size=1>Филиал</TD>"
                "<TD><font size=1>Счет</TD>"
                "<TD><font size=1>Клиент</TD>"
                "<TD><font size=1>Валюта</TD>"
                "<TD><font size=1>Сектор отраслей <br> экономики</TD>" /* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690. */
                "<TD><font size=1>Сектор <br> экономики</TD>" /* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690. */
                "<TD><font size=1>Дата <br> открытия </TD>"
                "<TD><font size=1>Дата <br> закрытия </TD>"
                "<TD><font size=1>Код <br> сегментации </TD>"
                "<TD><font size=1>Ставка<br>(%)</TD>"
                /*"<TD><font size=1>Ставка<br> на дату(%)</TD>"*/
                "<TD><font size=1>Сумма по <br> договору </TD>"
                "<TD><font size=1>Сумма в валюте<br>счета</TD>"
                "<TD><font size=1>Сумма конверт. <br> в тенге</TD>"
                "<TD><font size=1>Курс конверт. <br> в тенге</TD>"
                "<TD><font size=1>Гео код </TD>"
                "<TD><font size=1>Нач. %%</TD>"
                "<TD><font size=1>Нач. %% (KZT)</TD>"
                "<TD><font size=1>Расходы (11 ур)</TD>"
                "<TD><font size=1>Группа депозита </TD>"
                "<TD><font size=1>Признак 'Лица связанные с банком особыми отношениями' </TD>"
                "<TD><font size=1>Условине<br>обслуживания</TD>"
                "<TD><font size=1>Основание</TD>"
                "<TD><font size=1>Дата открытия <br> после пролонгации</TD>"
                "<TD><font size=1>Дата закрытия <br> после пролонгации</TD>"
                "<TD><font size=1>"  + v-labelidn +  "</TD>"
                "</TR>" skip.
            end.
            put unformatted "<tr><td align = left><font size=1>" t-acc.fil "</td>"
            "<td align = right><font size=1>`" t-acc.acc "</td>"
            "<td><font size=1>" t-acc.cif "</td>"
            "<td><font size=1>" t-acc.crc "</td>"
            "<td><font size=1>" if lookup(t-acc.ecdivis,'9991,9992') > 0 then '' else t-acc.ecdivis "</td>"
            "<td><font size=1>" t-acc.secek "</td>"/* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690. */
            "<td><font size=1>" string(t-acc.rdt,"99/99/9999") "</td>"
            "<td><font size=1>" string(t-acc.duedt,"99/99/9999") "</td>"
            "<td><font size=1>" t-acc.clnsegm "</td>"
            "<td><font size=1>" replace(trim(string(t-acc.rate, "->>9.99")), ".", ",") "</td>"
            /*"<td><font size=1>" replace(trim(string(t-acc.krate, "->>9.99")), ".", ",") "</td>"*/
            "<td align=right><font size=1>" replace(trim(string(t-acc.opnamt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
            "<td align=right><font size=1>" replace(trim(string(t-acc.amt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
            "<td align=right><font size=1>" replace(trim(string(t-acc.amtkzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
            "<td><font size=1>" replace(trim(string(t-acc.kurs, "->>9.99")), ".", ",") "</td>"
            "<td><font size=1>'" t-acc.geo "</td>"  skip
            "<td><font size=1>" replace(trim(string(t-acc.lev2,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
            "<td><font size=1>" replace(trim(string(t-acc.lev2kzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
            "<td><font size=1>" replace(trim(string(t-acc.lev11,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
            "<td><font size=1>" t-acc.des  "</td>"  skip
            "<td><font size=1>" t-acc.attrib  "</td>"
            "<td><font size=1>" t-acc.uslov  "</td>"
            "<td><font size=1>" t-acc.osnov  "</td>"
            "<td><font size=1>" t-acc.rdt1  "</td>"
            "<td><font size=1>" t-acc.duedt1 "</td>"
            "<td><font size=1>'" t-acc.rnn  "</td></tr>"  skip.
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
                "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.amtkzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                "<td>&nbsp</td>"
                "<td>&nbsp</td>"
                "<td>&nbsp</td>"
                "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.lev2kzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                "<td><font size=1>" replace(trim(string(accum total by (t-acc.gl) t-acc.lev11, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "<TD>&nbsp</TD>"
                "</tr>" skip .

        end.
    end.
    put unformatted "</table>" skip.

    {html-end.i " "}
    output close .
    hide all.
    unix silent cptwin value("r-salde.htm") excel.

end.