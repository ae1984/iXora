/* vc101chngb.p
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

/* vc101allb.p Валютный контроль
   Импорт МТ-101

   У юриков нужного банка почистить совпадающие ОКПО и поменять, если указан неверный

   15.02.2003 nadejda
*/

def input parameter p-bank like comm.txb.bank.

def shared temp-table t-cif
  field bank like txb.bank
  field depart as integer
  field cif like bank.cif.cif
  field ssn like bank.cif.ssn
  field name as char
  field prefix as char
  field fullname as char
  field jss like bank.cif.jss
  field delother as logical init no
  field change as logical init no
  index main is primary cif.


/* почистить совпадения */
for each t-cif where t-cif.bank = p-bank and t-cif.delother :
  for each ast.cif where trim(substr(trim(ast.cif.ssn), 1, 8)) = trim(substr(trim(t-cif.ssn), 1, 8)) and
           ast.cif.cif <> t-cif.cif exclusive-lock transaction:
    ast.cif.ssn = "00000000".
  end.
end.
release ast.cif.

/* изменить ОКПО */
for each t-cif where t-cif.bank = p-bank and t-cif.change :
  find ast.cif where ast.cif.cif = t-cif.cif exclusive-lock no-error.
  if avail ast.cif then ast.cif.ssn = trim(substr(trim(t-cif.ssn), 1, 8)).
  release ast.cif.
end.

