/* LCsts.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        смена статуса аккредитива для события Create
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame frlc (добавлено 3 новых поля)
   21/01/2011 id00810 - убрала фрейм, добавила сохранение статуса в таблице LCsts
   11/04/2011 id00810 - добавила статус CLS
   15/04/2011 id00810 - статус CLN
   23/05/2011 id00810 - статус ERR нужно присваивать без вопроса
   30/12/2011 id00810 - статус BO2 без вопроса
*/
{mainhead.i}

def input parameter v-lcstsold as char.
def input parameter v-lcstsnew as char.

def shared var v-lcsts as char.
def shared var s-lc like LC.LC.
def var v-yes as logi init yes.

if lookup(v-lcstsnew,'FIN,CLS,CNL,ERR,BO2') = 0  then do:
    message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
end.
if v-lcsts = v-lcstsold  then do transaction:
    v-lcsts = v-lcstsnew.

    find first LC where LC.LC = s-lc exclusive-lock no-error.
    LC.LCsts = v-lcstsnew.
    find current LC no-lock no-error.

    create LCsts.
    assign LCsts.LCnum  = s-lc
           LCsts.type   = 'CRE'
           LCsts.sts    = v-lcstsnew
           LCsts.whn    = g-today
           LCsts.who    = g-ofc
           LCsts.expimp = LC.LCtype
           LCsts.tim    = time.

end.
