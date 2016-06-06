/* aaaq-dda.f
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
        09.09.2013 evseev - tz-1376
*/

/* aaaq-dda.f
*/
form
     "КОД КЛИЕНТА: " cif.cif
     "" at 25 v-labelname format "x(14)" cif.sname format "x(35)" skip skip
     "НОМЕР СЧЕТА:" qaaa "(" s_aaa ")"
     "ВАЛЮТА СЧЕТА:"   at 41 crc.code skip
     "ГРУППА СЧЕТА:" lgr.lgr " " lgr.des format "x(25)"
     "СТАТУС: " at 41 aaa.sta "-" v-staname skip
     "ДАТА ОТКРЫТИЯ:" aaa.regdt format "99/99/9999" skip skip
     "ПОСЛ.ДЕБЕТ:" aaa.lstdb
     "ДАТА ПОСЛЕДНЕГО ДЕБЕТА:" at 41 aaa.ddt format "99/99/9999"  skip
     "ПОСЛ.КРЕДИТ:" aaa.lstcr
     "ДАТА ПОСЛЕДНЕГО КРЕДИТА:" at 41 aaa.cdt format "99/99/9999" skip

     with title "  ИНФОРМАЦИЯ О СЧЕТЕ  [DDA] " centered row 3 no-label overlay frame aaa.
