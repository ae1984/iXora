/* mv_photos.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Перемещение фотографий на сервер и привязка к анкете
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
        01/08/2005 madiyar
 * CHANGES
        02/08/2005 madiyar - забыл убрать отладочные сообщения, добавил второй входной параметр
        20/06/2006 madiyar - переделал под ssh, но пока только для актобе
        04/09/2006 madiyar - ssh уральск
        28/09/2006 madiyar - ssh атырау
        05/03/2007 madiyar - изменения для новых камер
        10/07/2007 madiyar - подправил автоматическое создание новых директорий на сервере (../[credtype]/[year]/[month]/..)
        11/07/2007 madiyar - подправил немножко криво, исправил
        31/10/2008 madiyar - альтернативная директория для загрузки фотографий
*/

{global.i}
{sysc.i}

def shared var s-credtype as char.

function ns_check returns character (input parm as character).
    def var v-str as char no-undo.
    v-str = parm.
    v-str = replace(v-str,"/","//").
    v-str = replace(v-str,"!","\\!").
    v-str = replace(v-str," ","\\ ").
    v-str = "\\""" + v-str + "\\""".
    return (v-str).
end function.

def input parameter p-pkankln as integer no-undo.
def input parameter p-dt as date no-undo.
def input parameter p-credtype as char no-undo.
def input parameter p-wdir as integer no-undo.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-ourbank = sysc.chval.

def temp-table wrk no-undo
  field sname as char
  field dname as char
index idx is primary sname.

def var v-filename as char.
def var i as integer no-undo.

def var v-phdirs as char no-undo.
def var v-phdird as char no-undo.
v-phdirs = get-sysc-cha ("pkphs").
v-phdird = get-sysc-cha ("pkphd").

if substr(v-phdirs,length(v-phdirs),1) <> "/" then v-phdirs = v-phdirs + "/".
if substr(v-phdird,length(v-phdird),1) <> "/" then v-phdird = v-phdird + "/".

v-phdird = v-phdird + string(p-credtype) + "/".

unix silent value ("if [ ! -d pkph ]; then mkdir pkph; chmod a+rx pkph; fi").
unix silent value ("rm -f pkph/*").
unix silent value ("if [ ! -d " + v-phdird + " ]; then mkdir " + v-phdird + "; chmod a+rx " + v-phdird + "; fi").
unix silent value ("if [ ! -d " + v-phdird + string(year(p-dt)) + " ]; then mkdir " + v-phdird + string(year(p-dt)) + "; chmod a+rx " + v-phdird + string(year(p-dt)) + "; fi").
unix silent value ("if [ ! -d " + v-phdird + string(year(p-dt)) + "/" + string(month(p-dt)) + " ]; then mkdir " + v-phdird + string(year(p-dt)) + "/" + string(month(p-dt)) + "; chmod a+rx " + v-phdird + string(year(p-dt)) + "/" + string(month(p-dt)) + "; fi").

if p-wdir = 1 then v-phdirs = v-phdirs + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
v-phdird = v-phdird + string(year(p-dt)) + "/" + string(month(p-dt)) + "/".


unix silent value("scp -q Administrator@`askhost`:" + ns_check(v-phdirs + "*.jpg") + " pkph/").

def stream s1.
input stream s1 through value("ls pkph/* | awk 'BEGIN\{FS=""/""\}\{print $NF\}'").

repeat:
  import stream s1 unformatted v-filename.
  create wrk.
  v-filename = replace(replace(replace(replace(trim(v-filename),'(','\\\('),')','\\\)'),' ','\\\ '),"'","\\\'").
  wrk.sname = v-filename.
  wrk.dname = trim(string(p-pkankln,">>>>>9")) + "\\ -\\ " + trim(v-filename).
end.

for each wrk:
unix silent value ("mv pkph/" + wrk.sname + " " + v-phdird + wrk.dname).
end.

unix silent value("ssh Administrator@`askhost` erase \\""" + replace(v-phdirs,'/',"\\\\") + "*.jpg\\""").


