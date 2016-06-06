/* repbonus1.p
 * MODULE
        Операционный модуль
 * DESCRIPTION
        Отчет о зарег-х пользователях в Internet Banking за период.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.5.4
 * AUTHOR
        24.01.2011 Luiza
 * BASES
        BANK COMM IB
 * CHANGES
        29.12.2011 id00004 добавил столбец Вид доступа
*/


def var v-dt1 as date.
def var v-dt2 as date.
def var v-filial as char no-undo.
def var v-txb as char no-undo.
def var v-ntxb as char no-undo.
def var v-who as char no-undo.
def var v-sel as int init 1.
def stream v-out.

def new shared temp-table tempofc no-undo
    field ofc as char
    field oname as char
index ind is primary ofc.

message "Ждите идет подготовка данных для отчета".

run totalofc1 (output v-sel).
/* сбор данных*/
def frame f-date
   v-dt1 label "Начало"  skip
   v-dt2 label "Конец "  skip
   /*cboname label "Филиал " skip */
with side-labels centered row 7 title "Параметры отчета".
update  v-dt1 v-dt2 with frame f-date.
message "Ждите идет подготовка данных для отчета".

def new shared temp-table wrk no-undo
    field txb like  webra.txb
    field ntxb like  txb.name
    field login like webra.login
    field cif like usr.cif
    field ncif like usr.contact[1]
    field jdt like webra.jdt
    field who like webra.who
    field nofc as char
    field teg as char
index ind is primary ntxb who jdt.

if v-sel = 1 then do:
    for each webra where webra.jdt >= v-dt1 and webra.jdt <= v-dt2 no-lock, usr where webra.login = usr.login no-lock, txb where  txb.bank = webra.txb no-lock.
        create wrk.
        wrk.txb = webra.txb.
        wrk.ntxb = txb.name.
        wrk.login = webra.login.
        wrk.cif = usr.cif.
        wrk.ncif = usr.contact[1].
        wrk.jdt = webra.jdt.
        wrk.who = webra.who.
        wrk.nofc = "".
        wrk.teg = webra.info[7].
    end.
end.
else do:
    find first txb where txb.txb = v-sel - 2 no-lock.
    if available txb then do:
        v-txb = txb.bank.
        v-ntxb = txb.name.
        for each webra where webra.txb = v-txb and  webra.jdt >= v-dt1 and webra.jdt <= v-dt2 no-lock, usr where webra.login = usr.login no-lock.
            create wrk.
        wrk.txb = webra.txb.
        wrk.ntxb = txb.name.
        wrk.login = webra.login.
        wrk.cif = usr.cif.
        wrk.ncif = usr.contact[1].
        wrk.jdt = webra.jdt.
        wrk.who = webra.who.
        wrk.nofc = "".
        wrk.teg = webra.info[7].
        end.
    end.
end.
for each wrk no-lock.
    v-who = wrk.who.
    find first tempofc where tempofc.ofc = v-who no-lock no-error.
    if available tempofc then wrk.nofc = tempofc.oname.
end.


/* вывод отчета*/

output stream v-out to repbonus.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h3>Отчет о зарегистрированных пользователях в Internet Banking за период с " string( v-dt1) " по " string(v-dt2) "</h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.


    put stream v-out unformatted "<tr align=center>"
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Наименование<br>филиала </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Логин<br>клиента </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> CIF<br>(код клиента) </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Наименование<br>клиента </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата<br>регистрации </B></FONT></TD>" skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ID сотрудн </B></FONT></TD>" skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Ф.И.О. сотрудника </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Вид доступа </B></FONT></TD>"  skip
    "</tr>" skip.
    for each wrk no-lock.
wrk.teg = replace(wrk.teg,"<", "" ).
wrk.teg = replace(wrk.teg,">", "" ).

        put stream v-out  unformatted "<TR> <TD align=""left"">" wrk.ntxb "</TD>" skip                                       /* филиал */
                        "<TD align=""center"">" wrk.login "</TD>" skip                                       /* login */
                        "<TD align=""center"">" wrk.cif "</TD>" skip                                       /* CIF */
                        "<TD align=""left"">" wrk.ncif "</TD>" skip                                       /* наимен клиента */
                        "<TD align=""left"">" wrk.jdt "</TD>" skip                                       /* Дата рег */
                        "<TD align=""left"">" wrk.who "</TD>" skip                                       /* id менедж */
                        "<TD align=""left"">" wrk.nofc "</TD> " skip                                     /* фио менедж */
                        "<TD align=""left"">" replace(wrk.teg,"<", "" ) "</TD> </TR>" skip.                                     /* фио менедж */
    end.
    put stream v-out unformatted "</table>".

    output stream v-out close.
    unix silent value("cptwin repbonus.html excel").
    hide message no-pause.
    return.

	