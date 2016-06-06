﻿/* aaatoday2.f
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

display stream m-out
"================================================================================================================================="
"КИФ     НАИМЕНОВАНИЕ, АДРЕС                                            "
"  СЧЕТ КЛИЕНТА               КТО          КОГДА  СТАТУС"
"                                                                     ТИП                            ОТКРЫЛ       ОТКРЫЛ   СЧЕТА"
"================================================================================================================================="
with no-box width 142.
