/* swiftext.p
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
/* A.Namyasenko
 *
 *   get swift extension
 *   input:
 *          bankbic   - swift bic
 *          key       - 1 - test if we have the key; 0 - not test
 *          result    - 0 - OK, 1 - not OK
 *   return :
 *          result
 */

define input        parameter bankbic as char format "x(13)".
define input        parameter key     as int.
define input-output parameter result  as int.

def var cmdk     as char format "x(70)".
def var addrbank as char format "x(80)".

if key eq 1 then
    cmdk = "/usr/local/bin/bicplinfo -k " + bankbic.
else
    cmdk = "/usr/local/bin/bicplinfo "    + bankbic.

if (index(bankbic, " ") ne 0 ) or
   (bankbic             eq "") or
   (length(bankbic)     le 7 ) or
   (length(bankbic)     gt 12)
then do:
    result = 1.
    return.
end.


input through value(cmdk) no-echo.
set addrbank with frame indata no-box no-labels width 80.
input close.

if addrbank eq "NO BASE" then do:
    result = 0.
    return.
end.

if  addrbank eq "ERROR" then do:
    message "CAN'T FIND BANK " + "'" + bankbic + "'" +
	      " IN THE SWIFT BIC DATA BASE".
    result = 1.
    return.
end.

if addrbank eq "NO EXTENSION" then do:
    message "CAN'T FIND BANK " + "'" + bankbic + "'" +
	      " IN THE SWIFT BIC DATA BASE".
    result = 1.
    return.
end.

if addrbank eq "BAD DATE" then do:
    message "WE HAVE A-KEYS WITH BANK " + "'" + bankbic + "'" +
	      " BUT WITH FUTURE DATE".
    result = 1.
    return.
end.

if addrbank eq "NO KEY" then do:
    message "WE DON" + "'" + "T HAVE A-KEYS WITH BANK " + "'" + bankbic + "'" +
	      " ".
    result = 1.
    return.
end.

MESSAGE addrbank VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание ".
result = 0.
return.
