/* bksprt.p
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

/* bksprt.p
 * Модуль
     Используется во всех модулях где может производится штамповка кассовых транзакций  
 * Назначение
     Повторная печать чека БКС отштампованных кассовых транзакций
 * Применение

 * Вызов
     
 * Пункты меню
     п.3.1.12 kanat Печать чека БКС 

 * Автор
     kanat
 * Дата создания:
     04.08.03
 * Изменения
     04.08.2003 kanat написал процедуру
*/

def var v-jh-number as char.
def var v-payment as char init "".
def var v-bks-choice as logical.
def var v-jl-jdt as date.


update v-jh-number label "Введите номер проводки: " with centered side-label.


     find first jh where jh.jh = int(v-jh-number) and jh.sts = 6 no-lock no-error.
     find first jl where jl.jh = jh.jh and jl.jdt = jh.jdt and jl.gl = 100100 no-lock no-error. 
     if avail jl then do:
        v-jl-jdt = jl.jdt.
     	MESSAGE "Печатать чек БКС?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "БКС" UPDATE v-bks-choice.
     	if v-bks-choice = true then do:  
     		for each jl where jl.jh = int(v-jh-number) and jl.jdt = v-jl-jdt and jl.gl = 100100 no-lock.
    			find first crc where crc.crc = jl.crc no-lock no-error.
   			v-payment = v-payment + string(v-jh-number) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
     		end.
     			v-payment = right-trim(v-payment,"|").
     			run bks.p(v-payment,"TRX").
     	end.
     end.
     else do:
     	MESSAGE "Проводка не кассовая либо не отштампована кассиром" VIEW-AS ALERT-BOX TITLE "Внимание".
     end.










