/* help-debls.p
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
        01/06/2006 u00600 - добавила поиск по РНН
        02/06/2006 u00600 - добавила формат для debls.name
        05/06/2006 u00600 - добавила debls.sts
        18/11/2011 evseev  - переход на ИИН/БИН

*/
{chbin.i}
def input parameter v-grp like debgrp.grp.
def input parameter showall as logical.
def var choice as int format "9" init 2.
def var str as char format "x(60)".
def var str-rnn as char format "x(12)".

if v-bin then message "Поиск по номеру (1) поиск по части названия (2) поиск по ИИН/БИН (3)" update choice.
else message "Поиск по номеру (1) поиск по части названия (2) поиск по РНН (3)" update choice.
if choice = 2 then message "Часть названия" update str.
if choice = 3 then do:
   if v-bin then message "ИИН/БИН" update str-rnn.
   else message "РНН" update str-rnn.
end.

{skappbra.i
      &head      = "debls"
      &index     = "ls no-lock"
      &formname  = "hlpdeb"
      &framename = "hls"
      &where     = " debls.grp = v-grp and (showall or debls.ls ne 0) and
                     caps(debls.name) matches caps('*' + trim(str) + '*') and
                     debls.rnn matches ('*' + trim(str-rnn) + '*') "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "debls.ls debls.name format 'x(37)' debls.sts"
      &highlight = "debls.ls debls.name debls.sts"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do
                          on endkey undo, leave:
                           /* frame-value = debls.ls. */
                           hide frame hls.
                           return string(debls.ls).
                    end."
      &end = "hide frame hls."
}


