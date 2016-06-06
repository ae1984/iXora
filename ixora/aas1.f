/* aas1.f
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
        20/03/2012 dmitriy - добавил форматы для aas.ln и aas.payee
*/

form aas.ln format '>>9'
     aas.sic    label 'Код '
     aas.chkdt  label 'Дата чека'
     aas.chkno  label 'Чек '
     aas.chkamt label 'Сумма' format 'zzz,zzz,zzz,zz9.99'
     aas.payee  label 'Основание' format 'x(45)'
     v-specin   label 'П' format 'x(1)'
     v-speckr   label 'Д' format 'x(1)'
     with overlay   column 1 row 4 14 down
        title 'Счет ' + s-aaa + '. Специальные инструкции' frame aas1.
