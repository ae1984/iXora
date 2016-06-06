/* lclimsts.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - смена статуса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1
 * AUTHOR
        21/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}
def input param v-stsold as char.
def input param v-stsnew as char.

def shared var s-cif       as char.
def shared var s-number    as int.
def shared var s-ourbank   as char no-undo.
def shared var v-limsts    as char.
def        var v-yes       as logi no-undo.

find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
if not avail lclimit then return.

if v-stsnew <> 'FIN' and v-stsnew <> 'ERR' then do:
    message 'Do you want to change limit status?' view-as alert-box question buttons yes-no title ' QUESTION !' update v-yes.
    if not v-yes then return.
end.
if v-limsts = v-stsold  then do:
    find current lclimit exclusive-lock no-error.
    lclimit.sts = v-stsnew.
    find current lclimit no-lock no-error.

    create lclimitsts.
    assign lclimitsts.bank   = s-ourbank
           lclimitsts.cif    = s-cif
           lclimitsts.number = s-number
           lclimitsts.sts    = v-stsnew
           lclimitsts.whn    = g-today
           lclimitsts.who    = g-ofc
           lclimitsts.tim    = time.
    v-limsts = v-stsnew.
end.