/* vinload.p
 * MODULE
        Загрузка обновлений базы VIN кодов
 * DESCRIPTION
        для загрузки необходимо положить файлы в C:\vinload\
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
        22.07.2013 galina
 * CHANGES


*/
{global.i}

define variable v-readvalue  as character no-undo.
define variable v-vinroot    as character no-undo.
define variable v-vinload    as character no-undo.
define variable v-filename   as character no-undo.
define variable v-str        as character no-undo.
define variable v-infile     as character no-undo.
define variable v-copyed     as character no-undo.
define variable v-readline   as character no-undo.
define variable v-files      as character no-undo.
define variable v-count      as int no-undo.
def var v-vin as char no-undo.
def var v-f45 as char no-undo.
def var v-bin as char no-undo.
def var v-f40 as char no-undo.

define stream   v-fnstream.
define stream   v-fstream.



input through value('ssh Administrator@`askhost` dir /b "c:\\vinload\\*"').
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


run savelog ("vinload", v-filename + " Начало загрузки ... " ).


run chengefilerights("/tmp/vinload/").

unix silent value ("rm -f /tmp/vinload*//*").

v-vinroot = "/data/import/vinload/" .
run chengefilerights(v-vinroot).

v-vinload = v-vinroot + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
run chengefilerights(v-vinload).

message "Идет загрузка...".
input through value("scp -pq Administrator@`askhost`:'c:\\vinload\\" + v-filename + "' '/tmp/vinload/" + v-filename + "' ;echo $?").
import unformatted v-str.
if v-str <> "0" then do:
    run savelog( "vinload", "Ошибка копирования файла ! " + v-filename).
    message "Ошибка копирования файла ! " + v-filename view-as alert-box.
    message "Имя файла не должно содержать русские символы и пробелы!" view-as alert-box.
    return.
end.


input through value( "find /tmp/vinload/" + v-filename + ";echo $?").
repeat:
    import unformatted v-str.
end.
if v-str <> "0" then do:
   run savelog ("vinload", v-filename + " файл не найден.").
   message v-filename + " файл не найден." view-as alert-box.
   return.
end.
output to value("/tmp/vinload/" + v-filename) append.
put unformatted chr(10).
output close.
/**/
def var v-loadstr as int.
v-loadstr = 0.
input stream v-fnstream from value("/tmp/vinload/" + v-filename).
v-count = 0.
repeat:
   do transaction:
       v-count = v-count + 1.
       import stream v-fnstream unformatted v-readline.

       if trim(v-readline) = '' then next.

       if num-entries(trim(v-readline),'|') <> 4 then do:
           run savelog ("vinload", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + ": " + v-readline ).
           next.
       end.
       assign v-vin = trim(entry(1, v-readline, "|"))
              v-f45 = trim(entry(2, v-readline, "|"))
              v-f40 = trim(entry(3, v-readline, "|"))
              v-bin = trim(entry(4, v-readline, "|")).
       if v-vin = '' and v-f45 = '' then do:
           run savelog ("vinload", v-filename + " Ошибка импорта файла " + v-filename + " на строке "  + string(v-count) + ": " + v-readline ).
           next.
       end.

       find first vincode where vincode.vin = v-vin and vincode.f45 = v-f45  and vincode.bin = v-bin use-index vinbinidx exclusive-lock no-error.
       if avail vincode then do:
          vincode.f40  = v-f40.
          v-loadstr = v-loadstr + 1.
       end.
       else do:
         create vincode.
         assign vincode.vin  = v-vin
                vincode.f45  = v-f45
                vincode.f40  = v-f40
                vincode.bin  = v-bin.
         v-loadstr = v-loadstr + 1.
       end.
       hide message no-pause.
       message "Обрабатывается строка " v-count " ".

   end.


end.
hide message no-pause.
input stream v-fnstream close.


if v-count <= 1 then do:
   run savelog ("vinload", v-filename + " файл пуст.").
   message v-filename + " файл пуст." view-as alert-box.
   return.
end.



if v-count > 0 then do transaction:
   create histloadfile.
   assign histloadfile.module = "vin"
        histloadfile.regdt = today
        histloadfile.tm = time
        histloadfile.ofc  = g-ofc
        histloadfile.fname =  v-filename.

end.

run savelog ("vinload", v-filename + " Количество загруженных строк " + string(v-loadstr)).


unix silent value('cp /tmp/vinload/' + v-filename + " " + v-vinload).

def var v-dbpath as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".
unix silent value("cptwin " + v-dbpath + "vinload." + string(today, "99.99.9999" ) + ".log wordpad").


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