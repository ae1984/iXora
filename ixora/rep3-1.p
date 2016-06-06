/* rep3-1.p
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
        02.11.2011 damir - изменил название файла отчета.
        13.02.2012 damir - добавил адреса получателей.
        20.02.2012 damir - перекомпиляция,изменились адресаты пользователей.
        28.02.2012 damir - отчет "Анализ процентной маржи" должен приходить 1 - го числа (за последнее число пред.месяца),
        изменен список получателей....
        01.02.2012 damir - замена отчета на EXCEL.
        26.04.2013 damir - Оптимизация кода.
*/
{global.i}

def shared var v-statusRep as logi. /*Статус запуска отчета*/
def shared var v-mailRep as char. /*Адресаты получателей рассылки*/

def var vfname as char.
def var v-downdate as date.
def var v-update as date.
def var v-option as char init "mail".
def var vres as logi init no.
def var weekrep as inte.

if day(today) = 1 then assign v-update = today - 1.
else if day(today) = 2 then assign v-update = today - 2.
else if day(today) = 3 then assign v-update = today - 3.
else if day(today) = 4 then assign v-update = today - 4.
else if day(today) = 5 then assign v-update = today - 5.
else if day(today) = 6 then assign v-update = today - 6.

if v-statusRep then do:
    pause 3.
    run repmarj(input v-option, input v-downdate, input v-update, output vfname, input-output vres).
    pause 3.
    run savelog ("repauto", "rep3-1.Результат = " + string(vres)).
    unix silent value ("cp " + vfname + " rep_rcp.xls").
    unix silent value ("un-win rep_rcp.xls Analysis_of_the_interest_margin.xls").
    run mail(v-mailRep, "BANK <abpk@metrocombank.kz>", "АНАЛИЗ ПРОЦЕНТНОЙ МАРЖИ", "" , "1", "", "Analysis_of_the_interest_margin.xls").
    run savelog ("repauto", "rep3-1.Успешная отправка на EMAIL файла " + vfname).
    unix silent value ("rm rep_rcp.xls").
    unix silent value ("rm Analysis_of_the_interest_margin.xls").
end.

