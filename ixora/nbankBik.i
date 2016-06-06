/* nbankBik.i
 * MODULE
        Название банка и БИК
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
        25/12/2012 evseev
 * BASES
        BANK
 * CHANGES
        03/05/2012 evseev - добавил banknamefil
        16/05/2012 evseev - добавил banklocat
        14.06.2012 damir  - добавил fullnamerus,fullnamekz.

*/

def var v-clecod as char no-undo.
v-clecod = "FOBAKZKA".
find sysc where sysc.sysc = "clecod" no-lock no-error.
if avail sysc then v-clecod = sysc.chval.

def var v-nbank as char no-undo.
v-nbank = '"ForteBank"'.
find sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-nbank = sysc.chval.

def var v-nbankru as char no-undo.
v-nbankru = 'АО "ForteBank"'.
find sysc where sysc.sysc = "banknameRu" no-lock no-error.
if avail sysc then v-nbankru = sysc.chval.

def var v-nbankkz as char no-undo.
v-nbankkz = '"ForteBank" АЌ'.
find sysc where sysc.sysc = "banknameKz" no-lock no-error.
if avail sysc then v-nbankkz = sysc.chval.

def var v-nbanken as char no-undo.
v-nbanken = '"ForteBank" JSC'.
find sysc where sysc.sysc = "banknameEn" no-lock no-error.
if avail sysc then v-nbanken = sysc.chval.

def var v-nbankDgv as char no-undo.
v-nbankDgv = '"ForteBank"'.
find sysc where sysc.sysc = "banknameDgv" no-lock no-error.
if avail sysc then v-nbankDgv = sysc.chval.

def var v-nbank1 as char no-undo.
v-nbank1 = 'ForteBank'.
find sysc where sysc.sysc = "bankname1" no-lock no-error.
if avail sysc then v-nbank1 = sysc.chval.

def var v-nbankfil as char no-undo.
v-nbankfil = 'ForteBank'.
find sysc where sysc.sysc = "banknamefil" no-lock no-error.
if avail sysc then v-nbankfil = sysc.chval.


def var v-banklocat as char no-undo.
v-banklocat = 'banklocat'.
find sysc where sysc.sysc = "banklocat" no-lock no-error.
if avail sysc then v-banklocat = sysc.chval.

def var v-ful_bnk_ru as char no-undo.
find first sysc where sysc.sysc eq "fullnamerus" no-lock no-error.
if avail sysc then v-ful_bnk_ru = trim(sysc.chval).

def var v-ful_bnk_kz as char no-undo.
find first sysc where sysc.sysc eq "fullnamekz" no-lock no-error.
if avail sysc then v-ful_bnk_kz = trim(sysc.chval).
