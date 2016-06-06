/* orgcif.p
 * MODULE
        Платежные карты.
 * DESCRIPTION
        Описание - Загрузка файлов по ПК из ИБ.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        TXB
 * AUTHOR
        21/05/2013 id01294 zhassulan - ТЗ №1788 (кредитный лимит)
 * CHANGES
*/

define input  parameter v-EXT_ID   as character.
define output parameter orgBin     as character.
define output parameter orgName    as character.
define output parameter orgAddress as character.

find first txb.cif where txb.cif.cif = v-EXT_ID no-lock no-error.
if avail txb.cif then do:
   orgBin      = txb.cif.bin.
   orgName     = txb.cif.prefix + ' ' + txb.cif.name.
   orgAddress  = txb.cif.addr[1] + txb.cif.addr[2] + txb.cif.addr[3].
end.