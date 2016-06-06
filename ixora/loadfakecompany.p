/* loadfakecompany.p
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
        09.04.2013 evseev - tz-1678
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def var v-error    as logical no-undo.
def var v-files    as char no-undo.
def var v-str      as char no-undo.
def var v-exist1    as char no-undo.
def var v-file    as char no-undo.
def var v-bnk as char no-undo.

v-error = false.

v-files = ''.
input through value('ssh Administrator@`askhost` dir /b "c:\\rnnload\\*.csv"').
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + v-str.
    end.
end.

def var v-select as char.
run sel2 ("Выберите файл для загрузки", v-files, output v-select).
if v-select = "0" then return.
v-file = entry(int(v-select) , v-files , "|").


run savelog ("loadfakecompany", v-file + " Начало загрузки ... " ).

v-bnk = 'TXB??'.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if avail sysc then v-bnk = trim(sysc.chval).

input through value( "find /tmp/fakecompany/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/fakecompany/").
    unix silent value("chmod 777 /tmp/fakecompany/").
end.
else unix silent value ("rm -f /tmp/fakecompany/*.*").

def var v-fakecompany as char.
v-fakecompany = "/data/import/fakecompany/" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
input through value( "find " + v-fakecompany + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-fakecompany).
    unix silent value("chmod 777 " + v-fakecompany).
end.

message "Идет загрузка...".
input through value("scp -pq Administrator@`askhost`:'c:\\rnnload\\" + v-file + "' '/tmp/fakecompany/" + v-file + "' ;echo $?").
import unformatted v-str.
if v-str <> "0" then do:
    run savelog( "loadfakecompany", "Ошибка копирования файла ! " + v-file).
    message "Ошибка копирования файла ! " + v-file view-as alert-box.
    message "Имя файла не должно содержать русские символы и пробелы!" view-as alert-box.
    return.
end.


unix silent value('cp /tmp/fakecompany/*.csv ' + v-fakecompany).

def temp-table t-fakecompany no-undo
     field num as int
     field str as char
     index idx is primary num.

def var v-txt like t-fakecompany.str no-undo.

def var v-count as int.
def stream r-in.


empty temp-table t-fakecompany.

/**/
input through value( "find /tmp/fakecompany/" + v-file + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
   run savelog ("loadfakecompany", v-file + " файл не найден.").
   message v-file + " файл не найден." view-as alert-box.
   return.
end.
/**/
input stream r-in from value("/tmp/fakecompany/" + v-file).
v-count = 0.
repeat:
   v-count = v-count + 1.
   import stream r-in unformatted v-txt.
   if v-txt <> "" then do:
      create t-fakecompany.
          assign t-fakecompany.num = v-count
                 t-fakecompany.str = v-txt.
   end.
end.
input stream r-in close.

if v-count <= 1 then do:
   run savelog ("loadfakecompany", v-file + " файл пуст.").
   message v-file + " файл пуст." view-as alert-box.
   return.
end.

/*
№ п/п;
Наименование налогоплательщика;
РНН налогоплательщика;
ИИН/БИН налогоплательщика;
Ф.И.О. руководителя организации, РНН, ИИН;
Ф.И.О. учредителей, РНН, ИИН;
Номер и дата Приказа налогового органа об аннулировании Свидетельства плательщика НДС;
Дата аннулирования Свидетельства плательщика НДС
1;2;3;4;5;6;7;8
*/

def var v-rnn   as char .
def var v-bin   as char .


/*v-str = "Загрузка новых данных:  1 из " + string(v-count).
displ v-str   no-label format 'x(50)' with side-label centered frame fr1.*/

for each t-fakecompany.
   if t-fakecompany.str matches "*ИИН/БИН налогоплательщика*" then next.
   v-rnn   = "ошибка". v-rnn   = trim(entry(3, t-fakecompany.str, ";")) no-error.
   v-bin   = "ошибка". v-bin   = trim(entry(4, t-fakecompany.str, ";")) no-error.
   if trim(v-bin) = "" or v-bin = "ошибка" then next.
   if trim(v-bin) = "4"  then next.
   find first fakecompany where fakecompany.bin = v-bin use-index idx_bin exclusive-lock no-error.
   if not avail fakecompany then create fakecompany.
   assign
         fakecompany.line  = t-fakecompany.num
         fakecompany.rnn   = v-rnn
         fakecompany.bin   = v-bin
         fakecompany.str  = t-fakecompany.str
         fakecompany.regdt = today
         fakecompany.ofc   = g-ofc
         fakecompany.fname = v-file.

   /*v-str = "Загрузка новых данных:  " + string(t-fakecompany.num) + " из " + string(v-count).
   displ v-str   no-label format 'x(50)' with side-label centered frame fr1.*/
end.

v-count = 0.
for each fakecompany where fakecompany.regdt <> today no-lock.
  v-count = v-count + 1.
end.

def var i as int.
i = 0.
for each fakecompany where fakecompany.regdt <> today exclusive-lock:
    /*i = i + 1.
    v-str = "Удаление старых данных:  " + string(i) + " из " + string(v-count).
    displ v-str   no-label format 'x(50)' with side-label centered frame fr1.*/

    delete fakecompany.
end.
hide frame fr1.

create histloadfile.
   assign histloadfile.module = "fakecompany"
        histloadfile.regdt = today
        histloadfile.tm = time
        histloadfile.ofc  = g-ofc
        histloadfile.fname =  v-file.


run savelog ("loadfakecompany", v-file + " Загрузка завершена ..." ).
message " Загрузка файла " + v-file + " завершена!" view-as alert-box.
