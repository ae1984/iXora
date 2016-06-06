/* kredxml.p
 * MODULE
        Формирование файла для загрузки в Кред бюро
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        BANK COMM
 * AUTHOR
        07/09/07 marinav
 * CHANGES
        09/10/07 marinav - изменен формат
        22/11/07 marinav - деление на пакеты по 1000 записей
        19.02.08 marinav - удалено pksysc.daval = g-today, т к коннект не отрабатывал.......(???)
        13.08.2008 galina - рассылка файла с ошибками на меня и кред.администратора
        18.08.2008 galina - поменяла пароль на новый Arman2008
        19.08.2008 galina - исправила адрес получателя
        10.09.2008 galina - проверяем наличие файла перед удалением
        17.10.2008 galina - поменяла пароль и логин на новый
        25/03/2009 galina - добавила Саяна Рахимова (id00027) в рассылку результата выгрузки
        18.06.2009 galina - изменила пароль и логин
        27/10/2009 galina - поменяла пароль
        20/12/2009 galina - поменяла пароль и логин
        02/09/2010 galina - удаляем лог ошибок, если он уже сущетсвует
        21/07/2011 madiyar - рассылка результата отработки и лога ошибок только на группу fcb@metrocombank.kz
        11/08/2011 kapar ТЗ947
        30/12/2011 kapar по ТЗ947 дополнительный контроль
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        17/05/2012 kapar - изменил пароль
        19/08/2013 Sayat(id01143) - ТЗ 1776 от 27/03/2013 "Изменения в отчете «Признак согласия на отправку в Кредитное Бюро»"
*/



{global.i}
{nbankBik.i}

def var v-ans as logi.
def var v-find as char.
def var v-find0 as char.
def var v-find1 as char.
def var num as char.
find first cmp no-lock no-error.
if cmp.name matches '*МКО*'  then num = 'MKO'.
else num = 'GB'.

      v-ans = false.
      message skip " Выгрузить данные в ПКБ по " + v-nbank1 + " ... ?" skip(1) view-as alert-box buttons yes-no title "" update v-ans.
      if not v-ans then return.

define new shared var v-paket as int.
define new shared var v-dogcount as int.
define new shared var v-paket1 as int.
define new shared var v-garcount as int.

v-paket = 1.
v-paket1 = 1.
v-dogcount = 0.
v-garcount = 0.
input through value( "find /data/log/res.xml;echo $?").
  repeat:
    import unformatted v-find.
  end.
if v-find = "0" then unix silent value("rm /data/log/res.xml").


def var v-dbpath as char.
def var v-findlog as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
v-findlog = ''.
input through value( "find " + v-dbpath + "kredbureau." + string(today, "99.99.9999" ) + ".log;echo $?").
repeat:
     import unformatted v-findlog.
end.
if v-findlog = "0" then unix silent rm -f value(v-dbpath + "kredbureau." + string(today, "99.99.9999" ) + ".log").





define new shared stream m-out.
define new shared var v-sendmail as int.

define new shared stream m-out1.
define new shared var v-sendmail1 as int.

def var v-logfile as char.
def var v-sendfile as char.
def var i as integer.

output stream m-out to "kred.xml".

put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
put stream m-out unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
put stream m-out unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
put stream m-out unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZ_v5.xsd">' skip.

output stream m-out1 to "gar.xml".

put stream m-out1 unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
put stream m-out1 unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
put stream m-out1 unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
put stream m-out1 unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZ_v5_guar.xsd">' skip.

{r-branch.i &proc = "kredxml1 (txb.bank)"}

put stream m-out unformatted '</Records>' skip.
put stream m-out1 unformatted '</Records>' skip.
output stream m-out close.
output stream m-out1 close.

/*message 'v-garcount = ' + string(v-garcount) + ' v-dogcount = ' + string(v-dogcount) view-as alert-box.*/
if v-garcount > 0 then do:
    v-find0 = ''.
    input through value( "find /data/log/gar" + string(v-paket1) + ".xml;echo $?").
    repeat:
        import unformatted v-find0.
    end.
    if v-find0 = "0" then unix silent value("rm /data/log/gar" + string(v-paket1) + ".xml").
    unix silent cp gar.xml value("/data/log/gar" + string(v-paket1) + ".xml").
    unix silent koi2utf gar.xml garan.xml.
    unix silent value ("cb1pump.pl -zip -login=MBuser56 -password=2W3e4r5t -method=UploadZippedData2 -schid=11 -file2send=garan.xml > /data/log/res.xml") .
    run mail('FCB@fortebank.com', "FORTEBANK <abpk@fortebank.com>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res.xml").

    v-find1 = ''.
    input through value( "find `askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml;echo $?").
    repeat:
        import unformatted v-find1.
    end.
    if v-find1 = "0" then unix silent value("rm `askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml").
    unix silent scp -q garan.xml value(" Administrator@`askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml").
end.
if v-dogcount > 0 then do:
    v-find0 = ''.
    input through value( "find /data/log/kred" + string(v-paket) + ".xml;echo $?").
    repeat:
        import unformatted v-find0.
    end.
    if v-find0 = "0" then unix silent value("rm /data/log/kred" + string(v-paket) + ".xml").
    unix silent cp kred.xml value("/data/log/kred" + string(v-paket) + ".xml").
    unix silent koi2utf kred.xml kredit.xml.
    unix silent value ("cb1pump.pl -zip -login=MBuser56 -password=2W3e4r5t -method=UploadZippedData2 -schid=3 -file2send=kredit.xml > /data/log/res.xml") .
    run mail('FCB@fortebank.com', "FORTEBANK <abpk@fortebank.com>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res.xml").
    v-find1 = ''.
    input through value( "find `askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml;echo $?").
    repeat:
        import unformatted v-find1.
    end.
    if v-find1 = "0" then unix silent value("rm `askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml").
    unix silent scp -q kredit.xml value(" Administrator@`askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml").
end.

/*отправляем письмо об ошибках*/
if  v-sendmail > 0 then do:
    /*find sysc where sysc.sysc = "stglog" no-lock no-error.
    v-dbpath = sysc.chval.*/
    if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
    v-logfile = "kredbureau." + string(today, "99.99.9999" ) + ".log".
    v-sendfile = "cb1_error." + string(today, "99.99.9999" ) + ".txt".
    unix silent value("/pragma/bin9/un-win " + v-dbpath + v-logfile + " " + v-sendfile).
    run mail("FCB@fortebank.com","FORTEBANK <abpk@fortebank.com>", "Выгрузка в КБ1. Ошибки!", " ", "", "",v-sendfile).
    unix silent rm -f value(v-sendfile).
end.

find first pksysc where pksysc.sysc = '1cb' no-error.
/*if pksysc.daval ne g-today then pksysc.daval = g-today.*/



