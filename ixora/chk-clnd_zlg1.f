/* chk_clnd_zlg1.f
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
        09/07/2004 madiar
 * CHANGES
*/

form lnmonsrp.num label "N"
     lnmonsrp.zname label "Залог"
     lnmonsrp.crc label "Валюта"
     lnmonsrp.nsum label "Сумма" format ">>>,>>>,>>>,>>9.99"
   with overlay no-hide centered row 5 10 down
   title v-title
   frame longr1.