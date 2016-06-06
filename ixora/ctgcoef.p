/* ctgcoef.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет коэффициентов по пулам для провизий МСФО
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
        23/08/2012 kapar
 * BASES
        BANK COMM
 * CHANGES
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
        27/06/2013 Sayat(id01143) - ТЗ 1882 от 05/06/2013 "Доработка алгоритма расчета провизий МСФО"
*/

{mainhead.i}
{dates.i}

def new shared var v-dt as date no-undo.
def new shared var v-pool as char extent 10.
def new shared var v-poolName as char extent 10.
def new shared var v-poolId as char extent 10.
/*def shared var g-today as date.*/
def var x-dt as date.
def new shared var v-mindt as date extent 10.
def var m as int.
def var n as int.
def var p-sum as deci extent 10.
def var v-sum as deci extent 10.
def var k as int extent 10.
def var nd as int.

def buffer b-ctgprov for ctgprov.
def var fname as char.

run mondays(month(g-today), year(g-today), output nd).
x-dt = date(month(g-today), nd, year(g-today)) + 1.

update " Дата: " x-dt format "99/99/9999" validate (day(x-dt) = 1 and x-dt > g-today,"Число должно быть позже сегодняшнего и 1-ое!") no-label with centered row 13 frame frd  title "Расчет".

def new shared var v-sum_msb as deci no-undo.

v-pool[1] = "27,67".
v-poolName[1] = "Ипотечные займы".
v-poolId[1] = "ipoteka".
v-mindt[1] = date(1,1,2013).
v-pool[2] = "28,68".
v-poolName[2] = "Автокредиты".
v-poolId[2] = "auto".
v-mindt[2] = date(7,1,2008).
v-pool[3] = "20,60".
v-poolName[3] = "Прочие потребительские кредиты".
v-poolId[3] = "flobesp".
v-mindt[3] = date(7,1,2008).
v-pool[4] = "90,92".
v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
v-poolId[4] = "metro".
v-mindt[4] = date(1,1,2011).
v-pool[5] = "81,82".
v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
v-poolId[5] = "sotr".
v-mindt[5] = date(7,1,2008).
v-pool[6] = "16,26,56,66".
v-poolName[6] = "Метро-экспресс МСБ".
v-poolId[6] = "express-msb".
v-mindt[6] = date(7,1,2010).
v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-mindt[7] = date(7,1,2010).
v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[8] = "Инидивид. МСБ".
v-poolId[8] = "individ-msb".
v-mindt[8] = date(7,1,2010).
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".
v-mindt[9] = date(7,1,2010).
v-pool[10] = "95,96".
v-poolName[10] = "Ипотека «Астана бонус»".
v-poolId[10] = "astana-bonus".
v-mindt[10] = date(8,1,2012).

define new shared stream m-out.
v-dt = monthsadd(x-dt,-1).

repeat while v-dt <= x-dt:

    fname = "ctgloans_" + string(year(v-dt)) + "_" + string(month(v-dt),"99") + "_" + string(day(v-dt),"99") + ".htm".
    output stream m-out to value(fname).
    put stream m-out unformatted
        "<html><head>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
        "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
        "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
        "</head><body>" skip.
    put stream m-out unformatted
        "<BR><b>Распределение займов по пулам</b><BR>" skip
        "<b>Отчет на " string(v-dt) "</b><br>" skip.
    v-sum_msb = 0.

    /*{r-branch.i &proc = "msfosk2"}*/

    for each comm.txb where comm.txb.consolid no-lock:
        do transaction:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run msfosk2.
        end.
    end.
    if connected ("txb") then disconnect "txb".


    put stream m-out unformatted
        "<b>Собственный капитал " replace(string(v-sum_msb,'->>>>>>>>>>>>>>>>9.99<<<<'),'.',',') "</b><br>" skip.
    v-sum_msb = round(v-sum_msb / 20,2).
    put stream m-out unformatted
        "<b>Сумма для перехода в индивид " replace(string(v-sum_msb,'->>>>>>>>>>>>>>>>9.99<<<<'),'.',',') "</b><br>" skip.

    if v-dt > g-today then
    do transaction:
        find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnmsfo" exclusive-lock no-error.
        if not avail pksysc then do:
            create pksysc.
            assign pksysc.credtype = '0'
                    pksysc.sysc = 'lnmsfo'
                    pksysc.des = "МСФО - 5% СК".
        end.
        assign pksysc.daval = g-today
            pksysc.inval = time
            pksysc.deval = v-sum_msb.
        find current pksysc no-lock.
    end.

    for each ctgprov where ctgprov.dt = v-dt:
        delete ctgprov.
    end.
    put stream m-out unformatted
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td valign=""center"">Филиал</td>" skip
        "<td valign=""center"">Ссудный счет</td>" skip
        "<td valign=""center"">Код клиента</td>" skip
        "<td valign=""center"">ОД</td>" skip
        "<td valign=""center"">%</td>" skip
        "<td valign=""center"">Пеня</td>" skip
        "<td valign=""center"">Дисконт</td>" skip
        "<td valign=""center"">Сумма по займу</td>" skip
        "<td valign=""center"">Сумма по клиенту</td>" skip
        "<td valign=""center"">Группа</td>" skip
        "<td valign=""center"">Пул(истор)</td>" skip
        "<td valign=""center"">Пул(факт)</td>" skip
        "<td valign=""center"">Дней просрочкм(ОД)</td>" skip
        "<td valign=""center"">Дней просрочки(%)</td>" skip
        "<td valign=""center"">Макс.просрочка по займу</td>" skip
        "<td valign=""center"">Макс.просрочка по клиенту</td>" skip
        "<td valign=""center"">Реструктуризация по займу</td>" skip
        "<td valign=""center"">Реструктуризация по клиенту</td>" skip
        "<td valign=""center"">Валюта займа</td>" skip
        "<td valign=""center"">Индивидуально?</td>" skip
        "</tr>" skip.


    /*{r-branch.i &proc = "ctgcoef2"}*/

    for each comm.txb where comm.txb.consolid no-lock:
        do transaction:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run ctgcoef2.
        end.
    end.
    if connected ("txb") then disconnect "txb".


    for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = 'ctg' :
        if ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n8 + ctgprov.n9 + ctgprov.n10 = 0 then delete ctgprov.
        else do:
            find last b-ctgprov where b-ctgprov.dt < ctgprov.dt and b-ctgprov.tp = ctgprov.tp and b-ctgprov.poolId = ctgprov.poolId no-lock no-error.
            if avail b-ctgprov then ctgprov.n8 = maximum(ctgprov.n9 - b-ctgprov.n9, 0).
            else ctgprov.n8 = maximum(ctgprov.n9, 0).
        end.
    end.

    /*Коэффициент перехода*/
    do transaction:
    do m = 1 to 10:
        do n = 1 to 10: p-sum[n] = 0. v-sum[n] = 0. end.
        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[m] no-lock no-error.
        find last b-ctgprov where b-ctgprov.dt < v-dt and b-ctgprov.tp = "ctg" and b-ctgprov.poolId = v-poolId[m] no-lock no-error.
        if not avail ctgprov then next.
        p-sum[1] = p-sum[1] + ctgprov.n1.
        p-sum[2] = p-sum[2] + ctgprov.n2.
        p-sum[3] = p-sum[3] + ctgprov.n3.
        p-sum[4] = p-sum[4] + ctgprov.n4.
        p-sum[5] = p-sum[5] + ctgprov.n5.
        p-sum[6] = p-sum[6] + ctgprov.n6.
        p-sum[7] = p-sum[7] + ctgprov.n7.
        p-sum[8] = p-sum[8] + ctgprov.n8.
        if avail b-ctgprov then do:
            v-sum[1] = v-sum[1] + b-ctgprov.n1.
            v-sum[2] = v-sum[2] + b-ctgprov.n2.
            v-sum[3] = v-sum[3] + b-ctgprov.n3.
            v-sum[4] = v-sum[4] + b-ctgprov.n4.
            v-sum[5] = v-sum[5] + b-ctgprov.n5.
            v-sum[6] = v-sum[6] + b-ctgprov.n6.
            v-sum[7] = v-sum[7] + b-ctgprov.n7.
            v-sum[8] = v-sum[8] + b-ctgprov.n8.
        end.
        else next.
        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "kfc" and ctgprov.poolId = v-poolId[m] no-error.
        if not avail ctgprov then do:
            create ctgprov.
            assign ctgprov.dt = v-dt.
                   ctgprov.tp = "kfc".
                   ctgprov.poolId = v-poolId[m].
        end.
        if v-sum[1] = 0 then ctgprov.n2 = -1. else ctgprov.n2 = p-sum[2] / v-sum[1].
        if v-sum[2] = 0 then ctgprov.n3 = -1. else ctgprov.n3 = p-sum[3] / v-sum[2].
        if v-sum[3] = 0 then ctgprov.n4 = -1. else ctgprov.n4 = p-sum[4] / v-sum[3].
        if v-sum[4] = 0 then ctgprov.n5 = -1. else ctgprov.n5 = p-sum[5] / v-sum[4].
        if v-sum[5] = 0 then ctgprov.n6 = -1. else ctgprov.n6 = p-sum[6] / v-sum[5].
        if v-sum[6] = 0 then ctgprov.n7 = -1. else ctgprov.n7 = p-sum[7] / v-sum[6].
        if v-sum[7] = 0 then ctgprov.n8 = -1. else ctgprov.n8 = p-sum[8] / v-sum[7].

        if ctgprov.n1 > 1 then ctgprov.n1 = 1.
        if ctgprov.n2 > 1 then ctgprov.n2 = 1.
        if ctgprov.n3 > 1 then ctgprov.n3 = 1.
        if ctgprov.n4 > 1 then ctgprov.n4 = 1.
        if ctgprov.n5 > 1 then ctgprov.n5 = 1.
        if ctgprov.n6 > 1 then ctgprov.n6 = 1.
        if ctgprov.n7 > 1 then ctgprov.n7 = 1.
        if ctgprov.n8 > 1 then ctgprov.n8 = 1.
    end.

    /*Процент резервирования, в разрезе периодов*/

    do m = 1 to 10:
        do n = 1 to 10:
            k[n] = 0.
            p-sum[n] = 0.
            v-sum[n] = 0.
        end.
        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "kfc" and ctgprov.poolId = v-poolId[m] no-lock no-error.
        if not avail ctgprov then next.
        for each ctgprov where ctgprov.dt <= v-dt and ctgprov.tp = "kfc" and ctgprov.poolId = v-poolId[m] no-lock:
            if ctgprov.n2 >= 0 then do: p-sum[2] = p-sum[2] + ctgprov.n2. k[2] = k[2] + 1. end.
            if ctgprov.n3 >= 0 then do: p-sum[3] = p-sum[3] + ctgprov.n3. k[3] = k[3] + 1. end.
            if ctgprov.n4 >= 0 then do: p-sum[4] = p-sum[4] + ctgprov.n4. k[4] = k[4] + 1. end.
            if ctgprov.n5 >= 0 then do: p-sum[5] = p-sum[5] + ctgprov.n5. k[5] = k[5] + 1. end.
            if ctgprov.n6 >= 0 then do: p-sum[6] = p-sum[6] + ctgprov.n6. k[6] = k[6] + 1. end.
            if ctgprov.n7 >= 0 then do: p-sum[7] = p-sum[7] + ctgprov.n7. k[7] = k[7] + 1. end.
            if ctgprov.n8 >= 0 then do: p-sum[8] = p-sum[8] + ctgprov.n8. k[8] = k[8] + 1. end.
        end.

        if k[2] <> 0 then v-sum[2] = p-sum[2] / k[2]. else v-sum[2] = 0.
        if k[3] <> 0 then v-sum[3] = p-sum[3] / k[3]. else v-sum[3] = 0.
        if k[4] <> 0 then v-sum[4] = p-sum[4] / k[4]. else v-sum[4] = 0.
        if k[5] <> 0 then v-sum[5] = p-sum[5] / k[5]. else v-sum[5] = 0.
        if k[6] <> 0 then v-sum[6] = p-sum[6] / k[6]. else v-sum[6] = 0.
        if k[7] <> 0 then v-sum[7] = p-sum[7] / k[7]. else v-sum[7] = 0.
        if k[8] <> 0 then v-sum[8] = p-sum[8] / k[8]. else v-sum[8] = 0.

        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prc" and ctgprov.poolId = v-poolId[m] no-error.
        if not avail ctgprov then do:
            create ctgprov.
            assign ctgprov.dt = v-dt.
                   ctgprov.tp = "prc".
                   ctgprov.poolId = v-poolId[m].
        end.

        if v-sum[1] >= 0 then ctgprov.n1 = 100 * absolute(v-sum[2] * v-sum[3] * v-sum[4] * v-sum[5] * v-sum[6] * v-sum[7] * v-sum[8]). else ctgprov.n1 = -1.
        if v-sum[2] >= 0 then ctgprov.n2 = 100 * absolute(v-sum[3] * v-sum[4] * v-sum[5] * v-sum[6] * v-sum[7] * v-sum[8]). else ctgprov.n2 = -1.
        if v-sum[3] >= 0 then ctgprov.n3 = 100 * absolute(v-sum[4] * v-sum[5] * v-sum[6] * v-sum[7] * v-sum[8]). else ctgprov.n3 = -1.
        if v-sum[4] >= 0 then ctgprov.n4 = 100 * absolute(v-sum[5] * v-sum[6] * v-sum[7] * v-sum[8]). else ctgprov.n4 = -1.
        if v-sum[5] >= 0 then ctgprov.n5 = 100 * absolute(v-sum[6] * v-sum[7] * v-sum[8]). else ctgprov.n5 = -1.
        if v-sum[6] >= 0 then ctgprov.n6 = 100 * absolute(v-sum[7] * v-sum[8]). else ctgprov.n6 = -1.
        if v-sum[7] >= 0 then ctgprov.n7 = 100 * absolute(v-sum[8]). else ctgprov.n7 = -1.
        if v-sum[8] >= 0 then ctgprov.n8 = 100. else ctgprov.n8 = -1.
        if k[8] = 0 then ctgprov.n8 = 0.
    end.

    /*Сумма резервов на основной долг*/

    do m = 1 to 10:
        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[m] no-lock no-error.
        if not avail ctgprov then next.
        for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[m]:
            v-sum[1] = ctgprov.n1.
            v-sum[2] = ctgprov.n2.
            v-sum[3] = ctgprov.n3.
            v-sum[4] = ctgprov.n4.
            v-sum[5] = ctgprov.n5.
            v-sum[6] = ctgprov.n6.
            v-sum[7] = ctgprov.n7.
            v-sum[8] = ctgprov.n8.
        end.
        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prc" and ctgprov.poolId = v-poolId[m] no-lock no-error.
        if not avail ctgprov then next.
        for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prc" and ctgprov.poolId = v-poolId[m]:
            v-sum[1] = (v-sum[1] / 100) * ctgprov.n1.
            v-sum[2] = (v-sum[2] / 100) * ctgprov.n2.
            v-sum[3] = (v-sum[3] / 100) * ctgprov.n3.
            v-sum[4] = (v-sum[4] / 100) * ctgprov.n4.
            v-sum[5] = (v-sum[5] / 100) * ctgprov.n5.
            v-sum[6] = (v-sum[6] / 100) * ctgprov.n6.
            v-sum[7] = (v-sum[7] / 100) * ctgprov.n7.
            v-sum[8] = (v-sum[8] / 100) * ctgprov.n8.
        end.

        find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = v-poolId[m] no-error.
        if not avail ctgprov then do:
            create ctgprov.
            assign ctgprov.dt = v-dt.
                   ctgprov.tp = "rzr".
                   ctgprov.poolId = v-poolId[m].
        end.
        ctgprov.n1 = v-sum[1].
        ctgprov.n2 = v-sum[2].
        ctgprov.n3 = v-sum[3].
        ctgprov.n4 = v-sum[4].
        ctgprov.n5 = v-sum[5].
        ctgprov.n6 = v-sum[6].
        ctgprov.n7 = v-sum[7].
        ctgprov.n8 = v-sum[8].
    end.

    /*Процент резервирования*/
    if v-dt > g-today then do:
        do m = 1 to 10:
            find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[m] no-lock no-error.
            if not avail ctgprov then next.
            for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[m]:
                v-sum[1] = ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n9 + ctgprov.n10.
            end.
            find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = v-poolId[m] no-lock no-error.
            if not avail ctgprov then next.
            for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = v-poolId[m]:
                v-sum[2] = ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n8.
            end.
            find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prz" and ctgprov.poolId = v-poolId[m] no-error.
            if not avail ctgprov then do:
                create ctgprov.
                assign ctgprov.dt = v-dt.
                       ctgprov.tp = "prz".
                       ctgprov.poolId = v-poolId[m].
            end.
            if v-sum[1] = 0 then ctgprov.n12 = 0. else ctgprov.n12 = v-sum[2] / v-sum[1].
            find first msfoc where msfoc.poolId = v-poolId[m] and msfoc.dt = v-dt no-error.
            if not avail msfoc then do:
                create msfoc.
                assign msfoc.dt = v-dt
                       msfoc.poolId = v-poolId[m]
                       msfoc.poolName = v-poolName[m].
            end.
            msfoc.amtAll = 0.
            msfoc.amtPr = 0.
            msfoc.amtSp = 0.
            msfoc.amtVosst = 0.
            msfoc.coeffr = 100 * v-sum[2] / v-sum[1].
        end.
    end.
    end. /*transaction*/
    put stream m-out unformatted "</table></body></html>".
    output stream m-out close.
    unix silent cptwin value(fname) excel.
    v-dt = monthsadd(v-dt,1).
end.
