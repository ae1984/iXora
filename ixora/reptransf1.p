/* reptransf1.p
 * MODULE
        Операционный модуль
 * DESCRIPTION
        Количество отправленных переводов.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.18
 * AUTHOR
        24.01.2011 Luiza
 * BASES
        BANK comm
 * CHANGES
*/


def new shared var v-dt1 as date.
def new shared var v-dt2 as date.
def new shared var v-fil-cnt as int.
def var ll as char no-undo.
def var cnt as int init 0.
def var cnt_total as int init 0.
def var v-txb as char no-undo .
def var v-ntxb as char no-undo.
def var v-who as char format "x(6)" no-undo.
def var v-nofc as char no-undo.
def var cbo as char init "По всем филиалам".

def stream v-out.
define new shared temp-table wrk no-undo
    field txb as char
    field ntxb as char
    field who as char
    field jdt as date
    field nofc as char
index ind1 is primary txb who.

def new shared temp-table tempofc no-undo
    field ofc as char
    field oname as char
index ind is primary ofc.

def frame f-date
   v-dt1 label "Начало"  skip
   v-dt2 label "Конец "  skip
   with side-labels centered row 7 title "Параметры отчета".

update  v-dt1 v-dt2  with frame f-date.
/* сбор данных*/
run txbs ("rpttransf").

/* вывод отчета*/
output stream v-out to reptransf.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h3>Количество отправленных менеджером переводов за период с " string(v-dt1) " по " string(v-dt2) "</h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:12px"">" skip.

    put stream v-out unformatted "<tr align=center>"
     "<TD bgcolor=""#95B2D1""><FONT size=""4""><B> Наименование<br>филиала </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""4""><B> ID сотрудн </B></FONT></TD>" skip
         "<TD bgcolor=""#95B2D1""><FONT size=""4""><B> Ф.И.О. сотрудника </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""4""><B> Количество<br>переводов </B></FONT></TD>" skip
    "</tr>" skip.
    find first wrk  no-lock no-error.
    if available wrk then do:
        v-txb = wrk.txb.
        v-ntxb = wrk.ntxb.
        v-who = wrk.who.
        v-nofc = wrk.nofc.
        for each wrk no-lock.
            if wrk.txb = v-txb and wrk.who = v-who then  do:
                cnt = cnt + 1.
                cnt_total = cnt_total + 1.
            end.
            else do:
                if  available wrk then do:
                    put stream v-out  unformatted "<TR> <TD align=""left"">" v-ntxb "</TD>" skip    /* филиал */
                            "<TD align=""left"">" v-who "</TD>" skip           /* id менедж */
                            "<TD align=""left"">" v-nofc "</TD>" skip   /* фио менедж */
                            "<TD align=""center"">" cnt "</TD> </TR>" skip.     /* count */
                    v-txb = wrk.txb.
                    v-ntxb = wrk.ntxb.
                    v-who = wrk.who.
                    v-nofc = wrk.nofc.
                    cnt = 1.
                    cnt_total = cnt_total + 1.
                end.
             end.
        end. /*end for each wrk*/
    end. /* end if available wrk then do */
put stream v-out  unformatted "<TR> <TD align=""left"">" v-ntxb "</TD>" skip    /* филиал */
        "<TD align=""left"">" v-who "</TD>" skip           /* id менедж */
        "<TD align=""left"">" v-nofc "</TD>" skip   /* фио менедж */
        "<TD align=""center"">" cnt "</TD> </TR>" skip.     /* count */
put stream v-out  unformatted "<TR> <TD>" "</TD>" skip
        "<TD>" "</TD>" skip
        "<TD>" "Итого" "</TD>" skip
        "<TD align=""center"">" cnt_total "</TD> </TR>" skip.     /* total count */
    put stream v-out unformatted "</table>".


    output stream v-out close.
    unix silent value("cptwin reptransf.html excel").



