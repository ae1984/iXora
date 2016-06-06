/* r-gl4.p
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
        r-gl4.p
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
         BANK COMM
 * AUTHOR
        25/05/2010 - id00024
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/

{mainhead.i}
{r-gl.i "new shared"}

def var v-count as integer.
def var vx-path as char no-undo.
def var v-name as char no-undo.

def var v-allcount1 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-allsumma1 as decimal format '>>>>>>>>>>>9.99'.

def var v-allcount2 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-allsumma2 as decimal format '>>>>>>>>>>>9.99'.

def var v-allcount3 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-allsumma3 as decimal format '>>>>>>>>>>>9.99'.


def var v-count1 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-summa1 as decimal format '>>>>>>>>>>>9.99'.

def var v-count2 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-summa2 as decimal format '>>>>>>>>>>>9.99'.

def var v-count3 as integer format '>>>>>>>>>>>>>>>>9'.
def var v-summa3 as decimal format '>>>>>>>>>>>9.99'.

def stream rep.

if connected ("txb") then disconnect "txb".

v-from = 01/01/2009.
v-to = 02/02/2010.

  repeat:
  update	v-from label "  С" help " Задайте начальную дату отчета в формате дд/мм/гггг" format "99/99/9999"
		v-to label "    ПО" help " Задайте конечную дату отчета в формате дд/мм/гггг" format "99/99/9999" skip
  with row 4 centered side-label frame opt no-hide no-label no-underline title " Период отчета ".
        if (v-from eq ?) or (v-from > v-to) or (v-from >= g-today) then message "Задайте начальную дату отчета в формате дд/мм/гггг (дата должна быть, дата должна быть меньше даты ПО и даты операционного дня)".
        if (v-to eq ?) or (v-to < v-from) or (v-to >= g-today) then message "Задайте конечную дату отчета в формате дд/мм/гггг (дата должна быть, дата должна быть больше даты С и меньше даты операционного дня)".
        else leave.
  end.

        if keyfunction(lastkey) eq "end-error" then return.

output stream rep to "outputfile.html".

 put stream rep unformatted "<html>" skip.
 put stream rep unformatted "<head>" skip.
 put stream rep unformatted "<META http-equiv= Content-Type content= text\/html; charset= windows-1251>" skip.
 put stream rep unformatted "<title>ОТЧЕТ <\/title>" skip.
 put stream rep unformatted "<\/head>" skip.
 put stream rep unformatted "<body>" skip.

    put stream rep unformatted "<TABLE border=1>" skip.
    put stream rep unformatted "<TR>" skip.
    put stream rep unformatted "<td colspan=8> <nobr> ОТЧЕТ ПО ДОХОДАМ В РАЗРЕЗЕ ПОДРАЗДЕЛЕНИЙ ЗА ПЕРИОД С " v-from " ПО " v-to "</nobr> </td>" skip.
    put stream rep unformatted "</TR>" skip.

    put stream rep unformatted "<TR>" skip.
    put stream rep unformatted "<td rowspan=2 align=center> № </td>" "<td rowspan=2 align=center> Подразделение </td>" skip.
    put stream rep unformatted "<td colspan=2 align=center> РКО </td> <td colspan=2 align=center> Диллинг </td> <td colspan=2 align=center> Гарантии </td>" skip.
    put stream rep unformatted "<TR>" skip.
    put stream rep unformatted "<td align=center>" "Сумма" "</td>" "<td align=center>" "Кол-во транзакций" "</td align=center>" "<td align=center>" "Сумма" "</td>" "<td align=center>" "Кол-во транзакций" "</td>" "<td align=center>" "Сумма" "</td>" "<td align=center>" "Кол-во транзакций" "</td>" skip.
    put stream rep unformatted "</TR>" skip.
    put stream rep unformatted "</TR>" skip.
    put stream rep unformatted "</TABLE>" skip.


find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

v-count = 0.

if bank.cmp.name matches "*МКО*" then vx-path = '/data/'.
else vx-path = '/data/b'.

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

for each comm.txb where comm.txb.consolid = true no-lock:
    if sysc.chval <> 'TXB00' and comm.txb.city <> integer(substr(bank.sysc.chval,4,2)) then next.

    v-name = comm.txb.info.
    displ "" v-name format "x(18)" with row 7 centered overlay no-hide no-label title " Пожалуйста, дождитесь завершения ".
    displ " - обработан ".
    pause 0.

    output stream rep close.

        if connected ("txb") then disconnect "txb".
            v-count = v-count + 1.
        connect value(" -db " + replace(comm.txb.path,'/data/',vx-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-gl4e.p (v-from, v-to, v-count, v-name, output v-count1, output v-summa1, output v-count2, output v-summa2, output v-count3, output v-summa3).

    v-allcount1 = v-allcount1 + v-count1.
    v-allsumma1 = v-allsumma1 + v-summa1.

    v-allcount2 = v-allcount2 + v-count2.
    v-allsumma2 = v-allsumma2 + v-summa2.

    v-allcount3 = v-allcount3 + v-count3.
    v-allsumma3 = v-allsumma3 + v-summa3.
end.

if connected ("txb") then disconnect "txb".

output stream rep to "outputfile.html" append.

    put stream rep unformatted "<TABLE border=1>" skip.
    put stream rep unformatted "<TR>" skip.
    put stream rep unformatted "<td>" "</td> <td>" "ИТОГО:" "</td>" skip.
    put stream rep unformatted "<td>" replace(string(v-allsumma1, ">>>>>>>>>>>9.99"), ".", ",") "</td> <td>" v-allcount1 "</td>" skip.
    put stream rep unformatted "<td>" replace(string(v-allsumma2, ">>>>>>>>>>>9.99"), ".", ",") "</td> <td>" v-allcount2 "</td>" skip.
    put stream rep unformatted "<td>" replace(string(v-allsumma3, ">>>>>>>>>>>9.99"), ".", ",") "</td> <td>" v-allcount3 "</td>" skip.
    put stream rep unformatted "</TR>" skip.
    put stream rep unformatted "</TABLE>" skip.

put stream rep unformatted "<\/body>" skip.
output stream rep close.

unix silent cptwin outputfile.html excel.exe.


