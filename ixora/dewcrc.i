/* dewcrc.i
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

            if acc_list.crc ne 1 then do:
                find last crchis where crchis.crc eq acc_list.crc and
                crchis.rdt le {1} no-lock no-error.
                put {1} at 1 + margin. 
                put "Курс " at 11 crchis.rate [1] " KZT/" crchis.code.
                if crchis.rate[9] ne 1 then put " за " crchis.rate[9].
                run pwskip(0).
            end.
 