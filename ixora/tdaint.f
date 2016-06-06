/* tdaint.f
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
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tdaint.f
*/
form
     "КИФ# -" cif.cif      "ВАЛ" at 41 crc.code at 45 skip
     cif.sname             "СЧЕТ#" at 41 qaaa skip
     cif.tel               "СТАТУС      " at 41 aaa.sta skip
     "ОСТАТОК    " grobal  "ЗАДЕРЖ.ОСТ" at 41 aaa.hbal vdet skip
     "ДОСТУПН.ОСТ" avabal
     "НАЧИСЛ. % " at 41 aaa.accrued format "zz,zzz,zzz.9999-"  skip
     "ПРОЦ.СТАВКА" intrat  "ВЫПЛАЧЕН.% " at 41 ytdint  skip
                           skip
                           cif.pss at 41 skip
     "ПОСЛ.ДЕБЕТ " aaa.lstdb
                           "ДАТА        " at 41 aaa.ddt format "99/99/9999"
                           skip
     "ПОСЛ.КРЕДИТ" aaa.lstcr
                           "ДАТА        " at 41 aaa.cdt format "99/99/9999"
                           skip
                           "ДАТА ОТКРЫТ." at 41 aaa.regdt format "99/99/9999"
                           skip
                           "ДАТА ОКОНЧАН" at 41 aaa.expdt format "99/99/9999"
                           skip
     "ШТРАФ ЗА ДОСРОЧНУЮ ВЫДАЧУ" vplt vpenalty skip
     "ПЛАТЕЖ НА  " vpay to 32
     "СУММА  " at 41 v-payment to 73
     skip
     "СТАВКА НАЛОГА" v-taxrate to 32
     "СУММА НАЛОГА" at 41 v-taxamt to 73 skip
     /*
     "PRINT " v-print   
     */
     "ТРАНЗАКЦИЯ  " at 41 s-jh format "zzzzzzz9"
     with title " ИНФОРМАЦИЯ О СЧЕТЕ " centered row 3 no-label frame aaa.
