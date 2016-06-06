/* vcrequest-bank.p
 * MODULE
        Вывод филиала
 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        vcrequestprint.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1 Запрос
 * AUTHOR
        26.01.2011 aigul
 * BASES
        BANK TXB COMM
 * CHANGES
*/

define input  parameter p-bank as char.
define input  parameter p-cif like txb.cif.cif.
define input parameter g-ofc like txb.ofc.ofc.
def output  parameter p-cifname as char.
def output  parameter p-fil as char.
def output  parameter p-ofc as char format "x(40)".
def var v-bnk as char.
v-bnk = "0" + substr(p-bank,4,2).

find first txb.cmp where txb.cmp.code = int(v-bnk) no-lock no-error.
if avail txb.cmp then p-fil = txb.cmp.name.

find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then p-cifname = txb.cif.name.

find first txb.ofc where txb.ofc.ofc = g-ofc no-lock no-error.
if avail txb.ofc then p-ofc = txb.ofc.name.