/* lclimcre.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Number of new limit
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1
 * AUTHOR
        19/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-cif     as char.
def shared var s-ourbank as char no-undo.
def shared var s-number  like lclimit.number.

find last lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif no-lock no-error.
if avail lclimit then s-number = lclimit.number + 1.
else s-number = 1.
