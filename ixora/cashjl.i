/* cashjl.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK
 * CHANGES
        30.09.2013 damir - Внедрено Т.З. № 1496.
*/

def {1} shared temp-table t-jl no-undo
    field gl like jl.gl
    field jh like jl.jh
    field dam like jl.dam
    field cam like jl.cam
    field who like jl.who
    field tel like jl.teller
    field jdt like jl.jdt
    field crc like jl.crc
    field tim like jl.tim
    field rem like jl.rem
    field dc like jl.dc
    field cd as inte
    field ln like jl.ln
index gl is primary gl cam dam
index idx1 crc ascending
index idx2 jh ascending
           ln ascending.


