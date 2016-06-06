/* trxtmpl.f
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
     with row 6 10 down width 100  centered overlay frame trxtmpl.

form trxtmpl.rem[1]  label "Назначение плат[1] "  trxtmpl.rem-f[1] skip
     trxtmpl.rem[2]  label "Назначение плат[2] "  trxtmpl.rem-f[2] skip
     trxtmpl.rem[3]  label "Назначение плат[3] "  trxtmpl.rem-f[3] skip
     trxtmpl.rem[4]  label "Назначение плат[4] "  trxtmpl.rem-f[4] skip
     trxtmpl.rem[5]  label "Назначение плат[5] "  trxtmpl.rem-f[5] 
     with row 20 title "Примечание" centered overlay side-label no-label frame trxfooter.

form trxhead.sts label "Ст" trxhead.sts-f
     trxhead.party label "Печ" format "x(25)" trxhead.party-f 
     trxhead.point label "P" trxhead.point-f 
     trxhead.depart label "D" trxhead.depart-f  
     trxhead.mult label "Rep" trxhead.mult-f 
     trxhead.opt label "Опц" 
     validate(trxhead.opt = "+" or trxhead.opt = "-","") trxhead.opt-f
     with with title vcode + " " + vname row 3 centered 
     side-labels no-label overlay frame trxheader.

