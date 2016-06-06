/* bookcred.f
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

form
    bookcod.code label "КОД" format "x(5)"
        validate (bookcod.code <> "", " Введите код элемента справочника !")
    bookcod.name label "НАИМЕНОВАНИЕ" format "x(40)"
        validate (bookcod.name <> "", " Введите название элемента справочника !")
    bookcod.info[1] label "МЕНЮ" format "x(4)"
    bookcod.regdt 
    bookcod.regwho
with centered 13 down title v-title row 4 frame bookcod.
