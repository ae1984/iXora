/* rmzterm.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Сверка пачек за указанную дату с Прагмой
 * RUN
        
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-7-3
 * AUTHOR
        05/05/05 sasco
 * CHANGES
*/


def var vd as date init today.
def var v-path as char.
def var s as char.
def var v-result as char.
def var tr as decimal.
def var td as decimal.
def var was20 as int init 0.
def var was21 as int init 0.
def var rem as char.

def var ctot as int.
def var cbad as int.

update vd label "Дата выгрузки" with side-labels centered row 1 frame getdat.

v-path = "L:\\CAPITAL\\TERMINAL\\TRANSIT\\" + substr (string (year(vd), "9999"), 3, 2) + "-" +
                                              string (month(vd), "99") + "-" +
                                              string (day(vd), "99") + "\\OUT\\". 

unix silent value("rm rmzsum.tmp 2> /dev/null").

input through value("rsh ntmain ""dir /b  " + v-path + "*.eks.*""") no-echo.
repeat:
      import unformatted s.
      message s. 
      unix silent value("rcp " + "NTMAIN:" + replace (v-path, "\\", "\\\\") + trim(s) + " " + trim(s) + " > /dev/null 2> /dev/null").
      unix silent value("cat " + trim(s) + " >> rmzsum.tmp").
      unix silent value("rm " + trim(s)).
      unix silent value("echo ~n >> rmzsum.tmp").
end.
input close.


message "Выбор платежей из пачек" view-as alert-box.

input from rmzsum.tmp.
output to remsum.tmp.
repeat:
    
    import unformatted s.
    
    if s matches "*:20:RMZ*" then do:
       was20 = 1.
       was21 = 0.
       rem = substr (s, 5, 10).
    end.
    
    if s matches "*:21:RMZ*" then do:
       was20 = 0.
       was21 = 1.
       rem = substr (s, 5, 10).
    end.

    if s matches "*:32A:*" then 
    if was20 = 1 then do:
       was20 = 0.
       put unformatted rem "|" substr (s, 15) skip.
    end.

    if s matches "*:32B:*" then 
    if was21 = 1 then do:
       was21 = 0.
       put unformatted rem "|" substr (s, 9) skip.
    end.

end.
output close.
input close.

unix silent value ("rm rmzsum.tmp").

message "Проверка платежей и сумм" view-as alert-box.

td = 0.
ctot = 0.
cbad = 0.

input from remsum.tmp.
repeat:
  import unformatted s.
  s = replace (s, ",", ".").
  ctot = ctot + 1.
    find remtrz where remtrz.remtrz = substr (s, 1, 10) no-lock no-error.
    if not avail remtrz then do: 
       cbad = cbad + 1.
       message substr(s, 1, 10) " - отсутствует в Прагме" view-as alert-box. 
       next.
    end.
    tr = decimal (substr (s, 12)).
    if tr <> remtrz.amt then do: 
       cbad = cbad + 1.
       displ tr label "Терминал" remtrz.amt label "Прагма" substr (s, 1, 10) label "Платеж" format "x(10)".
       pause.
    end.
end.
input close.
unix silent value ("rm remsum.tmp").

message "Проверка завершена~nошибочных - " cbad " платежей " view-as alert-box.


