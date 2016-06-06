/* a_pprep.p
 * MODULE

 * DESCRIPTION
        отчет Длительные платежные поручения
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16/07/2013 Luiza ТЗ № 1738
 * CHANGES
         30/09/2013 Luiza  - ТЗ 2047
*/


{mainhead.i}

def new shared var v-dt1 as date.
def new shared var v-dt2 as date.

def new shared temp-table lst no-undo
    field  txb    as char
    field  fil    as char
    field  cif    as char
    field  iin    as char
    field  fio    as char
    field  stat   as char
    field  aaa    as char
    field  sum    as decim
    field  crc    as int
    field  who    as char
    field  con    as char
    field  ben    as char
    field  rem    as char
    field  rmz    as char
    field  rmztim as int
    field  knp    as char
    field  fin    as date
    field  dtout  as date
    field  dtin   as date
    field  opl    as int
    field  id     as int
    field  nom    as int
    field  dtnom  as date
    index  idx is primary dtout fil fio .


def var v-bank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc!" view-as alert-box.
    return.
end.
v-bank = sysc.chval.

def frame f-date
   v-dt1 label "Начало" format "99/99/99" validate(v-dt1 < today, "Некорректная дата!") skip
   v-dt2 label "Конец " format "99/99/99" validate(v-dt2 >= v-dt1,"Некорректная дата!") skip
with side-labels centered row 7 title "Параметры отчета".

update  v-dt1 with frame f-date.
update  v-dt2 with frame f-date.

{r-brfilial.i &proc = "a_pprep_txb"}

def stream r-out.

    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    /*find first cmp no-lock no-error.
    put stream r-out unformatted "<br><br>" cmp.name "<br>" skip.*/
    put stream r-out unformatted "<br><br>  АО 'ForteBank' <br>" skip.
    put stream r-out unformatted "<br>" "Отчет по сформированным платежным поручениям c " + string(v-dt1)  + " по " + string(v-dt2)  "<br>" skip.
    put stream r-out unformatted "<br>" skip.
   put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr>"
        "<td align=""center"" valign=""top""> Филиал </td>"
        "<td align=""center"" valign=""top""> Код клиента </td>"
        "<td align=""center"" valign=""top""> ФИО </td>"
        "<td align=""center"" valign=""top""> ИИН</td>"
        "<td align=""center"" valign=""top""> Счет</td>"
        "<td align=""center"" valign=""top""> Сумма</td>"
        "<td align=""center"" valign=""top""> Валюта </td>"
        "<td align=""center"" valign=""top""> Дата </td>"
        "<td align=""center"" valign=""top""> Реквизиты бенефициара </td>"
        "<td align=""center"" valign=""top""> Назначение </td>"
        "<td align=""center"" valign=""top""> КНП </td>"
        "<td align=""center"" valign=""top""> Исполнитель </td>"
        "<td align=""center"" valign=""top""> Контролер </td>"
        "<td align=""center"" valign=""top""> Статус </td>"
        "<td align=""center"" valign=""top""> Срок действия <br> платежного поручения </td>"
        "<td align=""center"" valign=""top""> Номер RMZ  </td>"
        "<td align=""center"" valign=""top""> Время создан RMZ </td>"
        "</tr>" skip.
        for each lst no-lock.
            put stream r-out unformatted
                      "<tr>"
                      "<td>" lst.fil "</td>"
                      "<td>" lst.cif "</td>"
                      "<td>" lst.fio "</td>"
                      "<td>" "'" + lst.iin "</td>"
                      "<td>" lst.aaa "</td>"
                      "<td>" replace(trim(string(lst.sum,  ">>>>>>>>9.99")),'.',',') "</td>"
                      "<td>" lst.crc "</td>"
                      "<td>" lst.dtout "</td>"
                      "<td>" lst.ben "</td>"
                      "<td>" lst.rem "</td>"
                      "<td>" lst.knp "</td>"
                      "<td>" lst.who "</td>"
                      "<td>" lst.con "</td>"
                      "<td>" lst.stat "</td>"
                      "<td>" string(lst.fin) "</td>"
                      "<td>" lst.rmz "</td>"
                      "<td>" string(lst.rmztim, 'hh:mm') "</td>"
                      "</tr>" skip.
        end.
        put stream r-out unformatted "</table>" skip.
    pause 0.
    output stream r-out close.

    unix silent cptwin fin.htm excel.


