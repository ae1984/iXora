/* kfmank.p
 * MODULE
     Клиенты и счета
 * DESCRIPTION
        Проставляем или редактируем дату заполнения анкеты для фин.мониторинга
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
        25/03/2010 galina
 * BASES
        BANK
 * CHANGES
*/

{global.i}
def shared var s-cif like cif.cif.
def var v-ankdt as date.
def var v-ankdtold as date.
form
 v-ankdt format "99/99/9999" label 'Дата получения анкеты' validate(v-ankdt <> ?,'Введите дату')
with centered side-label row 7 overlay  title 'Информация для фин.мониторинга' frame fdt.

find first cif where cif.cif = s-cif no-lock no-error.
if not avail cif then next.
if (cif.reschar[1]) <> '' then do:
  v-ankdt = date(entry(1,cif.reschar[1])).
  v-ankdtold = date(entry(1,cif.reschar[1])).
end.

update v-ankdt with frame fdt.

if v-ankdt <> v-ankdtold then do transaction:
  find current cif exclusive-lock.
  cif.reschar[1] = string(v-ankdt,'99/99/9999') + ',' + g-ofc.
  find current cif no-lock.
end.


