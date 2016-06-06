/* involist.i
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       25/07/2007 madiyar - убрал ссылку на удаленную таблицу funhis
        02.02.10 marinav - расширение поля счета до 20 знаков
        28.11.2012 damir - Внедрено Т.З. № 1588.
*/

/* involist.i */

define {1} variable start_dt as date.
define {1} variable i as integer.
define {1} temp-table involist
                      field amt like bank.jl.dam
                      field acc like bank.aaa.aaa
                      field amt1 like bank.jl.dam
                      field crc like bank.crc.crc
                      field crcode like bank.crc.code
                      field rate as deci format "9999999.9999999999"
                      field dat as date format "99/99/9999"
                      field sts as char format "X(3)"
                      field who like bank.jh.who
                      field trx like bank.jl.trx
                      field jh like bank.jl.jh
                      field ln  as integer format "9999"
                      field tim as integer format "zzzzz9"
                      field num as integer format "999"
                      field faktura as inte format "99999999"
                      field jdt as date format "99/99/9999"
                      field glcom as integer format "999999"
                      field comcode like bank.joudoc.comcode
                      field prizn as char
                      field txb as char.
