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

form lnpsp.pdt label "Дата"
     lnpsp.nsum label "Сумма (тыс. KZT)" format ">>>,>>>,>>>,>>9.99"
   with overlay no-hide centered row 20 10 down
   title v-title
   frame longr.