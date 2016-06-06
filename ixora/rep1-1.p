/* rep1-1.p
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
        07.10.2011 damir - убрал из рассылки id00049.
        02.11.2011 damir - изменил название файла отчета.
        04.11.2011 damir - добавил в рассылку id01021.
        11.05.2012 kapar - СЗ от 03.05.2012
        29.05.2012 damir - добавил в рассылку id01153.
        02.08.2012 damir - исключил из рассылки id00941,включил id00844.
        26.04.2013 damir - Оптимизация кода.
*/
{global.i}

def shared var v-statusRep as logi. /*Статус запуска отчета*/
def shared var v-mailRep as char. /*Адресаты получателей рассылки*/

def var vfname as char.
def var v-yesterday as date.
def var v-option as char init "mail".
def var vres as logi init no.

find last dayrep no-lock no-error.
if avail dayrep then v-yesterday = dayrep.day.

if v-statusRep then do:
    pause 3.
    run r-lnday(input v-option, input v-yesterday, output vfname, input-output vres).
    pause 3.
    run savelog ("repauto", "rep1-1.Результат = " + string(vres)).
    unix silent value ("cp " + vfname + " rep_rcp.xls").
    unix silent value ("un-win rep_rcp.xls Report_for_the_day.xls").
    run mail(v-mailRep, "BANK <abpk@metrocombank.kz>", "ОТЧЕТ ЗА ДЕНЬ", "" , "1", "","Report_for_the_day.xls").
    run savelog ("repauto", "rep1-1.Успешная отправка на EMAIL файла " + vfname).
    unix silent value ("rm rep_rcp.xls").
    unix silent value ("rm Report_for_the_day.xls").
end.





