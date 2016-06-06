/* pcglprov.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Отчет по авоматическим проводкам по файлу GL
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        16-3-2
 * AUTHOR
        02/11/12 id00810
 * CHANGES
 */

{mainhead.i}
def var v-bank as char no-undo.
def var v-from as date no-undo.
def var v-to   as date no-undo.
def var v-jh   as char no-undo.
/*def temp-table wrk no-undo
  field bank as char
  field crc as integer
  field crc_code as char
  field jdt as date
  field jh as integer
  field dacc as char
  field dacc as char
  field dam as deci
  field cam as deci
  field dam_KZT as deci
  field cam_KZT as deci
  field rem as char
  field who as char
  index idx is primary bank crc jdt jh.
*/
update
    v-from label "  С"
        help " Задайте начальную дату отчета" skip
    v-to   label " ПО"
        help " Задайте конечную дату отчета" skip
 with row 8 centered side-label frame frprov title " Задайте период отчета ".
 hide frame frprov.


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
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.


def stream m-out.
output stream m-out to pcglprov.htm.

put stream m-out unformatted "<html><head><title></title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find first cmp no-lock no-error.
put stream m-out unformatted "<br><br>" cmp.name "<br>" skip
                             "<br>" "Автоматические проводки по файлу GL за период с " v-from " по " v-to "<br>" skip.

put stream m-out unformatted "<br>" skip.
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
          "<tr style=""font:bold"">"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Счет Дт</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Счет Кр</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Назначение</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примечание</td>"
          "</tr>" skip.

for each pcgl where ((v-bank = 'txb00' and can-do('*',pcgl.dbnk)) or (v-bank ne 'txb00' and pcgl.dbnk = v-bank)) and pcgl.ldt >= v-from and pcgl.ldt <= v-to no-lock by pcgl.dbnk by pcgl.fcrc by pcgl.dacc:
    put stream m-out unformatted
              "<tr>"
              "<td>" pcgl.ldt "</td>"
              "<td>" pcgl.jh1 "</td>"
              "<td>" pcgl.dacc "</td>"
              "<td>" pcgl.cacc "</td>"
              "<td>" pcgl.fcrc "</td>"
              "<td>" replace(trim(string(pcgl.tramt,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" pcgl.trdes "</td>"
              "<td>" pcgl.info[1]"</td>"
              "</tr>" skip.
end.
for each pcgl where ((v-bank = 'txb00' and can-do('*',pcgl.cbnk)) or (v-bank ne 'txb00' and pcgl.cbnk = v-bank)) and pcgl.ldt >= v-from and pcgl.ldt <= v-to no-lock by pcgl.cbnk by pcgl.fcrc by pcgl.cacc:
    if pcgl.dbnk = pcgl.cbnk then next.
    put stream m-out unformatted
              "<tr>"
              "<td>" pcgl.ldt     "</td>"
              "<td>" pcgl.jh2     "</td>"
              "<td>" pcgl.dacc    "</td>"
              "<td>" pcgl.cacc    "</td>"
              "<td>" pcgl.fcrc    "</td>"
              "<td>" replace(trim(string(pcgl.tramt,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" pcgl.trdes   "</td>"
              "<td>" pcgl.info[1] "</td>"
              "</tr>" skip.
end.

put stream m-out unformatted "</tr></table>" skip.
put stream m-out unformatted "<br>" skip.

output stream m-out close.
unix silent cptwin pcglprov.htm excel.

