/* trxcdf.f
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

form wcod.cod label "Code  " format "x(6)"
     wcod.name label "Codificator    " format "x(15)"
     wcod.drcod label "DrCod" format "x(5)"
     wcod.drcod-f label "  " format "x(2)"
     wcod.drname label "DrName            " format "x(18)"
     wcod.crcod label "CrCod" format "x(5)"
     wcod.crcode-f label "  " format "x(2)"
     wcod.crname label "CrName            " format "x(18)" 
     with row 15 3 down overlay frame trxcdf.
     
