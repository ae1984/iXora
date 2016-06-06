/* imcedt.p
 * MODULE
        редактирование аккредитива
 * DESCRIPTION
        Описание
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
        10/09/2010 galina - меняем g-lang
        21/12/2010 Vera   - изменился frame frlc (добавлено 3 новых поля)
        05/01/2011 Vera   - обновление переменных фрейма
        19/01/2011 id00810 - вид продукта s-lcprod
        13/05/2011 id00810 - перекомпиляция (изменение в LCsub.i)
        19/07/2011 id00810 - изменение в заголовке формы (s-ftitle)
        17/01/2012 id00810 - добавлены переменные: наименование филиала, формат сообщения
        07/05/2012 Lyubov - перекомпиляция (изменение в LCsub.i)
        18.11.2013 Lyubov  - ТЗ 2125, добавила obligation validity
*/


{mainhead.i}
{LC.i}

def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var v-lcsumcur as deci.
def shared var v-lcsumorg as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var v-oblval   as date.
def shared var s-lcprod   as char.
def shared var s-ftitle   as char.
def shared var s-namef    as char.
def shared var s-fmt      as char.

g-lang = 'RR'.
{LCsub.i
&option = "IMLCedt"
&start = "on 'end-error' of frame frlc do: g-lang = 'US'. end."
&head = "LC"
&headkey = "LC"
&framename = "frlc"
&formname = "LC1"
&where = " "
&updatecon = "false"
&deletecon = "false"
&predelete = " "
&display = " display s-namef v-cif v-cifname s-lc v-lcsumorg v-lccrc1 v-lcsumcur v-lccrc2 v-lcdtexp v-oblval v-lcsts s-fmt v-lcerrdes with frame frlc. pause 0."
&preupdate = " "
&postupdate = " "
&prerun = " "
&postrun = " "
&end = "g-lang = 'US'."
&mykey = " "
&myproc = " "
}