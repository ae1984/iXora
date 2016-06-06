/* h-crc.p
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
   14/08/03 nataly добавлена стока  return frame-value.
*/


{global.i}
{itemlist.i
        &file = "crc"
        &start = " "
        &where = "crc.sts <> 9"
        &form  = "crc.crc
         crc.des   format ""x(23)""
          crc.rate[9] label ""UNIT"" format ""zzzzz9""
          crc.rate[1] label ""MID-RATE""
          crchs.hs label 'H/S'"
        &frame = "row 5 centered scroll 1 6 down overlay "
        &predisp = "find crchs where crchs.crc = crc.crc no-lock."
        &flddisp = "crc.crc crc.des crc.rate[9] crc.rate[1] "
        &chkey = "crc"
        &chtype = "integer"
        &index  = "crc"
        &funadd = "if frame-value = "" "" then do:
                     {imesg.i 9205}.
                     pause 1.
                     next.
                   end." }
return frame-value.

