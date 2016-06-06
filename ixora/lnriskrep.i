/* lnriskrep.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        07.11.2013 dmitriy - ТЗ 1725, ТЗ 2108.
 * BASES
        BANK COMM
 * CHANGES
*/

put stream m-out unformatted "<html><head><title>Отчет</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>Отчет на " string(dt) "</h3><br><br>" skip.

put stream m-out unformatted
    "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
    "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"">nn<BR></td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Группа<BR></td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Заемщик<BR></td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Пул<BR>МСФО</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный<BR>менеджер</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный<BR>риск-менеджер</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный<BR>менеджер по залогам</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Уменьшение<BR>оборотов компании</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Остаток денег<BR>после взноса (ОПИУ)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Дата проведения<BR>первичного анализа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Дата проведения<BR>текущего мониторинга</td>"

"<td bgcolor=""#C0C0C0"" align=""center"">Количество баллов</td>"
"<td bgcolor=""#C0C0C0"" align=""center"">Финансовое состояние</td>"

    "<td bgcolor=""#C0C0C0"" align=""center"">Ухудшение<BR>фин. состояния</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Дата утверждения<BR>проекта</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>выдачи</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>завершения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Ставка<BR>вознаграждения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Провизии<BR>по АФН в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Провизии<BR>по МСФО в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Утвержденный<BR>лимит в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Основной<BR>долг в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Начисленное<BR>вознаграждение в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Штраф</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Залоги<BR></td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Общая сумма залога<br>недвижимого имущества<br>в KZT</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Общая сумма залога<br>движимого имущества<br>в KZT</td>"
    /*
    "<td bgcolor=""#C0C0C0"" align=""center"">Текущие<BR>просрочки</td>"
    */
    "<td bgcolor=""#C0C0C0"" align=""center"">Текущая<BR>просрочка в днях</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Максимальная<BR>просрочка в днях</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Количество<BR>просрочек</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Целевое<BR>использование займа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Блокировка<BR>счетов</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Был ли займ<BR>реструктуризирован</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Оценка<BR>индустрии</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Отрасль<BR>заемщика</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Код объекта<BR>кредитования</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Связанная сторона<BR>с банком</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Выполнение<BR>решений КК</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Ошибки<BR></td>"
    "</tr>" skip.

coun = 0.

for each wrk no-lock:

    coun = coun + 1.

find first codfr where codfr.codfr = "finsost" and codfr.code = wrk.fins no-lock no-error.
if avail codfr then v-fins = codfr.name[1]. else v-fins = "".

    put stream m-out unformatted
        "<tr>" skip
        "<td>" coun "</td>" skip
        "<td>" wrk.grp "</td>" skip
        "<td>" wrk.cifn "</td>" skip
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.poolmsfo "</td>" skip
        "<td>" wrk.bankn "</td>" skip
        "<td>" wrk.manager "</td>" skip
        "<td>" wrk.riskManager "</td>" skip
        "<td>" wrk.zalogManager "</td>" skip
        "<td>" if wrk.turnoverDecrease >= 0 then replace(trim(string(wrk.turnoverDecrease,">>>>>>>>>>>9.99")),'.',',') else '' "</td>" skip
        "<td>" replace(trim(string(wrk.cushion,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" wrk.applicationDate format "99/99/9999" "</td>" skip
        "<td>" wrk.lastMonitoring format "99/99/9999" "</td>" skip

"<td>" wrk.mark format "99" "</td>" skip
"<td>" v-fins "</td>" skip

        "<td>" wrk.fsDecline "</td>" skip
        "<td>" wrk.approvalDate format "99/99/9999" "</td>" skip
        "<td>" wrk.rdt format "99/99/9999" "</td>" skip
        "<td>" wrk.duedt format "99/99/9999" "</td>" skip
        "<td>" replace(trim(string(wrk.prem,">>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prov,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.provmsfo,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.opnamt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.od,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.shtraf,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        /*
        "<td>" replace(trim(string(wrk.zalog,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        */
        "<td>" wrk.zalog "</td>" skip
        "<td>" wrk.nedvij "</td>" skip
        "<td>" wrk.dvij "</td>" skip
        /*
        "<td>" replace(trim(string(wrk.overdue,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        */
        "<td>" wrk.daysOverdue "</td>" skip
        "<td>" wrk.maxDaysOverdue "</td>" skip
        "<td>" wrk.overdueCount "</td>" skip.

    if wrk.appropriateUseFundsPrc >= 0 then put stream m-out unformatted "<td>" replace(trim(string(wrk.appropriateUseFundsPrc,">>9.99")),'.',',') "</td>" skip.
    else do:
        if wrk.appropriateUseFundsPrc = -1 then put stream m-out unformatted "<td>Не требуется</td>" skip.
        else put stream m-out unformatted "<td></td>" skip.
    end.

    put stream m-out unformatted
        "<td>" wrk.blocks "</td>" skip
        "<td>" wrk.isRestructured "</td>" skip
        "<td>" wrk.industryEstimation "</td>" skip
        "<td>" wrk.industry "</td>" skip
        "<td>" wrk.lnObject "</td>" skip
        "<td>" wrk.isAffil "</td>" skip
        "<td>" wrk.kkres "</td>" skip
        "<td>" wrk.err "</td>" skip
        "</tr>" skip.

end.


