/* eknp_f3.p
 * MODULE
        Название модуля - Внутрибанковские операции
 * DESCRIPTION
        Описание - Форма-3 (движение денег на банковских счетах)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.6.5
 * BASES
        BANK COMM
 * AUTHOR
        05/04/2006 dpuchkov
 * CHANGES
        31.08.2006 dpuchkov оптимизация
        04/06/09 marinav исправлен путь к файлу
        30.03.2011 marinav - добавили КНП
        21.12.2012 damir - Отчет работал неправильно. Доработано с последними изменения НБРК. Внедрено Т.З. № 1620.
        05.02.2013 damir - Перекомпиляция. Исключил возможность повторения сохранения записей в tmp-jss.
*/
{mainhead.i}
{chbin.i}
{eknpjss_var.i "new"}

def temp-table tmp-jss
    field jssbin as char.

def var v-ifile_1 as char init "rnn.txt".
def var v-ifile_2 as char init "bin.txt".
def var v-str as char.
def var v-rsh as logi format "да/нет".
def var v-numrsh as char.

def var v-file1 as char init "eknp_f3_1.htm".
def var v-file2 as char init "eknp_f3_2.htm".

def stream v_rep1.
def stream v_rep2.

update
    vn-dtbeg label "с"
    vn-dt    label "по" skip(1)
    v-rsh    label "расшифровка" skip
with side-labels centered row 9 title "Введите" frame Rep.

if not v-rsh then v-numrsh = "0".
else do:
    run sel("Расшифровки","расшифровка1|расшифровка2|все").
    if return-value = "1" then v-numrsh = "1".
    else if return-value = "2" then v-numrsh = "2".
    else v-numrsh = "1,2".
end.

empty temp-table tmp-jss.
/*input through value("scp -q  Administrator@fs01.metrobank.kz:D:/public/Rep/rnn.txt ./ ;echo $?").*/
input through value("scp -q  Administrator@fs01.metrobank.kz:D:/public/Rep/bin.txt ./ ;echo $?").
input from value(v-ifile_2).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    find first tmp-jss where tmp-jss.jssbin = v-str no-lock no-error.
    if not avail tmp-jss then do:
        create tmp-jss.
        tmp-jss.jssbin = v-str.
    end.
end.
input close.

empty temp-table t-rash_1.
empty temp-table t-rash_2.

for each tmp-jss:
    v-jss = tmp-jss.jssbin.
    {r-branch.i &proc = "eknpjss"}
end.

/*Расшифровка 1*/
output stream v_rep1 to value(v-file1).
{html-title.i &stream = "stream v_rep1"}

put stream v_rep1 unformatted
    "<TABLE width='100%' border='1' cellpadding='0' cellspacing='0'>" skip.

put stream v_rep1 unformatted
    "<TR style='font-size:12pt;font:bold'>" skip
/*1*/    "<TD>Филиал</TD>" skip
/*2*/    "<TD>Код филиала</TD>" skip
/*3*/    "<TD>Наименование клиента</TD>" skip
/*4*/    "<TD>Балансовый счет</TD>" skip
/*5*/    "<TD>Счет главной книги</TD>" skip
/*6*/    "<TD>Лицевой счет</TD>" skip
/*7*/    "<TD>Валюта счета</TD>" skip
/*8*/    "<TD>Остаток на начало месяца</TD>" skip
/*9*/    "<TD>Обороты по Дт</TD>" skip
/*10*/   "<TD>Обороты по Кт</TD>" skip
/*11*/   "<TD>Остаток на конец месяца</TD>" skip
    "</TR>" skip.

for each t-rash_1 no-lock:
    put stream v_rep1 unformatted
        "<TR style='font-size:10pt'>" skip
    /*1*/    "<TD>" t-rash_1.bnkname "</TD>" skip
    /*2*/    "<TD>" t-rash_1.txb "</TD>" skip
    /*3*/    "<TD>" t-rash_1.cifname "</TD>" skip
    /*4*/    "<TD>" string(t-rash_1.gl_4) "</TD>" skip
    /*5*/    "<TD>" string(t-rash_1.gl) "</TD>" skip
    /*6*/    "<TD>" t-rash_1.acc "</TD>" skip
    /*7*/    "<TD>" t-rash_1.crccode "</TD>" skip
    /*8*/    "<TD>" replace(string(t-rash_1.bal_beg,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*9*/    "<TD>" replace(string(t-rash_1.dam,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*10*/   "<TD>" replace(string(t-rash_1.cam,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*11*/   "<TD>" replace(string(t-rash_1.bal_end,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
        "</TR>" skip.
end.

put stream v_rep1 unformatted
    "</TABLE>" skip.

{html-end.i "stream v_rep1"}
output stream v_rep1 close.

/*Расшифровка 2*/
output stream v_rep2 to value(v-file2).
{html-title.i &stream = "stream v_rep2"}

put stream v_rep2 unformatted
    "<TABLE width='100%' border='1' cellpadding='0' cellspacing='0'>" skip.

put stream v_rep2 unformatted
    "<TR style='font-size:12pt;font:bold'>" skip
/*1*/    "<TD>Филиал</TD>" skip
/*2*/    "<TD>Код филиала</TD>" skip
/*3*/    "<TD>Наименование клиента</TD>" skip
/*4*/    "<TD>Дата документа</TD>" skip
/*5*/    "<TD>№ документа</TD>" skip
/*6*/    "<TD>Назначение платежа</TD>" skip
/*7*/    "<TD>Дт Балансовый счет</TD>" skip
/*8*/    "<TD>Дт Счет главной книги</TD>" skip
/*9*/    "<TD>Дт Лицевой счет</TD>" skip
/*10*/   "<TD>Дт валюта счета</TD>" skip
/*11*/   "<TD>Кт Балансовый счет</TD>" skip
/*12*/   "<TD>Кт Счет главной книги</TD>" skip
/*13*/   "<TD>Кт Лицевой счет</TD>" skip
/*14*/   "<TD>Кт валюта счета</TD>" skip
/*15*/   "<TD>Обороты по Дт в номинале</TD>" skip
/*16*/   "<TD>Обороты по Дт в тенге</TD>" skip
/*17*/   "<TD>Обороты по Kт в номинале</TD>" skip
/*18*/   "<TD>Обороты по Kт в тенге</TD>" skip
/*19*/   "<TD>Код</TD>" skip
/*20*/   "<TD>Кбе</TD>" skip
/*21*/   "<TD>КНП</TD>" skip
/*22*/   "<TD>Наименование Банка бенефициара</TD>" skip
/*23*/   "<TD>Swift код Банка бенефициара</TD>" skip
/*24*/   "<TD>Наименование Банка отправителя</TD>" skip
/*25*/   "<TD>Swift код Банка отправителя</TD>" skip
    "</TR>" skip.

for each t-rash_2 no-lock:
    put stream v_rep2 unformatted
        "<TR style='font-size:10pt'>" skip
    /*1*/    "<TD>" t-rash_2.bnkname "</TD>" skip
    /*2*/    "<TD>" t-rash_2.txb "</TD>" skip
    /*3*/    "<TD>" t-rash_2.cifname "</TD>" skip
    /*4*/    "<TD>" string(t-rash_2.dtdoc,"99/99/9999") "</TD>" skip
    /*5*/    "<TD>" t-rash_2.rmz "</TD>" skip
    /*6*/    "<TD>" t-rash_2.rem "</TD>" skip
    /*7*/    "<TD>" string(t-rash_2.drgl_4) "</TD>" skip
    /*8*/    "<TD>" string(t-rash_2.drgl) "</TD>" skip
    /*9*/    "<TD>" t-rash_2.dacc "</TD>" skip
    /*10*/   "<TD>" t-rash_2.dcrccode "</TD>" skip
    /*11*/   "<TD>" string(t-rash_2.crgl_4) "</TD>" skip
    /*12*/   "<TD>" string(t-rash_2.crgl) "</TD>" skip
    /*13*/   "<TD>" t-rash_2.cacc "</TD>" skip
    /*14*/   "<TD>" t-rash_2.ccrccode "</TD>" skip
    /*15*/   "<TD>" replace(string(t-rash_2.damcrc,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*16*/   "<TD>" replace(string(t-rash_2.damkzt,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*17*/   "<TD>" replace(string(t-rash_2.camcrc,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*18*/   "<TD>" replace(string(t-rash_2.camkzt,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
    /*19*/   "<TD>" t-rash_2.KOd "</TD>" skip
    /*20*/   "<TD>" t-rash_2.KBe "</TD>" skip
    /*21*/   "<TD>" t-rash_2.KNP "</TD>" skip
    /*22*/   "<TD>" t-rash_2.benbank "</TD>" skip
    /*23*/   "<TD>" t-rash_2.swiftben "</TD>" skip
    /*24*/   "<TD>" t-rash_2.ordbank "</TD>" skip
    /*25*/   "<TD>" t-rash_2.swiftord "</TD>" skip
        "</TR>" skip.
end.
put stream v_rep2 unformatted
    "</TABLE>" skip.

{html-end.i "stream v_rep2"}
output stream v_rep2 close.

if lookup("1",v-numrsh) > 0 then unix silent cptwin value(v-file1) excel.
if lookup("2",v-numrsh) > 0 then unix silent cptwin value(v-file2) excel.






