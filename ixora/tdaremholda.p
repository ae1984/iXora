/* tdaremholda.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*01/04/03  nataly
доработка в связи с депозитом с изъятием */

def input parameter vaaa as char.
def var vln as inte initial 7777777.

do transaction:
 find aaa where aaa.aaa = vaaa exclusive-lock no-error.
 if not available aaa then return.
 find aas where aas.aaa = vaaa and aas.ln = vln exclusive-lock no-error.
 if available aas then do:
    aaa.hbal = aaa.hbal - aas.chkamt.
   /*nataly*/
    if aaa.hbal < 0 then aaa.hbal = 0.
   /*nataly*/
    delete aas.
 end.
end.
