﻿/* bookcod.f
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
    bookcod.code label "КОД" format "x(10)"
        validate (bookcod.code <> "", " Введите код элемента справочника !")
    bookcod.name label "НАИМЕНОВАНИЕ" format "x(45)"
        validate (bookcod.name <> "", " Введите название элемента справочника !")
    bookcod.regdt 
    bookcod.regwho
with centered 13 down title v-title overlay row 4 frame bookcod.
