/* vcreplc.p
 * MODULE
        Валютный контроль
        Список контрактов, имеющих лицевые карточки
 * DESCRIPTION

 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
        10.3.15
 * AUTHOR
        15.02.2006 u00600
 * CHANGES
        15/08/2006 u00600 - оптимизация

    25.02.2011 damir - изменил поля временой таблицы
                       добавил rbr-filial
                       добавил вывод номер ЛКБК, дата ЛКБК.
                       все что  в комментах - это закомментил.


*/
{vc.i}
{comm-txb.i}

def new shared var v-reptype as char.
def shared var g-today as date.

def var v-dt as date no-undo.
def var v-name as char no-undo.
def var i as integer no-undo.
def var v-sum1 as deci no-undo.
def var ctnum as char no-undo.
def var ctdate as date no-undo.
def var cardnum as char no-undo.
def var departid as integer no-undo.
def var v-dep as integer no-undo.
def var v-pssd as char .

def new shared temp-table rmztmp
    field cif like cif.cif
    field depart as integer
    field cifname as char                   /* наименование клиента */
    field contract like vccontrs.contract
    field ctei as char
    field ctnum as char                     /* номер контракта */
    field ctdate as date                    /* дата контракта */
    field psnum as char                     /* номер паспорта сделки */
    field psnumnum as integer
    field ncrc like ncrc.crc            /* валюта контракта */
    field cardnum as char                   /* номер лицевой карточки */
    field cardnumdt as char                 /* дата лицевой карточки */
    index main is primary cifname cif ctdate ctnum contract.


/*def new shared temp-table rmztmp
    field rmztmp_name     as char
    field rmztmp_k        as char
    field rmztmp_nc       as char
    field rmztmp_dt       as date
    field rmztmp_nps      as char
    field rmztmp_ncrc     as char
    field rmztmp_nlc      as char
    field rmztmp_sumlc    as deci
    field rmztmp_sumlcUSD as deci.*/

def var s-vcourbank as char no-undo.
def var v-psnum as char.
def var v-psnumnum as integer.
def var  v-ncrccod as char.
def var v-ctei as char.
s-vcourbank = comm-txb().

v-reptype = "A".
form
   skip(1)
   v-dt label 'На дату' format '99/99/9999' skip
   v-reptype label "Статус карточки:  A) все   N) статус - N  " format "x" skip
   with centered side-label row 5 title "УКАЖИТЕ ДАТУ И СТАТУС КАРТОЧКИ ДЛЯ ОТЧЕТА" frame f-dt.

v-dt = g-today.
update v-dt v-reptype with frame f-dt.
v-reptype = caps(v-reptype).
displ v-reptype with frame f-dt.

{r-brfilial.i   &proc = " vcreplcdat (input txb.bank, 0, v-dt) "}

def stream vcrpt.
output stream vcrpt to vcreplc.html.

{html-title.i
 &stream = " stream vcrpt "
 &size-add = "xx-"
 &title = "Отчет по лицевым карточкам"
}

put stream vcrpt unformatted
    "<B>" skip
    "<P align = ""center""><FONT size=""6"" face=""Times New Roman Cyr, Verdana, sans"">"
    "Контракты, имеющие лицевые карточки</FONT></P>" skip.

put stream vcrpt unformatted "<tr>"
    "<TABLE  width=""100%"" border=""1"" cellspacing=""9"" cellpadding=""0"">" skip
    "<TR align=""center"" valign=""center"" style=""font:boldborder-collapse: collapse""><font size=""12pt"">" skip
    "<td align=""center"">N</td>" skip
    "<td align=""center"">Код клиента</td>" skip
    "<td align=""center"">Наименование клиента</td>" skip
    "<td align=""center"">Контракт</td>" skip
    "<td align=""center"">Код экспорта (1) или импорта (2)</td>" skip
    "<td align=""center"">Номер контракта</td>" skip
	"<td align=""center"">Дата контракта</td>" skip
    "<td align=""center"">Номер паспорта сделки</td>" skip
	"<td align=""center"">Валюта контракта</td>" skip
	"<td align=""center"">Номер ЛКБК</td>" skip
	"<td align=""center"">Дата ЛКБК</td>" skip
	/*"<td align=""center"">Сумма лицевой карточки (эквивалент в USD)</td>" skip*/
    "</FONT></B></tr>" skip.

i = 0.

for each rmztmp no-lock:
i = i + 1.
    /*accumulate rmztmp.rmztmp_sumlcUSD (TOTAL by rmztmp.rmztmp_k).*/

    find ncrc where ncrc.crc = rmztmp.ncrc no-lock no-error.
    if avail ncrc then v-ncrccod = ncrc.code.
    else v-ncrccod = "&nbsp;".

    put stream vcrpt  unformatted
        "<tr align=""center""><font size=""12"">"
	    "<td>" i "</td>"
        "<td>" rmztmp.cif "</td>" skip
        "<td>" rmztmp.cifname "</td>" skip
        "<td>" rmztmp.contract "</td>" skip.
        if rmztmp.ctei = "E" then v-ctei = "1".
        else v-ctei = "2".
    put stream vcrpt  unformatted
        "<td>" v-ctei "</td>" skip
        "<td>" rmztmp.ctnum "</td>" skip.
    if rmztmp.ctdate <> ? then
    put stream vcrpt unformatted
        "<TD align=""left"">" + string(rmztmp.ctdate, "99/99/9999") + "</TD>" skip.
    else
    put stream vcrpt unformatted
        "<TD align=""left"">&nbsp;</TD>" skip.
    if rmztmp.psnum <> "" then
    put stream vcrpt unformatted
        "<td>" rmztmp.psnum + string(rmztmp.psnumnum) + "," + " " + "N" + string(rmztmp.psnumnum) "</td>" skip.
    else
    put stream vcrpt unformatted
        "<td>" "отсутствует" "</td>" skip.
    put stream vcrpt unformatted
        "<td>" ncrc.crc "</td>" skip
        "<td>" rmztmp.cardnum "</td>" skip
        "<td>" rmztmp.cardnumdt "</td>" skip
        /*"<td>" replace(trim(string(rmztmp.rmztmp_sumlc, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(rmztmp.rmztmp_sumlcUSD, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") " </td>" skip*/
        "</FONT></tr>" skip.

        /*if last-of(rmztmp.rmztmp_k) then do:
        v-sum1 = accum total by (rmztmp.rmztmp_k) rmztmp.rmztmp_sumlcUSD.
        put stream vcrpt unformatted "<tr align=""center""><font size=""4"">"
        "<TR valign = ""top"">" skip
        "<TD><B> ИТОГО: </B></TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align = ""center""><B>" replace(trim(string(v-sum1, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") " </B></TD>" skip
        "</TR>" skip.

        end.*/
end.
put stream vcrpt unformatted
    "</FONT></table>".

/*find bankl where bankl.bank = s-vcourbank no-lock no-error.
if avail bankl then
put stream vcrpt unformatted
    "<B><tr align=""left""><font size=""2"">" bankl.name skip.*/

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.*/

put stream vcrpt unformatted
    "</B></FONT></P>" skip.

{html-end.i}

output stream vcrpt close.
unix silent cptwin vcreplc.html iexplore.