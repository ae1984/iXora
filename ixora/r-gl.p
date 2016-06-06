/* r-gl.p
 * MODULE
        Обороты по счетам ГК
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-gl2.p
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        10/10/03 kim
 * CHANGES
        14/10/03 nataly  добавила ввод даты отчета + счета ГК
        08.01.2003 nadejda  - переделала на работу через r-branch.i
        03.02.2004 nadejda  - убрано условие на диапазон дат
        19.02.2009 galina - консолидированный отчет только на ЦО
        19/07/2011 madiyar - вывод в excel
        20/07/2011 id00810 - возможность выбора филиала на базе ЦО
        30/11/2011 dmitriy - добавил дополнительный выбор консолид.отчета: 1) в разрезе счетов ГК (как было) 2) в разрезе филиалов
        07/11/2011 dmitriy - на филиалах формируется только первый тип отчета
        14/02/2012 Luiza   - добавила возможность выбора всех счетов
        06/04/2012 Luiza   - вывод код кбе кнп
        02/08/2012 Luiza   - вывод символа кассового плана
        16/10/2012 id00810 -  если конечная дата отчета - текущий день, то обороты за текущий день включаются в подсчет исходящих остатков (ТЗ 1545)
        21/10/2013 Luiza   - ТЗ 2137 добавила столбец признак ДПК
*/

{mainhead.i}

{r-gl.i "new shared"}

def new shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field gl as integer
  field crc as integer
  field crc_code as char
  field jdt as date
  field jh as integer
  field glcorr as integer
  field glcorr_des as char
  field acc_corr as char
  field dam as deci
  field cam as deci
  field dam_KZT as deci
  field cam_KZT as deci
  field rem as char
  field who as char
  field glcorr2 as integer
  field glcorr_des2 as char
  field acc2 as char
  field cod as char
  field kbe as char
  field knp as char
  field rez as char
  field rez1 as char
  field cassp as char
  field DPK as char
  index idx is primary bank gl crc jdt jh.

def new shared temp-table wrk_ost no-undo
  field bank as char
  field gl as integer
  field crc as integer
  field dam_in as deci
  field cam_in as deci
  field dam_out as deci
  field cam_out as deci
  field dam_in_KZT as deci
  field cam_in_KZT as deci
  field dam_out_KZT as deci
  field cam_out_KZT as deci
  index idx is primary bank gl crc.


def var cons_type as int.

define frame f-cons_type
    cons_type label "Тип консолидированного отчета"
    help "1-Разбивка по счетам;  2-Разбивка по филиалам" skip
with side-labels centered row 10.

/* Luiza -------------------------------------------------------------------------------*/
    def var v-all as int.
    def var l as int.
    run sel2 ("Выберите :", " 1. По счету ГК | 2. По всем счетам ГК | 3. Выход ", output v-all).
    if keyfunction (lastkey) = "end-error" then return.
    if (v-all < 1) or (v-all > 2) then return.
    if v-all = 2 then do:
        update
              v-from label "  С" /*validate (12/15/00 <= v-from,
                " В базе информация с  " + string(12/15/00) )*/
                help " Задайте начальную дату отчета" skip
              v-to   label " ПО"
                help " Задайте конечную дату отчета" skip
         with row 8 centered  side-label frame opt1 title "Задайте период отчета и счета ГК (через запятую)".
          hide frame  opt1.
          v-list = "".
          l = 0.
          for each gl  where gl.gl > 0 no-lock.
              if l = 0 then v-list = string(gl.gl). else v-list = v-list + "," + string(gl.gl).
              l = l + 1.
          end.
   end.
/*---------------------------------------------------------------------------------------*/
    else do:
        update
              v-from label "  С" /*validate (12/15/00 <= v-from,
                " В базе информация с  " + string(12/15/00) )*/
                help " Задайте начальную дату отчета" skip
              v-to   label " ПО"
                help " Задайте конечную дату отчета" skip
              v-list label "СЧЕТ ГК" format "x(69)"
             /* validate( can-find(gl where gl.gl eq v-glacc),
             "Счет ГК не найден... ")*/
              help " Введите счета ГК (через запятую)"
         with row 8 centered  side-label frame opt title "Задайте период отчета и счета ГК (через запятую)".

          hide frame  opt.
    end.

/*def var i as int.
def var v-tmpgl as int.*/
def var v-branch as logical init false.

def var v-tdam as deci no-undo.
def var v-tcam as deci no-undo.
def var v-tdam_KZT as deci no-undo.
def var v-tcam_KZT as deci no-undo.
def var v-dam_in as deci no-undo.
def var v-cam_in as deci no-undo.
def var v-dam_out as deci no-undo.
def var v-cam_out as deci no-undo.
def var v-dam_out_KZT as deci no-undo.
def var v-cam_out_KZT as deci no-undo.
def var v-tdam1 as deci no-undo.
def var v-tcam1 as deci no-undo.
def var v-tdam_KZT1 as deci no-undo.
def var v-tcam_KZT1 as deci no-undo.
def var v-td        as logi no-undo.
def var v-aktiv     as logi no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
if txb.is_branch then v-branch = true.
if v-to = g-today then v-td = true.

/*do i = 1 to num-entries(v-list):
    v-tmpgl = int(entry(i, v-list)).
    v-glacc = v-tmpgl.

    for each crc no-lock:
        v-valuta = crc.crc.
        v-valuta_code = crc.code.
*/
        if v-branch = true then do:
            if connected ("txb") then disconnect "txb".
            find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
            connect value(" -db " + replace(txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
            run r-gl2(txb.name).
            if connected ("txb") then disconnect "txb".
        end.
        else do:
            {r-brfilial.i &proc = "r-gl2 (txb.info)"}
        end.
/*    end.
end.*/
if v-select = 1 then
    update cons_type with frame f-cons_type.
else cons_type = 1.
hide frame f-cons_type.

def stream m-out.
output stream m-out to r-gl.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find first cmp no-lock no-error.
put stream m-out unformatted "<br><br>" cmp.name "<br>" skip.

if v-select > 1 then do:
    find first txb where txb.txb = (v-select - 2) no-lock no-error.
    put stream m-out unformatted txb.info "<br>" skip.
end.

if cons_type = 1 then do:
    for each wrk no-lock break by wrk.gl by wrk.crc by wrk.bank :
    /*if first-of(wrk.bank) then do:
        put stream m-out unformatted "<br><br>" wrk.bankn "<br><br>" skip.
    end.*/
    if first-of(wrk.gl) then do:
        put stream m-out unformatted "<br>" "ОБОРОТЫ ПО СЧЕТУ " + string(wrk.gl).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then do:
            v-aktiv = if can-do('A,O,E',gl.type) then true else false.
            put stream m-out unformatted " " + gl.des.
        end.
        put stream m-out unformatted
            "<br>" skip
            "ЗА ПЕРИОД С " v-from " ПО " v-to "<br>" skip.
    end.
    if first-of(wrk.crc) then do:
        assign v-tdam      = 0
               v-tcam      = 0
               v-tdam_KZT  = 0
               v-tcam_KZT  = 0
               v-tdam1     = 0
               v-tcam1     = 0
               v-tdam_KZT1 = 0
               v-tcam_KZT1 = 0.
        put stream m-out unformatted "<br>Валюта: " + wrk.crc_code + "<br>" skip.
        put stream m-out unformatted
            "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
            "<tr><td colspan=7>Входящий остаток </td>" skip.

        if v-select = 1 then
        for each wrk_ost where /*wrk_ost.bank = wrk.bank and*/ wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
            accum wrk_ost.dam_in (total by wrk_ost.gl) wrk_ost.cam_in (total by wrk_ost.gl) wrk_ost.dam_in_KZT (total by wrk_ost.gl) wrk_ost.cam_in_KZT (total by wrk_ost.gl).
            if last-of(wrk_ost.gl) then
            put stream m-out unformatted
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
        end.

        else do:
            find first wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock no-error.
            if avail wrk_ost then do:
                put stream m-out unformatted
                    "<td>" replace(trim(string(wrk_ost.dam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.cam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.dam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.cam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
            else put stream m-out unformatted "<td></td><td></td><td></td><td></td>".
        end.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК Наим</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Корр Счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примеч</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ID</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК Наим2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Корр Счет2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кбе</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КНП</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство <br> КоррГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство <br> КоррГК2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Символ <br> кассплана </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак <br> ДПК </td>"

                  "</tr>" skip.
    end.

    put stream m-out unformatted
              "<tr>"
              "<td>" wrk.jdt "</td>"
              "<td>" wrk.bankn "</td>"
              "<td>" wrk.jh "</td>"
              "<td>" wrk.glcorr "</td>"
              "<td>" wrk.glcorr_des "</td>"
              "<td>&nbsp;" wrk.acc_corr "</td>"
              "<td>" wrk.crc_code "</td>"
              "<td>" replace(trim(string(wrk.dam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.dam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" wrk.rem "</td>"
              "<td>" wrk.who "</td>"
              "<td>" wrk.glcorr2 "</td>"
              "<td>" wrk.glcorr_des2 "</td>"
              "<td>" wrk.acc2 "</td>"
              "<td>" wrk.cod "</td>"
              "<td>" wrk.kbe "</td>"
              "<td>" wrk.knp "</td>"
              "<td align=""center"">" wrk.rez "</td>"
              "<td align=""center"">" wrk.rez1 "</td>"
              "<td align=""center"">" wrk.cassp "</td>"
              "<td align=""center"">" wrk.DPK "</td>"
              "</tr>" skip.

    v-tdam = v-tdam + wrk.dam. v-tcam = v-tcam + wrk.cam.
    v-tdam_KZT = v-tdam_KZT + wrk.dam_KZT. v-tcam_KZT = v-tcam_KZT + wrk.cam_KZT.
    if v-td and wrk.jdt = g-today
    then assign
        v-tdam1 = v-tdam1 + wrk.dam
        v-tcam1 = v-tcam1 + wrk.cam
        v-tdam_KZT1 = v-tdam_KZT1 + wrk.dam_KZT
        v-tcam_KZT1 = v-tcam_KZT1 + wrk.cam_KZT.

    if last-of(wrk.crc) then do:
        put stream m-out unformatted
              "<tr>"
              "<td colspan=7>ИТОГО ОБОРОТЫ</td>"
              "<td>" replace(trim(string(v-tdam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tdam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td></td>"
              "<td></td>"
              "</tr>" skip.
        put stream m-out unformatted "</table><br>" skip.
        put stream m-out unformatted
            "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
            "<tr><td colspan=7>Исходящий остаток </td>" skip.
        if v-select = 1 then
        for each wrk_ost where /*wrk_ost.bank = wrk.bank and*/ wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
            accum wrk_ost.dam_out (total by wrk_ost.gl) wrk_ost.cam_out (total by wrk_ost.gl) wrk_ost.dam_out_KZT (total by wrk_ost.gl) wrk_ost.cam_out_KZT (total by wrk_ost.gl).
            if last-of(wrk_ost.gl) then do:
                if v-aktiv then
                put stream m-out unformatted
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out)  + v-tdam1 - v-tcam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT) + v-tdam_kzt1 - v-tcam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                else
                put stream m-out unformatted
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out) + v-tcam1 - v-tdam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT) + v-tcam_kzt1 - v-tdam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
        end.

        else do:
            find first wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock no-error.
            if avail wrk_ost then do:
                if v-aktiv then
                put stream m-out unformatted
                "<td>" replace(trim(string(wrk_ost.dam_out + v-tdam1 - v-tcam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.dam_out_KZT + v-tdam_kzt1 - v-tcam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                else
                put stream m-out unformatted
                "<td>" replace(trim(string(wrk_ost.dam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out + v-tcam1 - v-tdam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.dam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out_KZT + v-tcam_kzt1 - v-tdam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
            else put stream m-out unformatted "<td></td><td></td><td></td><td></td>".
        end.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
    end.
end.
end. /*if cons_type = 1*/

if cons_type = 2 then do:
    /*----- Входящие и исходящие остатки по всем филиалам -----*/
    def var v-dam-in as deci.
    def var v-cam-in as deci.
    def var v-dam-inKZT as deci.
    def var v-cam-inKZT as deci.

    def var v-tdamKZT as deci.
    def var v-tcamKZT as deci.

    def var v-dam-out as deci.
    def var v-cam-out as deci.
    def var v-dam-outKZT as deci.
    def var v-cam-outKZT as deci.

    put stream m-out unformatted
        "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
        "<tr><td colspan=""14"">Все филиалы</td></tr>"
        "<tr bgcolor=""#C0C0C0"">
        <td rowspan=""2"">Счет ГК</td>
        <td rowspan=""2"">Валюта</td>
        <td colspan=""4"">Входящий остаток</td>
        <td colspan=""4"">Итого обороты</td>
        <td colspan=""4"">Исходящий остаток</td></tr>
        <tr bgcolor=""#C0C0C0"">
        <td>Дт</td><td>Кт</td><td>Дт_KZT</td><td>Кт_KZT</td>
        <td>Дт</td><td>Кт</td><td>Дт_KZT</td><td>Кт_KZT</td>
        <td>Дт</td><td>Кт</td><td>Дт_KZT</td><td>Кт_KZT</td>
        </tr></table>" skip.

    assign v-dam-in     = 0
           v-cam-in     = 0
           v-dam-inKZT  = 0
           v-cam-inKZT  = 0
           v-tdam       = 0
           v-tcam       = 0
           v-tdamKZT    = 0
           v-tcamKZT    = 0
           v-dam-out    = 0
           v-cam-out    = 0
           v-dam-outKZT = 0
           v-cam-outKZT = 0
           v-tdam1      = 0
           v-tcam1      = 0
           v-tdam_KZT1  = 0
           v-tcam_KZT1  = 0.
    for each wrk_ost break by wrk_ost.gl by wrk_ost.crc:
        v-dam-in = v-dam-in + wrk_ost.dam_in.
        v-cam-in = v-cam-in + wrk_ost.cam_in.
        v-dam-inKZT = v-dam-inKZT + wrk_ost.dam_in_KZT.
        v-cam-inKZT = v-cam-inKZT + wrk_ost.cam_in_KZT.

        v-dam-out = v-dam-out + wrk_ost.dam_out.
        v-cam-out = v-cam-out + wrk_ost.cam_out.
        v-dam-outKZT = v-dam-outKZT + wrk_ost.dam_out_KZT.
        v-cam-outKZT = v-cam-outKZT + wrk_ost.cam_out_KZT.

        if last-of(wrk_ost.crc) then do:
            for each wrk where wrk.crc = wrk_ost.crc break by wrk.crc:
                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then v-aktiv = if can-do('A,O,E',gl.type) then true else false.
                v-tdam = v-tdam + wrk.dam.
                v-tcam = v-tcam + wrk.cam.
                v-tdamKZT = v-tdamKZT + wrk.dam_KZT.
                v-tcamKZT = v-tcamKZT + wrk.cam_KZT.
                if v-td and wrk.jdt = g-today
                then assign
                v-tdam1 = v-tdam1 + wrk.dam
                v-tcam1 = v-tcam1 + wrk.cam
                v-tdam_KZT1 = v-tdam_KZT1 + wrk.dam_KZT
                v-tcam_KZT1 = v-tcam_KZT1 + wrk.cam_KZT.
            end.
            find first crc where crc.crc = wrk_ost.crc no-lock no-error.
            put stream m-out unformatted
            "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" "<tr>"
            "<td>" wrk_ost.gl "</td>"
            "<td>" crc.code "</td>"

            "<td>" replace(string(v-dam-in), '.',',') "</td>"
            "<td>" replace(string(v-cam-in), '.',',') "</td>"
            "<td>" replace(string(v-dam-inKZT), '.',',') "</td>"
            "<td>" replace(string(v-cam-inKZT), '.',',') "</td>"

            "<td>" replace(string(v-tdam), '.',',') "</td>"
            "<td>" replace(string(v-tcam), '.',',') "</td>"
            "<td>" replace(string(v-tdamKZT), '.',',') "</td>"
            "<td>" replace(string(v-tcamKZT), '.',',') "</td>".
            if v-aktiv then put stream m-out unformatted
            "<td>" replace(string(v-dam-out + v-tdam1 - v-tcam1), '.',',') "</td>"
            "<td>" replace(string(v-cam-out), '.',',') "</td>"
            "<td>" replace(string(v-dam-outKZT + v-tdam_KZT1 - v-tcam_KZT1), '.',',') "</td>"
            "<td>" replace(string(v-cam-outKZT), '.',',') "</td>".
            else put stream m-out unformatted
            "<td>" replace(string(v-dam-out), '.',',') "</td>"
            "<td>" replace(string(v-cam-out + v-tcam1 - v-tdam1), '.',',') "</td>"
            "<td>" replace(string(v-dam-outKZT), '.',',') "</td>"
            "<td>" replace(string(v-cam-outKZT + v-tcam_KZT1 - v-tdam_KZT1), '.',',') "</td>".
            put stream m-out unformatted
            "</tr></table>".
            v-dam-in = 0. v-cam-in = 0. v-dam-inKZT = 0. v-cam-inKZT = 0.
            v-tdam = 0. v-tcam = 0. v-tdamKZT = 0. v-tcamKZT = 0.
            v-dam-out = 0. v-cam-out = 0. v-dam-outKZT = 0. v-cam-outKZT = 0.
            v-tdam1 = 0. v-tcam1 = 0. v-tdam_KZT1 = 0. v-tcam_KZT1 = 0.
        end.
    end.
    /*---------------------------------------------------------*/
for each wrk no-lock break by wrk.bank by wrk.gl by wrk.crc:
    if first-of(wrk.bank) then do:
        put stream m-out unformatted "<br><br>" wrk.bankn "<br><br>" skip.
    end.
    if first-of(wrk.gl) then do:
        put stream m-out unformatted "<br>" "ОБОРОТЫ ПО СЧЕТУ " + string(wrk.gl).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then do:
            v-aktiv = if can-do('A,O,E',gl.type) then true else false.
            put stream m-out unformatted " " + gl.des.
        end.
        put stream m-out unformatted
            "<br>" skip
            "ЗА ПЕРИОД С " v-from " ПО " v-to "<br>" skip.
    end.
    if first-of(wrk.crc) then do:
        assign v-tdam      = 0
               v-tcam      = 0
               v-tdam_KZT  = 0
               v-tcam_KZT  = 0
               v-tdam1     = 0
               v-tcam1     = 0
               v-tdam_KZT1 = 0
               v-tcam_KZT1 = 0.

        put stream m-out unformatted "<br>Валюта: " + wrk.crc_code + "<br>" skip.
        put stream m-out unformatted
            "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
            "<tr><td colspan=7>Входящий остаток </td>" skip.

        if v-select = 1 then
        for each wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
            accum wrk_ost.dam_in (total by wrk_ost.gl) wrk_ost.cam_in (total by wrk_ost.gl) wrk_ost.dam_in_KZT (total by wrk_ost.gl) wrk_ost.cam_in_KZT (total by wrk_ost.gl).
            if last-of(wrk_ost.gl) then
            put stream m-out unformatted
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
            "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
        end.

        else do:
            find first wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock no-error.
            if avail wrk_ost then do:
                put stream m-out unformatted
                    "<td>" replace(trim(string(wrk_ost.dam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.cam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.dam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(wrk_ost.cam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
            else put stream m-out unformatted "<td></td><td></td><td></td><td></td>".
        end.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК Наим</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Корр Счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примеч</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ID</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК2 Наим</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кбе</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КНП</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство<br> КоррГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство<br> КоррГК2</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Символ <br> кассплана</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Признак<br> ДПК</td>"
                  "</tr>" skip.
    end.

    put stream m-out unformatted
              "<tr>"
              "<td>" wrk.jdt "</td>"
              "<td>" wrk.bankn "</td>"
              "<td>" wrk.jh "</td>"
              "<td>" wrk.glcorr "</td>"
              "<td>" wrk.glcorr_des "</td>"
              "<td>&nbsp;" wrk.acc_corr "</td>"
              "<td>" wrk.crc_code "</td>"
              "<td>" replace(trim(string(wrk.dam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.dam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" wrk.rem "</td>"
              "<td>" wrk.who "</td>"
              "<td>" wrk.glcorr2 "</td>"
              "<td>" wrk.glcorr_des2 "</td>"
              "<td>" wrk.cod "</td>"
              "<td>" wrk.kbe "</td>"
              "<td>" wrk.knp "</td>"
              "<td align=""center"">" wrk.rez "</td>"
              "<td align=""center"">" wrk.rez1 "</td>"
              "<td align=""center"">" wrk.cassp "</td>"
              "<td align=""center"">" wrk.DPK "</td>"
              "</tr>" skip.

    assign v-tdam = v-tdam + wrk.dam
           v-tcam = v-tcam + wrk.cam
           v-tdam_KZT = v-tdam_KZT + wrk.dam_KZT
           v-tcam_KZT = v-tcam_KZT + wrk.cam_KZT.
    if v-td and wrk.jdt = g-today
    then assign
        v-tdam1 = v-tdam1 + wrk.dam
        v-tcam1 = v-tcam1 + wrk.cam
        v-tdam_KZT1 = v-tdam_KZT1 + wrk.dam_KZT
        v-tcam_KZT1 = v-tcam_KZT1 + wrk.cam_KZT.

    if last-of(wrk.crc) then do:
        put stream m-out unformatted
              "<tr>"
              "<td colspan=7>ИТОГО ОБОРОТЫ</td>"
              "<td>" replace(trim(string(v-tdam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tdam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td></td>"
              "<td></td>"
              "</tr>" skip.
        put stream m-out unformatted "</table><br>" skip.
        put stream m-out unformatted
            "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
            "<tr><td colspan=7>Исходящий остаток </td>" skip.
        if v-select = 1 then
        for each wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
            accum wrk_ost.dam_out (total by wrk_ost.gl) wrk_ost.cam_out (total by wrk_ost.gl) wrk_ost.dam_out_KZT (total by wrk_ost.gl) wrk_ost.cam_out_KZT (total by wrk_ost.gl).
            if last-of(wrk_ost.gl) then do:
                if v-aktiv then
                put stream m-out unformatted
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out) + v-tdam1 - v-tcam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT) + v-tdam_kzt1 - v-tcam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                else
                put stream m-out unformatted
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out) + v-tcam1 - v-tdam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT) + v-tcam_kzt1 - v-tdam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
        end.

        else do:
            find first wrk_ost where wrk_ost.bank = wrk.bank and wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock no-error.
            if avail wrk_ost then do:
                if v-aktiv then
                put stream m-out unformatted
                "<td>" replace(trim(string(wrk_ost.dam_out + v-tdam1 - v-tcam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.dam_out_KZT + v-tdam_kzt1 - v-tcam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                else
                put stream m-out unformatted
                "<td>" replace(trim(string(wrk_ost.dam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out + v-tcam1 - v-tdam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.dam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(wrk_ost.cam_out_KZT + v-tcam_kzt1 - v-tdam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.
            else put stream m-out unformatted "<td></td><td></td><td></td><td></td>".
        end.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
    end.
end.

end. /*if cons_type = 2*/

output stream m-out close.
unix silent cptwin r-gl.htm excel.

