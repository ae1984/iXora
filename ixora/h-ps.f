/* h-ps.f
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
        29.06.2012 damir - расширил scroll и ширину фрэйма.
*/

        /* h-ps.f Валютный контроль
        Форма к списку паспортов сделок

        18.10.2002 nadejda создан
        25.03.2008 galina - изменен формат вывода номера документа
        */

form
   vcps.dndate format "99/99/99"
   v-dnnum format "x(26)" label "ПАСПОРТ/ДОПЛИСТ"
   codfr.name[2] format "x(6)" LABEL "ТИП"
   vcps.sum
   ncrc.code label "ВАЛ" format "xxx"
   vcps.lastdate format "99/99/99" label "ПОСЛДАТА"
with width 80 row 4 centered scroll 1 30 down overlay frame h-ps.


