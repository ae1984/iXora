/* pcarpostload.p
 * MODULE
        Загрузка остаков из Openway по транзитны счетам
 * DESCRIPTION
        для загрузки необходимо положить файлы в D:/euraz/Cards/IN/Trial Balance на сервере fs01
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        12.08.2013 galina
 * CHANGES


*/
{global.i}

define variable v-readvalue  as character no-undo.
define variable v-cardarproot    as character no-undo.
define variable v-pcarpsum    as character no-undo.
define variable v-filename   as character no-undo.
define variable v-str        as character no-undo.
define variable v-infile     as character no-undo.
define variable v-copyed     as character no-undo.
define variable v-readline   as character no-undo.
define variable v-files      as character no-undo.
define variable v-count      as int no-undo.
def var v-arp as char no-undo.
def var v-bank as char no-undo.
def var v-date as date no-undo.
def var v-crccode as char no-undo.
def var v-inbal as deci no-undo.
def var v-debit as deci no-undo.
def var v-credit as deci no-undo.
def var v-outbal as deci no-undo.
def var v-crc as int no-undo.
define stream   v-fnstream.
define stream   v-fstream.




input through value('ssh Administrator@fs01.metrobank.kz dir /b "D:\\euraz\\Cards\\In\\TrialBalance\\*"').
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
        if v-str <> "" then v-str = v-str + "|".
        v-files = v-files + v-str.
    end.
end.

def var v-select as char.
run sel2 ("Выберите файл для загрузки", v-files, output v-select).
if v-select = "0" then return.
v-filename = entry(int(v-select) , v-files , "|").


run savelog ("pcarpsum", v-filename + " Начало загрузки ... " ).


run chengefilerights("/tmp/pcarpsum/").

unix silent value ("rm -f /tmp/pcarpsum*//*").

v-cardarproot = "/data/import/pcarpsum/" .
run chengefilerights(v-cardarproot).

v-pcarpsum = v-cardarproot + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
run chengefilerights(v-pcarpsum).

input through value("scp -pq Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/TrialBalance/" + v-filename + " /tmp/pcarpsum/" + v-filename + ";echo $?").
import unformatted v-str.
if v-str <> "0" then do:
    run savelog( "pcarpsum", "Ошибка копирования файла ! " + v-filename).
    message "Ошибка копирования файла ! " + v-filename
    "Имя файла не должно содержать русские символы и пробелы!" view-as alert-box.
    return.
end.


input through value( "find /tmp/pcarpsum/" + v-filename + ";echo $?").
repeat:
    import unformatted v-str.
end.
if v-str <> "0" then do:
   run savelog ("pcarpsum", v-filename + " файл не найден.").
   message v-filename + " файл не найден." view-as alert-box.
   return.
end.
output to value("/tmp/pcarpsum/" + v-filename) append.
put unformatted chr(10).
output close.
/**/
def var v-loadstr as int.
v-loadstr = 0.
input stream v-fnstream from value("/tmp/pcarpsum/" + v-filename).
v-count = 0.
repeat:
   do transaction:
       v-count = v-count + 1.
       import stream v-fnstream unformatted v-readline.

       if trim(v-readline) = '' then next.

       if num-entries(v-readline,chr(9)) <> 8 then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + ": " + v-readline  + ' Неверный формат строки').
           next.
       end.
       if v-readline begins 'FILIAL' then next.

       assign v-arp = trim(entry(2,v-readline,chr(9)))
              v-crccode = trim(entry(4,v-readline,chr(9))).

       v-date = date(trim(entry(3,v-readline,chr(9)))) no-error.
       if error-status:error then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный формат даты ' + trim(entry(3,v-readline,chr(9)))).
           next.
       end.

       v-inbal = deci(trim(entry(5,v-readline,chr(9)))) no-error.
       if error-status:error then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный формат BEGIN_BALANCE ' + trim(entry(5,v-readline,chr(9)))).
           next.

       end.

       v-debit = deci(trim(entry(6,v-readline,chr(9)))) no-error.
       if error-status:error then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный формат DEBIT ' + trim(entry(6,v-readline,chr(9)))).
           next.

       end.

       v-credit = deci(trim(entry(7,v-readline,chr(9)))) no-error.
       if error-status:error then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный формат CREDIT ' + trim(entry(7,v-readline,chr(9)))).
           next.

       end.

       v-outbal = deci(trim(entry(8,v-readline,chr(9)))) no-error.
       if error-status:error then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный формат END_BALANCE ' + trim(entry(8,v-readline,chr(9)))).
           next.
       end.

       if v-arp = '285900' or v-arp = '185800' then next.
       else do:
           v-bank = ''.
           if v-arp begins "KZ" then do:
                find first txb where txb.bank = 'TXB' + substr(v-arp,length(v-arp) - 1,2) no-lock no-error.
                if not avail txb then do:
                    run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Не найден филиал ' + substr(v-arp,length(v-arp) - 1,2)).
                    next.
                end.
                else v-bank = txb.bank.
           end.
       end.
       find first crc where crc.code = v-crccode no-lock no-error.
       if not avail crc then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + '. Неверный код валюты ' + v-crccode).
           next.
       end.
       else v-crc = crc.crc.

       find first pcarpsum where pcarpsum.bank = v-bank and pcarpsum.arp = v-arp  and pcarpsum.dtost = v-date no-lock no-error.
       if avail pcarpsum then do:
           run savelog ("pcarpsum", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + ". Запись по счету " + v-arp + " за дату " + string(v-date) + " уже есь в базе").
           next.
       end.
       else do:
         create pcarpsum.
         assign pcarpsum.bank = v-bank
                pcarpsum.arp = v-arp
                pcarpsum.dtost = v-date
                pcarpsum.inbal = v-inbal
                pcarpsum.debit = v-debit
                pcarpsum.credit = v-credit
                pcarpsum.outbal = v-outbal
                pcarpsum.rwho = g-ofc
                pcarpsum.rwhn = g-today
                pcarpsum.filename = v-filename
                pcarpsum.rtim = time.
         v-loadstr = v-loadstr + 1.
       end.
       hide message no-pause.
       message "Обрабатывается строка " v-count " ".
   end.


end.
hide message no-pause.
input stream v-fnstream close.


if v-count <= 1 then do:
   run savelog ("pcarpsum", v-filename + " файл пуст.").
   message v-filename + " файл пуст." view-as alert-box.
   return.
end.



run savelog ("pcarpsum", v-filename + " Количество загруженных строк " + string(v-loadstr)).


unix silent value('cp /tmp/pcarpsum/' + v-filename + " " + v-pcarpsum).

def var v-dbpath as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
unix silent value("cptwin " + v-dbpath + "pcarpsum." + string(today, "99.99.9999" ) + ".log wordpad").


procedure chengefilerights.
	def input parameter dir_name as char.
    def var v-exist as char.

	input through value( "find " + dir_name + ";echo $?").
	repeat:
  		import unformatted v-exist.
	end.
	if v-exist <> "0" then do:
       unix silent value ("mkdir " + dir_name).
  	   unix silent value("chmod 777 " + dir_name).
	end.
end procedure.