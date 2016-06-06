/* LCok799.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Корреспонденция - входящий свифт - OK
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
        10/01/2011 Vera
 * BASES
        BANK COMM
 * CHANGES
    21/11/2011 id00810 - сохраним для истории информацию о пользователе
*/

{mainhead.i}

def shared var s-corsts as  char.
def shared var s-lc     like LC.LC.
def shared var s-lccor  like LCswt.lccor.
def        var v-yes    as   logi no-undo.

find first LCswt where LCswt.LC = s-lc and Lcswt.mt = 'O799' and LCswt.LCcor = s-lccor no-lock no-error.
if LCswt.sts  = 'NEW' then do:
    pause 0.
    message 'Do you want to change Correspondence status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
    find current LCswt exclusive-lock no-error.
    assign LCswt.sts = 'FIN'
           LCswt.dt  = g-today
           lcswt.info[2] = g-ofc.
    find current LCswt no-lock no-error.
    s-corsts = LCswt.sts.
end.
