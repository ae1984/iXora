/* vcmainshared.i
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vcarcon.p,vccontr.p,vccontrs.p,vcdndocs.p и т.д.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/

def {1} shared var s-newcontract as logi.
def {1} shared var v-cifname as char.
def {1} shared var s-vcourbank as char.
def {1} shared var v-workcond as logi.




