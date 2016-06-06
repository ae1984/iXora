/* vcarcon.p
 * MODULE
        vcarcon.p Валютный контроль
 * DESCRIPTION
        Поиск/новый меню "Архив"
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
        17/06/04 saltanat
 * BASES
        BANK COMM
 * CHANGES
        09.04.2009 galina - убрала удаление конрактов с нулевой суммой
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        19.01.2010 galina - перекомпиляция в связи с изменением vccontrs.f
        09/11/2010 galina - убрала проверку на принадлежность клиета департаменту менеджера
        09.08.2011 damir  - объявил переменные v-valogov1,v-valogov2
        05.08.2011 aigul - новые переменные для банка бен и корр
        09.09.2011 damir - объявил переменную v-check.
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/
{vc.i}
{mainhead.i}
{get-dep.i}
{comm-txb.i}
{vcmainshared.i "new"}

def shared var s-cif like cif.cif.

def var v-dep as integer.
def var v-lgrlist as char init "151,153".
def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.
def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .
def var v-check as logi init no.

s-vcourbank = comm-txb().
s-newcontract = false.
find cif where cif.cif = s-cif no-lock no-error.
v-dep = get-dep(g-ofc, g-today).
v-cifname = caps(s-cif) + "  " + trim(trim(substring(cif.sname, 1, 40)) + " " + trim(cif.prefix)).
/*if v-dep <> 1 and (integer(cif.jame) mod 1000) <> v-dep then do:
  message skip "  Клиент не вашего департамента!" skip(1) "  Работа с контрактами запрещена!" skip(1)
     view-as alert-box button ok title "".
  return.
end.*/

{   vc-sixn.i
    &head       = vccontrs
    &headkey    = contract
    &option     = VCCONTR
    &numsys     = prog
    &keytype    = integer
    &numprg     = vccontrn
    &subprg     = vccontrs
    &status     = 'arh'
    &no-add     = " message skip ' Нельзя создавать новый контракт в этом пункте меню !' skip(1) view-as alert-box button ok title ''.
                    next.
                  "
}

/*def temp-table t-contrs
field contract like vccontrs.contract
index main is primary contract.

do transaction on error undo, retry:
find first vccontrs where vccontrs.rwho = g-ofc and vccontrs.ctsum = 0 no-lock no-error.
if avail vccontrs then do:
for each vccontrs where vccontrs.rwho = g-ofc and vccontrs.ctsum = 0 no-lock:
for each vccthis where vccthis.contract = vccontrs.contract. delete vccthis. end.
create t-contrs.
t-contrs.contract = vccontrs.contract.
end.
for each t-contrs no-lock:
find vccontrs where vccontrs.contract = t-contrs.contract exclusive-lock no-error.
if avail vccontrs then
delete vccontrs.
end.
end.
end.*/
