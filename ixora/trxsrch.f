/* trxsrch.f
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Поиск шаблона по заданным параметрам
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
        01/09/04 sasco
 * CHANGES

*/

/*
form 
     tmphd.ln label "Л" format "99"
     tmphd.amt at 3 label "Сум" format "z.99"
     tmphd.amt-f at 7 format "x(2)" no-label 
     tmphd.crc at 9 label "Вл"
     tmphd.crc-f at 11 no-label
     tmphd.rate at 12 label "Курс   "
     tmphd.rate-f at 19 format "x(2)"  no-label
     tmphd.drgl at 21 label "Г/К-Дб"
     tmphd.drgl-f at 27 format "x(2)" no-label
     tmphd.drsub at 29 label "Суб"
     tmphd.drsub-f at 32 format "x(2)" no-label
     tmphd.dev at 34 label "Ур"
     tmphd.dev-f at 36 format "x(2)" no-label
     tmphd.dracc at 38 label "Счет-дебет"
     tmphd.dracc-f at 48 format "x(2)" no-label
     tmphd.crgl at 50 label "Г/К-Кр"
     tmphd.crgl-f at 56 format "x(2)" no-label
     tmphd.crsub at 58 label "Суб"
     tmphd.crsub-f at 61 format "x(2)" no-label
     tmphd.cev at 63 label "Ур"
     tmphd.cev-f at 65 format "x(2)" no-label
     tmphd.cracc at 67 label "Счет-кред." 
     tmphd.cracc-f at 77 format "x(2)" no-label
    with centered row 2 15 down frame tmphd.
*/

form 
     tmphd.scrc at 4 label "Валюта" 
               help "укажите валюту (all - любая)"
     tmphd.sdrgl at 12 label "Г/К-Дб"
               help "укажите Г/К (all - любая)"
     tmphd.sdrsub at 20 label "Суб"
               help "укажите субсчет (all - любой)"
     tmphd.sdev at 25 label "Ур"
               help "укажите уровень (all - любой)"
     tmphd.sdracc at 29 label "Счет-дебет"
               help "укажите счет (all - любой)"
     tmphd.scrgl at 41 label "Г/К-Кр"
               help "укажите Г/К (all - любая)"
     tmphd.scrsub at 48 label "Суб"
               help "укажите субсчет (all - любой)"
     tmphd.scev at 53 label "Ур"
               help "укажите уровень (all - любой)"
     tmphd.scracc at 58 label "Счет-кред." 
               help "укажите счет (all - любой)"
    with centered row 8 10 down frame tmphd.


