/* preupdcondition.i
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

/* условие на справочники клиента clnsts, secek, ecdivis - 
  их запрещено редактировать после проведения контроля */

/*v-sub = 'cln' and can-find(cif where cif.cif = v-acc and cif.crg <> '' no-lock)
    and (sub-cod.d-cod = 'clnsts' or sub-cod.d-cod = 'secek' or sub-cod.d-cod = 'ecdivis')*/

  if not isvalidcod(sub-cod.ccode, output errormess)
  then do:
       message errormess.
       pause. leave.
  end.
