/* p905txb1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        p905_ps.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19.09.2011 aigul
 * BASES
        TXB
 * CHANGES
*/

def input parameter p-remtrz as char.
def input parameter p-ref1 as char.
def output parameter p-ref2 as char.
def output parameter p-ref3 as char.
def var oldpid like txb.que.pid .
def var oldpri like txb.que.pri .
def var nparpri as cha .
def var nparpid as cha .
def var v-que as char.
def var v-ref as char.
def var v-ref2 as char.
find first txb.remtrz where txb.remtrz.remtrz = p-remtrz no-lock no-error.
if avail txb.remtrz then v-ref = txb.remtrz.cwho + "@metrocombank.kz;".
find first txb.ofcsend where txb.ofcsend.typ = "glbuh" and txb.ofcsend.ofc <> p-ref1 no-lock no-error.
if avail txb.ofcsend then do:
    v-ref = v-ref + " " + txb.ofcsend.ofc + "@metrocombank.kz;".
    v-ref2 = txb.ofcsend.ofc.
end.
p-ref2 = v-ref.
p-ref3 = v-ref2.


