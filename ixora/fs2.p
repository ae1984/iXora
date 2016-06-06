/* fs2.p
 * MODULE
        Статистика
 * DESCRIPTION
        Банковские займы, выданные в тенге и иностранной валюте с указанием ставок вознаграждения по ним
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
        21/10/08 marinav
 * CHANGES
        10/09/09 aigul - добавила вычисление суммы по кредитам МСБ
        13/10/10 aigul - поправила вывод ФЛ МСБ

*/


{global.i}

def new shared  var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
define variable bilance  as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-cif as char format "x(30)".
def var v-gl as char.
def var i as int.
define variable v-dt     as date format "99/99/9999".
define variable v-dtn     as date format "99/99/9999".
def buffer b-aaa  for aaa.

update
  v-dtn label " НАЧАЛЬНАЯ ДАТА ПЕРИОДА " format "99/99/9999" skip
  v-dt label "  КОНЕЧНАЯ ДАТА ПЕРИОДА " format "99/99/9999"
  with centered row 5 side-label frame f-dt.


def new shared temp-table vsb2
             field nn as int
             field sumnk as decimal format 'z,zzz,zzz,zz9-'
             field sumnkp as decimal format 'z,zzz,zzz,zz9-'
             field sumdk as decimal format 'z,zzz,zzz,zz9-'
             field sumdkp as decimal format 'z,zzz,zzz,zz9-'
             field sumvk as decimal format 'z,zzz,zzz,zz9-'
             field sumvkp as decimal format 'z,zzz,zzz,zz9-'
             field sumnd as decimal format 'z,zzz,zzz,zz9-'
             field sumndp as decimal format 'z,zzz,zzz,zz9-'
             field sumdd as decimal format 'z,zzz,zzz,zz9-'
             field sumddp as decimal format 'z,zzz,zzz,zz9-'
             field sumvd as decimal format 'z,zzz,zzz,zz9-'
             field sumvdp as decimal format 'z,zzz,zzz,zz9-'
                /*MCБ*/
             field sumnkm as decimal format 'z,zzz,zzz,zz9-'
             field sumnkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumdkm as decimal format 'z,zzz,zzz,zz9-'
             field sumdkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumvkm as decimal format 'z,zzz,zzz,zz9-'
             field sumvkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumndm as decimal format 'z,zzz,zzz,zz9-'
             field sumndpm as decimal format 'z,zzz,zzz,zz9-'
             field sumddm as decimal format 'z,zzz,zzz,zz9-'
             field sumddpm as decimal format 'z,zzz,zzz,zz9-'
             field sumvdm as decimal format 'z,zzz,zzz,zz9-'
             field sumvdpm as decimal format 'z,zzz,zzz,zz9-'.

i = 1.
repeat :
  create vsb2.
  nn  = i.
  sumnk = 0.
  sumnkp = 0.

  sumdk = 0.
  sumdkp = 0.

  sumvk = 0.
  sumvkp = 0.

  sumnd = 0.
  sumndp = 0.

  sumdd = 0.
  sumddp = 0.

  sumvd = 0.
  sumvdp = 0.

 /*MCБ*/
  sumnkm = 0.
  sumnkpm = 0.

  sumdkm = 0.
  sumdkpm = 0.

  sumvkm = 0.
  sumvkpm = 0.

  sumndm = 0.
  sumndpm = 0.

  sumddm = 0.
  sumddpm = 0.

  sumvdm = 0.
  sumvdpm = 0.

  i = i + 1.
  if i = 10 then leave.
end.

def var v-strokaname as char extent 9 init
["Всего",
 "до 1 мес.",
 "от 1 до 3 мес.",
 "от 3 до 6 мес.",
 "от 6 мес. до 1 года",
 "от 1 года до 2 лет",
 "от 2 года до 3 лет",
 "от 3 года до 5 лет",
 "от 5 лет и более"].

define stream vcrpt.
output stream vcrpt to fs1.html.

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted "<p align=""center""><b> ОТЧЕТ - FS "  skip
    "  Банковские займы, выданные в тенге и иностранной валюте с указанием ставок вознаграждения по ним "   skip
    " на   "  + string( v-dt)  + "      в тыс. тенге </b></p>" skip(2).
/*заголовок таблицы*/

{2sb2_mcb.i}

/**********************************************************************************/
{r-brfilial.i &proc = "fs2dat (v-dt, v-dtn)"}

/**********************************************************************************/


for each vsb2:

put stream vcrpt  unformatted
  "<tr>"
    "<td width=""17%"">" v-strokaname[nn] "</td>" skip
    "<td width=""7%"">"  string(round(sumnk / 1000, 0),'zzzzzzzzzzz9')  "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumnkp * 100 / sumnk,1) = ? then 0 else round(sumnkp * 100 / sumnk,1), 'z9.99'),".",",") +  "</td>" skip

    "<td width=""7%"">"  string(round(sumnkm / 1000, 0),'zzzzzzzzzzz9')  "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumnkpm * 100 / sumnkm,1) = ? then 0 else round(sumnkpm * 100 / sumnkm,1), 'z9.99'),".",",") +  "</td>" skip

    "<td width=""7%"">" round(sumdk / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumdkp * 100 / sumdk,1) = ? then 0 else round(sumdkp * 100 / sumdk,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumdkm / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumdkpm * 100 / sumdkm,1) = ? then 0 else round(sumdkpm * 100 / sumdkm,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumvk / 1000, 0) "</td>" skip
    "<td width=""6%"">" + replace(string(if round(sumvkp * 100 / sumvk,1) = ? then 0 else round(sumvkp * 100 / sumvk,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumvkm / 1000, 0) "</td>" skip
    "<td width=""6%"">" + replace(string(if round(sumvkpm * 100 / sumvkm,1) = ? then 0 else round(sumvkpm * 100 / sumvkm,1), 'z9.99'),".",",") + "</td>" skip



    "<td width=""7%"">" round(sumnd / 1000, 0)  "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumndp * 100 / sumnd,1) = ? then 0 else round(sumndp * 100 / sumnd,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumndm / 1000, 0)  "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumndpm * 100 / sumndm,1) = ? then 0 else round(sumndpm * 100 / sumndm,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumdd / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumddp * 100 / sumdd,1) = ? then 0 else round(sumddp * 100 / sumdd,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumddm / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumddpm * 100 / sumddm,1) = ? then 0 else round(sumddpm * 100 / sumddm,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumvd / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumvdp * 100 / sumvd,1) = ? then 0 else round(sumvdp * 100 / sumvd,1), 'z9.99'),".",",") + "</td>" skip

    "<td width=""7%"">" round(sumvdm / 1000, 0) "</td>" skip
    "<td width=""7%"">" + replace(string(if round(sumvdpm * 100 / sumvdm,1) = ? then 0 else round(sumvdpm * 100 / sumvdm,1), 'z9.99'),".",",") + "</td>" skip

  "</tr>" skip.

end.

{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin fs1.html excel").


