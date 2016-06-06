/* tdaremholdfiz.p
 * MODULE
        Удаление спец интсрукций по неснижаемому остатку 
 * DESCRIPTION
        Удаление спец интсрукций по неснижаемому остатку 
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
        17.04.06 nataly добавлена обработка кода 193,180,181 - исключения по кредитам
*/

/*01/04/03  nataly
доработка в связи с депозитом с изъятием */

def input parameter vaaa as char no-undo.

do transaction:
 find aaa where aaa.aaa = vaaa exclusive-lock no-error.
 if not available aaa then return.
 find aas where aas.aaa = vaaa and aas.payee begins 'Неснижаемый остаток ОД' exclusive-lock no-error.
 if available aas then do:
    aaa.hbal = aaa.hbal - aas.chkamt.
   /*nataly*/
    if aaa.hbal < 0 then aaa.hbal = 0.
   /*nataly*/
    delete aas.
 end.
end.
