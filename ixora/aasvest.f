/* aasvest.f
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
        15.08.2011 ruslan - изменил форму
        17.08.2011 ruslan - перекомпиляция
*/


/*form aas_hist.sic label 'Код' aas_hist.chkdt label 'Дата чека'
     aas_hist.chkno label 'Чек' aas_hist.chkamt label 'Сумма'
     aas_hist.payee label 'PAMATOJUMS'*/
form waas.num label 'Номер' waas.ttype label "Тип" format "x(3)" aas_hist.regdt label 'ДАТА'
     waas.sum format '->>>,>>>,>>>,>>9.99' aas_hist.payee label 'ОСНОВАНИЕ' format "x(24)"
     with overlay   column 1 row 4 14 down
        title 'История специальных инструкций'  frame aasvest.
