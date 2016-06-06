/* insinf.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Информация о банке и клиенте
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
        28/01/2010 galina
 * BASES
        BANK TXB
 * CHANGES
        27.08.2012 evseev - иин/бин
*/
def input parameter p-clbin as char.
def output parameter p-name as char.
def output parameter p-rnn as char.
def output parameter p-badr as char.
def output parameter p-cladr as char.
def output parameter p-bin as char.

find first txb.cif where txb.cif.bin = p-clbin no-lock no-error.
if avail txb.cif then p-cladr = txb.cif.addr[1] + ' ' + txb.cif.addr[2].
find first txb.cmp no-lock no-error.
if avail txb.cmp then
  assign p-name = txb.cmp.name
         p-rnn = txb.cmp.addr[2]
         p-badr = txb.cmp.addr[1].

find txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
if avail txb.sysc then do:
   p-bin = txb.sysc.chval.
end.