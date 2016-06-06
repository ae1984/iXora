/* h-crc2.p
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
        22.10.2012 Lyubov
 * CHANGES

*/

def var vcrc as int.
{global.i}
{itemlist.i
        &file = "crc"
        &start = " "
        &where = "crc.sts <> 9"
        &form  = "crc.crc
         crc.code label ""CODE"" format ""x(3)""
         crc.des   format ""x(23)"" "
        &frame = "row 5 centered scroll 1 6 down overlay "
        &predisp = "find crchs where crchs.crc = crc.crc no-lock."
        &flddisp = "crc.crc crc.code crc.des "
        &chkey = "crc"
        &chtype = "integer"
        &index  = "crc"
        &funadd = "if frame-value = "" "" then do:
                     {imesg.i 9205}.
                     pause 1.
                     next.
                   end." }
return frame-value.
