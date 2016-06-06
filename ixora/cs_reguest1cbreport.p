/* .p
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
        06.05.2013 evseev tz-1810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-credtype as char init '4' no-undo.
def shared var v-aaa      as char no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.

run savelog("cs_reguest1cbreport", "30. " + s-credtype + " " + v-aaa + " " + v-bank + " " + v-cifcod).

def var v-code as char no-undo.

def var v-select  as inte.
run sel2 ("Выберите :", " 1. Посмотреть ответ КБ  | 2. Выход ", output v-select).


if v-select = 1 then do:
   run 1CB_Report.
end.
