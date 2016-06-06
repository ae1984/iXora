/* tstbal.p
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


def var v-a like glbal.bal label "Актив". 
def var v-p like glbal.bal label "Пасив".
def var v-d like glbal.bal label "Доходы".
def var v-r like glbal.bal label "Расходы".
for each crc :
find glbal where glbal.gl eq 199995 and glbal.crc eq crc.crc no-lock no-error.
if available glbal then v-a = glbal.bal. else v-a = 0.

find glbal where glbal.gl eq 399995 and glbal.crc eq crc.crc no-lock no-error.
if available glbal then v-p = glbal.bal. else v-p = 0.

find glbal where glbal.gl eq 499995 and glbal.crc eq crc.crc no-lock no-error.
if available glbal then v-d = glbal.bal. else v-d = 0.

find glbal where glbal.gl eq 599995 and glbal.crc eq crc.crc no-lock no-error.
if available glbal then v-r = glbal.bal. else v-r = 0.

displ crc.code v-a v-p v-a - v-p  v-d v-r v-d - v-r.

end.                                      




