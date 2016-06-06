/* comm-swt.i
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

/* KOVAL Вызов справочника из codfr любого кодификатора 

Например:
  Вызов
  run comm-swmc("iso3166", input-output country).
  /* Передаем код справочник и input-output переменную */

  name = return-value. /* Возвращается наименоввние */

  В country (input-output) передается значение codfr.code.

*/

procedure comm-swmc.
def input parameter v-codfr-cdfr as char.
def input-output parameter v-codfr-code as char.
def var v-codfr-name as char init "".

find first codfr no-lock where codfr.codfr = v-codfr-cdfr and codfr.code  = v-codfr-code no-error.
if avail codfr then do:
	v-codfr-name = trim(codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4] + codfr.name[5]).
	v-codfr-code = v-codfr-name.
end.

return v-codfr-name.

end.
