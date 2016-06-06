/* rep_vp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по валютной позиции
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
 * BASES
	BANK COMM
 * AUTHOR

 * CHANGES
            03/05/2012 Luiza
*/


{mainhead.i}

def new shared var fdt as date.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.

def stream v-out.

fdt = g-today.
def frame f-date
   fdt label "На" format "99/99/99" validate(fdt <= g-today, "Некорректная дата!") skip
with side-labels centered row 7 title "Укажите дату".
update  fdt  with frame f-date.

define new shared temp-table wrkk no-undo
    field fil as char
    field crc as int
    field od as decim
    field pr as decim
    field pen as decim
    field afn as decim
    field rate as decim
    field pr1 as decim
   index ind is primary  crc.

define new shared temp-table wrk1 no-undo
    field lev as int
    field fil as char
    field poz1 as decim
    field prov as decim
    field bay as decim
    field rate as decim
    field sel as decim
    field poz2 as decim
    field vo as decim
    field vt as decim
    field vou as decim /* внебал обязат на утро */
    field vtu as decim /* внебал треб на утро */
    field vd as decim
    field vc as decim
    field gl as int
    field rem as char
    field fio as char
    field corrgl as int
    field corrglname as char
    field doc as char
    field jh as int
    field id as char
    field tt as int
    field crc as int
    field crccode as char
    field sort1 as int
    field d as date
    index ind1 is primary  sort1 fil lev  jh.

define temp-table tot no-undo
    field crc as int
    field bay as decim
    field sel as decim
    index ind2 is primary  crc.

def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < fdt no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.

{r-branch.i &proc = "rep_vp3"}

for each comm.txb where comm.txb.consolid and true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run rep_vp1.
end.

if connected ("txb")  then disconnect "txb".


/*run txbs ("rep_vp1").*/

for each wrk1 where wrk1.lev = 3 break by wrk1.crc:
    if first-of(wrk1.crc) then do:
        create tot.
        tot.crc = wrk1.crc.
    end.
    find first tot where tot.crc = wrk1.crc.
    tot.bay = tot.bay + wrk1.bay.
    tot.sel = tot.sel + wrk1.sel.
end.

find first wrkk.
def var vv as logic init no.
if v-fil-int > 1 then v-fil-cnt = "консолидированный отчет".
output stream v-out to a_rep.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream v-out unformatted  "<h3>" "Отчет по валютной позиции АО 'МЕТРОКОМБАНК' на " string(fdt) "(" v-fil-cnt ")" "</h3>" skip.
        put stream v-out unformatted  "<table><tr><TD><FONT size=""2"">" "Отчет сформирован " today " в " STRING(TIME,"HH:MM:SS") "</td></tr></table>" skip.

        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:11px"">" skip.
        for each wrk1 break by wrk1.sort1:
            if first-of(wrk1.sort1) then do:
                if wrk1.crc = 2 and wrk1.lev = 1 then do:
                    put stream v-out unformatted "<tr align=center>"
                    "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B>Филиал</B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ВП утро </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Покупка</B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Курс </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Продажа</B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ВП итоги дня </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Счет  ГК </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Примечание </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Клиент </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> КоррГК </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> КоррГК Наим </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Документ </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Транзакция </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ID исполнителя </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Время опер</B></FONT></TD>"  skip
                        /* "<TD><FONT size=""2""><B> Вход остат 185800 в USD</B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Внебал обязат в USD на утро</B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Внебал требов в USD на утро</B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Дебет 185800 в USD  </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Кредит 185800 в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Исход ост 185800 в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Внебал обязат в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Внебал требов в USD </B></FONT></TD>" skip*/
                         /*"<TD><FONT size=""2""><B> Дебет<br>внебаланс в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Кредит<br>внебаланс в USD </B></FONT></TD>" skip*/
                        /* "<TD><FONT size=""2""><B> МФСО ОД в USD </B></FONT></TD>"  skip
                         "<TD><FONT size=""2""><B> МФСО%   в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> МФСО пеня   в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> АФН   в USD </B></FONT></TD>" skip
                         "<TD><FONT size=""2""><B> Курс </B></FONT></TD>" skip*/
                    "</tr>" skip.
                end.
                else do:
                    put stream v-out unformatted "<tr align=center>"
                    "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B>Филиал</B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ВП утро </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Покупка </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Курс </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Продажа </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ВП итоги дня </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Счет  ГК </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Примечание </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Клиент </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> КоррГК </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> КоррГК Наим </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Документ </B></FONT></TD>" skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Транзакция </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> ID исполнителя </B></FONT></TD>"  skip
                         "<TD bgcolor=""#C0C0C0""><FONT size=""2""><B> Время опер</B></FONT></TD>"  skip
                    "</tr>" skip.
                end.
            end.
            if wrk1.lev = 1 then do:
                find first tot where tot.crc = wrk1.crc.
                if wrk1.crc = 2 then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#e7eaeb""><align=""left""><B>" wrk1.crccode "</B></TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.poz1 + ((wrkk.od + wrkk.pr - wrkk.afn) /*/ wrkk.rate*/),'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(tot.bay,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(tot.sel,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.poz2 + (wrkk.pr1 /*/ wrkk.rate*/),'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                   /* "<TD align=""right"">" replace(trim(string(wrk1.prov,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.vou,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.vtu,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.bay,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.rate,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.sel,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.vo,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.vt,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip*/
                    /*"<TD align=""right"">" replace(trim(string(wrk1.vd,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.vc,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip*/
                    "</TR>" skip.
                    /* вывод провизии */
                    find first wrkk.
                    put stream v-out  unformatted "<TR> <TD align=""left""><B>" "из них по провизиям""</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string((wrkk.od + wrkk.pr - wrkk.afn) /*/ wrkk.rate*/,'->>>>>>>>>>>9.99')),'.',',')"</B></TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(wrkk.pr1 /*/ wrkk.rate*/,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    /* "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                   "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip*/
                   /* "<TD align=""right"">" replace(trim(string(wrkk.od,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrkk.pr,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrkk.pen,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrkk.afn,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrkk.rate,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip*/
                    "</TR>" skip.
                end.
                else do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#e7eaeb""><align=""left""><B>" wrk1.crccode "</B></TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.poz1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(tot.bay,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right""><B>" "</TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(tot.sel,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.poz2,'->>>>>>>>>>>9.99')),'.',',') "</TD></TR>" skip.
                end.
            end.
            if wrk1.lev = 3 then do:
               if wrk1.bay <> 0 or wrk1.sel <> 0 then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#e7eaeb""><align=""left"">" wrk1.fil "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right"">" "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.bay,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right"">" "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right""><B>" replace(trim(string(wrk1.sel,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""right"">"  "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD bgcolor=""#e7eaeb""><align=""center"">" "</TD>" skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD bgcolor=""#e7eaeb""><align=""left"">" "</TD> " skip
                    "<TD align=""left"">" "</TD></TR>" skip.
                end.
            end.
            if wrk1.lev = 4 then do:
                put stream v-out  unformatted "<TR> <TD><align=""left"">" "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.poz1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.bay,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.rate,'->>>>>>>>>>>9.9999')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.sel,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.poz2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" wrk1.gl "</TD>" skip
                "<TD align=""left"">" wrk1.rem "</TD> " skip
                "<TD align=""left"">" wrk1.fio "</TD>" skip
                "<TD align=""left"">" wrk1.corrgl "</TD> " skip
                "<TD align=""left"">" wrk1.corrglname "</TD> " skip
                "<TD align=""left"">" wrk1.doc "</TD> " skip
                "<TD align=""left"">" wrk1.jh "</TD> " skip
                "<TD align=""left"">" wrk1.id "</TD> " skip
                "<TD align=""left"">" string(wrk1.tt,"HH:MM:SS") "</TD></TR>" skip.
            end.
        end.
        put stream v-out unformatted "</table>".
    output stream v-out close.
    unix silent value("cptwin a_rep.html excel").
    hide message no-pause.
    return.
