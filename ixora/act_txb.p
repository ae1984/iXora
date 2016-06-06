/* act_txb.p
 * MODULE
        Активные клиенты
 * DESCRIPTION
        Подсчет количества клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT

 * INHERIT
        cifcnt-txb.p
 * MENU
        Пункт меню
 * AUTHOR
        29/06/06 u00600
 * CHANGES
        06/07/2006 u00600 - данные клиентов и ИО и со штрих-кодом, графы iosh, iosh_act по ТЗ ї391 от 04.07.06
        04/09/2006 u00121 - по филиалам запускалась "пэшка", теперь "эрка"
*/

/*{global.i}*/

def var v-dt1 as date format "99/99/9999" label "Период с..." init today no-undo.
def var v-dt2 as date format "99/99/9999" label "Период по..." init today no-undo.
def var kol as int initial 10 format "zz9" label "Введите мин. кол-во проводок"  no-undo.

def new shared var vdt1 as date format "99/99/9999" no-undo.
def new shared var vdt2 as date format "99/99/9999" no-undo.
def new shared var koltxb as int no-undo.

define frame act-rep
 v-dt1 help "Введите начало периода" skip
 v-dt2 help "Введите конец периода" skip
 kol help "Введите количество" skip
 with row 5 side-labels centered title " Параметры отчета ".  

displ v-dt1 v-dt2 kol with frame act-rep.
update v-dt1 v-dt2 kol with frame act-rep.

vdt1 = v-dt1. vdt2 = v-dt2. koltxb = kol.

def new shared temp-table t-tabl no-undo
    field filial as char
    field type as char
    field RKO as integer
    field RKO1 as char
    field cif_kl as integer
    field cif_act as integer
    field io as integer
    field io_act as integer
    field sh as integer
    field sh_act as integer
    field iosh as integer
    field iosh_act as integer.

def new shared temp-table t-vsego no-undo
    field filial as char
    field type as char
    field RKO1 as char
    field cif_kl as integer
    field cif_act as integer
    field io as integer
    field io_act as integer
    field sh as integer
    field sh_act as integer
    field iosh as integer
    field iosh_act as integer.

def new shared var vtxb as char no-undo.

message " Отчет формируется... ".

run connib.

{r-branch.i &proc="act_kl"}

if connected ('ib') then disconnect 'ib'.

output to rep.html.               

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
    "<br><P align=""left"" style=""font:bold"">Отчет по активным клиентам <br>"
     " За период с " string(vdt1, "99/99/9999") " по "  string(vdt2, "99/99/9999") " </P>" skip.

put  unformatted     
         "<TABLE cellspacing=""0"" cellpadding=""15"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center>Филиал</td>"
          "<td align=center>Тип</td>"
          "<td align=center>РКО</td></td>"
          "<td align=center>Всего<br>клиентов</td>"
          "<td align=center>Активных<br>клиентов</td>"
          "<td align=center>Доля<br>активных<br>клиентов<br>(в%)</td>"
          "<td align=center>Всего<br>клиентов<br>со штрих-<br>кодом</td>"
          "<td al ign=center>Активных<br>клиентов со<br>штрих-кодом</td>"
          "<td align=center>Доля активных<br>клиентов со<br>штрих-кодом<br>(в%)</td>"
          "<td align=center>Всего<br>интернет<br>клиентов</td>"
          "<td align=center>Всего<br>активных<br>интернет<br>клиентов</td>"
          "<td align=center>Доля активных<br>интернет<br>клиентов (в%)</td>"
          "<td align=center>Всего<br>клиентов ИО<br>и со штрих-кодом</td>"
          "<td align=center>Активных<br>клиентов ИО<br>и со штрих-кодом</td>"
          "<td align=center>Доля активных<br>клиентов ИО<br>и со штрих-кодом (в %)</td>"
          "<td align=center>Всего<br>остальных<br>клиентов</td>"
          "<td align=center>Активных<br>остальных<br>клиентов</td>"
          "<td align=center>Доля активных<br>остальных<br>клиентов (в %)</td>"
        "</tr><tr></tr>" skip.

for each t-vsego by t-vsego.type by t-vsego.filial:
for each t-tabl where t-tabl.filial = t-vsego.filial and t-tabl.type = t-vsego.type by t-tabl.type by t-tabl.filial:

find first txb where txb.bank = t-tabl.filial and txb.consolid no-lock no-error.  /*база comm*/

       put unformatted 
        "<TR><TD>" if t-tabl.RKO = 1 then txb.info else "&nbsp;" "</TD>" skip
          "<TD >" if t-tabl.type = 'b' then "Юр" else "Физ" "</TD>" skip 
          "<TD >" t-tabl.RKO1 "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.cif_kl = 0 then "" else string(t-tabl.cif_kl) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.cif_act = 0 then "" else string(t-tabl.cif_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.cif_kl = 0 or t-tabl.cif_act = 0 then "" else string((t-tabl.cif_act / t-tabl.cif_kl) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.sh = 0 then "" else string(t-tabl.sh) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.sh_act = 0 then "" else string(t-tabl.sh_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.sh = 0 or t-tabl.sh_act = 0 then "" else string((t-tabl.sh_act / t-tabl.sh) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.io = 0 then "" else string(t-tabl.io) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.io_act = 0 then "" else string(t-tabl.io_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.io = 0 or t-tabl.io_act = 0 then "" else string((t-tabl.io_act / t-tabl.io) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.iosh = 0 then "" else string(t-tabl.iosh) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.iosh_act = 0 then "" else string(t-tabl.iosh_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-tabl.iosh = 0 or t-tabl.iosh_act = 0 then "" else string((t-tabl.iosh_act / t-tabl.iosh) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip

          "<TD align=""right"">&nbsp;" if (t-tabl.cif_kl - t-tabl.sh - t-tabl.io - t-tabl.iosh) = 0 then "" else string((t-tabl.cif_kl - t-tabl.sh - t-tabl.io - t-tabl.iosh)) "</TD>" skip
          "<TD align=""right"">&nbsp;" if (t-tabl.cif_act - t-tabl.sh_act - t-tabl.io_act - t-tabl.iosh_act) = 0 then "" else string((t-tabl.cif_act - t-tabl.sh_act - t-tabl.io_act - t-tabl.iosh_act)) "</TD>" skip
          "<TD align=""right"">&nbsp;" if (t-tabl.cif_kl - t-tabl.sh - t-tabl.io - t-tabl.iosh) = 0 or (t-tabl.cif_act - t-tabl.sh_act - t-tabl.io_act - t-tabl.iosh_act) = 0 then "" else string(((t-tabl.cif_act - t-tabl.sh_act - t-tabl.io_act - t-tabl.iosh_act) / (t-tabl.cif_kl - t-tabl.sh - t-tabl.io - t-tabl.iosh)) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "</TR>" skip.
end.
       put unformatted 
        "<TR><TD>&nbsp;</TD>" skip
          "<TD >&nbsp;</TD>" skip
          "<TD><B>" t-vsego.RKO1 "</B></TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.cif_kl = 0 then "" else string(t-vsego.cif_kl) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.cif_act = 0 then "" else string(t-vsego.cif_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.cif_kl = 0 or t-vsego.cif_act = 0 then "" else string((t-vsego.cif_act / t-vsego.cif_kl) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.sh = 0 then "" else string(t-vsego.sh) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.sh_act = 0 then "" else string(t-vsego.sh_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.sh = 0 or t-vsego.sh_act = 0 then "" else string((t-vsego.sh_act / t-vsego.sh) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.io = 0 then "" else string(t-vsego.io) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.io_act = 0 then "" else string(t-vsego.io_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.io = 0 or t-vsego.io_act = 0 then "" else string((t-vsego.io_act / t-vsego.io) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.iosh = 0 then "" else string(t-vsego.iosh) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.iosh_act = 0 then "" else string(t-vsego.iosh_act) "</TD>" skip
          "<TD align=""right"">&nbsp;" if t-vsego.iosh = 0 or t-vsego.iosh_act = 0 then "" else string((t-vsego.iosh_act / t-vsego.iosh) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip

          "<TD align=""right"">&nbsp;" if (t-vsego.cif_kl - t-vsego.sh - t-vsego.io - t-vsego.iosh) = 0 then "" else string((t-vsego.cif_kl - t-vsego.sh - t-vsego.io - t-vsego.iosh)) "</TD>" skip
          "<TD align=""right"">&nbsp;" if (t-vsego.cif_act - t-vsego.sh_act - t-vsego.io_act - t-vsego.iosh_act) = 0 then "" else string((t-vsego.cif_act - t-vsego.sh_act - t-vsego.io_act - t-vsego.iosh_act)) "</TD>" skip
          "<TD align=""right"">&nbsp;" if (t-vsego.cif_kl - t-vsego.sh - t-vsego.io - t-vsego.iosh) = 0 or (t-vsego.cif_act - t-vsego.sh_act - t-vsego.io_act - t-vsego.iosh_act) = 0 then "" else string(((t-vsego.cif_act - t-vsego.sh_act - t-vsego.io_act - t-vsego.iosh_act) / (t-vsego.cif_kl - t-vsego.sh - t-vsego.io - t-vsego.iosh)) * 100, "->>>,>>>,>>>,>>9.99") "</TD>" skip
          "</B></TR>" skip.

end.

put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.

unix silent cptwin rep.html excel.exe.