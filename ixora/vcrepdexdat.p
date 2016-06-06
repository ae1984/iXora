/* vcrepdexdat.p
 * MODULE
        Название Программного Модуля - Валютный контроль
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
        18.05.2004 nadejda  - добавлены поля РНН и ОКПО клиента
        08.07.2004 saltanat - включен shared переменная v-contrtype и переменная v-contractnum,
                              нужны для деления контрактов типа "1" и "5".
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype
                              Расчет должников по консигнации за определенный период - для отчета по задолжникам и Приложения 14

        13.01.2003 nadejda - вырезан кусок из vcrepdex.p
        31.07.2003 nadejda - добавлено поле sumdolg для совместимости
        10.02.2011 damir   - Добавление новых переменных cardnum Номер ЛКБК, carddt Дата ЛКБК
                             Добавление переменной Сроки репатриации - ctterm
        14.02.2011 damir   - Добавлена переменная v-maxdolg для сравнения
                             Сравнение срок задолжености > срок репатриации и платежи usd > 50000 usd
        17.02.2011 damir   - для сравнения (дни задолженности и (сроки репатриации формат 999,99 от 1 до 3 это дни, 4 и 5 это года ) переводим сроки в дни (в году 360 дней учесть)
                             добавлюя функцию check-term которая переведет срок "999.99" в дни
                             field srokrep as decimal
                             def var v-repdays as integer.
                             def var v-repyears as integer.
                             берем только экспортные vccontrs.expimp = "e"
                             меняю условие ГТД + Акты > Плат , созвонился с Мариной объяснил ситуацию
                             добавил def var v-crccon as integer.
        17.02.2011 damir     поменял условие с согласованием с Мариной Нигматуллиной v-sumgtd + v-sumakt > v-sumplat
        25,02,2011 damir   - добавил field namefil as char
        01.02.2011 damir   - новые переменные v-dt1,v-dt2 для сравнения
        02.02.2011 damir   - новые переменные v-summall1,v-sumdolg1 для сравнения
        31.03.2011 damir   - небольшие корректировки.
        23.06.2011 damir   - полностью поменял алгоритм расчета добавил алгоритм стр. 242-432.
        25.07.2012 damir   - добавил тип документа 07.
        12.10.2012 damir   - найдены маленькие погрешности, пропущенные при тестировании  Т.З. № 804. Исправлено.
        25.12.2012 damir   - Внедрено Т.З. 1306. Оптимизация кода.
*/

{vcrepdexvar.i}
{vcconv.i}

def var v-ourbnk as char.
def var v-nambnk as char.
def var v-cttype as char.
def var v-expimp as char.
def var v-workcond as logi.

def temp-table vcdoc
    field contr  as inte
    field dt     as date
    field sum    as deci
    field docsum as deci
    field sts    as inte.

def temp-table vcdocum
    field contr  as inte
    field dt     as date.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-nambnk = trim(txb.cmp.name).

v-cttype = "1".
v-expimp = "E".

{vcdocsdiffcoll_txb.i}

for each vccontrs where trim(vccontrs.bank) = v-ourbnk and lookup(trim(vccontrs.cttype),v-cttype) > 0 and
trim(vccontrs.expimp) = v-expimp no-lock:
    if vccontrs.ctdate < s-dtb then next.
    if vccontrs.sts begins "C" and ((not s-closed) or (s-closed and vccontrs.udt < s-dte)) then next.

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        v-workcond = false.

        {vcdocsdifferent.i}

        {vc_com_exp-cred.i &cttype = "1" &limitexp = "50000" &limitimp = "50000"}

        if v-workcond then do:
            create t-dolgs.
            t-dolgs.txb = v-ourbnk.
            t-dolgs.ncrc = vccontrs.ncrc.
            t-dolgs.days = (s-dte - 1) - vv-term.
            t-dolgs.sumcon = konv2concrc((v-sumgtd + v-sumakt) - v-sumplat,2,vccontrs.ncrc,s-dte - 1).
            t-dolgs.sumusd = (v-sumgtd + v-sumakt) - v-sumplat.
            t-dolgs.sumdolg = vv-summa - v-PayReturn.
            t-dolgs.srokrep = check_term(vccontrs.ctterm).
            t-dolgs.cif = txb.cif.cif.
            t-dolgs.depart = inte(txb.cif.jame) mod 1000.
            t-dolgs.namefil = v-nambnk.
            t-dolgs.cifname = trim(txb.cif.sname) + " " + trim(txb.cif.prefix).
            t-dolgs.cifrnn = txb.cif.jss.
            t-dolgs.cifokpo = txb.cif.ssn.
            t-dolgs.contract = vccontrs.contract.
            t-dolgs.ctdate = vccontrs.ctdate.
            t-dolgs.ctterm = vccontrs.ctterm.
            t-dolgs.ctnum = vccontrs.ctnum.
            t-dolgs.ctei = vccontrs.expimp.
            find  first vcdocs  where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "40" no-lock no-error.
            if available vcdocs then do:
                t-dolgs.cardnum = vccontrs.cardnum.
                t-dolgs.carddt = vccontrs.cardformmc.
            end.
        end.
    end. /*if avail txb.cif*/
end.




