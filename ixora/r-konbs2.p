/* r-kbs.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        Консолидированный баланс
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        gm-konbs21.p - крутит программу сборки балансов по всем филиалам
 * MENU
        9.12.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        04.09.2003 nadejda - поставила проверку существования архивного каталога, потом каждый файл запишется и в архив тоже
        04.12.2003 nadejda - убрала коннект на comm, там автоконнект
        01.06.2003 nadejda - переделала балансы так, чтобы считать на любую дату
        02/08/07 marinav     Замена rcp на  scp   
*/

{mainhead.i}

 

def var v-result as char.
def new shared var dirc     as char format "x(15)".
def new shared var dircarc  as char format "x(15)".
def new shared var ipaddr   as char format "x(15)".
def new shared var v-dat as date.


dirc = "C:/Public/Balance/". 
find sysc where sysc.sysc eq "BALDIR" no-lock no-error.
if avail sysc and sysc.chval <> "" then dirc = trim (sysc.chval).
if substr (dirc, length(dirc), 1) <> "/" then dirc = dirc + "/".


/* архивный каталог - проверка существования */
output to sendtest.
put "test OK" skip.
output close.

find last cls no-lock no-error.
if not avail cls then return.
v-dat = cls.whn. 

dircarc = dirc + "arc" + string (year (v-dat), "9999") + "/" + string (month (v-dat), "99") + "/".
input through value("scp -q sendtest Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?").

repeat:
  import v-result.
end.
pause 0.

if v-result <> "0" then do:
  message skip " Каталог" dircarc "не существует! ~n~n Создайте его СЕЙЧАС!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

run gm-konbs21.

