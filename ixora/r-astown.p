/* r-astown.p
 * MODULE
	Основные средства
 * DESCRIPTION
	 Ведомость основных средств закрепленных за сотрудником
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
        24/05/2013 Luiza - ТЗ 1842

 * CHANGES
        19/06/2013 Luiza - ТЗ 1902
        20/06/2013 Luiza - перекомпиляци
*/

def var bsum$ as dec format "->>>,>>>,>>9.99" 	no-undo.
def var isum$ as dec format "->>>,>>>,>>9.99" 	no-undo.
def var ic$ as int no-undo.
def var i$ as int format ">>>>>." init 1 	no-undo.
def var i1$ as int format ">>>>>" 		no-undo.
def var gr$ as char format "x(3)" 		no-undo.
def var q$ as int format ">>>>>" 		no-undo.
def var qacc$ as int format ">>>>>" 		no-undo.
def var v-attn as char format "x(3)" 		no-undo.
def var v-file as char init "inv3.htm" 		no-undo.
def var v-ek as int no-undo.
def var v-own as char no-undo.
def var v-ofc as char no-undo.
def var v-fio as char no-undo.
define var v-attnn as char.

def stream r-out.

{global.i}
 find first cmp no-lock no-error.

def var repdt as date no-undo.
repdt = g-today.

define temp-table tempast
    field ast      as char
    field dtown    as date
    field own      as char
    field ofcname  as char
    field gl       as int
    field fag      as char
    field naim     as char
    field addr     as char
    field name     as char
    field qty      as decim
    field rdt      as date
    field noy      as int
    field dam1     as decim
    field cam1     as decim
    field dam3     as decim
    field cam3     as decim
    field attn     as char
    field attnn    as char
    field nal      as char
    index own is primary own.


run sel2 ("Выберите :", " 1. По одному сотруднику   | 2. По всем сотрудникам | 3. Выход ", output v-ek).
if keyfunction (lastkey) = "end-error" then return.
if (v-ek < 1) or (v-ek > 2) then return.
form repdt label "Введите дату " validate(repdt <= g-today, "Неверная дата")  with frame fr row 5 overlay column 5.
update repdt with frame fr.
if v-ek = 1 then do:
    define temp-table tempofc
        field ofc  as   char
        field name as   char
        index id is primary name.
    empty temp-table tempofc.
    for each ofc where ofc.ofc begins "id" no-lock.
        find first ofcblok where ofcblok.ofc = ofc.ofc and ofcblok.sts = "u" no-lock no-error.
        if not available ofcblok then do:
            create tempofc.
            tempofc.ofc = ofc.ofc.
            tempofc.name = ofc.name.
        end.
    end.
    for each astofc  no-lock.
        create tempofc.
        tempofc.ofc = astofc.id.
        tempofc.name = astofc.fio.
    end.

    DEFINE QUERY q-ofc FOR tempofc .

    DEFINE BROWSE b-ofc QUERY q-ofc
           DISPLAY tempofc.name label "       ФИО   " format "x(30)" tempofc.ofc label "id сотруд" format "x(8)"
           WITH  15 DOWN.
    DEFINE FRAME f-ofc b-ofc  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 25 width 75 NO-BOX.

    form v-fio label "Введите начальные буквы фамилии "   with frame fr1 row 9 overlay column 5.

    update v-fio with frame fr1.
    v-ofc = "".
    OPEN QUERY  q-ofc FOR EACH tempofc where tempofc.name begins v-fio no-lock.
    ENABLE ALL WITH FRAME f-ofc.
    wait-for return of frame f-ofc
    FOCUS b-ofc IN FRAME f-ofc.
    v-own = tempofc.ofc.
    v-ofc = tempofc.name.
    if v-ofc = "" then do:
        message "Сотрудник не выбран!" view-as alert-box.
        return.
    end.
    hide frame f-ofc.
    displ "Ждите идет сбор данных.....".
    pause 0.
    for each ast where ast.own = v-own no-lock.
        find last astown where astown.ast = ast.ast and astown.whn <= repdt no-lock no-error .
        if available astown and astown.own = v-own then do:
            create tempast.
            tempast.ast      = ast.ast.
            tempast.dtown    = astown.whn.
            tempast.own      = astown.own.
            find first ofc where ofc.ofc = astown.own no-lock no-error.
            if available ofc then tempast.ofcname = ofc.name.
            else do:
                find first astofc where astofc.id = astown.own no-lock no-error.
                if available astofc then tempast.ofcname = astofc.fio.
            end.
            tempast.gl       = ast.gl.
            tempast.fag      = ast.fag.
            find first fagn where fagn.fag = ast.fag no-lock no-error.
            tempast.naim     = fagn.naim.
            tempast.addr     = ast.addr[2].
            tempast.name     = ast.name.
            tempast.qty      = ast.qty .
            tempast.rdt      = ast.rdt.
            tempast.noy      = ast.noy.
            tempast.dam1     = ast.dam[1].
            tempast.cam1     = ast.cam[1].
            tempast.dam3     = ast.dam[3].
            tempast.cam3     = ast.cam[3].
            tempast.attn     = ast.attn.
            find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
            if available codfr then tempast.attnn = codfr.name[1].
            tempast.nal      = "".
        end.
    end.

    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream r-out unformatted "<br><br>  АО 'ForteBank' <br>" skip.
    put stream r-out unformatted "<br>" "ВЕДОМОСТЬ ОСНОВНЫХ СРЕДСТВ закрепленных за " + v-ofc + " на " + string(repdt) "<br>" skip.

        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
          "<tr>"
          "<td align=""center"" valign=""top""> Закреплен за </td>"
          "<td align=""center"" valign=""top""> Дата <br> закреплен </td>"
          "<td align=""center"" valign=""top""> Счет </td>"
          "<td align=""center"" valign=""top""> Группа</td>"
          "<td align=""center"" valign=""top""> Номер  <br> карточки</td>"
          "<td align=""center"" valign=""top""> Инв. номер</td>"
          "<td align=""center"" valign=""top""> Наименование </td>"
          "<td align=""center"" valign=""top""> Кол-во </td>"
          "<td align=""center"" valign=""top""> дата  <br> регистрации</td>"
          "<td align=""center"" valign=""top""> Срок износа </td>"
          "<td align=""center"" valign=""top""> балансовая  <br> стоимость в тенге </td>"
          "<td align=""center"" valign=""top""> Начислен.  <br> амортиз-я в тенге </td>"
          "<td align=""center"" valign=""top""> Остат  <br> стоим-ть в тенге </td>"
          /*"<td align=""center"" valign=""top""> Фонд переоценки </td>"*/
          "<td align=""center"" valign=""top""> Профит центр </td>"
          /*"<td align=""center"" valign=""top""> Налоговый  <br> комитет </td>"*/
          "</tr>" skip.
        for each tempast no-lock use-index own break by tempast.own .
            put stream r-out unformatted "<tr>".
            if first-of(tempast.own) then do:
                put stream r-out unformatted "<td>" tempast.own " " tempast.ofcname "</td>".
            end.
            else put stream r-out unformatted "<td>" "</td>".
            put stream r-out unformatted "<td>" tempast.dtown "</td>"
            "<td>" tempast.gl "</td>"
            "<td>" tempast.fag  " " tempast.naim "</td>"
            "<td>" tempast.ast "</td>"
            "<td>" tempast.addr "</td>"
            "<td>" tempast.name "</td>"
            "<td>" tempast.qty "</td>"
            "<td>" tempast.rdt "</td>"
            "<td>" tempast.noy "</td>"
            "<td>" replace(trim(string(tempast.dam1 - tempast.cam1, ">>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(tempast.cam3 - tempast.dam3, ">>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string((tempast.dam1 - tempast.cam1) - (tempast.cam3 - tempast.dam3), ">>>>>>>>>>9.99")),'.',',') "</td>"
            /*"<td>" "</td>"*/
            "<td>" tempast.attn " " tempast.attnn "</td>"
            /*"<td>" "</td>"*/
            "</tr>" skip.
        end.
        put stream r-out unformatted "</table>" skip.
end.
if v-ek = 2 then do:
    displ "Ждите идет сбор данных.....".
    pause 0.
    for each ast where ast.own <> "" no-lock.
        create tempast.
        tempast.ast      = ast.ast.
        find last astown where astown.ast = ast.ast and astown.whn <= repdt  no-lock no-error .
        if available astown then assign tempast.dtown = astown.whn tempast.own = astown.own.
        else assign tempast.dtown = ast.whnown tempast.own = ast.own.
        find first ofc where ofc.ofc = astown.own no-lock no-error.
        if available ofc then tempast.ofcname  = ofc.name.
        else do:
            find first astofc where astofc.id = astown.own no-lock no-error.
            if available astofc then tempast.ofcname = astofc.fio.
        end.
        tempast.gl       = ast.gl.
        tempast.fag      = ast.fag.
        find first fagn where fagn.fag = ast.fag no-lock no-error.
        tempast.naim     = fagn.naim.
        tempast.addr     = ast.addr[2].
        tempast.name     = ast.name.
        tempast.qty      = ast.qty .
        tempast.rdt      = ast.rdt.
        tempast.noy      = ast.noy.
        tempast.dam1     = ast.dam[1].
        tempast.cam1     = ast.cam[1].
        tempast.dam3     = ast.dam[3].
        tempast.cam3     = ast.cam[3].
        tempast.attn     = ast.attn.
        find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
        if available codfr then tempast.attnn = codfr.name[1].
    end.
    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream r-out unformatted "<br><br>  АО 'ForteBank' <br>" skip.
    put stream r-out unformatted "<br>" "ВЕДОМОСТЬ ОСНОВНЫХ СРЕДСТВ закрепленных за сотрудниками филиала " + cmp.name + " на " + string(repdt) "<br>" skip.

    put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
      "<tr>"
      "<td align=""center"" valign=""top""> Закреплен за </td>"
      "<td align=""center"" valign=""top""> Дата <br> закреплен </td>"
      "<td align=""center"" valign=""top""> Счет </td>"
      "<td align=""center"" valign=""top""> Группа</td>"
      "<td align=""center"" valign=""top""> Номер  <br> карточки</td>"
      "<td align=""center"" valign=""top""> Инв. номер</td>"
      "<td align=""center"" valign=""top""> Наименование </td>"
      "<td align=""center"" valign=""top""> Кол-во </td>"
      "<td align=""center"" valign=""top""> дата  <br> регистрации</td>"
      "<td align=""center"" valign=""top""> Срок износа </td>"
      "<td align=""center"" valign=""top""> балансовая  <br> стоимость в тенге </td>"
      "<td align=""center"" valign=""top""> Начислен.  <br> амортиз-я в тенге </td>"
      "<td align=""center"" valign=""top""> Остат  <br> стоим-ть в тенге </td>"
      /*"<td align=""center"" valign=""top""> Фонд переоценки </td>"*/
      "<td align=""center"" valign=""top""> Профит центр </td>"
      /*"<td align=""center"" valign=""top""> Налоговый  <br> комитет </td>"*/
      "</tr>" skip.
        for each tempast no-lock use-index own break by tempast.own .
            put stream r-out unformatted
            "<tr>".
            put stream r-out unformatted "<td>" tempast.own " " tempast.ofcname "</td>".
            put stream r-out unformatted "<td>" tempast.dtown "</td>"
            "<td>" tempast.gl "</td>"
            "<td>" tempast.fag  " " tempast.naim "</td>"
            "<td>" tempast.ast "</td>"
            "<td>" tempast.addr "</td>"
            "<td>" tempast.name "</td>"
            "<td>" tempast.qty "</td>"
            "<td>" tempast.rdt "</td>"
            "<td>" tempast.noy "</td>"
            "<td>" replace(trim(string(tempast.dam1 - tempast.cam1, ">>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(tempast.cam3 - tempast.dam3, ">>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string((tempast.dam1 - tempast.cam1) - (tempast.cam3 - tempast.dam3), ">>>>>>>>>>9.99")),'.',',') "</td>"
            /*"<td>" "</td>"*/
            "<td>" tempast.attn " " tempast.attnn "</td>"
            /*"<td>" "</td>"*/
            "</tr>" skip.
        end.
        put stream r-out unformatted "</table>" skip.
end.

output stream r-out close.

unix silent cptwin fin.htm excel.
pause 0.