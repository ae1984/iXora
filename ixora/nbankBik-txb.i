/* nbankBik-txb.i
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
        TXB
 * CHANGES
        03/05/2012 evseev - добавил banknamefil
        16/05/2012 evseev - добавил banklocat
        14.06.2012 damir  - добавил fullnamerus,fullnamekz.

*/

def var v-clecod as char no-undo.
v-clecod = "FOBAKZKA".
find txb.sysc where txb.sysc.sysc = "clecod" no-lock no-error.
if avail txb.sysc then v-clecod = txb.sysc.chval.

def var v-nbank as char no-undo.
v-nbank = '"ForteBank"'.
find txb.sysc where txb.sysc.sysc = "bankname" no-lock no-error.
if avail txb.sysc then v-nbank = txb.sysc.chval.

def var v-nbankru as char no-undo.
v-nbankru = 'АО "ForteBank"'.
find txb.sysc where txb.sysc.sysc = "banknameRu" no-lock no-error.
if avail txb.sysc then v-nbankru = txb.sysc.chval.

def var v-nbankkz as char no-undo.
v-nbankkz = '"ForteBank" АЌ'.
find txb.sysc where txb.sysc.sysc = "banknameKz" no-lock no-error.
if avail txb.sysc then v-nbankkz = txb.sysc.chval.

def var v-nbanken as char no-undo.
v-nbanken = '"ForteBank" JSC'.
find txb.sysc where txb.sysc.sysc = "banknameEn" no-lock no-error.
if avail txb.sysc then v-nbanken = txb.sysc.chval.

def var v-nbankDgv as char no-undo.
v-nbankDgv = '"ForteBank"'.
find txb.sysc where txb.sysc.sysc = "banknameDgv" no-lock no-error.
if avail txb.sysc then v-nbankDgv = txb.sysc.chval.

def var v-nbank1 as char no-undo.
v-nbank1 = 'ForteBank'.
find txb.sysc where txb.sysc.sysc = "bankname1" no-lock no-error.
if avail txb.sysc then v-nbank1 = txb.sysc.chval.

def var v-nbankfil as char no-undo.
v-nbankfil = 'ForteBank'.
find txb.sysc where txb.sysc.sysc = "banknamefil" no-lock no-error.
if avail txb.sysc then v-nbankfil = txb.sysc.chval.

def var v-banklocat as char no-undo.
v-banklocat = 'banklocat'.
find txb.sysc where txb.sysc.sysc = "banklocat" no-lock no-error.
if avail txb.sysc then v-banklocat = txb.sysc.chval.

def var v-ful_bnk_ru as char no-undo.
find first txb.sysc where txb.sysc.sysc eq "fullnamerus" no-lock no-error.
if avail txb.sysc then v-ful_bnk_ru = trim(txb.sysc.chval).

def var v-ful_bnk_kz as char no-undo.
find first txb.sysc where txb.sysc.sysc eq "fullnamekz" no-lock no-error.
if avail txb.sysc then v-ful_bnk_kz = trim(txb.sysc.chval).
