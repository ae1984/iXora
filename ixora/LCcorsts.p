/* LCcorsts.p
 * MODULE
        Trade Finance
 * DESCRIPTION

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
        07/02/2011 evseev - взял за основу LCsts.p
 * BASES
        BANK COMM
 * CHANGES
        05.03.2012 Lyubov  - передаем формат сообщения шареной переменной s-mt

*/
{mainhead.i}

def input parameter v-stsold as char.
def input parameter v-stsnew as char.

/*def shared var v-lcsts as char.*/
def shared var s-lc like LC.LC.
def shared var s-mt as inte.
def shared var s-corsts like lcswt.sts.
def shared var s-lccor like lcswt.lccor.

def var v-yes as logi init yes.

if v-stsnew <> 'FIN' then do:
    message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
end.
if s-corsts = v-stsold  then do transaction:
    s-corsts = v-stsnew.

    find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I' + string(s-mt) exclusive-lock no-error.
    LCswt.sts = v-stsnew.
    find current LCswt no-lock no-error.

    create LCsts.
    assign LCsts.LCnum = s-lc + '_' + string(s-lccor)
           /*LCsts.type = ''*/
           LCsts.sts = v-stsnew
           LCsts.whn = g-today
           LCsts.who = g-ofc
           LCsts.expimp = LCswt.LCtype
           LCsts.tim = time.
end.
