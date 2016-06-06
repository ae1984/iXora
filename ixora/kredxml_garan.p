/* kredxml_garan.p
 * MODULE
        Ежедневная выгрузка по гарантиям в Кред бюро
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
        21/05/2010 galina
 * CHANGES
        21/07/2011 madiyar - рассылка результата отработки и лога ошибок только на группу fcb@metrocombank.kz
*/

{global.i}

def var v-ans as logi.
def var v-find as char.
def var v-find0 as char.

define new shared var v-paket as int.
define new shared var v-dogcount as int.
v-paket = 1.
input through value( "find /data/log/res_garan.xml;echo $?").
  repeat:
    import unformatted v-find.
  end.
if v-find = "0" then unix silent value("rm /data/log/res_garan.xml").

define new shared stream m-out.
define new shared var v-sendmail as int.
def var v-dbpath as char.
def var v-logfile as char.
def var v-sendfile as char.
def var i as integer.

output stream m-out to "kredgaran.xml".

put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
put stream m-out unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
put stream m-out unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
put stream m-out unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZv2.xsd">' skip.

{r-branch.i &proc = "kredxml1_garan (txb.bank)"}

put stream m-out unformatted '</Records>' skip.
output stream m-out close.
if v-dogcount > 0 then do:
   v-find0 = ''.
   input through value( "find /data/log/kred" + string(v-paket) + "garan.xml;echo $?").
    repeat:
     import unformatted v-find0.
    end.
   if v-find0 = "0" then unix silent value("rm /data/log/kred" + string(v-paket) + "garan.xml").
   unix silent cp kredgaran.xml value("/data/log/kred" + string(v-paket) + "garan.xml").
   unix silent koi2utf kredgaran.xml kreditgaran.xml.
   unix silent value ("cb1pump.pl -zip -login=Mbuser37 -password=Nastya2211 -method=UploadZippedData2 -file2send=kreditgaran.xml > /data/log/res_garan.xml") .
   run mail('FCB@metrocombank.kz', "METROKOMBANK <abpk@metrobank.kz>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res_garan.xml").
end.


/*отправляем письмо об ошибках*/
if  v-sendmail > 0 then do:
    find sysc where sysc.sysc = "stglog" no-lock no-error.
    v-dbpath = sysc.chval.
    if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
    v-logfile = "kredbureau." + string(today, "99.99.9999" ) + ".log".
    v-sendfile = "cb1_garanerror." + string(today, "99.99.9999" ) + ".txt".
    unix silent value("/pragma/bin9/un-win " + v-dbpath + v-logfile + " " + v-sendfile).
    run mail("FCB@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Выгрузка в КБ1. Ошибки!", " ", "", "",v-sendfile).
    unix silent rm -f value(v-sendfile).
end.


