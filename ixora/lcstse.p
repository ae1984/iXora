/* lcstse.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Смена статуса события
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
        16/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        19/07/2011 id00810 - добавлен статус BO2
*/
{mainhead.i}

def input param v-stsold as char.
def input param v-stsnew as char.

def shared var s-lc          like LC.LC.
def shared var s-event       like lcevent.event.
def shared var s-number      like lcevent.number.
def shared var s-sts         like lcevent.sts.
def        var v-yes         as   logi            init yes.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

if v-stsnew <> 'FIN' and v-stsnew <> 'ERR' and v-stsnew <> 'BO2' then do:
    message 'Do you want to change event status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
end.
if s-sts = v-stsold  then do transaction:
    s-sts = v-stsnew.

    find first lcevent where lcevent.lc = s-lc and lcevent.event = s-event and lcevent.number = s-number no-lock no-error.
    if avail lcevent then do:
        find current lcevent exclusive-lock no-error.
        lcevent.sts = v-stsnew.
        find current lcevent no-lock no-error.
    end.

    create LCsts.
    assign LCsts.LCnum  = s-lc
           LCsts.num    = s-number
           LCsts.type   = s-event
           LCsts.sts    = v-stsnew
           LCsts.whn    = g-today
           LCsts.who    = g-ofc
           LCsts.expimp = lc.lctype
           LCsts.tim    = time.
end.