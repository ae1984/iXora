/*advrbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advice of Refusal
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
        25/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
*/
/*{global.i}*/
{mainhead.i}

def shared var s-lc like LC.LC.

def  shared var s-event like lcevent.event.
def  shared var s-number like lcevent.number.
def  shared var s-sts like lcevent.sts.

def var v-zag as char.
def var v-yes as logi init yes.
def var v-str as char.
def var v-sp  as char.
def var v-file  as char.

pause 0.
if s-sts <> 'BO1'  then do:
    message "Letter of status should be BO1!" view-as alert-box error.
    return.
end.
else do:
  message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
  if not v-yes then return.

  run mt734 no-error.
  if error-status:error then do:
    run lcstse(s-sts,'ERR').
    return.
  end.
  run lcstse(s-sts,'FIN').


end.
