/* rep2-2.p
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def var vfname       as char.
def var v-yesterday  as date.
def var v-option     as char init "mail".
def var vres         as logi init no.
def var i            as logi init yes.

find last dayrep no-lock no-error.
if avail dayrep then v-yesterday  = dayrep.day.
pause 2.
if i then do:
    run ccdb(input v-option, input v-yesterday, input 4, output vfname, input-output vres).
end.
run savelog ("rep1", "Результат = " + string(vres)).
unix silent value ("cp " + vfname + " rep_rcp.html").
unix silent value ("un-win rep_rcp.html rep.html").
run mail("riski@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Концентрация депозитной базы ФЛ", "" , "1", "","rep.html").
/*run mail("id00705@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Концентрация депозитной базы ФЛ", "" , "1", "","rep.html").*/
run savelog ("rep1", "Успешная отправка на EMAIL файла " + vfname).
unix silent value ("rm rep_rcp.html").
unix silent value ("rm rep.html").



