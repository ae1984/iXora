
/* r-kbs.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        Балансы по всем филиалам
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        r-kbs1.p - крутит программу создания балансов по всем филиалам
 * MENU
        9.12.5
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        04.09.2003 nadejda - поставила проверку существования архивного каталога, потом каждый файл запишется и в архив тоже
        01.06.2003 nadejda - переделала балансы так, чтобы считать на любую дату
        23/05/2011 madiyar - в команде копирования тестового файла sendtest -> sendtest.txt
*/



{mainhead.i}

def var v-result as char.
def new shared var dirc     as char format "x(15)".
def new shared var dircarc  as char format "x(15)".
def new shared var ipaddr   as char format "x(15)".


dirc = "C:/Public/Balance/". 
find sysc where sysc.sysc eq "BALDIR" no-lock no-error.
if avail sysc and sysc.chval <> "" then dirc = trim (sysc.chval).
if substr (dirc, length(dirc), 1) <> "/" then dirc = dirc + "/".


/* архивный каталог - проверка существования */
output to sendtest.txt.
put " " skip.
output close.

def new shared var v-dat as date.
find last cls no-lock no-error.
if not avail cls then return.
v-dat = cls.whn.

dircarc = dirc + "arc" + string (year (v-dat), "9999") + "/" + string (month (v-dat), "99") + "/".
input through value("scp -q sendtest.txt Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?"). 
repeat:
  import v-result.
end.
pause 0.

if v-result <> "0" then do:
  message skip " Каталог" dircarc "не существует! ~n~n Создайте его СЕЙЧАС!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

update v-dat validate (v-dat < g-today, " Неверная дата!") label " ДАТА ОТЧЕТА " format "99/99/9999" skip
       with centered row 5 side-label no-box frame f-dat.
hide frame f-dat no-pause.

unix silent value ("echo > rpt.img").

{r-branch.i &proc = "gm-kbsall (txb.logname, txb.name)"}

