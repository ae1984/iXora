/* aaaq-sav.f
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

/*   aaaq-sav.f    */

form
     "КОД КЛИЕНТА: " cif.cif
     "КЛИЕНТ: " at 25 cif.sname format "x(35)" skip skip
     "НОМЕР СЧЕТА: "  qaaa "(" aaa.gl ")"
     "ВАЛЮТА СЧЕТА: " at 41 crc.code skip
     "ГРУППА СЧЕТА:" lgr.lgr " " lgr.des format "x(25)"
     "СТАТУС: " at 41 aaa.sta "-" v-staname skip
     "ДАТА ОТКРЫТИЯ :" aaa.regdt skip
     "ПОСЛ. ДЕБЕТ:" aaa.lstdb
     "ДАТА ПОСЛ.ДЕБЕТА :" at 41 aaa.ddt skip
     "ПОСЛ.КРЕДИТ:" aaa.lstcr
     "ДАТА ПОСЛ.КРЕДИТА:" at 41 aaa.cdt skip
     with title " ИНФОРМАЦИЯ О СЧЕТЕ [SAV]" centered row 3 no-label overlay frame aaa.
