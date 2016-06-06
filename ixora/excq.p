/* excq.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/10/2011 lyubov
 * BASES
        BANK
 * CHANGES
*/

def shared temp-table tbxc no-undo
    field crc  like crc.crc label ""
    field aaa  like bxcif.aaa label ""
    field code  like crc.code label ""
    field amount like bxcif.amount label ""
    field rem like bxcif.rem label ""
    field whn like bxcif.whn label ""
    index aaa is primary aaa crc.

    def var sum as deci.
    def var sum1 as deci.
    def shared var fdt like bxcif.whn.
    def var city as char.

 function GetNormSumm returns char (input summ as deci ):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then
   do:
    ss1 = summ.
    ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
   end.
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
   end.

   return trim(replace(ret,".",",")).
end function.

find first cmp no-lock no-error.
if avail cmp then city = cmp.name.

define stream m-out.
output stream m-out to excq.xls.
put stream m-out unformatted "<html><head><title>Задолженности</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3><tr>"city "</tr></h3><br>" skip.
put stream m-out unformatted "<h3>ОТЧЕТ О ЗАДОЛЖЕННОСТИ КЛИЕНТА ПО СЧЕТУ</h3><br>" skip.
put stream m-out unformatted "<h3> НА " string(fdt) "</h3><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</TD>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код клиента</TD>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Клиент</TD>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Примечание</TD>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата</TD>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет</TD>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</TD>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма в KZT</TD>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код тарифа</TD>"
                        "</TR>" skip.

/*for each tbxc where tbxc.amount <> 0 no-lock break by tbxc.aaa by tbxc.crc by tbxc.rem:*/

for each bxcif where bxcif.whn <= fdt and bxcif.amount <> 0 no-lock break by crc by aaa by cif by rem:
sum = bxcif.amount.

find crc where  bxcif.crc = crc.crc no-lock no-error.
find last crchis where crchis.crc = crc.crc and crchis.whn <= bxcif.whn no-lock no-error.
/*if bxcif.aaa = 'KZ05470292205A056216' then message '111' crchis.rate[1] bxcif.amount crchis.whn view-as alert-box.*/
find first cif where cif.cif = bxcif.cif.

if bxcif.crc = 2 then
sum1 = bxcif.amount * crchis.rate[1].
else sum1 = sum.

put stream m-out unformatted
                  "<tr>" skip
/*1 */            "<td>" crc.code "</td>" skip
/*2 */            "<td>" cif.cif "</td>" skip
/*3 */            "<td>" cif.name "</td>" skip
/*4 */            "<td>" bxcif.rem "</td>" skip
/*5 */            "<td>" bxcif.whn "</td>" skip
/*6 */            "<td>" bxcif.aaa "</td>" skip
/*7 */            "<td>" GetNormSumm (sum) "</td>" skip
/*8 */            "<td>" GetNormSumm (sum1) "</td>" skip
/*9 */            "<td>" bxcif.type "</td>" skip
                  "</tr>" skip.
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin excq.xls excel.