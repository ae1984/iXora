/* prisvhist.p
 * MODULE
        Особые отношения
 * DESCRIPTION
        Формирование отчёта по истории посещений
 * BASES
        BANK COMM
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
        30/04/2008 alex
 * CHANGES
        07/05/2008 alex - добавил COMM
       
*/

def stream v-out.
output stream v-out to hist.html.

put stream v-out unformatted
    "<html><title>Отчет по истории посещений</title><META http-equiv=Content-Type content=""text/html; charset=windows-1251""><body>" skip
    "<table border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
    "<tr align= center valign= top style= font:bold; font-size:xx-small bgcolor= #C0C0C0><td width= 10%>Офицер</td>" skip
    "<td>Дата</td>" skip
    "<td>Время</td>" skip
    "<td%>Операция</td></tr>" skip.

def var dt1 as date no-undo.
def var dt2 as date no-undo.

def frame dat.

dt2 = today.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.
hide frame dat.
    
    for each svhist where (svhist.rdt ge dt1) and (svhist.rdt le dt2) no-lock.
        put stream v-out unformatted
            "<tr><td>" + svhist.rwho + "</td>" skip
            "<td>" + string(svhist.rdt, "99/99/9999") + "</td>" skip
            "<td>" + string(svhist.rtm, "hh:mm:ss") + "</td>" skip
            "<td>".
            
        if svhist.toprt = "edt" then 
            put stream v-out unformatted "Редактирование".
                
        if svhist.toprt = "add" then
            put stream v-out unformatted
                "Добавление. РНН: " + entry(1, svhist.oprt, "|") + ", Наименование/ФИО: " + entry(2, svhist.oprt, "|").
                
        if svhist.toprt = "del" then
            put stream v-out unformatted
                "Удаление. РНН: " + entry(1, svhist.oprt, "|") + ", Наименование/ФИО: " + entry(2, svhist.oprt, "|").
                
        if svhist.toprt = "sea" then
            put stream v-out unformatted
                "Поиск. Поле: """ + entry(1, svhist.oprt, "|") + """, значение: """ + entry(2, svhist.oprt, "|") + """, результат: """ + entry(3, svhist.oprt, "|") + """".
        
        put stream v-out unformatted "</td></tr>".
    end.
    
    put stream v-out unformatted
    "</table></body></html>"skip.
output stream v-out close.
unix silent cptwin hist.html excel.