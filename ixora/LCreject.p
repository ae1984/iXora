/* LCreject.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка аккредитива на корректировку
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
   21/01/2011 id00810 - убрала фрейм, изменила статусы
*/

{mainhead.i}

def shared var v-lcsts as char.
if v-lcsts  <> 'NEW' and v-lcsts  <> 'FIN' then do:
    pause 0.
    run LCsts(v-lcsts,'NEW').
end.


