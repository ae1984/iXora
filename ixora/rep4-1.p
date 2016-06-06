/* rep4-1.p
 * MODULE
        Название модуля - Реестр неакцептованных документов (ВалКон)
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
        26.04.2013 damir - Оптимизация кода.
*/
{global.i}

def shared var v-statusRep as logi. /*Статус запуска отчета*/
def shared var v-mailRep as char. /*Адресаты получателей рассылки*/

def var v-option as char init "mail".
def var vres as logi init no.

{defperem.i "new"}

if v-statusRep then do:
    pause 3.
    run vcrepac(input v-option, input g-today, input-output vres).
    pause 3.
    if v-yesno = yes then do:
        unix silent value ("cp " + vfname + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofcmain, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В филиалах есть неакцептованные документы валютного контроля!!!", "" , "", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno1 = yes then do:
        unix silent value ("cp " + vfname1 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb01, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno2 = yes then do:
        unix silent value ("cp " + vfname2 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb02, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno3 = yes then do:
        unix silent value ("cp " + vfname3 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb03, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno4 = yes then do:
        unix silent value ("cp " + vfname4 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb04, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno5 = yes then do:
        unix silent value ("cp " + vfname5 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb05, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno6 = yes then do:
        unix silent value ("cp " + vfname6 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb06, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno7 = yes then do:
        unix silent value ("cp " + vfname7 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb07, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno8 = yes then do:
        unix silent value ("cp " + vfname8 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb08, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno9 = yes then do:
        unix silent value ("cp " + vfname9 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb09, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno10 = yes then do:
        unix silent value ("cp " + vfname10 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb10, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno11 = yes then do:
        unix silent value ("cp " + vfname11 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb11, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno12 = yes then do:
        unix silent value ("cp " + vfname12 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb12, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno13 = yes then do:
        unix silent value ("cp " + vfname13 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb13, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno14 = yes then do:
        unix silent value ("cp " + vfname14 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb14, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno15 = yes then do:
        unix silent value ("cp " + vfname15 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb15, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
    if v-yesno16 = yes then do:
        unix silent value ("cp " + vfname16 + " rep_rcp.html").
        unix silent value ("un-win rep_rcp.html Unaccepted_document.html").
        run mail(v-ofctxb16, "BANK <abpk@metrocombank.kz>", "ВНИМАНИЕ! В Вашем филиале есть неакцептованные документы валютного контроля!!!", "" , "1", "","Unaccepted_document.html").
        unix silent value ("rm rep_rcp.html").
        unix silent value ("rm Unaccepted_document.html").
    end.
end.


