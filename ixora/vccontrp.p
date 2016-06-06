/* vccontrp.p
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
 * BASES
        BANK COMM
 * CHANGES
        30.10.02 nadejda создан
        07/04/2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        18.04.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        13.05.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        02.06.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        06.06.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        25.07.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        10.11.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        09/11/2010 galina - убрала проверку на принадлежность клиета департаменту менеджера
        04.08.2011 damir - объявил переменные v-valogov1,v-valogov2
        08.08.2011 aigul - вывод инфы по ИНН, счета получателя, банк бенефициара, банк-корреспондент
        09.09.2011 damir - объявил переменную v-check.
        26.12.2012 damir - Внедрено Т.З. № 1306. Добавил vcmainshared.i.
*/
{vc.i}
{mainhead.i VCCONTRS}
{get-dep.i}
{vcmainshared.i "new"}
{comm-txb.i}

def new shared var s-cif like cif.cif.
def new shared var s-contract like vccontrs.contract.
def new shared frame vccontrs.
def new shared frame menu.
def new shared var s-newrec as logical.

def buffer bvccontrs for vccontrs.

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

{vccontrs.f}

run h-pcontract.

if s-contract <> 0 then do:
    find vccontrs where vccontrs.contract = s-contract no-lock no-error.
    find cif where cif.cif = vccontrs.cif no-lock no-error.
    if avail cif and (s-vcourbank = "txb00" and get-dep(g-ofc, g-today) = 1) or s-vcourbank = vccontrs.bank then do:
        s-cif = vccontrs.cif.
        v-cifname = s-cif + "  " + trim(trim(substring(cif.name, 1, 40)) + " " + trim(cif.prefix)).
        run vccontrs.
    end.
    else do:
        if not avail cif and s-vcourbank = vccontrs.bank then message skip "  Клиент не существует!" skip(1)
        "  Работа с контрактами невозможна!" skip(1) view-as alert-box button ok title "".
        else do:
            if s-vcourbank <> vccontrs.bank then message skip "  Клиент не вашего офиса!" skip(1) "  Работа с контрактами запрещена!" skip(1) view-as alert-box button ok title "".
            else message skip "  Клиент не вашего департамента!" skip(1) "  Работа с контрактами запрещена!" skip(1) view-as alert-box button ok title "".
        end.
    end.
end.
