/* r-vpkon2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        14/04/06 nataly добавили колонку чистая позиция
	    30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09.11.2012 dmitriy - изменение алгоритма в связи с добавлением новых счетов конвертации (ТЗ 1569)
*/
def new shared temp-table wrk
field bank as char
field crc as char
field ost1 as deci
field ost2 as deci
field dr as deci
field cr as deci
field arpsaist as deci
field arppras as deci.

def new shared stream rpt.
def new shared var sum1 as decimal.
def new shared var sum2 as decimal.
def new shared var sum3 as decimal.
def new shared var sum4 as decimal.
def new shared var sum5 as decimal.
def new shared var sum6 as decimal.
def new shared var sum7 as decimal.
def new shared var sum88 as decimal.

def shared var fdt as date.
def shared var prz as integer.

def var vst1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def var ven1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def var dr1  as decimal format 'z,zzz,zzz,zz9.99-'.
def var cr1  as decimal format 'z,zzz,zzz,zz9.99-'.

define  variable g-batch  as log initial false.

def new shared var v-crc as integer.
def new shared var v-branch as char.


def shared temp-table tsum
       field crc as integer
       field vpval as decimal
       field vpkz as decimal.


display '   Идет расчет ...   '  with row 5 frame ww centered .

find first cmp no-lock no-error.
find first ofc where ofc.ofc = userid('bank') no-lock no-error.


output  stream rpt to "rpt.img".
put stream rpt skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name )                               format 'x(79)' at 02 skip(1)
'КОНСОЛИДИРОВАННАЯ ВАЛЮТНАЯ ПОЗИЦИЯ '     format 'x(42)' at 29 skip
' ЗА '  + string( fdt, '99/99/9999' ) + ' г.' format 'x(17)' at 37 skip(1)
'Исполнитель: ' + trim( ofc.name )             format 'x(79)' at 02 skip.

/*в условиях выборки необходимо указать txb.glbal.crc <> 0, т.к. почему-то сч. 680500 в таблице glbal имеет значение поля crc 0*/

  put stream rpt ' ' fill( '=', 165 )           format 'x(165)'  .
  put stream rpt 'Вход. ост.' format 'x(15)' at 14
                 'Дебет  ' format 'x(10)'  at 39
                 'Кредит ' format 'x(10)' at 57
                 'Исход. ост.'format 'x(15)' at 70
                 ' Обяз-ва ' format 'x(10)' at 87
                 ' Требов.  ' format 'x(10)' at 108
                 'Чистая ВП ' format 'x(15)' at 130
                 'Чистая ВП ' format 'x(15)' at 150 skip.
  put stream rpt ' г/к 1858 ' format 'x(15)' at 14
                 '         ' format 'x(10)'  at 39
                 '         ' format 'x(10)' at 57
                 'г/к 1858 'format 'x(15)' at 70
                 ' по внеб. ' format 'x(10)' at 87
                 ' по внеб. ' format 'x(10)' at 108
                 '(USD,EUR,RUB)' format 'x(15)' at 130
                 'USD,EUR,RUB в KZT' format 'x(19)' at 150 skip.
  put stream rpt ' ' fill( '=', 165 )           format 'x(165)'       skip(1).

for each crc no-lock where crc.crc > 0 and crc.sts ne 9
     break by crc.crc:
 v-crc = crc.crc.

{r-branch.i &proc = "vlptek(comm.txb.name)"}
/*
for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    v-branch =  txb.service .
    run vlptek.

end.

if connected ("txb") then disconnect "txb".
*/
if sum1 <>  0 or sum2 <> 0 or sum3 <> 0 or sum4 <> 0 then do:
 put stream rpt skip  ' ' fill ('-',160) format 'x(160)' at 7.
 put stream rpt skip crc.code format 'x(4)' at 1
    sum1 format 'zzz,zzz,zzz,zz9.99-' at 9 /*знак меняем на противоположный*/
    sum2 format 'zz,zzz,zzz,zz9.99-' at 29
    sum3 format 'z,zzz,zzz,zz9.99-' at 47
    sum4 format 'zzz,zzz,zzz,zz9.99-' at 67   /*знак меняем на противоположный*/
    sum6 format 'zzz,zzz,zzz,zz9.99-' at 87       /*требования*/
    sum5 format 'zzz,zzz,zzz,zz9.99-' at 107        /*обяз-ва*/
    (- sum6 + sum5 + sum4)
         format 'zzz,zzz,zzz,zz9.99-' at 127
   sum88 format 'zzz,zzz,zzz,zz9.99-' at 147 skip(2).
    create tsum.
     assign tsum.crc = crc.crc
            tsum.vpval  = (- sum6 + sum5 + sum4)
            tsum.vpkz    = sum88.
 end.
  sum1 = 0. sum2 = 0. sum3 = 0. sum4 = 0 . sum5 = 0. sum6 = 0. sum7 = 0. sum88 = 0 .
  vst1 = 0. dr1 = 0 .  cr1 = 0. ven1 = 0.
end . /*crc*/



 put stream rpt  skip(1)
      " =====      КОНЕЦ ДОКУМЕНТА     ====="
    SKIP(1).

output stream rpt close.

run PrintRep.

if prz = 1 then do:
if not g-batch then do:
  pause 0 before-hide.
  run menu-prt( 'rpt.img' ).
  pause 0 no-message.
  pause before-hide.
end.
end.
return.


procedure PrintRep:
    def var v-str as char.
    def var file1 as char.

    v-str = string( today, "99.99.9999" ) + ', ' + string( time, 'HH:MM:SS' ) + ', ' + trim( cmp.name ).


    file1 = "vpkon.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<TABLE><tr></tr>"
    "<tr align=""left""><td colspan=""7"">" v-str "</td></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""7"">КОНСОЛИДИРОВАННАЯ ВАЛЮТНАЯ ПОЗИЦИЯ</td></tr>"
    "<tr align=""center""><td colspan=""7"">ЗА " fdt format "99.99.9999" " г.</td></tr>"
    "<TR></TR>"
    "<tr align=""left""><td colspan=""7"">Испольнитель: " ofc.name "</td></tr>"
    "</table>" skip.

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
    "<TR align=""center"" style=""font:bold;background:#CCCCCC"">"
    "<TD></TD>"
    "<TD>ВП на начало периода</TD>"
    "<TD>Продано</TD>"
    "<TD>Куплено</TD>"
    "<TD>ВП на конец периода</TD>"
    "<TD>Обяз-ва по внеб.</TD>"
    "<TD>Требов по внеб.</TD>".

    for each crc no-lock where crc.crc > 0 and crc.sts ne 9 break by crc.crc:

        for each wrk where wrk.crc = crc.code no-lock break by wrk.crc:
            accumulate wrk.ost1 (SUB-TOTAL by wrk.crc).
            accumulate wrk.ost2 (SUB-TOTAL by wrk.crc).
            accumulate wrk.dr (SUB-TOTAL by wrk.crc).
            accumulate wrk.cr (SUB-TOTAL by wrk.crc).
            accumulate wrk.arpsaist (SUB-TOTAL by wrk.crc).
            accumulate wrk.arppras (SUB-TOTAL by wrk.crc).

            put unformatted
            "<TR align=""left"">"
            "<TD>" wrk.bank "</TD>"
            "<TD>" replace(string(wrk.ost1),".",",") "</TD>"
            "<TD>" replace(string(wrk.dr),".",",") "</TD>"
            "<TD>" replace(string(wrk.cr),".",",") "</TD>"
            "<TD>" replace(string(wrk.ost2),".",",") "</TD>"
            "<TD>" replace(string(wrk.arpsaist),".",",") "</TD>"
            "<TD>" replace(string(wrk.arppras),".",",") "</TD>"
            "</TR>".

            if last-of (wrk.crc) then do:
                sum1 = accum sub-total by wrk.crc wrk.ost1.
                sum2 = accum sub-total by wrk.crc wrk.dr.
                sum3 = accum sub-total by wrk.crc wrk.cr.
                sum4 = accum sub-total by wrk.crc wrk.ost2.
                sum5 = accum sub-total by wrk.crc wrk.arpsaist.
                sum6 = accum sub-total by wrk.crc wrk.arppras.

                put unformatted
                "<TR align=""left""  style=""background:#CCCCCC"">"
                "<TD>" wrk.crc "</TD>"
                "<TD>" replace(string(sum1),".",",") "</TD>"
                "<TD>" replace(string(sum2),".",",") "</TD>"
                "<TD>" replace(string(sum3),".",",") "</TD>"
                "<TD>" replace(string(sum4),".",",") "</TD>"
                "<TD>" replace(string(sum5),".",",") "</TD>"
                "<TD>" replace(string(sum6),".",",") "</TD>"
                "</TR>".
            end.

        end.

    end.

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.


