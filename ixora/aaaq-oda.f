/* aaaq-oda.f
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

/* aaaq-oda.f
*/
form
     "CIF#: -" cif.cif  "CRC:"   at 42 crc.code skip
     "NAME: " cif.sname "ACCT#:" at 40 qaaa  skip
     "TAX#: " cif.pss                           skip
     "TEL#: " cif.tel      "STATUS:" at 44 aaa.sta skip

     "CREDIT LINE:" crline "INT PD YTD:" at 40 ytdint   skip
     "CREDIT USED:" crused "INT RATE:"   at 42 aaa.rate format "z9.9999%"
     skip
     "GROSS   BAL:" avabal "NO.  USAGE:" at 40 vcnt     skip
     "NET     BAL:" vnet   "INTEREST" at 40 v-int
     skip
     "LAST  DEBIT:" aaa.lstdb
                           "LAST DB DATE:" at 40 aaa.ddt skip
     "LAST CREDIT:" aaa.lstcr
                           "LAST CR DATE:" at 40 aaa.cdt skip
     "MTD-ACCUMUL:" mtd
                           "OPEN    DATE:" at 40 aaa.regdt skip
     "YTD-AVERAGE:" ytd skip
     "FLOAT INFORMATION:       1:" aaa.fbal[1] skip
     "2:" aaa.fbal[2]
     "3:" aaa.fbal[3]
     "4:" aaa.fbal[4] skip
     "5:" aaa.fbal[5]
     "6:" aaa.fbal[6]
     "7:" aaa.fbal[7] skip
     with title " ACCOUNT INFORMATION " centered row 3 no-label overlay frame aaa.
