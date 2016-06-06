/* s-funamt.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Показывает остатки на уровнях по заданному счету FUN 
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
        15.12.03 nataly
 * CHANGES
*/

def shared var s-fun like fun.fun.
def var v-sub like trxbal.sub initial "fun".
run amt_level(v-sub, s-fun).
