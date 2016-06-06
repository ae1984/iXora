/* loninfo.p
 * MODULE
        Кредитные операции
 * DESCRIPTION
        Справка по месту требования о наличии у клиента ссудной задолженности
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        3-1-1
 * AUTHOR
        31/08/11 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/
{nbankBik.i}
def stream m-out.
def shared var s-lon like lon.lon.
def var str-tg as char.
def var str-tn as char.
def var v-sumtg as deci init 0.
def var v-sumtn as char.
def var sum1 as deci init 0.
def var sum2 as deci init 0.
def var sum4 as deci init 0.
def var sum5 as deci init 0.
def var sum7 as deci init 0.
def var sum9 as deci init 0.
def var sum16 as deci init 0.
def var sum33 as deci init 0.
def var sum13 as deci init 0.
def var sum14 as deci init 0.
def var sum30 as deci init 0.
def var summ as deci init 0.

def var i as integer.
def var v-crc1 as char.
def var v-crc2 as char.
def var v-dolg as char init "".
def var sds-com as deci.

def var cmp-name as char.
def var v-todayru as char.
def var v-todaykz as char.
def var summ-all as deci.
def var summ-dog as deci.
def var summ-vrd as deci.
def var summ-tiin as int.

def var str-od1 as char.
def var str-od2 as char.
def var str-vo1 as char.
def var str-vo2 as char.
def var str-com as char.
def var str-neu as char.
def var str-sumdog as char.

def var v-tnod1 as char.
def var v-tnod2 as char.
def var v-tnvo1 as char.
def var v-tnvo2 as char.
def var v-tncom as char.
def var v-tnneu as char.
def var v-tnsumdog as char.


{global.i}

find first cmp no-lock no-error.
find first lon where lon.lon = s-lon no-lock no-error.
find first cif where cif.cif = lon.cif no-lock no-error.

function sum-space returns char (input sum as deci).
    def var s as char.
    def var s1 as char.
    def var s2 as char.
    def var n as int.
    def var n1 as int.
    def var i as int.

    s = string(sum).
    n = length(s).
    if n <= 3 then n1 = 1.
    if n > 3 and n <= 6 then n1 = 2.
    if n > 6 and n <= 9 then n1 = 3.
    if n > 9 and n <= 12 then n1 = 4.
    if n > 12 and n <= 15 then n1 = 5.

    s2 = ''.
    if n1 = 1 then s2 = s.
    if n1 > 1 then do:
        do i = 1 to n1:
           if n - 3 * i + 1 >= 1 then s1 = " " + substr(s, n - 3 * i + 1 , 3). /* &nbsp */
           else if  n - 3 * i + 1 = 0 then s1 = substr(s, 1 , 2).
           else if  n - 3 * i + 1 < 0 then s1 = substr(s, 1 , abs(n - 3 * i + 1)).
           s2 = s1 + s2.
        end.
    end.

    return s2.
end function.

function tiin returns char (input sum as deci).
    def var s as char.
    def var s1 as char.
    def var sum1 as int.

    sum = sum - trunc(sum,0).
    s = string(sum).
    s1 = substr(s, 2, 2).
    if length(s1) = 1 then s1 = s1 + '0'.
    if s1 = '' then s1 = '0'.

    return s1.
end function.

/* у клиентов все кредиты в одной валюте */
if lon.crc = 1 then do:
    v-crc1 = "тенге".
    v-crc2 = "тиын".
end.
if lon.crc = 2 then do:
    v-crc1 = "долларов".
    v-crc2 = "центов".
end.
if lon.crc = 3 then do:
    v-crc1 = "евро".
    v-crc2 = "евроцентов".
end.

cmp-name = cmp.name.
if cmp-name matches "*Филиал*" then cmp-name = replace (cmp-name, "Филиал", "Филиалом").

run pkdefdtstr(today, output v-todayru, output v-todaykz).

for each lon where lon.cif = cif.cif no-lock:

    run levsum(1, output sum1).
    run levsum(2, output sum2).
    run levsum(4, output sum4).
    run levsum(5, output sum5).
    run levsum(7, output sum7).
    run levsum(9, output sum9).
    run levsum(16, output sum16).
    run levsum(33, output sum33).
    run levsum(13, output sum13).
    run levsum(14, output sum14).
    run levsum(30, output sum30).
    summ = summ + sum1 + sum2 + sum4 + sum5 + sum7 + sum9 + sum16 + sum33.
end.

v-sumtg = summ.
v-sumtn = tiin(v-sumtg). /*trunc(abs((v-sumtg) - (round(v-sumtg, 0))) * 100, 0).*/

run Sm-vrd(v-sumtg, output str-tg).

if (sum7 + sum9 + sum4 + sum16 + sum5 + sum33 = 0) then v-dolg = "Просроченная задолженность отсутствует.".

sum1 = 0.
sum7 = 0.
sum2 = 0.
sum4 = 0.
sum9 = 0.
sum16 = 0.
sum5 = 0.
sum33 = 0.

if (sum13 + sum14 + sum30 > 0) then message "Наличие остатков на 13, 14, 30 уровнях. Справка не формируется" view-as alert-box warning.
else run sum-dogovor.

Procedure sum-dogovor:

    def var txt as char extent 15.

      if v-sumtg <= 0 then leave.

      output stream m-out to lninfo.html.

      put stream m-out unformatted
         "<HTML><HEAD><TITLE></TITLE>
         <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
         <META content=ru http-equiv=Content-Language>
         </HEAD>
         <BODY style='margin-left:.5pt;margin-top:.1pt;margin-right:.1pt;margin-bottom:.2pt'>
         <TABLE style=""FONT-SIZE: 12pt"" border=0 align=center width=700 style=""font-family: times new roman"">
         <TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:right'>
         <br><br><br><br><br>По месту требования<br><br>
         </TR>

         <TR width=350 valign=top style='text-indent:35.45pt;width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
         Настоящим " + v-nbankru + " подтверждает наличие ссудной задолженности у "
         cif.prefix " " cif.name " (РНН " cif.jss ") перед " cmp-name " по состоянию на "
         v-todayru " года в общей сумме " sum-space(trunc(v-sumtg, 0)) " (" str-tg ") " v-crc1 " " v-sumtn " " v-crc2 ", в т.ч.:
         </TR>" skip.

      i = 1.
      for each lon where lon.cif = cif.cif no-lock:
        find first loncon where loncon.lon = lon.lon no-lock no-error.

        run levsum(1, output sum1).
        run levsum(2, output sum2).
        run levsum(4, output sum4).
        run levsum(5, output sum5).
        run levsum(7, output sum7).
        run levsum(9, output sum9).
        run levsum(16, output sum16).
        run levsum(33, output sum33).
        run levsum(13, output sum13).
        run levsum(14, output sum14).
        run levsum(30, output sum30).

        summ-dog = sum1 + sum2 + sum4 + sum5 + sum7 + sum9 + sum16 + sum33.

        sds-com = 0.
        if lon.grp = 90 or lon.grp = 92 then do:
            for each bxcif where bxcif.cif = lon.cif no-lock:
                sds-com = sds-com + bxcif.amount.
            end.
        end.

        v-tnod1 = tiin(sum1 + sum7).
        v-tnod2 = tiin(sum7).
        v-tnvo1 = tiin(sum2 + sum9 + sum4).
        v-tnvo2 = tiin(sum9 + sum4).
        v-tncom = tiin(sds-com).
        v-tnneu = tiin(sum16 + sum5 + sum33).
        v-tnsumdog = tiin(summ-dog).

        run Sm-vrd(sum1 + sum7, output str-od1).
        run Sm-vrd(sum7, output str-od2).
        run Sm-vrd(sum2 + sum9 + sum4, output str-vo1).
        run Sm-vrd(sum9 + sum4, output str-vo2).
        run Sm-vrd(sds-com, output str-com).
        run Sm-vrd(sum16 + sum5 + sum33, output str-neu).
        run Sm-vrd(summ-dog, output str-sumdog).

          if summ-dog > 0 then do:
              put stream m-out unformatted
                 "<TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
                 " string(i) ") по Договору №" loncon.lcnt " от " string(lon.rdt) " г. в общей сумме " sum-space(trunc(summ-dog, 0)) " (" str-sumdog ") " v-crc1 " "  v-tnsumdog " " v-crc2 ", в т.ч.:
                 </TR>" skip.
          end.
          else next.

          if (sum1 + sum7) > 0 then do:
              put stream m-out unformatted
                 "<TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
                    •  по основному долгу – " sum-space(trunc(sum1 + sum7, 0)) " (" str-od1 ") " v-crc1 " "  v-tnod1 " " v-crc2 ",
                    из которых просроченные " sum-space(trunc(sum7, 0)) " (" str-od2 ") " v-crc1 " " v-tnod2 " " v-crc2 ";
                 </TR>" skip.
          end.

          if (sum2 + sum9 + sum4) > 0 then do:
          put stream m-out unformatted
             "<TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
                •	по начисленному вознаграждению " sum-space(trunc(sum2 + sum9 + sum4, 0)) " (" str-vo1 ") " v-crc1 " " v-tnvo1 " " v-crc2 ",
                из которых просроченные " sum-space(trunc(sum9 + sum4, 0)) " (" str-vo2 ") " v-crc1 " " v-tnvo2 " " v-crc2 ";
             </TR>" skip.
          end.

          if lon.grp = 90 or lon.grp = 92 then do:
          put stream m-out unformatted
             "<TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
                •	по комиссии за ведение счета " sum-space(sds-com) " (" str-com ") " v-crc1 "; (Если экспресс кредит)
             </TR>" skip.
          end.

          if (sum16 + sum5 + sum33) > 0 then do:
          put stream m-out unformatted
             "<TR width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>
                •	по начисленной неустойке " sum-space(trunc(sum16 + sum5 + sum33, 0)) " (" str-neu ") " v-crc1 " " v-tnneu " " v-crc2 ";
             </TR>" skip.
          end.

      i = i + 1.
      end.

        if v-dolg <> "" then do:
            put stream m-out unformatted
            "<tr width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:left'>"
            "<br><br>" v-dolg "</tr>" skip.
        end.

        put stream m-out unformatted
            "<trwidth=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:left;font:bold'>
            <br><br>Директор</tr>" skip.

        find first ofc where ofc.ofc = g-ofc no-lock no-error.

        put stream m-out unformatted
            "<tr width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:left'>
            <br><br>Исп.: " ofc.name "</tr>" skip.

     put stream m-out "</table>" skip.

     put stream m-out "</body></html>" skip.

     output stream m-out close.
     unix silent cptwin lninfo.html winword.exe.
     unix silent rm lninfo.html.

End Procedure.

procedure levsum:
    def input parameter lev as int.
    def output parameter sum as deci.

    for each trxbal where trxbal.subled = 'lon' and trxbal.acc = lon.lon and trxbal.lev = lev no-lock:
      sum = sum + (trxbal.dam - trxbal.cam).
    end.

    sum = abs(sum).
end procedure.



