/* swiftext2.p
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

/* SWIFTEXT.P */
/* A.Namyasenko, KOVAL
 *
 *   get swift extension
 *   input:
 *          bankbic   - swift bic
 *   return :
 * 	    mesg      - Bank name
 *          result    - true - OK, false - not OK
 */

define input        parameter bankbic as char format "x(13)".
define input-output parameter result  as logical.
define input-output parameter mesg    as char.

def var cmdk     as char format "x(70)".
def var addrbank as char format "x(80)".

cmdk = "/usr/local/bin/bicplinfo "    + bankbic.

if (index(bankbic, " ") ne 0 ) or (bankbic             eq "") or
   (length(bankbic)     le 7 ) or (length(bankbic)     gt 12) then do:
    result = false.
    mesg = addrbank.
    return.
end.

input through value(cmdk) no-echo.
 set addrbank with frame indata no-box no-labels width 80.
input close.

if addrbank eq "NO BASE" then do:
    result = false.
    mesg = addrbank.
    return.
end.

if addrbank eq "ERROR" then do:
    mesg = "CAN'T FIND BANK " + "'" + bankbic + "'" + " IN THE SWIFT BIC DATA BASE".
    result = false.
    return.
end.

if addrbank eq "NO EXTENSION" then do:
    mesg = "CAN'T FIND BANK " + "'" + bankbic + "'" + " IN THE SWIFT BIC DATA BASE".
    result = false.
    return.
end.

if addrbank eq "BAD DATE" then do:
    mesg = "WE HAVE A-KEYS WITH BANK " + "'" + bankbic + "'" + " BUT WITH FUTURE DATE".
    result = false.
    return.
end.

if addrbank eq "NO KEY" then do:
    mesg = "WE DON" + "'" + "T HAVE A-KEYS WITH BANK " + "'" + bankbic + "'" + " ".
    result = false.
    return.
end.
    mesg = addrbank.
    result = true.
return.
