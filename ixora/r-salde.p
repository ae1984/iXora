/* r-salde.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.01.2013 ТЗ-1626
 * BASES
        BANK
 * CHANGES
*/

/*Переменные****************************************************/
def new shared var v-gllist  as char.
def new shared var v-isdialog  as logi.
def new shared var v-print  as logi.
def new shared var v-headgl  as logi.
def new shared var v-okedall as char init "".

def new shared var vasof  as date.
def new shared var vasof2 like vasof.
def new shared var v-crc  like crc.crc.
def new shared var vglacc as char format "x(6)".
def new shared var v-withprc as logi.
def new shared var v-withzero as logi.
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
	index gl is primary gl.

def new shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
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

v-gllist = "".
v-isdialog = yes.
vglacc = "".

v-print = yes.
v-headgl = yes.
v-okedall = "".

run r-salde0.


