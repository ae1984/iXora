/* accmaint.f
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

/*
accmaint.f
*/

form
     "CIF# -" cif.cif      skip
     cif.sname             "СЧЕТ#" at 41 aaa.aaa  "(" s_aaa ")" skip
     cif.tel  "ТИП  " at 41 aaa.grp format "99"             
     "СОСТОЯНИЕ   " at 50 aaa.sta
    help "New Active Inactiv Dormant Closed Mature Feeless Semi Tempo" 
     skip
     "ПОЛН.БАЛАНС" grobal  shold at 41 aaa.hbal vdet skip
     "ДОСТ.БАЛАНС" avabal
     "НАЧ.ПРОЦЕНТ" at 41 aaa.accrued format "zz,zzz,zzz.99-"  skip
     "КРЕД.ЛИНИЯ " crline  "ПРЦ ОПЛАЧЕН" at 41 ytdint  skip
     "ИСП.КРЕД.Л." crused  skip
                           cif.pss at 41 skip
     "ПОСЛ.ДЕБЕТ " aaa.lstdb
                           "ДАТА ДЕБЕТА." at 41 aaa.ddt format "99/99/9999"
                           skip
     "ПОСЛ.КРЕДИТ" aaa.lstcr
                           "ДАТА КРЕДИТА" at 41 aaa.cdt format "99/99/9999"
                           skip
                           "ДАТА РЕГИСТР" at 41 aaa.regdt format "99/99/9999"
                           skip
     "ОСТАНОВЛЕН?" vrel    sstop at 41 vstop skip(1)
 "   FLOAT ИНФОРМАЦИЯ  ----------------------------------------------------"
     skip
     "   1" aaa.fbal[1] "4" aaa.fbal[4] "7" aaa.fbal[7] skip
     "   2" aaa.fbal[2] "5" aaa.fbal[5] skip
     "   3" aaa.fbal[3] "6" aaa.fbal[6]
     with title " ИНФОРМАЦИЯ ПО СЧЕТУ " centered row 2 no-label frame aaa.
