/* chbin.i
 * MODULE
        Операционный
 * DESCRIPTION
        Функция для проверки перехода на ИНН/БИН
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
        25/01/2011 marinav
 * BASES
        BANK
 * CHANGES
        18.09.2012 evseev - ТЗ-1390
        24.09.2012 evseev - ТЗ-1368
        26.12.2012 damir - Внедрено Т.З. 1620. Добавил v-bin_rnn_dt.
*/

def var v-bin as logi init no.
def var v-tegidn as char init "RNN".
def var v-labelidn as char init "РНН".
def var v-bin_rnn_dt as date.

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.

if v-bin then v-tegidn = "IDN". else v-tegidn = "RNN".
if v-bin then v-labelidn = "ИИН/БИН". else v-labelidn = "РНН".

/*Дата переключатель - переход на ИИН/БИН - отображение данных по дате создания операции*/
find first sysc where sysc.sysc eq "dtrnnbin" no-lock no-error.
if avail sysc then v-bin_rnn_dt = sysc.daval.