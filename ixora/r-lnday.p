/* r-lnday.p
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
        01/06/2004 madiyar - добавил вывод стандартного заголовка прагмы
                             изменил название отчета
                             убрал из отчета таблицы по гарантиям
                             овердрафты (группы 70 и 80) теперь выводятся в 1-ой и 2-ой таблицах
                             3-я и 4-ая таблицы - только экспресс кредиты
        04/06/2004 madiyar - 1-ая и 2-ая таблицы теперь выводятся с разбивкой на юр/физ. лица
        17/06/2004 madiyar - в связи с необходимостью формирования данного отчета для филиалов и консолидированного - вынес расчеты в
                             r-lnday2.p с подключением к bank с алиасом txb.
        29/10/2004 madiyar - добавил новый отчет
        01/11/2004 madiyar - добавил еще один отчет
        08/11/2004 madiyar - путаница с валютами вышла... исправил
        15/11/2004 madiyar - изменения в формате вывода отчета
        17/11/2004 madiyar - переделал 3-ий отчет и небольшие изменения по первым двум
        19/11/2004 madiyar - убрал границы в итоговых ячейках, индексы
        13/12/2004 madiyar - добавил количество списанных кредитов
        21/12/2004 madiyar - мелкие исправления
        19/01/2005 madiyar - в 3-ем отчете в "Выдано" добавил колонку "Количество (всего)"
        02/02/2005 madiyar - изменения во 2-ом отчете
        14/03/2005 madiyar - добавил курсовую разницу
        16/03/2005 madiyar - добавил курсы валют, изменил формат отчета
        24/03/2005 madiyar - добавил 4-ый отчет
        28/03/2005 madiyar - исправил глюк, происходящий при запуске отчета на филиале
        31/03/2005 madiyar - исправил итоги в 4-ом отчете
        01/09/2005 madiyar - убрал количество (всего) выданных
        03/10/2005 madiyar - изменил второй отчет - по курсу за день операции, а не за конец периода
        29/03/2006 madiyar - в детализированный отчет добавил группу кредита, ставку и признак "краткоср/долгоср"
        21/04/2006 madiyar - переделал с использованием r-brfilial.i
        03/07/2006 sasco - добавил TXB-актобе и караганда
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        10/10/2006 madiyar - надоело дорисовывать филиалы, переделал, чтобы дорисовывались на автомате; no-undo
        11/10/2006 madiyar - убрал лишнее поле port.city
        06/04/2007 madiyar - отредактировал заголовки
        16/04/2007 madiyar - убрал в итогах "по банку"
        06/03/2008 madiyar - евро 11 -> 3
        26/03/2008 alex - изменен формат отчета (итоги, нумерация)
        22/07/2009 madiyar - вариант по непросроченным + комиссия
        12.07.2011 damir    - добавил 4 входных параметра эту программу вызывает rep1.p и r-lnday0.p
        01.09.2011 damir    - для v-option = 'mail' и когда v-selrep = '1' изменил алгоритм.
        26.10.2011 damir    - устранил мелкие ошибки.
        13.04.2012 damir    - изменил формат с "yes/no" на "да/нет".
        25/04/2012 evseev   - rebranding. Название банка из sysc или изменил проверку банка или рко
        04.07.2012 damir    - добавил v-creiss,v-crerep,v-crerepexpr.
*/

{global.i}
{comm-txb.i}
def var s-ourbank as char.
s-ourbank = comm-txb().

def input parameter v-option      as char.
def input parameter v-yesterday   as date.
def output parameter vfname       as char init "ttt.xls".
def input-output parameter vres   as logi.

def new shared temp-table crover_vyd no-undo
    field bank   as   char
    field prname as   char
    field cif    like lon.cif
    field lon    like lon.lon
    field gua    like lon.gua
    field crc    like lon.crc
    field opnamt as   deci
    field paid   as   deci
    field paidt  as   deci
    field who    like lnscg.who
    field urfiz  as   integer
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary paid bank urfiz
    index ind2 paid urfiz bank crc cif.

def new shared temp-table crover_pog no-undo
    field bank   as   char
    field prname as   char
    field cif    like lon.cif
    field lon    like lon.lon
    field gua    like lon.gua
    field crc    like lon.crc
    field opnamt as   deci
    field sum1   like lon.opnamt
    field sum2   like lon.opnamt
    field sum1t  like lon.opnamt
    field sum2t  like lon.opnamt
    field who    like lnsch.who
    field urfiz  as   integer
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary sum1 sum2 bank urfiz
    index ind2 bank lon who
    index ind3 sum1 sum2 urfiz bank crc cif.

def new shared temp-table bd_vyd no-undo
    field bank   as   char
    field prname as   char
    field cif    like lon.cif
    field lon    like lon.lon
    field crc    like lon.crc
    field paid   like lon.opnamt
    field duedt  like lon.duedt
    field who    like lnsch.who
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary paid bank
    index ind2 paid crc bank cif.

def new shared temp-table bd_pog no-undo
    field bank   as   char
    field prname as   char
    field cif    like lon.cif
    field lon    like lon.lon
    field crc    like lon.crc
    field sum1   like lon.opnamt
    field sum2   like lon.opnamt
    field sum3   like lon.opnamt
    field duedt  like lon.duedt
    field who    like lnsch.who
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary sum1 sum2 bank
    index ind2 bank lon who
    index ind3 sum1 sum2 crc bank cif.

def new shared temp-table port no-undo
    field bank         as   char
    field ln           as   integer
    field sts          as   char
    field kol1         as   integer
    field sum1         as   deci
    field kol2         as   integer
    field sum2         as   deci
    field kol_vyd_all  as   integer
    field kol_vyd      as   integer
    field sum_vyd      as   deci
    field kol_pog      as   integer
    field sum_pog      as   deci
    field sum_pog_full as   deci
    field sum_pog_part as   deci
    field sum_spis     as   deci
    field kol_spis     as   integer
    index ind is primary bank ln.

def temp-table wrk_fiz no-undo
    field prname as   char
    field cif    like lon.cif
    field crc    like lon.crc
    field paid   as   deci
    field paidt  as   deci
    field sum1   as   deci
    field sum2   as   deci
    field sum1t  as   deci
    field sum2t  as   deci
    index ind is primary paid desc sum1 desc sum2 desc.

define new shared temp-table port2 no-undo
  field bank as character
  field ids_name as character
  field urfiz as integer
  field crc like crc.crc
  field coun as integer extent 4
  field sum as decimal extent 4
  index idx is primary bank urfiz crc.

function frmt_outi returns char (input parm as integer).
    def var mystr as char.
    if parm >= 0 then mystr = trim(string(parm,'>>>>>>>>>>>9')).
    else mystr = '(' + trim(string(- parm,'>>>>>>>>>>>9')) + ')'.
    return (mystr).
end function.

function frmt_outd returns char (input parm as decimal).
    def var mystr as char.
    if parm >= 0 then mystr = replace(trim(string(parm,'>>>>>>>>>>>9.99')),'.',',').
    else mystr = '(' + replace(trim(string(- parm,'>>>>>>>>>>>9.99')),'.',',') + ')'.
    return (mystr).
end function.

def var dt1        as date no-undo.
def var dt2        as date no-undo.
define stream m-out.
def var v-sel        as char no-undo.
def var v-selrep     as char no-undo.
def var cbank        as char no-undo.
def var coun         as inte no-undo.
def var itog         as deci no-undo.
def var itgp         as deci no-undo.
def var itgc         as deci no-undo.
def var i            as inte no-undo.
def var cnt1         as deci no-undo.
def var cnt2         as deci no-undo.
def var usrnm        as char no-undo.
def var v-bc         as char no-undo.
def var v-creiss     as deci no-undo.
def var v-crerep     as deci no-undo.
def var v-crerepexpr as deci no-undo.

def new shared var s-prosr as logi.
s-prosr = no.

if v-option = "mail" then do: /*Damir*/
    v-selrep = "1".
    dt1 = v-yesterday.
    dt2 = v-yesterday.
    s-prosr = no.
    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.
    def var vv-path as char no-undo.
    if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
    else vv-path = '/data/b'.
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-lnday2 (input dt1, input dt2, input txb.name).
    end.
    if connected ("txb") then disconnect "txb".
end.
else do:
    run sel2 (" Выбор типа отчета: ", " 1. Детализированный | 2. Общий ", output v-selrep).
    if v-selrep = '0' then v-selrep = '1'.

    dt2 = g-today - 1.
    dt1 = date(month(dt2),1,year(dt2)).

    update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
           s-prosr label ' Только непросроченные кредиты ' format 'да/нет' skip
           with side-label row 5 centered frame dat .
    hide frame dat.

    {r-brfilial.i &proc = "r-lnday2 (input dt1, input dt2, input txb.name)"}.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

def var rates as decimal extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt <= dt2 no-lock no-error.
  if avail crchis then rates[crc.crc] = crchis.rate[1].
end.

/************************ Report 1 ************************/

if v-selrep = '1' then do: /* выводить или нет детализированный отчет */

if v-option = "mail" then output stream m-out to value(vfname).
else output stream m-out to day.htm.

if v-option = "mail" then do:
    put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
      "<h3> ПРЕДОСТАВЛЕННЫЕ И ПОГАШЕННЫЕ ФИНАНСОВЫЕ ОБЯЗАТЕЛЬСТВА КЛИЕНТОВ ЗА ПЕРИОД С " string(dt1) " ПО " string(dt2) "</h3><br><br>" skip.


    /*----------------------------------------------------------------------------------------------------------*/
    def buffer b-crover_pog for crover_pog.
    v-crerep = 0.
    for each crover_pog no-lock break by crover_pog.bank:
        if first-of(crover_pog.bank) then do:
            itog = 0.
            for each b-crover_pog where b-crover_pog.bank = crover_pog.bank no-lock break by b-crover_pog.urfiz:
                itog = itog + b-crover_pog.sum1.
            end.
            v-crerep = v-crerep + itog.
        end.
    end.

    def buffer b-bd_pog for bd_pog.
    v-crerepexpr = 0.
    for each bd_pog no-lock break by bd_pog.bank:
        if first-of(bd_pog.bank) then do:
            itog = 0.
            for each b-bd_pog where b-bd_pog.bank = bd_pog.bank no-lock:
                itog = itog + b-bd_pog.sum1.
            end.
            v-crerepexpr = v-crerepexpr + itog.
        end.
    end.
    /*----------------------------------------------------------------------------------------------------------*/

    put stream m-out unformatted "<h4>Выдано кредитов</h4>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.

    def buffer b-crover_vyd for crover_vyd.
    v-creiss = 0.
    for each crover_vyd no-lock break by crover_vyd.bank:
        if first-of(crover_vyd.bank) then do:
            itog = 0.
            coun = 1.
            find first txb where txb.name = crover_vyd.bank and txb.consolid no-lock no-error.
            if avail txb then v-bc = txb.info. else v-bc = "unknown".
            put stream m-out unformatted
                "<TR style=""font:bold"">" skip
                "<TD colspan=9 bgcolor='#9BCDFF'>" v-bc "</TD>" skip
                "</TR>" skip.
            for each b-crover_vyd where b-crover_vyd.bank = crover_vyd.bank no-lock break by b-crover_vyd.urfiz:
                itog = itog + b-crover_vyd.paid.
                if first-of(b-crover_vyd.urfiz) then do:
                    if b-crover_vyd.urfiz = 0 then
                    put stream m-out unformatted
                        "<tr style=""font:bold""><td colspan=9>Юридические лица</td></tr>" skip.
                    else
                    put stream m-out unformatted
                        "<tr style=""font:bold""><td colspan=9>Физические лица</td></tr>" skip.
                end.
                put stream m-out unformatted
                    "<tr align=""right"">"
                    "<td align=""center""> " coun                             "</td>"
                    "<td align=""left""> " b-crover_vyd.prname format "x(60)" "</td>"
                    "<td> " b-crover_vyd.gua                                  "</td>"
                    "<td> " b-crover_vyd.crc                                  "</td>"
                    "<td> " replace(trim(string(b-crover_vyd.paid,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                    "<td> " b-crover_vyd.who format "x(10)"                   "</td>" skip
                    "<td> " b-crover_vyd.grp                                  "</td>"
                    "<td> " replace(trim(string(b-crover_vyd.prem,'>>9.99')),'.',',') "</td>"
                    "<td> " if b-crover_vyd.krdo then "крат" else "долг"      "</td>" skip
                    "</tr>" skip.
                coun = coun + 1.
            end.
            put stream m-out unformatted
                "<tr style=""font:bold"">
                <td></td>
                <td colspan=2>ИТОГО</td>
                <td></td>
                <td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>
                </tr>".
            v-creiss = v-creiss + itog.
        end.
    end. /* for each crover_vyd */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

    put stream m-out unformatted
        "<TR style=""font:bold"">" skip
        "<TD align=left colspan=4>ВСЕГО ВЫДАНО КРЕДИТОВ</TD>" skip
        "<TD align=center>" replace(trim(string(v-creiss,'>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
        "<TD colspan=4></TD>" skip
        "</TR>" skip.

    put stream m-out unformatted
        "<TR style=""font:bold"">" skip
        "<TD align=left colspan=4>ВСЕГО ПОГАШЕНО КРЕДИТОВ</TD>" skip
        "<TD align=center>" replace(trim(string(v-crerep + v-crerepexpr,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
        "<TD colspan=4></TD>" skip
        "</TR>" skip.

    put stream m-out unformatted
        "<TR style=""font:bold"">" skip
        "<TD align=left colspan=4>В Т.Ч. ПОГАШЕНО КРЕДИТОВ ПО ЭКСПРЕСС-КРЕДИТАМ</TD>" skip
        "<TD align=center>" replace(trim(string(v-crerepexpr,'>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
        "<TD colspan=4></TD>" skip
        "</TR>" skip.

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Погашено кредитов</h4>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма %</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.

    for each crover_pog no-lock break by crover_pog.bank:
        if first-of(crover_pog.bank) then do:
            coun = 1.
            itog = 0.
            itgp = 0.
            find first txb where txb.name = crover_pog.bank and txb.consolid no-lock no-error.
            if avail txb then v-bc = txb.info. else v-bc = "unknown".
            put stream m-out unformatted
                "<TR style=""font:bold"">" skip
                "<TD colspan=10 bgcolor='#9BCDFF'>" v-bc "</TD>" skip
                "</TR>" skip.
            for each b-crover_pog where b-crover_pog.bank = crover_pog.bank no-lock break by b-crover_pog.urfiz:
                itog = itog + b-crover_pog.sum1.
                itgp = itgp + b-crover_pog.sum2.
                if first-of(b-crover_pog.urfiz) then do:
                    if b-crover_pog.urfiz = 0 then
                    put stream m-out unformatted
                        "<tr style=""font:bold""><td colspan=10>Юридические лица</td></tr>" skip.
                    else
                    put stream m-out unformatted
                        "<tr style=""font:bold""><td colspan=10>Физические лица</td></tr>" skip.
                end.

                put stream m-out unformatted "<tr align=""right"">"
                    "<td align=""center""> " coun "</td>"
                    "<td align=""left""> " b-crover_pog.prname format "x(60)" "</td>"
                    "<td> " b-crover_pog.gua "</td>"
                    "<td> " b-crover_pog.crc "</td>"
                    "<td> " replace(trim(string(b-crover_pog.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                    "<td> " replace(trim(string(b-crover_pog.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                    "<td> " b-crover_pog.who  format "x(10)" "</td>"
                    "<td> " b-crover_pog.grp "</td>"
                    "<td> " replace(trim(string(b-crover_pog.prem,'>>9.99')),'.',',') "</td>"
                    "<td> " if b-crover_pog.krdo then "крат" else "долг" "</td>" skip
                    "</tr>" skip.
                coun = coun + 1.
            end.
            put stream m-out unformatted
                "<tr style=""font:bold"">" skip
                "<td></td>" skip
                "<td colspan=2>ИТОГО</td>" skip
                "<td></td>" skip
                "<td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td>" replace(trim(string(itgp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "</tr>".
        end.
    end. /* for each crover_pog */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Выдано экспресс-кредитов</h4>" skip.
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Дата погашения</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.

    def buffer b-bd_vyd for bd_vyd.
    for each bd_vyd no-lock break by bd_vyd.bank:
        if first-of(bd_vyd.bank) then do:
            coun = 1.
            itog = 0.
            find first txb where txb.name = bd_vyd.bank and txb.consolid no-lock no-error.
            if avail txb then v-bc = txb.info. else v-bc = "unknown".
            put stream m-out unformatted
                "<TR style=""font:bold"">" skip
                "<TD colspan=9 bgcolor='#9BCDFF'>" v-bc "</TD>" skip
                "</TR>" skip.
            for each b-bd_vyd where b-bd_vyd.bank = bd_vyd.bank no-lock:
                itog = itog + b-bd_vyd.paid.
                put stream m-out unformatted "<tr align=""right"">"
                "<td align=""center""> " coun "</td>"
                "<td align=""left""> " b-bd_vyd.prname format "x(60)" "</td>"
                "<td> " b-bd_vyd.crc "</td>"
                "<td> " replace(trim(string(b-bd_vyd.paid,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td> " b-bd_vyd.duedt "</td>"
                "<td> " b-bd_vyd.who  format "x(10)" "</td>"
                "<td> " b-bd_vyd.grp "</td>"
                "<td> " replace(trim(string(b-bd_vyd.prem,'>>9.99')),'.',',') "</td>"
                "<td> " if b-bd_vyd.krdo then "крат" else "долг" "</td>" skip
                "</tr>" skip.
                coun = coun + 1.
            end.
            put stream m-out unformatted "<tr style=""font:bold""><td></td><td colspan=2>ИТОГО</td><td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>".
        end.
    end. /* for each bd_vyd */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Погашение и досрочное погашение ОД и % по экспресс-кредитам</h4>" skip.
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма %</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Дата погашения</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.

    for each bd_pog no-lock break by bd_pog.bank:
        if first-of(bd_pog.bank) then do:
            coun = 1.
            itog = 0.
            itgp = 0.
            itgc = 0.
            find first txb where txb.name = bd_pog.bank and txb.consolid no-lock no-error.
            if avail txb then v-bc = txb.info. else v-bc = "unknown".
            put stream m-out unformatted
                "<TR style=""font:bold"">" skip
                "<TD colspan=11 bgcolor='#9BCDFF'>" v-bc "</TD>" skip
                "</TR>" skip.
            for each b-bd_pog where b-bd_pog.bank = bd_pog.bank no-lock:
                itog = itog + b-bd_pog.sum1.
                itgp = itgp + b-bd_pog.sum2.
                itgc = itgc + b-bd_pog.sum3.
                put stream m-out unformatted "<tr align=""right"">"
                "<td align=""center""> " coun "</td>"
                "<td align=""left""> " b-bd_pog.prname format "x(60)" "</td>"
                "<td> " b-bd_pog.crc "</td>"
                "<td> " replace(trim(string(b-bd_pog.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td> " replace(trim(string(b-bd_pog.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td> " replace(trim(string(b-bd_pog.sum3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td> " b-bd_pog.duedt "</td>"
                "<td> " b-bd_pog.who format "x(10)" "</td>"
                "<td> " b-bd_pog.grp "</td>"
                "<td> " replace(trim(string(b-bd_pog.prem,'>>9.99')),'.',',') "</td>"
                "<td> " if b-bd_pog.krdo then "крат" else "долг" "</td>" skip
                "</tr>" skip.
                coun = coun + 1.
            end.
            put stream m-out unformatted
                "<tr style=""font:bold""><td></td><td colspan=2>ИТОГО</td>"
                "<td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(itgp,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(itgc,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td colspan=4></td></tr>".
        end.
    end. /* for each bd_pog */

    put stream m-out unformatted "</table><BR><BR>" skip.

    output stream m-out close.
    hide message no-pause.
end.
else do:
    put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
      "<h3> ПРЕДОСТАВЛЕННЫЕ И ПОГАШЕННЫЕ ФИНАНСОВЫЕ ОБЯЗАТЕЛЬСТВА КЛИЕНТОВ ЗА ПЕРИОД С " string(dt1) " ПО " string(dt2) "<BR>" skip
      "(" v-bankname ")</h3><br><br>" skip.

    put stream m-out unformatted "<h4>Выдано кредитов</h4>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.
    coun = 1. /* cnt1 = 0. */
    itog = 0.
    for each crover_vyd no-lock break by crover_vyd.bank by crover_vyd.urfiz:

      if v-select = 1 and first-of(crover_vyd.bank) then do:
           find first txb where txb.name = crover_vyd.bank and txb.consolid no-lock no-error.
           if avail txb then v-bc = txb.info. else v-bc = "unknown".
           put stream m-out unformatted "<tr style=""font:bold""><td bgcolor=""#9BCDFF"" colspan=9>" v-bc "</td></tr>" skip.
           coun = 1.
      end.
           itog = itog + crover_vyd.paid.
        if first-of(crover_vyd.urfiz) then do:
           if crover_vyd.urfiz = 0 then put stream m-out unformatted "<tr style=""font:bold""><td colspan=9>Юридические лица</td></tr>" skip.
           else put stream m-out unformatted "<tr style=""font:bold""><td colspan=9>Физические лица</td></tr>" skip.
        end.

      put stream m-out unformatted "<tr align=""right"">"
                       "<td align=""center""> " coun "</td>"
                       "<td align=""left""> " crover_vyd.prname format "x(60)" "</td>"
                       "<td> " crover_vyd.gua "</td>"
                       "<td> " crover_vyd.crc "</td>"
                       "<td> " replace(trim(string(crover_vyd.paid,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                       "<td> " crover_vyd.who format "x(10)" "</td>" skip
                       "<td> " crover_vyd.grp "</td>"
                       "<td> " replace(trim(string(crover_vyd.prem,'>>9.99')),'.',',') "</td>"
                       "<td> " if crover_vyd.krdo then "крат" else "долг" "</td>" skip
                       "</tr>" skip.
      /* cnt1 = cnt1 + crover_vyd.paid. */
      coun = coun + 1.
      if last-of(crover_vyd.bank) then do:
          if itog > 0 then
          put stream m-out unformatted
            "<tr style=""font:bold"">" skip
            "<td></td>" skip
            "<td colspan=2>ИТОГО</td>" skip
            "<td></td>" skip
            "<td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "</tr>" skip.
          itog = 0.
      end.


    end. /* for each crover_vyd */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Погашено кредитов</h4>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма %</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.
    coun = 1. /* cnt1 = 0. cnt2 = 0. */
    itog = 0.
    itgp = 0.
    for each crover_pog no-lock break by crover_pog.bank by crover_pog.urfiz:

      if v-select = 1 and first-of(crover_pog.bank) then do:
           find first txb where txb.name = crover_pog.bank and txb.consolid no-lock no-error.
           if avail txb then v-bc = txb.info. else v-bc = "unknown".
           put stream m-out unformatted "<tr style=""font:bold""><td bgcolor=""#9BCDFF"" colspan=10>" v-bc "</td></tr>" skip.
           coun = 1.
      end.
           itog = itog + crover_pog.sum1.
           itgp = itgp + crover_pog.sum2.
      if first-of(crover_pog.urfiz) then do:
        if crover_pog.urfiz = 0 then put stream m-out unformatted "<tr style=""font:bold""><td colspan=10>Юридические лица</td></tr>" skip.
        else put stream m-out unformatted "<tr style=""font:bold""><td colspan=10>Физические лица</td></tr>" skip.
      end.

      put stream m-out unformatted "<tr align=""right"">"
                   "<td align=""center""> " coun "</td>"
                   "<td align=""left""> " crover_pog.prname format "x(60)" "</td>"
                   "<td> " crover_pog.gua "</td>"
                   "<td> " crover_pog.crc "</td>"
                   "<td> " replace(trim(string(crover_pog.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " replace(trim(string(crover_pog.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " crover_pog.who  format "x(10)" "</td>"
                   "<td> " crover_pog.grp "</td>"
                   "<td> " replace(trim(string(crover_pog.prem,'>>9.99')),'.',',') "</td>"
                   "<td> " if crover_pog.krdo then "крат" else "долг" "</td>" skip
                   "</tr>" skip.
      /* cnt[1] = cnt[1] + crover_pog.sum1. cnt[2] = cnt[2] + crover_pog.sum2. */
      coun = coun + 1.

      if last-of(crover_pog.bank) then do:
           if itog > 0 then
                put stream m-out unformatted
                    "<tr style=""font:bold"">" skip
                    "<td></td>" skip
                    "<td colspan=2>ИТОГО</td>" skip
                    "<td></td>" skip
                    "<td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                    "<td>" replace(trim(string(itgp,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                    "</tr>" skip.
           itog = 0.
           itgp = 0.
      end.

    end. /* for each crover_pog */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Выдано экспресс-кредитов</h4>" skip.
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Дата погашения</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.
    coun = 1. /* cnt1 = 0. */
    itog = 0.
    for each bd_vyd no-lock break by bd_vyd.bank:

      if v-select = 1 and first-of(bd_vyd.bank) then do:
           find first txb where txb.name = bd_vyd.bank and txb.consolid no-lock no-error.
           if avail txb then v-bc = txb.info. else v-bc = "unknown".

           put stream m-out unformatted "<tr style=""font:bold""><td bgcolor=""#9BCDFF"" colspan=9>" v-bc "</td></tr>" skip.
           coun = 1.
      end.
           itog = itog + bd_vyd.paid.
      put stream m-out unformatted "<tr align=""right"">"
                   "<td align=""center""> " coun "</td>"
                   "<td align=""left""> " bd_vyd.prname format "x(60)" "</td>"
                   "<td> " bd_vyd.crc "</td>"
                   "<td> " replace(trim(string(bd_vyd.paid,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " bd_vyd.duedt "</td>"
                   "<td> " bd_vyd.who  format "x(10)" "</td>"
                   "<td> " bd_vyd.grp "</td>"
                   "<td> " replace(trim(string(bd_vyd.prem,'>>9.99')),'.',',') "</td>"
                   "<td> " if bd_vyd.krdo then "крат" else "долг" "</td>" skip
                   "</tr>" skip.

      /* cnt1 = cnt1 + bd_vyd.paid. */
      coun = coun + 1.

      if last-of(bd_vyd.bank) then do:
          if itog > 0 then put stream m-out unformatted "<tr style=""font:bold""><td></td><td colspan=2>ИТОГО</td><td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>".
          itog = 0.
      end.

    end. /* for each bd_vyd */

    put stream m-out unformatted "</table><BR><BR>" skip.

    put stream m-out unformatted "<h4>Погашение и досрочное погашение ОД и % по экспресс-кредитам</h4>" skip.
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                     "<tr style=""font:bold"">"
                     "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма %</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Дата погашения</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель</td>" skip
                     "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>"
                     "<td bgcolor=""#C0C0C0"" align=""center"">Крат/Долг</td>" skip
                     "</tr>" skip.
    coun = 1. /* cnt1 = 0. cnt2 = 0. */
    itog = 0.
    itgp = 0.
    itgc = 0.
    for each bd_pog no-lock break by bd_pog.bank:

      if v-select = 1 and first-of(bd_pog.bank) then do:
           find first txb where txb.name = bd_pog.bank and txb.consolid no-lock no-error.
           if avail txb then v-bc = txb.info. else v-bc = "unknown".
           put stream m-out unformatted "<tr style=""font:bold""><td bgcolor=""#9BCDFF"" colspan=10>" v-bc "</td></tr>" skip.
           coun = 1.
      end.

      itog = itog + bd_pog.sum1.
      itgp = itgp + bd_pog.sum2.
      itgc = itgc + bd_pog.sum3.
      put stream m-out unformatted "<tr align=""right"">"
                   "<td align=""center""> " coun "</td>"
                   "<td align=""left""> " bd_pog.prname format "x(60)" "</td>"
                   "<td> " bd_pog.crc "</td>"
                   "<td> " replace(trim(string(bd_pog.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " replace(trim(string(bd_pog.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " replace(trim(string(bd_pog.sum3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td> " bd_pog.duedt "</td>"
                   "<td> " bd_pog.who format "x(10)" "</td>"
                   "<td> " bd_pog.grp "</td>"
                   "<td> " replace(trim(string(bd_pog.prem,'>>9.99')),'.',',') "</td>"
                   "<td> " if bd_pog.krdo then "крат" else "долг" "</td>" skip
                   "</tr>" skip.

      /* cnt1 = cnt1 + bd_pog.sum1. cnt2 = cnt2 + bd_pog.sum2. */
      coun = coun + 1.

      if last-of(bd_pog.bank) then do:
           if itog > 0 then put stream m-out unformatted "<tr style=""font:bold""><td></td><td colspan=2>ИТОГО</td>"
                   "<td>" replace(trim(string(itog,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td>" replace(trim(string(itgp,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td>" replace(trim(string(itgc,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                   "<td colspan=4></td></tr>".
           itog = 0.
           itgp = 0.
           itgc = 0.
      end.

    end. /* for each bd_pog */

    put stream m-out unformatted "</table><BR><BR>" skip.

    output stream m-out close.

    hide message no-pause.
end.
if v-option <> "mail" then unix silent cptwin day.htm excel.

end. /* if v-selrep = '1' - выводить или нет детализированный отчет */

/****************************** Report 2 ************************************/

def var st_border as char init "style=""border:.5pt; border:solid;""".

if v-selrep = '2' then do: /* выводить или нет средний отчет */

def var sum_cif as deci extent 4.
def var sum_cift as deci extent 4.
def var sum_crc as deci extent 4.
def var sum_crct as deci extent 4.
def var sum_1 as deci extent 4.
def var sum_2 as deci extent 4.
def var sum_1t as deci extent 4.
def var sum_2t as deci extent 4.
def var sum_tot as deci extent 4.
def buffer b-crchis for crchis.

def var v-crcusd as deci.
def var v-crceur as deci.

find last crchis where crchis.crc = 2 and crchis.rdt <= dt2 no-lock no-error.
v-crcusd = crchis.rate[1].
find last crchis where crchis.crc = 3 and crchis.rdt <= dt2 no-lock no-error.
v-crceur = crchis.rate[1].

output stream m-out to day2.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
                 "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
                 "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.
/* 2.1 выдано */

put stream m-out unformatted "<h4> Предоставленные кредиты за период с " string(dt1) " по " string(dt2) "<BR>" skip
                 "(" v-bankname ")</h4><br>" skip.

sum_tot = 0.

/* 2.1.1. юр лица */

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out unformatted
                 "<tr style=""font:bold"" align=""left"">" skip
                 "<td colspan=3></td>" skip
                 "<td>USD/KZT</td>" skip
                 "<td>" replace(trim(string(v-crcusd,">>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip
                 "<tr style=""font:bold"" align=""left"">" skip
                 "<td colspan=3></td>" skip
                 "<td>EUR/KZT</td>" skip
                 "<td>" replace(trim(string(v-crceur,">>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip.

put stream m-out unformatted
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Код кл</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Наименование заемщика</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Валюта</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td></tr>" skip.

sum_2t = 0.
for each crover_vyd where crover_vyd.urfiz = 0 no-lock use-index ind2 break by crover_vyd.bank by crover_vyd.crc by crover_vyd.cif:

  if first-of(crover_vyd.bank) then do:
     find first txb where txb.bank = crover_vyd.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr style=""font:bold""><td colspan=5 " st_border ">" v-bc "</td></tr>" skip.
     coun = 1. sum_1t[1] = 0.
  end.

  if first-of(crover_vyd.crc) then do:
    sum_crc[1] = 0. sum_crct[1] = 0.
    for each wrk_fiz: delete wrk_fiz. end.
  end.

  if first-of(crover_vyd.cif) then do: sum_cif[1] = 0. sum_cift[1] = 0. end.

  sum_cif[1] = sum_cif[1] + crover_vyd.paid.
  sum_crc[1] = sum_crc[1] + crover_vyd.paid.
  sum_cift[1] = sum_cift[1] + crover_vyd.paidt.
  sum_crct[1] = sum_crct[1] + crover_vyd.paidt.

  if last-of(crover_vyd.cif) then do:

     /*if sum_cif[1] * rates[1] / rates[2] >= 50000 then do:*/
       create wrk_fiz.
       wrk_fiz.prname = crover_vyd.prname.
       wrk_fiz.cif = crover_vyd.cif.
       wrk_fiz.crc = crover_vyd.crc.
       wrk_fiz.paid = sum_cif[1].
       wrk_fiz.paidt = sum_cift[1].
     /*end.*/

  end.

  if last-of(crover_vyd.crc) then do:

     for each wrk_fiz no-lock:
         find crc where crc.crc = crover_vyd.crc no-lock no-error.
         put stream m-out unformatted "<tr>"
                     "<td align=""center"" " st_border ">" coun "</td>"
                     "<td " st_border ">" wrk_fiz.cif "</td>"
                     "<td " st_border ">" wrk_fiz.prname "</td>"
                     "<td " st_border ">" crc.code "</td>"
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.paid,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
         coun = coun + 1.
     end.

     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crct[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_1t[1] = sum_1t[1] + sum_crct[1].
  end.

  if last-of(crover_vyd.bank) then do:
     put stream m-out unformatted "<tr><td>&nbsp;</td></tr>" skip.
     find first txb where txb.bank = crover_vyd.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
            "<td colspan=3>Итого " v-bc ", KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_1t[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_2t[1] = sum_2t[1] + sum_1t[1].
  end.

end. /* for each crover_vyd */

put stream m-out unformatted
        "<tr><td>&nbsp;</td></tr>" skip.
/*        "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ЮРИДИЧЕСКИМ ЛИЦАМ В USD:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ЮРИДИЧЕСКИМ ЛИЦАМ В KZT:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2t[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
        "</table><BR><BR>" skip.

sum_tot[1] = sum_tot[1] + sum_2t[1].

/* 2.1.2. физ лица */

put stream m-out unformatted "<b>Физические лица</b><br><br>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"" " st_border ">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Код кл</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Наименование заемщика</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Валюта</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td></tr>".

coun = 0. sum_2t[1] = 0.
for each crover_vyd where crover_vyd.urfiz = 1 no-lock use-index ind2 break by crover_vyd.crc by crover_vyd.bank by crover_vyd.cif:

  if first-of(crover_vyd.crc) then do:
     sum_crc[1] = 0. sum_crct[1] = 0.
  end.

  if first-of(crover_vyd.bank) then do:
     coun = 0. sum_1[1] = 0. sum_1t[1] = 0.
     for each wrk_fiz: delete wrk_fiz. end.
  end.

  if first-of(crover_vyd.cif) then do: sum_cif[1] = 0. sum_cift[1] = 0. end.

  sum_cif[1] = sum_cif[1] + crover_vyd.paid.
  sum_cift[1] = sum_cift[1] + crover_vyd.paidt.

  if last-of(crover_vyd.cif) then do:
    if sum_cif[1] * rates[crover_vyd.crc] / rates[2] >= 50000 then do:
      create wrk_fiz.
      wrk_fiz.prname = crover_vyd.prname.
      wrk_fiz.cif = crover_vyd.cif.
      wrk_fiz.crc = crover_vyd.crc.
      wrk_fiz.paid = sum_cif[1].
      wrk_fiz.paidt = sum_cift[1].
    end.
    coun = coun + 1.
    sum_1[1] = sum_1[1] + sum_cif[1].
    sum_1t[1] = sum_1t[1] + sum_cift[1].
  end.

  if last-of(crover_vyd.bank) then do:
     find crc where crc.crc = crover_vyd.crc no-lock no-error.
     find first txb where txb.bank = crover_vyd.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr>"
            "<td colspan=2 " st_border "></td>" skip
            "<td " st_border ">" caps(v-bc) " - " coun " КРЕДИТА(ОВ)</td>" skip
            "<td " st_border ">" crc.code "</td>" skip
            "<td align=""right"" " st_border ">" replace(trim(string(sum_1[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_crc[1] = sum_crc[1] + sum_1[1].
     sum_crct[1] = sum_crct[1] + sum_1t[1].

     coun = 1.
     find first wrk_fiz no-lock no-error.
     if avail wrk_fiz then do:
        put stream m-out unformatted "<tr style=""font:bold""><td colspan=5 " st_border ">в том числе:</td></tr>" skip.
        for each wrk_fiz no-lock:
           put stream m-out unformatted "<tr>"
                     "<td align=""center"" " st_border ">" coun "</td>"
                     "<td " st_border ">" wrk_fiz.cif "</td>"
                     "<td " st_border ">" wrk_fiz.prname "</td>"
                     "<td " st_border ">" crc.code "</td>"
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.paid,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
           coun = coun + 1.
        end.
     end.
  end.

  if last-of(crover_vyd.crc) then do:
     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crct[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_2t[1] = sum_2t[1] + sum_crct[1].
  end.

end. /* for each crover_vyd */

if sum_2[1] > 0 then do:
   put stream m-out unformatted
          "<tr><td>&nbsp;</td></tr>" skip.
         /* "<tr style=""font:bold"" align=""right"">"
          "<td colspan=3>ВСЕГО ПО ПОТРЕБИТЕЛЬСКИМ КРЕДИТАМ В USD:</td>" skip
          "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
   put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
          "<td colspan=3>ВСЕГО ПО ПОТРЕБИТЕЛЬСКИМ КРЕДИТАМ В KZT:</td>" skip
          "<td colspan=2>" replace(trim(string(sum_2t[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
end.

sum_tot[1] = sum_tot[1] + sum_2t[1].

/* 2.1.3. bd */

put stream m-out unformatted
    "<tr><td>&nbsp;</td></tr>" skip
    "<tr style=""font:bold""><td bgcolor=""#C0C0C0"" colspan=5 " st_border ">ЭКСПРЕСС-КРЕДИТЫ</td></tr>" skip.

coun = 0. sum_2[1] = 0.
for each bd_vyd no-lock use-index ind2 break by bd_vyd.crc by bd_vyd.bank by bd_vyd.cif:

  if first-of(bd_vyd.crc) then sum_crc[1] = 0.

  if first-of(bd_vyd.bank) then do:
     coun = 0. sum_1[1] = 0.
  end.

  coun = coun + 1.
  sum_1[1] = sum_1[1] + bd_vyd.paid.

  if last-of(bd_vyd.bank) then do:
     find crc where crc.crc = bd_vyd.crc no-lock no-error.
     find first txb where txb.bank = bd_vyd.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr>"
            "<td colspan=2 " st_border "></td>" skip
            "<td " st_border ">" caps(v-bc) " - " coun " КРЕДИТА(ОВ)</td>" skip
            "<td " st_border ">" crc.code "</td>" skip
            "<td " st_border ">" replace(trim(string(sum_1[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_crc[1] = sum_crc[1] + sum_1[1].
  end.

  if last-of(bd_vyd.crc) then do:
     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     sum_2[1] = sum_2[1] + sum_crc[1].
  end.

end. /* for each bd_vyd */

put stream m-out unformatted
        "<tr><td>&nbsp;</td></tr>" skip.
/*        "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ИТОГО ПО ПРОГРАММЕ ""БД"" В USD:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ИТОГО ПО ПРОГРАММЕ ""БД"" В KZT:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
        "</table><BR><BR>" skip.

sum_tot[1] = sum_tot[1] + sum_2[1].

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted
                 "<tr style=""font:bold"">" skip
                 "<td colspan=3>ВСЕГО ВЫДАНО, KZT:</td>" skip
                 "<td colspan=2>" replace(trim(string(sum_tot[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "</tr></table><BR><BR>" skip.

/* 2.2. погашено */

put stream m-out unformatted "<h4> Погашенные кредиты за период с " string(dt1) " по " string(dt2) "<BR>" skip
                 "(" v-bankname ")</h4><br>" skip.

sum_tot = 0.

/* 2.2.1. юр лица */

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out unformatted
                 "<tr style=""font:bold"" align=""left"">" skip
                 "<td colspan=5></td>" skip
                 "<td>USD/KZT</td>" skip
                 "<td>" replace(trim(string(v-crcusd,">>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip
                 "<tr style=""font:bold"" align=""left"">" skip
                 "<td colspan=5></td>" skip
                 "<td>EUR/KZT</td>" skip
                 "<td>" replace(trim(string(v-crceur,">>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip.

put stream m-out unformatted
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Код кл</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Наименование заемщика</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Валюта</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма ОД</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма %</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Комиссия</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Итого</td></tr>" skip.

sum_2 = 0. sum_2t = 0.
for each crover_pog where crover_pog.urfiz = 0 no-lock use-index ind3 break by crover_pog.bank by crover_pog.crc by crover_pog.cif:

  if first-of(crover_pog.bank) then do:
     find first txb where txb.bank = crover_pog.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr style=""font:bold""><td colspan=8>" v-bc "</td></tr>" skip.
     coun = 1. sum_1 = 0. sum_1t = 0.
  end.

  if first-of(crover_pog.crc) then do:
    sum_crc = 0. sum_crct = 0.
    for each wrk_fiz: delete wrk_fiz. end.
  end.

  if first-of(crover_pog.cif) then do: sum_cif = 0. sum_cift = 0. end.

  sum_cif[1] = sum_cif[1] + crover_pog.sum1.
  sum_cif[2] = sum_cif[2] + crover_pog.sum2.
  sum_cif[3] = 0.
  sum_cif[4] = sum_cif[4] + crover_pog.sum1 + crover_pog.sum2.
  sum_cift[1] = sum_cift[1] + crover_pog.sum1t.
  sum_cift[2] = sum_cift[2] + crover_pog.sum2t.
  sum_cift[3] = 0.
  sum_cift[4] = sum_cift[4] + crover_pog.sum1t + crover_pog.sum2t.

  if last-of(crover_pog.cif) then do:
    /*if crover_pog.opnamt * crchis.rate[1] >= 5000000 then do:*/
      create wrk_fiz.
      wrk_fiz.prname = crover_pog.prname.
      wrk_fiz.cif = crover_pog.cif.
      wrk_fiz.crc = crover_pog.crc.
      wrk_fiz.sum1 = sum_cif[1].
      wrk_fiz.sum2 = sum_cif[2].
      wrk_fiz.sum1t = sum_cift[1].
      wrk_fiz.sum2t = sum_cift[2].
    /*end.*/
    do i = 1 to 4: sum_crc[i] = sum_crc[i] + sum_cif[i]. sum_crct[i] = sum_crct[i] + sum_cift[i]. end.
  end.

  if last-of(crover_pog.crc) then do:
     coun = 1.
     find crc where crc.crc = crover_pog.crc no-lock no-error.
     for each wrk_fiz no-lock:
           put stream m-out unformatted "<tr>"
                     "<td align=""center"" " st_border ">" coun "</td>"
                     "<td " st_border ">" wrk_fiz.cif "</td>"
                     "<td " st_border ">" wrk_fiz.prname "</td>"
                     "<td " st_border ">" crc.code "</td>"
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                     "<td align=""right"" " st_border ">0</td>" skip
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum1 + wrk_fiz.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
           coun = coun + 1.
     end.

     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crct[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_1t[i] = sum_1t[i] + sum_crct[i]. end.
  end.

  if last-of(crover_pog.bank) then do:
     put stream m-out unformatted "<tr><td>&nbsp;</td></tr>" skip.
     find first txb where txb.bank = crover_pog.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
            "<td colspan=3>Итого " v-bc ", KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_1t[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_1t[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_1t[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_1t[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_2t[i] = sum_2t[i] + sum_1t[i]. end.
  end.

end. /* for each crover_pog */

put stream m-out unformatted
        "<tr><td>&nbsp;</td></tr>" skip.
      /*  "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ЮРИДИЧЕСКИМ ЛИЦАМ В USD:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[2] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[3] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ЮРИДИЧЕСКИМ ЛИЦАМ В KZT:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2t[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
        "</table><BR><BR>" skip.

do i = 1 to 4: sum_tot[i] = sum_tot[i] + sum_2t[i]. end.

/* 2.2.2. физ лица */

put stream m-out unformatted "<b>Физические лица</b><br>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"" " st_border ">"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Код кл</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Наименование заемщика</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Валюта</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма ОД</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма %</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Комиссия</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Итого</td></tr>".

coun = 0. sum_2 = 0. sum_2t = 0.
for each crover_pog where crover_pog.urfiz = 1 no-lock use-index ind3 break by crover_pog.crc by crover_pog.bank by crover_pog.cif:

  if first-of(crover_pog.crc) then do: sum_crc = 0. sum_crct = 0. end.

  if first-of(crover_pog.bank) then do:
     coun = 0. sum_1 = 0. sum_1t = 0.
     for each wrk_fiz: delete wrk_fiz. end.
  end.

  if first-of(crover_pog.cif) then do: sum_cif = 0. sum_cift = 0. end.

  sum_cif[1] = sum_cif[1] + crover_pog.sum1.
  sum_cif[2] = sum_cif[2] + crover_pog.sum2.
  sum_cif[3] = 0.
  sum_cif[4] = sum_cif[4] + crover_pog.sum1 + crover_pog.sum2.

  sum_cift[1] = sum_cift[1] + crover_pog.sum1t.
  sum_cift[2] = sum_cift[2] + crover_pog.sum2t.
  sum_cift[3] = 0.
  sum_cift[4] = sum_cift[4] + crover_pog.sum1t + crover_pog.sum2t.

  if last-of(crover_pog.cif) then do:
    if sum_cif[1] * rates[crover_pog.crc] / rates[2] >= 50000 then do:
      create wrk_fiz.
      wrk_fiz.prname = crover_pog.prname.
      wrk_fiz.cif = crover_pog.cif.
      wrk_fiz.crc = crover_pog.crc.
      wrk_fiz.sum1 = sum_cif[1].
      wrk_fiz.sum2 = sum_cif[2].
      wrk_fiz.sum1t = sum_cift[1].
      wrk_fiz.sum2t = sum_cift[2].
    end.
    coun = coun + 1.
    do i = 1 to 4: sum_1[i] = sum_1[i] + sum_cif[i]. sum_1t[i] = sum_1t[i] + sum_cift[i]. end.
  end.

  if last-of(crover_pog.bank) then do:
     find crc where crc.crc = crover_pog.crc no-lock no-error.
     find first txb where txb.bank = crover_pog.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted "<tr>"
            "<td colspan=2 " st_border "></td>" skip
            "<td " st_border ">" caps(v-bc) " - " coun " КРЕДИТА(ОВ)</td>" skip
            "<td " st_border ">" crc.code "</td>" skip
            "<td align=""right"" " st_border ">" replace(trim(string(sum_1[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td align=""right"" " st_border ">" replace(trim(string(sum_1[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td align=""right"" " st_border ">" replace(trim(string(sum_1[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td align=""right"" " st_border ">" replace(trim(string(sum_1[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_crc[i] = sum_crc[i] + sum_1[i]. sum_crct[i] = sum_crct[i] + sum_1t[i]. end.

     coun = 1.
     find first wrk_fiz no-lock no-error.
     if avail wrk_fiz then do:
       put stream m-out unformatted
           "<tr style=""font:bold""><td colspan=8 " st_border ">в том числе:</td></tr>" skip.
       for each wrk_fiz no-lock:
           put stream m-out unformatted "<tr>"
                     "<td align=""center"" " st_border ">" coun "</td>"
                     "<td " st_border ">" wrk_fiz.cif "</td>"
                     "<td " st_border ">" wrk_fiz.prname "</td>"
                     "<td " st_border ">" crc.code "</td>"
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                     "<td align=""right"" " st_border ">" replace(trim(string(0,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                     "<td align=""right"" " st_border ">" replace(trim(string(wrk_fiz.sum1 + wrk_fiz.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
           coun = coun + 1.
       end.
     end.

  end.

  if last-of(crover_pog.crc) then do:

     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crct[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crct[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_2t[i] = sum_2t[i] + sum_crct[i]. end.

  end.

end. /* for each crover_pog */

if sum_2[4] > 0 then do:
   put stream m-out unformatted
        "<tr><td>&nbsp;</td></tr>" skip.
       /* "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ПОТРЕБИТЕЛЬСКИМ КРЕДИТАМ В USD:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[2] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[3] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
   put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ВСЕГО ПО ПОТРЕБИТЕЛЬСКИМ КРЕДИТАМ В KZT:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2t[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2t[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
end.

do i = 1 to 4: sum_tot[i] = sum_tot[i] + sum_2t[i]. end.

/* 2.2.3. bd */

put stream m-out unformatted
      "<tr><td>&nbsp;</td></tr>" skip
      "<tr style=""font:bold""><td bgcolor=""#C0C0C0"" colspan=8 " st_border ">ЭКСПРЕСС-КРЕДИТЫ</td></tr>" skip.

coun = 0. sum_2 = 0.
for each bd_pog no-lock use-index ind3 break by bd_pog.crc by bd_pog.bank by bd_pog.cif:

  if first-of(bd_pog.crc) then sum_crc = 0.

  if first-of(bd_pog.bank) then do:
     coun = 0. sum_1 = 0.
  end.

  coun = coun + 1.
  sum_1[1] = sum_1[1] + bd_pog.sum1.
  sum_1[2] = sum_1[2] + bd_pog.sum2.
  sum_1[3] = sum_1[3] + bd_pog.sum3.
  sum_1[4] = sum_1[4] + bd_pog.sum1 + bd_pog.sum2 + bd_pog.sum3.

  if last-of(bd_pog.bank) then do:
     find crc where crc.crc = bd_pog.crc no-lock no-error.
     find first txb where txb.bank = bd_pog.bank and txb.consolid no-lock no-error.
     if avail txb then v-bc = txb.info. else v-bc = "unknown".
     put stream m-out unformatted
            "<tr>" skip
            "<td colspan=2 " st_border "></td>" skip
            "<td " st_border ">" caps(v-bc) " - " coun " КРЕДИТА(ОВ)</td>" skip
            "<td " st_border ">" crc.code "</td>" skip
            "<td " st_border ">" replace(trim(string(sum_1[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td " st_border ">" replace(trim(string(sum_1[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td " st_border ">" replace(trim(string(sum_1[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td " st_border ">" replace(trim(string(sum_1[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_crc[i] = sum_crc[i] + sum_1[i]. end.
  end.

  if last-of(bd_pog.crc) then do:
     put stream m-out unformatted
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в валюте кредита:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
            "<tr style=""font:bold"" align=""right"">" skip
            "<td colspan=3>Итого в KZT:</td>" skip
            "<td colspan=2>" replace(trim(string(sum_crc[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(sum_crc[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip.
     do i = 1 to 4: sum_2[i] = sum_2[i] + sum_crc[i]. end.
  end.

end. /* for each bd_pog */

put stream m-out unformatted
        "<tr><td>&nbsp;</td></tr>" skip.
       /* "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ИТОГО ПОГАШЕНО ПО ПРОГРАММЕ ""БД"" В USD:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[2] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[3] / rates[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip. */
put stream m-out unformatted "<tr style=""font:bold"" align=""right"">"
        "<td colspan=3>ИТОГО ПОГАШЕНО ПО ПРОГРАММЕ ""БД"" В KZT:</td>" skip
        "<td colspan=2>" replace(trim(string(sum_2[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(sum_2[4],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>" skip
        "</table><BR><BR>" skip.

do i = 1 to 4: sum_tot[i] = sum_tot[i] + sum_2[i]. end.

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted
                 "<tr style=""font:bold"">" skip
                 "<td colspan=3>ВСЕГО ПОГАШЕНО, KZT:</td>" skip
                 "<td colspan=2>" replace(trim(string(sum_tot[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" replace(trim(string(sum_tot[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" replace(trim(string(sum_tot[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" replace(trim(string(sum_tot[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "</tr></table><BR><BR>" skip.

put stream m-out unformatted "</body></html>" skip.

output stream m-out close.

hide message no-pause.

unix silent cptwin day2.htm excel.

end. /* if v-selrep = '2' - выводить или нет средний отчет */

/************************ end of report 2 ********************************/
/************************    Report 3     ********************************/

if v-selrep = '2' then do: /* выводить или нет общий отчет */

output stream m-out to day3.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
                 "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
                 "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

put stream m-out unformatted "<h4> Предоставленные и погашенные финансовые обязательства клиентов"
                 " за период с " string(dt1) " по " string(dt2) "<BR>" skip
                 "(" v-bankname ")</h4><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3></td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=6>Динамика портфеля</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=8>Денежная позиция</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2 colspan=2>Позиция</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Курсовая<BR>разница</td>" skip
                 "</tr>" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>На " dt1 format "99/99/9999" "</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>За " dt2 format "99/99/9999" "</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Прирост</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>Выдано</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=5>Погашено</td>" skip
                 "<tr style=""font:bold"">" skip.

put stream m-out unformatted
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip.

put stream m-out unformatted /* Выдано */
     /* "<td bgcolor=""#C0C0C0"" align=""center"">Количество<BR>(всего)</td>" skip */
     "<td bgcolor=""#C0C0C0"" align=""center"">Количество<BR>(только<BR>новых)</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<BR>(всего)</td>" skip.

put stream m-out unformatted /* Погашено */
     "<td bgcolor=""#C0C0C0"" align=""center"">Количество<BR>(полностью<BR>погашенных)</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Полностью<BR>погашено</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Частично<BR>погашено</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">В т.ч.<BR>списано</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во<BR>списанных</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Итого</td>" skip.

put stream m-out unformatted
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>" skip
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>" skip.


put stream m-out unformatted "</tr></table><BR><BR>" skip.


def buffer b-port for port.
/* подготовка большого итого*/

for each port where port.bank <> "TXB99" no-lock:

  find first b-port where b-port.bank = "TXB99" and b-port.sts = port.sts no-error.
  if not avail b-port then do:
    create b-port.
    b-port.bank = "TXB99".
    b-port.ln = port.ln.
    b-port.sts = port.sts.
  end.
  b-port.kol1 = b-port.kol1 + port.kol1.
  b-port.sum1 = b-port.sum1 + port.sum1.
  b-port.kol2 = b-port.kol2 + port.kol2.
  b-port.sum2 = b-port.sum2 + port.sum2.
  b-port.kol_vyd_all = b-port.kol_vyd_all + port.kol_vyd_all.
  b-port.kol_vyd = b-port.kol_vyd + port.kol_vyd.
  b-port.sum_vyd = b-port.sum_vyd + port.sum_vyd.
  b-port.kol_pog = b-port.kol_pog + port.kol_pog.
  b-port.sum_pog = b-port.sum_pog + port.sum_pog.
  b-port.sum_pog_full = b-port.sum_pog_full + port.sum_pog_full.
  b-port.sum_pog_part = b-port.sum_pog_part + port.sum_pog_part.
  b-port.sum_spis = b-port.sum_spis + port.sum_spis.
  b-port.kol_spis = b-port.kol_spis + port.kol_spis.

end.


for each port no-lock break by port.bank:

  if first-of(port.bank) then do:
    if port.bank = "TXB99" then v-bc = "ВСЕГО".
    else do:
      find first txb where txb.bank = port.bank and txb.consolid no-lock no-error.
      if avail txb then v-bc = txb.info. else v-bc = "unknown".
    end.
    put stream m-out unformatted
           v-bc "<BR>"
           "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
  end.

  put stream m-out unformatted
                 if port.sts = "ИТОГО" then "<tr style=""font:bold"">" else "<tr>" skip
                 "<td>" port.sts "</td>" skip
                 "<td>" port.kol1 "</td>" skip
                 "<td>" replace(trim(string(port.sum1,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" port.kol2 "</td>" skip
                 "<td>" replace(trim(string(port.sum2,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" frmt_outi(port.kol2 - port.kol1) "</td>" skip
                 "<td>" frmt_outd(port.sum2 - port.sum1) "</td>" skip
                /* "<td>" port.kol_vyd_all "</td>" skip */
                 "<td>" port.kol_vyd "</td>" skip
                 "<td>" replace(trim(string(port.sum_vyd,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" port.kol_pog "</td>" skip
                 "<td>" replace(trim(string(port.sum_pog_full,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" replace(trim(string(port.sum_pog_part,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" replace(trim(string(port.sum_spis,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" port.kol_spis "</td>" skip
                 "<td>" replace(trim(string(port.sum_pog_full + port.sum_pog_part,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                 "<td>" frmt_outi(port.kol_vyd - port.kol_pog) "</td>" skip
                 "<td>" frmt_outd(port.sum_vyd - port.sum_pog_full - port.sum_pog_part) "</td>" skip
                 "<td>" frmt_outd(port.sum2 - port.sum1 - (port.sum_vyd - port.sum_pog_full - port.sum_pog_part)) "</td>" skip
                 "</tr>" skip.

  if last-of(port.bank) then do:
    put stream m-out unformatted "</table><BR><BR>" skip.
  end.

end. /* for each port */

/*
put stream m-out unformatted
           "(*) ""Кол-во"" - количество НОВЫХ выданных кредитов (т.е. выданных впервые внутри указанного периода), ""Сумма"" - сумма выдачи по всем кредитам, включая кредиты с первой выдачей ранее указанного периода<BR>" skip
           "(**) ""Кол-во"" - количество ПОЛНОСТЬЮ погашенных кредитов (только по ОД), ""Сумма"" - сумма погашения ОД по всем кредитам" skip
           "</body></html>" skip.
*/

output stream m-out close.

unix silent cptwin day3.htm excel.

end. /* if v-selrep = '2' - выводить или нет общий отчет */

/************************ end of report 3 ********************************/
/************************    Report 4     ********************************/

if v-selrep = '2' then do: /* выводить или нет общий отчет */

for each crover_vyd no-lock break by crover_vyd.bank by crover_vyd.urfiz by crover_vyd.crc:

  if first-of(crover_vyd.crc) then do:
    find first port2 where port2.bank = crover_vyd.bank and port2.urfiz = crover_vyd.urfiz and port2.crc = crover_vyd.crc no-error.
    if not avail port2 then do:
      create port2.
      port2.bank = crover_vyd.bank.
      port2.urfiz = crover_vyd.urfiz.
      port2.crc = crover_vyd.crc.
      find first crc where crc.crc = crover_vyd.crc no-lock no-error.
      port2.ids_name = if crover_vyd.urfiz = 0 then "ЮР" + ' ' + crc.code else "ФИЗ" + ' ' + crc.code.
    end.
  end.

  port2.sum[3] = port2.sum[3] + crover_vyd.paid.

end. /* for each crover_vyd */

for each bd_vyd no-lock break by bd_vyd.bank by bd_vyd.crc:

  if first-of(bd_vyd.crc) then do:
    find first port2 where port2.bank = bd_vyd.bank and port2.urfiz = 1 and port2.crc = bd_vyd.crc no-error.
    if not avail port2 then do:
      create port2.
      port2.bank = bd_vyd.bank.
      port2.urfiz = 1.
      port2.crc = bd_vyd.crc.
      find first crc where crc.crc = bd_vyd.crc no-lock no-error.
      port2.ids_name = "ФИЗ" + ' ' + crc.code.
    end.
  end.

  port2.sum[3] = port2.sum[3] + bd_vyd.paid.

end. /* for each bd_vyd */

for each crover_pog no-lock break by crover_pog.bank by crover_pog.urfiz by crover_pog.crc:

  if first-of(crover_pog.crc) then do:
    find first port2 where port2.bank = crover_pog.bank and port2.urfiz = crover_pog.urfiz and port2.crc = crover_pog.crc no-error.
    if not avail port2 then do:
      create port2.
      port2.bank = crover_pog.bank.
      port2.urfiz = crover_pog.urfiz.
      port2.crc = crover_pog.crc.
      find first crc where crc.crc = crover_pog.crc no-lock no-error.
      port2.ids_name = if crover_pog.urfiz = 0 then "ЮР" + ' ' + crc.code else "ФИЗ" + ' ' + crc.code.
    end.
  end.

  port2.sum[4] = port2.sum[4] + crover_pog.sum1.

end. /* for each crover_pog */

for each bd_pog no-lock break by bd_pog.bank by bd_pog.crc:

  if first-of(bd_pog.crc) then do:
    find first port2 where port2.bank = bd_pog.bank and port2.urfiz = 1 and port2.crc = bd_pog.crc no-error.
    if not avail port2 then do:
      create port2.
      port2.bank = bd_pog.bank.
      port2.urfiz = 1.
      port2.crc = bd_pog.crc.
      find first crc where crc.crc = bd_pog.crc no-lock no-error.
      port2.ids_name = "ФИЗ" + ' ' + crc.code.
    end.
  end.

  port2.sum[4] = port2.sum[4] + bd_pog.sum1.

end. /* for each crover_pog */

def buffer b-port2 for port2.

for each port2 no-lock break by port2.urfiz by port2.crc:

  if port2.bank = "TXBALL" then next.

  /*if first-of(port2.crc) then do:*/
    find first b-port2 where b-port2.bank = "TXBALL" and b-port2.urfiz = port2.urfiz and b-port2.crc = port2.crc no-error.
    if not avail b-port2 then do:
      create b-port2.
      b-port2.bank = "TXBALL".
      b-port2.urfiz = port2.urfiz.
      b-port2.crc = port2.crc.
      b-port2.ids_name = port2.ids_name.
    end.
  /*end.*/

  do i = 1 to 4:
    b-port2.coun[i] = b-port2.coun[i] + port2.coun[i].
    b-port2.sum[i] = b-port2.sum[i] + port2.sum[i].
  end.

end.

output stream m-out to day4.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
                 "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
                 "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

put stream m-out unformatted "<h4> Предоставленные и погашенные финансовые обязательства клиентов"
                 " за период с " string(dt1) " по " string(dt2) "<BR>" skip
                 "(" v-bankname ")</h4><br><br>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3 " st_border "></td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=6 " st_border ">Динамика портфеля</td>" skip
                 "<td align=""center""></td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=6 " st_border ">Денежная позиция</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3 " st_border ">Разница</td>" skip
                 "</tr>" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">На " dt1 format "99/99/9999" "</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">За " dt2 format "99/99/9999" "</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">Прирост</td>" skip
                 "<td align=""center""></td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">Выдано</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">Погашено</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2 " st_border ">Позиция</td>" skip
                 "</tr>" skip
                 "<tr style=""font:bold"">" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "<td align=""center""></td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Кол-во</td>" skip
                 "<td bgcolor=""#C0C0C0"" align=""center"" " st_border ">Сумма</td>" skip
                 "</tr>" skip.

def var ss-coun as integer extent 4.

for each port2 no-lock break by port2.bank:

  if first-of(port2.bank) then do:
    ss-coun = 0.
    if port2.bank = "TXBALL" then put stream m-out unformatted "<tr style=""font:bold""><td colspan=15>ВСЕГО</td></tr>" skip.
    else do:
      find first txb where txb.bank = port2.bank and txb.consolid no-lock no-error.
      if avail txb then v-bc = txb.info. else v-bc = "unknown".
      put stream m-out unformatted "<tr style=""font:bold""><td colspan=15>" caps(v-bc) "</td></tr>" skip.
    end.
  end.

  put stream m-out unformatted
       "<tr>" skip
       "<td " st_border ">" port2.ids_name "</td>" skip
       "<td " st_border ">" port2.coun[1] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" port2.coun[2] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" port2.coun[2] - port2.coun[1] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[2] - port2.sum[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       "<td " st_border ">" port2.coun[3] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" port2.coun[4] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" port2.coun[3] - port2.coun[4] "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[3] - port2.sum[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(port2.sum[2] - port2.sum[1] - (port2.sum[3] - port2.sum[4]),"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "</tr>" skip.

  do i = 1 to 4:
    ss-coun[i] = ss-coun[i] + port2.coun[i].
  end.

  if last-of(port2.bank) then do:
    put stream m-out unformatted
       "<tr style=""font:bold"">" skip
       "<td></td>" skip
       "<td>" ss-coun[1] "</td>" skip
       "<td></td>" skip
       "<td>" ss-coun[2] "</td>" skip
       "<td></td>" skip
       "<td>" ss-coun[2] - ss-coun[1] "</td>" skip
       "<td colspan=2></td>" skip
       "<td>" ss-coun[3] "</td>" skip
       "<td></td>" skip
       "<td>" ss-coun[4] "</td>" skip
       "<td></td>" skip
       "<td>" ss-coun[3] - ss-coun[4] "</td>" skip
       "<td colspan=2></td>" skip
       "</tr>" skip.
  end.

end.

put stream m-out unformatted "</table><BR><BR>" skip.

output stream m-out close.

unix silent cptwin day4.htm excel.

end. /* if v-selrep = '2' - выводить или нет общий отчет */

hide message no-pause.

vres = yes.

