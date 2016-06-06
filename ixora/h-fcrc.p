/* h-fcrc.p
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


{global.i}
{itemlist.i
        &file = "crc"
        &start = " "
        &where = "true"
        &form  = "crc.crc
         crc.des   format ""x(23)""
          crc.rate[9] label ""UNIT"" format ""zzzzz9""
          crc.rate[1] label ""MID-RATE""
          crc.rate[2] label ""CASH-BUY""
          crc.rate[3] label ""CASH-SELL""
          crchs.hs label 'H/S'
          crc.rate[4] label ""T/T-BUY"" at 23
          crc.rate[5] label ""T/T-SELL""
          crc.rate[6] label ""T/C-BUY""
          crc.rate[7] label ""T/C-SELL"" "
        &frame = "row 5 centered scroll 1 6 down overlay "
        &predisp = "find crchs where crchs.crc = crc.crc no-lock."
        &flddisp = "crc.crc crc.des crc.rate[9]
                    crc.rate[1] crc.rate[2] crc.rate[3] crchs.hs
                    crc.rate[4] crc.rate[5] crc.rate[6] crc.rate[7]"
        &chkey = "crc"
        &chtype = "integer"
        &index  = "crc"
        &funadd = "if frame-value = "" "" then do:
                     {imesg.i 9205}.
                     pause 1.
                     next.
                   end." }
