/* chbin_txb.i
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
        06/06/2011 evseev
 * BASES
        BANK
 * CHANGES
        18.09.2012 evseev - ТЗ-1390
        26.12.2012 damir - Внедрено Т.З. 1620. Добавил v-bin_rnn_dt.
*/

def var v-bin as logi init no.
def var v-tegidn as char init "RNN".
def var v-bin_rnn_dt as date.

find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.

if v-bin then v-tegidn = "IDN". else v-tegidn = "RNN".

/*Дата переключатель - переход на ИИН/БИН - отображение данных по дате создания операции*/
find first txb.sysc where txb.sysc.sysc eq "dtrnnbin" no-lock no-error.
if avail txb.sysc then v-bin_rnn_dt = txb.sysc.daval.