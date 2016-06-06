/* rep2-1.p
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
        03.10.2011 damir - отчет приходит в формате XLS.
        04.10.2011 damir - только 3 получателя, riski@metrocombank.kz - убрал.
        02.11.2011 damir - изменил название файла отчета.
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
if avail dayrep then v-yesterday  = dayrep.day.

if v-statusRep then do:
    pause 3.
    run ccdb(input v-option, input v-yesterday, input 1, output vfname, input-output vres).
    pause 3.
    run savelog ("repauto", "rep2-1.Результат = " + string(vres)).
    unix silent value ("cp " + vfname + " rep_rcp.xls").
    unix silent value ("un-win rep_rcp.xls Concentration_of_the_deposit_base.xls").
    run mail(v-mailRep, "BANK <abpk@metrocombank.kz>", "КОНЦЕНТРАЦИЯ ДЕПОЗИТНОЙ БАЗЫ ЮЛ и ФЛ", "" , "1", "","Concentration_of_the_deposit_base.xls").
    run savelog ("repauto", "rep2-1.Успешная отправка на EMAIL файла " + vfname).
    unix silent value ("rm rep_rcp.xls").
    unix silent value ("rm Concentration_of_the_deposit_base.xls").
end.

