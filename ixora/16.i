/* 16.i
 * MODULE
        Отчеты для статистики
 * DESCRIPTION
        Отчет 16ПБ - общая
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        16run.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-2-14-9
 * AUTHOR
        11/03/04 sasco
 * CHANGES
        16/05/08 marinav сделала консолидацию
        14.02.2012 aigul - исправила вывод ГК 185800
*/


def {1} shared var v-date1 as date.
def {1} shared var v-date2 as date.

def {1} shared temp-table wrk

             field bank as char
             field crc like bank.crc.crc

             field dgl like bank.gl.gl
             field cgl like bank.gl.gl

             /* тип дебета / кредита: D /C */
             field dc as char form "x(1)"

             /* юр / физ: F / U */
             field fu as char

             /* рез / нерез: R / N */
             field res as char

             /* СУММЫ */
             field sum as decimal format "z,zzz,zzz,zzz,zz9.99-"

             /* КОД ФИЛИАЛА, КЛИЕНТА, НОМЕР ПРОВОДКИ */
             field cif as char format "x(6)" init ""
             field jh as int format "zzzzzzzz9"
             field party as char format "x(15)"

             field drem like bank.jl.rem
             field crem like bank.jl.rem

             field dam as decimal
             field cam as decimal
             field ln as int

             index idx_wrk is primary
                              bank crc dc dgl cgl fu res.


def {1} shared temp-table glacc$ field glacc$ as int.


def {1} shared temp-table tot

             field bank as char
             field dc as char form "x(1)"

             field crc like bank.crc.crc

             field dgl like bank.gl.gl
             field cgl like bank.gl.gl

             /* юр / физ: F / U */
             field fu as char

             /* рез / нерез: R / N */
             field res as char

             /* СУММЫ */
             field sum as decimal format "z,zzz,zzz,zzz,zz9.99-"

             field numtrx as int

             index idx_wrk is primary
                              bank crc dc dgl cgl fu res.

