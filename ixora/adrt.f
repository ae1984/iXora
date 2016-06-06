/* crc.f
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
        01/02/2006 dpuchkov
 * CHANGES
*/

form aadrt.crc LABEL "ВАЛЮТА" FORMAT 'Z9' 
     aadrt.mon LABEL "МЕСЯЦ"  format "z9"
     aadrt.rate label "СТАВКА" format "z9.99 " 
     aadrt.whn label "РЕГ.ДАТА"
     aadrt.who    LABEL "ЛОГИН " 
      with  centered row  3 down frame crc.

