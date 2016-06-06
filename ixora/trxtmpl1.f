/* trxtmpl1.f
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
        01/09/04 sasco русифицировал форму
        04/12/08 marinav - увеличение формы для IBAN
*/

def {1} shared frame trxtmpl1.
def var vdown as inte initial 8.

/*
form trxtmpl.ln label "Л" format "99"
     trxtmpl.amt at 3 label "Сум" format "z.99"
     trxtmpl.amt-f at 7 format "x(2)" no-label 
     trxtmpl.crc at 9 label "Вл"
     trxtmpl.crc-f at 11 no-label
     trxtmpl.rate at 12 label "Курс   "
     trxtmpl.rate-f at 19 format "x(2)"  no-label
     trxtmpl.drgl at 21 label "Г/К-Дб"
     trxtmpl.drgl-f at 27 format "x(2)" no-label
     trxtmpl.drsub at 29 label "Суб"
     trxtmpl.drsub-f at 32 format "x(2)" no-label
     trxtmpl.dev at 34 label "Ур"
     trxtmpl.dev-f at 36 format "x(2)" no-label
     trxtmpl.dracc at 38 label "Счет-дебет"
     trxtmpl.dracc-f at 48 format "x(2)" no-label
     trxtmpl.crgl at 50 label "Г/К-Кр"
     trxtmpl.crgl-f at 56 format "x(2)" no-label
     trxtmpl.crsub at 58 label "Суб"
     trxtmpl.crsub-f at 61 format "x(2)" no-label
     trxtmpl.cev at 63 label "Ур"
     trxtmpl.cev-f at 65 format "x(2)" no-label
     trxtmpl.cracc at 67 label "Счет-кред." 
     trxtmpl.cracc-f at 77 format "x(2)" no-label
     with row 22 8 down centered overlay frame trxtmpl1.
*/
form trxtmpl.ln label "Л" format "99"
     trxtmpl.amt at 3 label "Сум" format "z.99"
     trxtmpl.amt-f at 7 format "x(2)" no-label 
     trxtmpl.crc at 9 label "Вл"
     trxtmpl.crc-f at 11 no-label
     trxtmpl.rate at 12 format "z.99" label "Курс "
     trxtmpl.rate-f at 17 format "x(2)"  no-label
     trxtmpl.drgl at 19 label "Г/К-Дб"
     trxtmpl.drgl-f at 25 format "x(2)" no-label
     trxtmpl.drsub at 27 label "Суб"
     trxtmpl.drsub-f at 30 format "x(2)" no-label
     trxtmpl.dev at 32 label "Ур"
     trxtmpl.dev-f at 34 format "x(2)" no-label
     trxtmpl.dracc at 36 format "x(20)" label "Счет-дебет"
     trxtmpl.dracc-f at 56 format "x(2)" no-label
     trxtmpl.crgl at 60 label "Г/К-Кр"
     trxtmpl.crgl-f at 66 format "x(2)" no-label
     trxtmpl.crsub at 68 label "Суб"
     trxtmpl.crsub-f at 71 format "x(2)" no-label
     trxtmpl.cev at 73 label "Ур"
     trxtmpl.cev-f at 75 format "x(2)" no-label
     trxtmpl.cracc at 77 format "x(20)" label "Счет-кред." 
     trxtmpl.cracc-f at 97 format "x(2)" no-label
     with row 22 vdown down width 100 centered overlay frame trxtmpl1.
