/* aaaq-cda.f
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

/* aaaq-cda.f */
form
     "КОД КЛИЕНТА: " cif.cif
     "НАИМЕНОВАНИЕ:" at 25 cif.sname format "x(35)" skip skip
     "НОМЕР СЧЕТА:" qaaa "(" aaa.gl ")"
     "ВАЛЮТА СЧЕТА:    " at 41 crc.code skip
     "ГРУППА СЧЕТА:" lgr.lgr " " lgr.des format "x(25)"
     "СТАТУС: " at 41 aaa.sta "-" v-staname skip
     "СРОК ВКЛАДА(В ДНЯХ) :" vday
     "ПРОЦЕНТ    %" at 41 intrat skip
     "ОСТАЛОСЬ(ДНЕЙ):" vterm skip
     "ДАТА ОТКР. :" aaa.regdt format "99/99/9999"
     "СУММА ОТКР.:" at 41 aaa.opnamt skip
     "ДАТА ЗАКР. :"  aaa.expdt format "99/99/9999"
     "СУММА ЗАКР.:" at 41 mbal skip skip
     "ПОСЛ.ДЕБЕТ::" aaa.lstdb
     "ДАТА ПОСЛЕДНЕГО ДЕБЕТА:" at 41 aaa.ddt format "99/99/9999" skip
     "ПОСЛ.КРЕДИТ:" aaa.lstcr
     "ДАТА ПОСЛЕДНЕГО КРЕДИТА:" at 41 aaa.cdt format "99/99/9999" skip
     with title "  ИНФОРМАЦИЯ О СЧЕТЕ [CDA]" centered row 3 no-label overlay frame faaa.
