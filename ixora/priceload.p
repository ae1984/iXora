/* priceload.p
 * MODULE
        Загрузка котировок KASE
 * DESCRIPTION
        для загрузки необходимо положить файлы в C:\Price\
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
        26.06.2012 id01143 (Sayat) (ТЗ 1328)
        09.07.2012 id01143 добавлена проверка завершения загрузки файла в связи с возникновением ошибок при загрузке
        23.07.2012 id01143 используется функция replace для удаления лишних пробелов из значения котировки перед преобразованием в число
 * CHANGES

*/

{lgps.i}
{global.i}

def var filelog as char init "priceload".

define var t-file as char format "x(100)" no-undo.

define var t-nin as char no-undo.
define var t-price as char no-undo.
define var stext as char.
define var k as integer.
define var n as integer.
define var v-file as char init "Price". /* + string(day(today), "99") + "_" + string(month(today), "99") + "_" + string(year(today),"9999") + ".csv".*/

def var i as deci format ">>>,>>>,>>>,>>9.99".

define var dt as date format "99/99/9999".

/*output to log.txt.
put string(time,"HH:MM:SS") skip.
*/

input through value ("sgnget tmpprice Administrator@`askhost`:c:/price/" + v-file + "; echo $?").

repeat:
import unformatted stext.
end.

if stext <> "0" then do:
    message "error!" view-as alert-box.
    return.
end.

{comm-dir.i}
run comm-dir ("tmpprice/", "*", no).

for each comm-dir:
    i = 0.
    input from value("tmpprice/" + trim(comm-dir.fname) ).
    REPEAT on error undo, leave:
        do transaction:
            import unformatted t-file no-error.
            IF ERROR-STATUS:ERROR then do:
                message "Ошибка импорта котировок KASE" view-as alert-box.
                return.
            END.
            t-nin = entry(1,t-file,",").
            t-price = entry(2,t-file,",").
            /*
            k = num-entries(t-price," ").
            stext = t-price.
            t-price = "".
            do n = 1 to k:
                t-price = t-price + entry(n,stext," ").
            end.
            k = num-entries(t-price," ").
            t-price = "".
            do n = 1 to k:
                t-price = t-price + entry(n,stext," ").
            end.
            */
            t-price = replace(replace(t-price," ","")," ","").
            i = i + 1.
            if index(t-nin,"/") <> 0 and dt = ? then  dt = date(integer(entry(1,t-nin,"/")),integer(entry(2,t-nin,"/")),integer(entry(3,t-nin,"/"))).
            else do:
                /*message t-nin + " 1=1 " + string(i) view-as alert-box.*/
                if dt = ? then do:
                    message "Не указана дата котировок!" view-as alert-box.
                    return.
                end.
                find first dealref where dealref.nin = t-nin no-lock no-error.
                /*message t-nin + " 2=2 " + string(i) view-as alert-box.*/
                if avail(dealref) and length(t-price) <> 0 then do:
                    find last indval where indval.nin = t-nin and dt >= indval.begdate and ( dt < indval.enddate or indval.enddate = ? ) exclusive-lock no-error.
                    if avail(indval) and indval.begdate <> dt then assign indval.enddate = dt.
                    if avail(indval) and indval.begdate = dt then do:
                        /*message t-nin + " 3=3 " + string(i) view-as alert-box.*/
                        assign indval.rateval = decimal(t-price).
                        if substring(dealref.cbtype,1,2) = "2." or substring(dealref.cbtype,1,2) = "4." then indval.valcrc = 1.
                        else indval.valcrc = 0.
                    end.
                    else do:
                        create indval.
                        /*message t-nin + " 4=0 " + string(i) view-as alert-box.*/
                        assign indval.nin = t-nin.
                        /*message t-nin + " 4=1 " + string(i) view-as alert-box.*/
                        indval.begdate = dt.
                        /*message t-nin + " 4=2 " + string(i)+ " = " + trim(t-price) view-as alert-box.*/

                        /*message '"' + trim(t-price) + '"' view-as alert-box.*/

                        indval.rateval = decimal(t-price).
                        /*message t-nin + " 4=3 " + string(i) view-as alert-box.*/
                        if substring(dealref.cbtype,1,2) = "2." or substring(dealref.cbtype,1,2) = "4." then indval.valcrc = 1.
                        else indval.valcrc = 0.
                        /*message t-nin + " 4=4 " + string(i) view-as alert-box.*/
                    end.
                end.
            end.
        end.
    END.
    input close.
    run savelog(filelog, "Загружен - " + trim(comm-dir.fname) + " , записей - " + string(i,">>>>>>>>9")).
end.

message "Загрузка котировок завершена!" view-as alert-box.
