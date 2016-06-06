/* tdacrc-help.f
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
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

form crc.crc label "Nr" format "z9"
     crc.code label "Код" format "x(3)"
     crc.des label "Наименование" format "x(30)"
with row 7 8 down overlay centered title " Enter - выбрать валюту " frame crc.