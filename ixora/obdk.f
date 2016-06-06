/* obdk.f
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


put space(43) " Всего : " accumulate total by tbal.crc tbal.dam
    format "->>>,>>>,>>>,>>9.99" space(2) accumulate total by tbal.crc tbal.cam
    format "->>>,>>>,>>>,>>9.99" skip(1).
