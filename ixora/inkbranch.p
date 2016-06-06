/* inkbranch.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        INKM_ps.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        17/11/2008 alex
 * BASES
        TXB
 * CHANGES
*/

def input parameter v-jss as char no-undo.
def input parameter v-iik as char no-undo.
def output parameter v-stat as integer no-undo.

def shared var v-txb as char.

def var v-ourbank as char.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbank = txb.sysc.chval.
else run savelog( "inkps", "inkbranch: Отсутствует запись ourbank!").



for each txb.cif where txb.cif.jss = v-jss no-lock:
    v-txb = v-ourbank.
    find first txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.aaa = v-iik no-lock no-error.
    if avail txb.aaa then do:
        if (txb.aaa.sta <> "C") and (txb.aaa.sta <> "E") then do: v-stat = 1. leave. end.
        else do: v-stat = 13. leave. end.
    end.
end.




