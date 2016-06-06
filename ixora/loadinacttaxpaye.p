/* loadinacttaxpaye.p
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
        29.05.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
        06.06.2012 evseev - поиск по РНН и изменение записей
        09.04.2013 evseev - tz-1678
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


run savelog ("loadinacttaxpayer", v-file + " Начало загрузки ... " ).

v-bnk = 'TXB??'.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if avail sysc then v-bnk = trim(sysc.chval).

input through value( "find /tmp/inacttaxpayer/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/inacttaxpayer/").
    unix silent value("chmod 777 /tmp/inacttaxpayer/").
end.
else unix silent value ("rm -f /tmp/inacttaxpayer/*.*").

def var v-inacttaxpayer as char.
v-inacttaxpayer = "/data/import/inacttaxpayer/" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
input through value( "find " + v-inacttaxpayer + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-inacttaxpayer).
    unix silent value("chmod 777 " + v-inacttaxpayer).
end.

message "Идет загрузка...".
input through value("scp -pq Administrator@`askhost`:'c:\\rnnload\\" + v-file + "' '/tmp/inacttaxpayer/" + v-file + "' ;echo $?").
import unformatted v-str.
if v-str <> "0" then do:
    run savelog( "loadinacttaxpayer", "Ошибка копирования файла ! " + v-file).
    message "Ошибка копирования файла ! " + v-file view-as alert-box.
    message "Имя файла не должно содержать русские символы и пробелы!" view-as alert-box.
    return.
end.


unix silent value('cp /tmp/inacttaxpayer/*.csv ' + v-inacttaxpayer).

def temp-table t-inacttaxpayer no-undo
     field num as int
     field str as char
     index idx is primary num.

def var v-txt like t-inacttaxpayer.str no-undo.

def var v-count as int.
def stream r-in.


empty temp-table t-inacttaxpayer.

/**/
input through value( "find /tmp/inacttaxpayer/" + v-file + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
   run savelog ("loadinacttaxpayer", v-file + " файл не найден.").
   message v-file + " файл не найден." view-as alert-box.
   return.
end.
/**/
input stream r-in from value("/tmp/inacttaxpayer/" + v-file).
v-count = 0.
repeat:
   v-count = v-count + 1.
   import stream r-in unformatted v-txt.
   if v-txt <> "" then do:
      create t-inacttaxpayer.
          assign t-inacttaxpayer.num = v-count
                 t-inacttaxpayer.str = v-txt.
   end.
end.
input stream r-in close.

if v-count <= 1 then do:
   run savelog ("loadinacttaxpayer", v-file + " файл пуст.").
   message v-file + " файл пуст." view-as alert-box.
   return.
end.


/* 1    2     3       4            5       */
/*КНО;РНН;ИИН/БИН;Наименование;Дата Приказа*/
def var v-kno   as char .
def var v-rnn   as char .
def var v-bin   as char .
def var v-name  as char .
def var v-orddt as char .

v-str = "Загрузка новых данных:  1 из " + string(v-count).
displ v-str   no-label format 'x(50)' with side-label centered frame fr1.

for each t-inacttaxpayer.
   if t-inacttaxpayer.str matches "*КНО;РНН;ИИН/БИН;*" then next.
   v-kno   = "ошибка". v-kno   = trim(entry(1, t-inacttaxpayer.str, ";")) no-error.
   v-rnn   = "ошибка". v-rnn   = trim(entry(2, t-inacttaxpayer.str, ";")) no-error.
   v-bin   = "ошибка". v-bin   = trim(entry(3, t-inacttaxpayer.str, ";")) no-error.
   v-name  = "ошибка". v-name  = trim(entry(4, t-inacttaxpayer.str, ";")) no-error.
   v-orddt = "ошибка". v-orddt = trim(entry(5, t-inacttaxpayer.str, ";")) no-error.

   if v-kno   = "ошибка" or v-rnn   = "ошибка" or v-bin   = "ошибка" or v-name  = "ошибка" or v-orddt = "ошибка" then do:
      run savelog ("loadinacttaxpayer", v-file + " стр:" + string(t-inacttaxpayer.num) + " ошибка в строке!").
      v-error = true.
      next.
   end.
   if v-rnn   = "" and v-bin   = "" then do:
      run savelog ("loadinacttaxpayer", v-file + " стр:" + string(t-inacttaxpayer.num) + " ошибка в строке. пустая переменная!").
      v-error = true.
      next.
   end.

   if v-rnn <> "" then
      find first inacttaxpayer where inacttaxpayer.rnn = v-rnn use-index idx_rnn exclusive-lock no-error.
   else if v-bin <> "" then
      find first inacttaxpayer where inacttaxpayer.bin = v-bin use-index idx_bin exclusive-lock no-error.
   if not avail inacttaxpayer then create inacttaxpayer.

   assign
         inacttaxpayer.line  = t-inacttaxpayer.num
         inacttaxpayer.kno   = v-kno
         inacttaxpayer.rnn   = v-rnn
         inacttaxpayer.bin   = v-bin
         inacttaxpayer.name  = v-name
         inacttaxpayer.orddt = v-orddt
         inacttaxpayer.regdt = today
         inacttaxpayer.ofc   = g-ofc
         inacttaxpayer.fname = v-file.

   v-str = "Загрузка новых данных:  " + string(t-inacttaxpayer.num) + " из " + string(v-count).
   displ v-str   no-label format 'x(50)' with side-label centered frame fr1.
end.

v-count = 0.
for each inacttaxpayer where inacttaxpayer.regdt <> today no-lock.
  v-count = v-count + 1.
end.

def var i as int.
i = 0.
for each inacttaxpayer where inacttaxpayer.regdt <> today exclusive-lock:
    i = i + 1.
    v-str = "Удаление старых данных:  " + string(i) + " из " + string(v-count).
    displ v-str   no-label format 'x(50)' with side-label centered frame fr1.

    delete inacttaxpayer.
end.
hide frame fr1.

create histloadfile.
   assign histloadfile.module = "inacttaxpayer"
        histloadfile.regdt = today
        histloadfile.tm = time
        histloadfile.ofc  = g-ofc
        histloadfile.fname =  v-file.

run savelog ("loadinacttaxpayer", v-file + " Загрузка завершена ..." ).
message " Загрузка файла " + v-file + " завершена!" view-as alert-box.

if v-error then
   run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", v-bnk + " ОШИБКА: В загрузке loadinacttaxpayer", v-bnk + " ОШИБКА: В загрузке loadinacttaxpayer", "1", "", "").