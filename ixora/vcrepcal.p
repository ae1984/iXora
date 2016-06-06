/* vcrepcal.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчеты по платежам, ГТД и актам
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
        25/08/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        09.10.2013 damir - Внедрено Т.З. № 1670.
*/
def var v-select as integer.

def shared var s-contract like vccontrs.contract.
def shared var v-cifname as char.

v-select = 0.

run sel2 (" Отчеты ", " 1. Отчет по платежам| 2. Отчет по актам| 3. ВЫХОД ", output v-select).

case v-select:
   when 1 then run vcrptpl.
   when 2 then run vcrptact.
   when 3 then return.
end.

