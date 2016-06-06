/* funedt.f
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
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

form fun.fun      label "Номер сделки......" skip
     fun.gl       label "Гл.книга.........." gl.sname no-label skip
     fungrp.des no-label "(" fun.grp format "zz9" no-label ")" skip
     fun.bank     label "Контрагент........" fun.cst no-label skip
     fun.amt      label "Сумма............." skip
     fun.ddt[5]   label "Дата регистрации.." skip
     fun.rdt      label "Дата валютирования" skip
     fun.duedt    label "Дата закрытия....." skip
     fun.trm      label "Дней.............." skip
     fun.intrate  label "% ставка.........." format "z,zz9.9999" skip
     fun.interest label "Сумма процентов..." "(" fun.itype no-label ")" skip
     fun.dfb      label "Наш коррбанк......" vdfbnm no-label skip
     vdfbacct     label "Счет.............." skip
     fun.tbank    label "Коррбанк партнера." skip
     fun.acct     label "Счет.............." skip
     fun.who      label "Исполнитель......." s-jh label "Транзакция.." skip
     fun.rem      label "Примечания" 
     with frame fun row 2 side-label centered title " Ф О Н Д Ы ".
