/* codcondit.i
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
        28/04/2010 galina - добавила запрет редактирования кода подозрительности операции
        28.03.2012 Lyubov - добавила условия на запрет для справочника ecdivisg
*/

function isvalidcod returns logical (input v-cod as char, output errmess as char).
  def var v-valid as logi init false.
  def var v-cif like cif.cif.
  def buffer b-sub for sub-cod.

   v-cif = sub-cod.acc.
  if sub-cod.sub = 'gld' then do:
    if can-find(gl where string(gl.gl) = sub-cod.acc and gl.type = 'r' no-lock) and
      (int(v-cod) < 0) then
      errmess = 'Для счета доходов значение должно содержать код Профит-центра, 0 или msc'.
    else
    if can-find(gl where string(gl.gl) = sub-cod.acc and ((gl.type = 'l') or (gl.type = 'o'))
      no-lock) and (int(v-cod) <= 0) then
      errmess = 'Для счетов 2 и 3 класса значение должно содержать код Профит-центра или msc'.
    else
      v-valid = true.
  end.
  else do:
        /* условие на справочники клиента clnsts, secek, ecdivis -
      их запрещено редактировать после проведения контроля */
      if sub-cod.sub = 'cln' and can-find(cif where cif.cif = sub-cod.acc and cif.crg <> '' no-lock)
            and (sub-cod.d-cod = 'clnsts' or sub-cod.d-cod = 'secek' or sub-cod.d-cod = 'ecdivis' /*or sub-cod.d-cod = 'ecdivisg'*/ ) then
        errmess = 'Запрещено редактировать это значение после проведения контроля признаков клиента'.
      /* запрещено редактировать группу шифров отраслей экономики, если в перечне шифров стоит значение "0 - физические лица"*/
      else if sub-cod.sub = 'cln' and sub-cod.d-cod = 'ecdivisg' and can-find(first sub-cod where sub-cod.d-cod = 'ecdivis' and sub-cod.acc = v-cif and sub-cod.ccode = '0' no-lock) then do:
      find b-sub where b-sub.sub = 'cln' and b-sub.acc = sub-cod.acc and b-sub.d-cod = 'ecdivisg' exclusive-lock no-error.
      if avail b-sub then b-sub.ccode = 'msc'.
      errmess = 'Запрещено редактировать это значение для физических лиц'.
      end.
      /*запрет изменения признака подозрительности операции*/
      else if (sub-cod.sub = 'jou' or sub-cod.sub = 'RMZ') and sub-cod.d-cod = 'kfmsusp1' then do:
         if sub-cod.ccode = '01' and v-cod <> sub-cod.ccode then errmess = 'Запрещено менять признак операции с подозрительной на неподозрительную'.
         else v-valid = true.
      end.
      else v-valid = true.
  end.
  return v-valid.
end.

