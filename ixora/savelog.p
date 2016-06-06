/* savelog.p
 * MODULE
        Процедуры общего пользования
 * DESCRIPTION
        Запись строки в файл лога за сегодняшний день в каталоге логов текущей базы
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        17.12.2003 nadejda - путь к каталогу логов берется из sysc, в названии файла добавила дату
*/

define input parameter v-logfile as char.
define input parameter v-mess as char.

def var v-dbpath as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

output to value(v-dbpath + v-logfile + "." + string(today, "99.99.9999" ) + ".log") append.
    put unformatted 
    today " " 
    string(time, "hh:mm:ss") " "
    userid("bank") format "x(8)" " "
    v-mess
    skip.
output close.
