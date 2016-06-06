/* vcrepdusdat.p
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
        BANK TXB COMM
 * CHANGES
        18.05.2004 nadejda - изменение описания таблицы t-dolgs для совместимости
        13.01.2003 nadejda - выделен кусок из vcrepdpldat.p
        31.07.2003 nadejda - добавлено поле sumdolg для совместимости

        10.02.2011 damir   - Добавление новых переменных cardnum Номер ЛКБК, carddt Дата ЛКБК
                             Добавление переменной Сроки репатриации - ctterm
        14.02.2011 damir   - Добавлена переменная v-maxdolg для сравнения
                             добавил условие срок задолжености > срок репатриации и платежи usd > 50000 usd
                             срок задолженности = проходит ряд условий стр.199,209,304
        17.02.2011 damir   - для сравнения (дни задолженности и (сроки репатриации формат 999,99 от 1 до 3 это дни, 4 и 5 это года ) переводим сроки в дни (в году 360 дней учесть)
                             добавлюя функцию check-term которая переведет срок "999.99" в дни
                             field srokrep as decimal
                             def var v-repdays as integer.
                             def var v-repyears as integer.
        24.02.2011 damir   - добавляю дополнительную выборку. т.е сейчас 2 выборки 1) импорт - задолженность по актам(ГТД не учитывается)
                             2) экспорт - задолженность п платежам (ГТД не учитывается)
                             все закидывется во временную таблицу.
                             Номер ЛКБК, carddt Дата ЛКБК подтягиваются при формировании МТ-105
                             добавлены переменные v-dt1 v-sum1 v-sumakt1 v-sumplat1 чтоб не было путаницы
        25,02,2011 damir   - добавил field namefil as char
        31.03.2011 damir   - небольшие корректировки.
        17.06.2011 damir   - изменены алгоритмы расчета суммы просроченной в USD, и дней задолженности.
        23.06.2011 damir   - полностью поменял алгоритм расчета добавил алгоритм стр. 232-331 и стр.413-514.
        25.07.2012 damir   - добавил тип документа 07.
        12.10.2012 damir   - найдены маленькие погрешности, пропущенные при тестировании  Т.З. № 804. Исправлено.
        25.12.2012 damir   - Внедрено Т.З. 1306. Оптимизация кода.
*/

{vcrepdusvar.i}
{vcconv.i}

def var v-ourbnk as char.
def var v-nambnk as char.
def var v-cttype as char.
def var v-expimp as char.
def var v-workcond as logi.

def temp-table vcdoc
    field contr as inte
    field dt    as date
    field sum   as deci
    field sts   as inte.

def temp-table vcdocum
    field contr  as inte
    field dt     as date.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-nambnk = trim(txb.cmp.name).

v-cttype = "3".
v-expimp = "E,I".

{vcdocsdiffcoll_txb.i}

for each vccontrs where trim(vccontrs.bank) = v-ourbnk and lookup(trim(vccontrs.cttype),v-cttype) > 0 and
lookup(trim(vccontrs.expimp),v-expimp) > 0 no-lock:
    if vccontrs.ctdate < s-dtb then next.
    if vccontrs.sts begins "C" and ((not s-closed) or (s-closed and vccontrs.udt < s-dte)) then next.

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        v-workcond = false.

        {vcdocsdifferent.i}

        {vcrep_dus.i &cttype = "3" &limitexp = "50000" &limitimp = "50000"}

        if v-workcond then do:
            create t-dolgs.
            t-dolgs.txb = v-ourbnk.
            t-dolgs.ncrc = vccontrs.ncrc.
            t-dolgs.days = (s-dte - 1) - vv-term.
            if vccontrs.expimp = "E" then do:
                t-dolgs.sumcon = konv2concrc(v-sumakt - v-sumplat,2,vccontrs.ncrc,s-dte - 1).
                t-dolgs.sumusd = v-sumakt - v-sumplat.
            end.
            else if vccontrs.expimp = "I" then do:
                t-dolgs.sumcon = konv2concrc(v-sumplat - v-sumakt,2,vccontrs.ncrc,s-dte - 1).
                t-dolgs.sumusd = v-sumplat - v-sumakt.
            end.
            t-dolgs.sumdolg = vv-summa - v-PayReturn.
            t-dolgs.cif = txb.cif.cif.
            t-dolgs.depart = integer(txb.cif.jame) mod 1000.
            t-dolgs.namefil = v-nambnk.
            t-dolgs.cifname = trim(txb.cif.sname) + " " + trim(txb.cif.prefix).
            t-dolgs.cifrnn = txb.cif.jss.
            t-dolgs.cifokpo = txb.cif.ssn.
            t-dolgs.contract = vccontrs.contract.
            t-dolgs.ctdate = vccontrs.ctdate.
            t-dolgs.ctterm = vccontrs.ctterm.
            t-dolgs.ctnum = vccontrs.ctnum.
            t-dolgs.ctei = vccontrs.expimp.
            find  first vcdocs of vccontrs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "40" no-lock no-error.
            if available vcdocs then do:
                t-dolgs.cardnum = vccontrs.cardnum.
                t-dolgs.carddt = vccontrs.cardformmc.
            end.
        end.
    end.
end.


