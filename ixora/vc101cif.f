/* vc101cif.f
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

/* vcmsg101chcif.f Валютный контроль
   Форма к списку клиентов

   27.12.2002 nadejda создан
*/


form
    t-chcif.bank label "БАНК" format "x(5)"
    t-chcif.cif label "КЛИЕНТ" format "x(6)"
    t-chcif.cifname label "НАИМЕНОВАНИЕ" format "x(35)"
    t-chcif.rnn label "РНН" format "x(12)"
    t-chcif.okpo label "ОКПО" format "x(8)"
    t-chcif.valcon label "ВАЛКОН?" 
   with width 80 row 9 centered scroll 1 10 down overlay title " ВЫБЕРИТЕ КЛИЕНТА " frame f-chcif.
