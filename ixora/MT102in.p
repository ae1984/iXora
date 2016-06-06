/* MT102in.p
 * MODULE
     Операции   
 * DESCRIPTION
        Автоматическое зачисление з/п на счет клиента из МТ102
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2.1.8
 * BASES
        BANK       
 * AUTHOR
        18/05/2009 galina
 * CHANGES
*/

{global.i}

def stream rep.
def var v-log as char no-undo.
def var fnamelist1 as char no-undo.
def var i as integer no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var fname as char no-undo.
def var v-path as char no-undo.
def var v-str as char no-undo.
def var v-exist as char no-undo.
def var v-path1 as char no-undo.

v-log = "MT102repday" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".log".
output stream rep to value(v-log).


find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then return.

v-path = "/data/" + sysc.chval + "/import/MT102/" + string(g-today,'99.99.99') + "/".
v-path1 = "/data/".
do i = 3 to num-entries(v-path,'/') - 1:
    v-path1 = v-path1 + entry(i,v-path,'/') + "/".
    input through value( "find " + v-path1 + ";echo $?").
    repeat:
      import unformatted v-exist.
    end.
    
    if v-exist <> "0" then do:
       unix silent value ("mkdir " + v-path1).
       unix silent value("chmod 777 " + v-path1).
    end. 
end.

        
input through value( "ssh Administrator@`askhost` dir /B C:\\\\MT102\\\\*.*").
fnamelist1 = ''.
repeat:
  import unformatted v-str.
  if trim(v-str) <> '' then do:
    if fnamelist1 <> '' then fnamelist1 = fnamelist1 + ','.
    fnamelist1 = fnamelist1 + entry(num-entries(v-str,'/'),v-str,'/').
  end.
end.
pause 0.


if fnamelist1 = '' then do:
  put stream rep unformatted "info  - нет файлов для прогрузки ... выход" skip.
  output stream rep close.
  return.
end.
else put stream rep unformatted "info  - файлы для прогрузки ... " + fnamelist1 skip.

unix silent value("scp -q Administrator@`askhost`:C:/MT102/*.* /home/id00194;echo $?").


do i = 1 to num-entries(fnamelist1):
  rcode = 0. rdes = ''.
  fname = entry(i,fnamelist1).
  put stream rep unformatted "-------- begin " + fname + " -----------" skip.
  
  output stream rep close.
  
  run MT102trx(fname,v-log,output rcode,output rdes).
  
  output stream rep to value(v-log) append.
  
  /* загрузка прошла без ошибок */
  if rcode > 11 then   put stream rep unformatted "error - " + string(rcode) + " " + rdes skip.
  
  if rcode = 0 then do: 
    put stream rep unformatted "Загрузка закончена без ошибок" skip.
      /* -- записываем файл в архив -- */
    unix silent value("cp " + fname + " " + v-path).       
    /*удаляем из папки обработанные сообщения*/
    unix silent  value ("ssh Administrator@`askhost` erase /Q C:\\\\MT102\\\\" + fname).
    
  end.
  /*удаляем из домашнего каталога*/
  unix silent value("rm -f " + fname).
  put stream rep unformatted "------------------------------------------" skip(2).
end. /* do i */

output stream rep close.

unix silent value("un-win1 " + v-log + " MT102imp_log.txt").
unix silent value("cptwin MT102imp_log.txt").
unix silent value("rm -f " + v-log).
unix silent value("rm -f MT102imp_log.txt").

 

  

