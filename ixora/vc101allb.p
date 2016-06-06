/* vc101allb.p
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
        21.01.2004 nadejda - явно прописала присвоение delother и change
*/

/* vc101allb.p Валютный контроль
   Импорт МТ-101

   Собрать всех юриков нужного банка во временную таблицу

   15.02.2003 nadejda
*/

def input parameter p-bank like comm.txb.bank.

def shared temp-table t-cif
  field bank like comm.txb.bank
  field depart as integer
  field cif like bank.cif.cif
  field ssn like bank.cif.ssn
  field name as char
  field prefix as char
  field fullname as char
  field jss like bank.cif.jss
  field delother as logical 
  field change as logical 
  index main is primary cif.


for each ast.cif where ast.cif.type = "b" no-lock:
  create t-cif.
  buffer-copy ast.cif to t-cif.
  t-cif.bank = p-bank.
  t-cif.fullname = trim(trim(t-cif.name) + " " + trim(t-cif.prefix)).
  t-cif.jss = trim(t-cif.jss).
  t-cif.ssn = substr(trim(t-cif.ssn), 1, 8).
  t-cif.depart = integer(cif.jame) mod 1000.
  t-cif.delother = no.
  t-cif.change = no.
end.



