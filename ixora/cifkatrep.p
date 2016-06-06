/* cifkatrep.p
 * MODULE
            Клиенты и их счета
 * DESCRIPTION
            Отчет - Текущие остатки по категориям клиентов
 * RUN

 * CALLER
          cifkat*.p

 * SCRIPT

 * INHERIT
 
 * MENU
        8.1.15.*
 
 * AUTHOR
        31/07/2003 sasco

 * CHANGES
        09/09/2003 sasco - вывод информации по закрытым счетам
*/


define input parameter p-trw as character. /* код категории клиентов */

define temp-table tmp
            field cif like cif.cif
            field aaa like aaa.aaa
            field crc like aaa.crc
            field name like aaa.name
            field sum as decimal format '->>>,>>>,>>>,>>9.99'
            field closed as char format 'x(10)'
            index idx_tmp is primary crc cif aaa.

find codfr where codfr.codfr = 'cifkat' and codfr.code = p-trw no-lock no-error.
if not available codfr then do:
   message "Не найден код категории (" p-trw ")" view-as alert-box title ''.
   return.
end.

for each cif where cif.trw = p-trw no-lock:
    for each aaa where aaa.cif = cif.cif no-lock:

        if aaa.sta <> 'C' and not (string(aaa.lgr) begins '5') then do:
           create tmp.
           assign tmp.cif = cif.cif
                  tmp.aaa = aaa.aaa
                  tmp.crc = aaa.crc
                  tmp.name = trim(trim(cif.prefix) + " " + trim(cif.name))
                  tmp.sum = aaa.cr[1] - aaa.dr[1].
        end. /* sta <> 'C' */

        if aaa.sta = 'C' then do:
           find first sub-cod where sub-cod.sub = 'cif' and 
                                    sub-cod.acc = aaa.aaa and 
                                    sub-cod.d-cod = 'clsa' no-lock no-error.
           if avail sub-cod then do:
              create tmp.
              assign tmp.cif = cif.cif
                     tmp.aaa = aaa.aaa
                     tmp.crc = aaa.crc
                     tmp.name = trim(trim(cif.prefix) + " " + trim(cif.name))
                     tmp.sum = aaa.cr[1] - aaa.dr[1]
                     tmp.closed = string (sub-cod.rdt, "99/99/9999").
           end.
        end. /* sta = 'C' */

    end. /* for each aaa */
end.

output to rpt.txt.

put unformatted  today format '99/99/9999' '   ОТЧЕТ ПО СЧЕТАМ КЛИЕНТОВ' skip (2).
put unformatted '             ' codfr.name[1] skip.

for each tmp break by tmp.crc by tmp.cif by tmp.aaa:
    if first-of (tmp.crc) then do:
        find first crc where crc.crc = tmp.crc no-lock no-error.
        put unformatted skip(2) ' ВАЛЮТА - ' crc.code skip.
        put unformatted '------------------------------------------------------------------------' skip.
        put unformatted '  Счет                 Клиент                       Остаток    Закрыт' skip.
        put unformatted '------------------------------------------------------------------------' skip.
    end.
    put tmp.aaa tmp.name tmp.sum '   ' tmp.closed skip.

    if last-of (tmp.crc) then 
        put unformatted '------------------------------------------------------------------------' skip.
end.

put unformatted skip (2).

output close.
run menu-prt( 'rpt.txt' ).
