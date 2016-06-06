/* contrz.f
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


form "-----------------------------------------------------------------" skip
     remtrz.remtrz label "Платеж"
     remtrz.ordins[1] label "Банк отпр." skip(1)
     b-aaa label "Счет" b-cif label "Клиент"  b-name no-label format "x(41)"
     skip
     b-name1 no-label format "x(73)"skip
     "------Реквизиты банка------"
     remtrz.rbank label "Назв." at 32
     remtrz.rcbank label "Кор.Банк" at 52 skip
     remtrz.actins[1] format "x(36)" no-label
     "   ------ Реквизиты получателя --" skip
     remtrz.actins[2] format "x(35)"no-label
     remtrz.ba format "x(34)" no-label at 40 skip
     remtrz.actins[3] no-label
     ben1 format "x(35)" no-label at 40 skip
     remtrz.actins[4] no-label
     ben2 format "x(35)" no-label at 40 skip
     ben3 format "x(35)" no-label at 40 skip
     "----- Детали платежа ------"
     ben4 format "x(35)" no-label at 40 skip
     remtrz.detpay[1] format "x(35)" no-label skip
     remtrz.detpay[2] format "x(35)" no-label
     " ---Сумма и валюта платежа----" skip
     remtrz.detpay[3] format "x(35)" no-label 
     remtrz.payment label "Сумма" at 40
     b-crc no-label at 69 skip
     remtrz.detpay[4] format "x(35)" no-label remtrz.valdt2 label
     "Дата проводки" at 40 skip
     remtrz.jh1 label "Пров" /*brem.valdt label "Value date" at 37*/ skip
     "------Комиссионные---------"  v-comgl format "zzzzzz" no-label
                                       comdes format "x(20)" no-label skip
     remtrz.svca format "zzzzzz.99" label "Сумма" c-code no-label
     c-aaa label "Счет" c-cif label "Клиент" c-name no-label format "x(21)"
     with frame rembo side-labels
     row 1 centered overlay width 76 title "Контроль исходящих платежей".
