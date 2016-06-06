/* vcvknp.p
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
        13.11.09 marinav  можно редактировать
*/

/* vcvknp.p Валютный контроль 
   Просмотр справочника кодов назначения платежа

   18.10.2002 nadejda создан
*/

{mainhead.i VCVKNP}

displ 'КОДЫ НАЗНАЧЕНИЯ ПЛАТЕЖА' at 10 with row 4 no-box no-label frame vcheader.

run vcview('spnpl', '*').

hide frame vcheader. hide frame vcfooter.


