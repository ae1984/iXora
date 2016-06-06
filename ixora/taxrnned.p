/* taxrnned.p
 * MODULE
        База РНН
 * DESCRIPTION
        Ввод/редактирование базы РНН
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.4.15
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	28/09/2005 - u00121 перекомпиляция в связи с изменением taxrnn.i
    04.09.2012 evseev - иин/бин
*/

def var nn as char  format "999999999999" initial "".

update nn label "Укажите ИИН/БИН" with frame aa.
hide frame aa.

{taxrnn.i}