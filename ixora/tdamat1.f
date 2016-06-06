/* tdamat1.f
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

/*   tdamat1.f
*/

form
     "CIF# -" cif.cif      "ПЕРС.КОД  / РЕГ.N" at 41 cif.pss skip
     cif.sname             "СЧЕТ          " at 41 aaa.aaa " (" aaa.gl ")" skip
     "СТАТУС  " aaa.sta    "СЧЕТ ДО ВОСТР." at 41 b-aaa.aaa " (" b-aaa.gl ")" skip
     "ВАЛЮТА    - " crc.des "ПРОЦЕНТ.СТАВКА" at 41 intrat skip
     "ОСТАТОК    " grobal   
     "ПЕРЕЧИСЛИТЬ % (2215) " at 41 vcalc format "zz,zzz,zzz.99-"  skip
     "ДОСТ.ОСТАТ." avabal
     "ПЕРЕЧИСЛИТЬ % (2211) " at 41 vcalc1 format "zz,zzz,zzz.99-"  skip
     "ЗАДЕР.ОСТ. " aaa.hbal
     "ВСЕГО ПЕРЕЧИСЛИТЬ %  " at 41 vcalcsv format "zz,zzz,zzz.99-"  skip
     "ВСЕГО НАЧИСЛ. %" at 41 ytdint skip
     "УДЕРЖАННЫЕ    %" at 41 aaa.cr[3] skip
     "ПОЛУЧЕННЫЕ    %" at 41 vsanproc

     "ПОСЛ.ДЕбЕТ " aaa.lstdb
                           "ДАТА        " at 41 aaa.ddt format "99/99/9999" skip
     "ПОСЛ.КРЕДИТ" aaa.lstcr
                           "ДАТА        " at 41 aaa.cdt format "99/99/9999"
                           skip(1)
     "С          " aaa.regdt format "99/99/9999"
     "ПО          " at 41 aaa.expdt format "99/99/9999" skip
     "ШТРАФ                " v-rate to 32  
     "СУММА" at 41 vpenalty to 72 skip
     "СТАВКА НЕРЕЗИД.НАЛОГА" v-taxrate to 32 
     "СУММА" at 41 v-taxamt to 72 skip
     /*
     "ВЫПОЛНЯТЬ ТРАНЗАКЦИЮ?" vans
     */
     "ТРАНЗАКЦИЯ  # " at 41 jl.jh format 'zzzzzzz9'

       /* "EWP TRX # " at 41 aal.aah   */
     with title " ДЕПОЗИТ  " centered row 3 no-label frame aaa.
