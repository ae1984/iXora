/* LCMNGA.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт контролирующего менеджера
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var v-cif as char.
def shared var v-cifname as char.
def shared var v-lcsts as char.
def new shared var v-lcerrdes as char.
def shared var s-lc like LC.LC.
def shared var v-find as logi.
def shared var s-ourbank as char no-undo.
define shared variable s-amdsts like lcamend.sts.
define shared variable s-lcamend like lcamend.lcamend.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lccrc1 as char.
def shared var v-lccrc2 as char.

if s-amdsts  = 'MNG' then run LC2auth2.




