/* vccontr.p
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
        17/06/04 saltanat включена переменная &status (true-активн.док.) при вызове vc-sixn.i
        12/03/2008 galina - перекомпиляция в связи с изменением vccontrs.f
        07/04/2008 galina - перекомпиляция в связи с изменением vccontrs.f
        17.04.2008 galina - убрала удаление контракта с нулевой суммой
        22.04.2008 galina - если тип <> 7 и сумма нулевая, то удалить этот конракт
        14.05.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        06.06.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        25.07.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        10.11.2008 galina - если тип = 3 и сумма нулевая, то не удалять этот конракт
        09.01.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        30.12.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        7/10/2010 aigul - перекомпиляция в связи с изменением vccontrs.f
        09/11/2010 galina - убрала проверку на принадлежность клиета департаменту менеджера
        11,03,2011 damir  - перекомпиляция в связи с добавлением нового поля opertyp
        03.08.2011 damir - объявил новые переменные v-valogov1,v-valogov2.
        05.08.2011 aigul - recompile
        09.09.2011 damir - объявил переменную v-check.
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/
{vc.i}
{mainhead.i}
{get-dep.i}
{vcmainshared.i "new"}

def shared var s-cif like cif.cif.

def temp-table t-contrs
    field contract like vccontrs.contract
index main is primary contract.

def var v-dep as integer.
def var v-lgrlist as char init "151,153".
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.
def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .
def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-check    as logi init no.

{comm-txb.i}
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
    &status     = 'rab'
    &postadd    = " vccontrs.cif = s-cif.
                    vccontrs.bank = s-vcourbank.
                    vccontrs.depart = v-dep.
                    vccontrs.stsdt = g-today.
                    /* код таможенного органа по умолчанию */
                    find first codfr where codfr.codfr = 'customs' and codfr.code <> 'msc' no-lock no-error.
                    if avail codfr then vccontrs.custom = codfr.code.
                    /* счет для снятия комиссии */
                    find sysc where sysc.sysc = 'vc-agr' no-lock no-error.
                    if avail sysc then v-lgrlist = sysc.chval.
                    find first aaa where aaa.cif = s-cif and aaa.sta <> 'C' and lookup(string(aaa.lgr), v-lgrlist) > 0 and aaa.crc = 1 no-lock no-error.
                    if avail aaa then vccontrs.aaa = aaa.aaa.
                    else do:
                        find first aaa where aaa.cif = s-cif and aaa.sta <> 'C' and lookup(string(aaa.lgr), v-lgrlist) > 0 no-lock no-error.
                        if avail aaa then vccontrs.aaa = aaa.aaa.
                    end.
                  "
}

do transaction on error undo, retry:
    find first vccontrs where vccontrs.rwho = g-ofc and vccontrs.ctsum = 0 and vccontrs.cttype <> '7' and vccontrs.cttype <> '3' no-lock no-error.
    if avail vccontrs then do:
        for each vccontrs where vccontrs.rwho = g-ofc and vccontrs.ctsum = 0 and vccontrs.cttype <> '7' and vccontrs.cttype <> '3' no-lock:
            for each vccthis where vccthis.contract = vccontrs.contract. delete vccthis. end.
            create t-contrs.
            t-contrs.contract = vccontrs.contract.
        end.
        for each t-contrs no-lock:
            find vccontrs where vccontrs.contract = t-contrs.contract exclusive-lock no-error.
            if avail vccontrs then delete vccontrs.
        end.
    end.
end.



