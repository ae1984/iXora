/* Inter-Branch.i
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
        Список вызываемых процедур - str-strx.p
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        28.11.2012 damir - Внедрено Т.З. № 1588.
*/

def {1} shared temp-table t-InterBrh
    field txb as char
    field docnum as char /* joudoc.docnum */
    field comcode as char /* joudoc.comcode */
    field whn as date /* joudoc.whn */
    field jdt as date /* jl.jdt */
    field jh as inte /* jl.jh */
    field sub as char /* jh.sub */
    field party as char /* jh.party */
    field who as char /* jl.who */
    field gl as inte /* jl.gl */
    field crc as inte /* jl.crc */
    field ln as inte /* jl.ln */
    field trx as char /* jl.trx */
    field rem as char extent 5 /* jl.rem */
    field ref as char /* jh.ref */
    field remtrz as char /* remtrz.remtrz */
    field svccgr as inte /* remtrz.svccgr */
    field rate as deci extent 9 /* crchis.rate */
index idx is primary jh  ascending
                     txb ascending

index idx2 jh  ascending
           txb ascending
           ln  ascending.

def buffer b-InterBrh for t-InterBrh.

def {1} shared temp-table t-work
    field txb as char
    field docnum as char
    field jh as inte
index idx is primary txb ascending.

def {1} shared var v_TXB as char init ''. /* comm.txb.bank */





