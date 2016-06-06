/* rnnchk.p
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

/*
Created by svl ftom wrnn.prg
22.03.99.

При ошибке возвращает true. ? 

*/
def input PARAMETER v-rnn as char.
def output parameter v-priznak as log.

def var i as int.
def var j as int.
def var v-wstr1 as char.
def var v-wstr2 as char.
def var v-nres as int.
def var v-s as int.
def var wstr2 as int extent 11. 

v-priznak = no.
v-wstr1 = v-rnn.
if length(v-rnn) lt 12 then v-wstr1 = v-rnn + fill("0",12 - length(v-rnn)).
 
do i = 1 TO 10:
    do j = 1 TO 10:
        if i = 1 then wstr2[j] = j.
        else wstr2[j] = wstr2[j + 1].
    end.
    wstr2[11] = wstr2[1].
    v-s = 0.
    do j = 1 TO 11:  
        v-s = v-s + wstr2[j] * integer(SUBString(v-wstr1,j,1)).
    END.
    v-nres = v-s modulo 11.
    IF v-nres < 10 then do:
        IF STRing(v-nres,"9") ne substring(v-rnn,length(v-rnn),1) then do:
            v-priznak = true.
            RETURN.
        end.
        RETURN.
    END.
END.

RETURN.




