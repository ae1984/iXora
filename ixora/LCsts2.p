/* LCsts2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        смена статуса изменения по аккредитиву
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
        01/03/2011 id00810 - убрала фрейм
*/
{mainhead.i}

def input parameter v-lcstsold as char.
def input parameter v-lcstsnew as char.

def shared var s-lc like LC.LC.
def var v-yes as logi init yes.
define shared variable s-amdsts like lcamend.sts.
define shared variable s-lcamend like lcamend.lcamend.

if v-lcstsnew <> 'FIN' and v-lcstsnew <> 'ERR' and v-lcstsnew <> 'amend' then do:
    message 'Do you want to change amendment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
end.
if s-amdsts = v-lcstsold  then do transaction:
    s-amdsts = v-lcstsnew.

    find first LCamend where LCamend.LC = s-lc and LCamend.lcamend = s-lcamend exclusive-lock no-error.
    LCamend.sts = v-lcstsnew.
    find current LCamend no-lock no-error.

    create LCsts.
    assign LCsts.LCnum = s-lc
           LCsts.num = s-lcamend
           LCsts.type = 'AMD'
           LCsts.sts = v-lcstsnew
           LCsts.whn = g-today
           LCsts.who = g-ofc
           LCsts.expimp = 'I'
           LCsts.tim = time.
end.