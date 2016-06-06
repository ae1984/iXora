/* pcmt102.p
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
        12.10.2012 Lyubov
 * BASES
        BANK
 * CHANGES
*/

def shared var s-remtrz as char.

def stream str41.
def var v-unidir as cha .
define variable v-resultx as character.

def var v-strs as char no-undo.
def var v-str-count as integer no-undo.

def shared temp-table ttmps no-undo
    field sstr as char /*содержимое строки файла*/
    field scnt as integer /*порядковый номер строки в файле*/
    index ttmps-idx scnt.

find sysc where sysc.sysc = "PSJIN" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " ERROR !!! There isn't record PSJIN in sysc file !! ". pause 10.
 run lgps.
 return .
end.
v-unidir = sysc.chval.

v-unidir = v-unidir + s-remtrz.

input through value ("cp " + v-unidir + " " + s-remtrz + "; echo $?").
repeat:
  import v-resultx.
end.

v-str-count = 1. /*количество строк скинем на 1*/

input stream str41 from value(s-remtrz). /*читаем содержимое файла*/
repeat:
    import stream str41 unformatted v-strs.
    v-strs = trim(v-strs).

    create ttmps.
    assign
        ttmps.sstr = v-strs
        ttmps.scnt = v-str-count.

    v-str-count = v-str-count + 1.
end.
input stream str41 close.