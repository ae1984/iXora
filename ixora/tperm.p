/* tperm.p
 * MODULE
        Обработка временных прав пользователей.
 * DESCRIPTION
        Проставляет и удаляет права пользователей.
 * RUN
        Из dayclose при закрытии дня
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        (12-2-9 : Выдача временного доступа)
 * AUTHOR
        17.09.04 - suchkov
 * CHANGES
        21.03.06 u00121 - добавил опцию no-undo  в описание локальных переменных, изменил вид соообщения после сохранения
        03.08.06 Isakov A.(u00671) - доработан пункт меню (12-2-9 : Выдача временного доступа), при выдаче временного
                                     доступа с датой начала = g-today, выдача прав производится автоматически в этом же пункте.
*/
{mainhead.i}
/*
{global.i}
*/
define new shared var s-target as date. /* Isakov A. - 01.08.06 */
define variable typ  as integer format ">9" no-undo.
define variable vtyp as character no-undo.
define variable ofc  as character no-undo.
define variable per  as character format "x(20)" no-undo.
define variable bd   as date initial today no-undo.
define variable ed   as date no-undo.
def var upd-it as log init true no-undo.

define frame fr-1
    ofc label "Офицер"    validate(can-find(ofc where ofc.ofc = ofc),'Нет такого офицера!')
    bd  label "Начало"    validate( bd >= g-today, 'Дата начала должна быть не раньше, чем сегодня(' + string(g-today) + ')!')
    ed  label "Окончание" validate( ed >= g-today, 'Дата окончания должна быть не раньше, чем сегодня(' + string(g-today) + ')!')
    per label "Права"
    typ label "ТИП"       validate( typ > 0 and typ < 7 ,'Выберите тип (1-6)!')
    with centered title "Введите данные" .

on "help" of typ in frame fr-1 do:
  run uni_help ("pertype", "*", output vtyp).
  typ = integer (vtyp) .
  displ typ with frame fr-1.
end.

repeat:

  update ofc
         bd
         ed
         per
         typ  with frame fr-1.

  /* Isakov A. - 01.08.06 - если bd и ed равны,
     то на след. день сотруднику проставляются его старые права */
  if ed = bd then
    ed = ed + 1.

  do transaction:
    create tempsec.
    assign tempsec.type = typ
           tempsec.ofc  = ofc
           tempsec.bdat = bd
           tempsec.edat = ed
           tempsec.perm = per
           tempsec.who  = g-ofc
           tempsec.whn  = today.

  end.

  /* Isakov A. - 01.08.06 */
  if bd = g-today then
    do:
      s-target = g-today.
      run set_permissions(1). /* Выдача временных прав, если дата начала равна g-today */
    end.

  message "Принято для Офицера - " tempsec.ofc skip
          "Права выданы на "       tempsec.perm skip
          "Период действия с "     tempsec.bdat " по " tempsec.edat skip
          "Продолжить ввод?"
          view-as alert-box question buttons yes-no UPDATE upd-it.
          if not upd-it then leave.
end.




