/* updoda.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/



{global.i}

def input parameter v-aaa like aaa.aaa.

define new shared var s-aaa like aaa.aaa.
define new shared var s-aax as int.
define new shared var s-amt as dec decimals 2.
define new shared var s-stn as int.
define new shared var s-intr as log.
define new shared var s-force as log.
define new shared var s-regdt as date.
define new shared var s-bal as dec decimals 2.
define new shared var s-aah as int.
define new shared var srem as char format "x(50)" extent 2.
define new shared var saaa like aaa.aaa.
define new shared var raaa like aaa.aaa.
define new shared var damt as dec decimals 2.


define shared var s-jh like jh.jh.


def var amt4 like rem.amt.
def buffer b-aaa for aaa.
def var vln as int.
def var v-okey as log.
def var v-dc like jl.dc.
define var s-jhold like jh.jh.
def var s-oldcrl like aaa.opnamt.

s-jhold = s-jh.
s-jh = 0.
do transaction :
    find aaa where aaa.aaa eq v-aaa exclusive-lock no-error.
    find b-aaa where b-aaa.aaa eq aaa.craccnt exclusive-lock no-error.

    amt4 = 0.
    if aaa.dr[1] gt aaa.cr[1] then do:
        v-dc = "C" .
        amt4 = aaa.dr[1] - aaa.cr[1] .
    end.
    if aaa.cr[1] gt aaa.dr[1] and b-aaa.dr[1] ne b-aaa.cr[1] then do:
        v-dc = "D".
        if aaa.cr[1] - aaa.dr[1] ge b-aaa.dr[1] - b-aaa.cr[1] then
            amt4 = b-aaa.dr[1] - b-aaa.cr[1] .
            else amt4 = aaa.cr[1] - aaa.dr[1] .
    end.

    if amt4 ne 0 then do :
        damt = amt4.
        if v-dc = "C" then do:
            saaa = b-aaa.aaa.
            raaa = aaa.aaa.
            srem[1] = "O/D PROTECT " .
            srem[2] = "FROM " + saaa + " TO " + raaa.
            run s-oda22.
        end.
        else do:
            saaa = aaa.aaa.
            raaa = b-aaa.aaa.
            srem[1] = "O/D PAYMENT ".
            srem[2] = "FROM " + saaa + " TO " + raaa.
            run s-oda21.
        end.
    end.
end.

s-jh = s-jhold.
