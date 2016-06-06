/* upd-aaa.p
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
        27.01.10 marinav - расширение поля счета до 20 знаков
*/

def var v-aaa like aaa.aaa.
update v-aaa label 'Введите номер счета ' .

find aaa where aaa.aaa = v-aaa  no-error.
if not available aaa then message 'Счет ' v-aaa ' не найден в Базе'.
else do:
if aaa.accrued <> 0 then  aaa.accrued  =  0.
end.