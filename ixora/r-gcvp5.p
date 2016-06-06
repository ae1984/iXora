/* r-gcvp4.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Акты сверок Период указывается с ... по ... включительно!!!
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        25.09.10  marinav
 * CHANGES
        27/04/2012 evseev  - повтор
*/

{mainhead.i}


def new shared var v-dtb as date.
def new shared var v-dte as date.

update
  v-dtb label " Начальная дата " format "99/99/9999" skip
  v-dte label "  Конечная дата " format "99/99/9999"
  with centered row 5 side-label frame f-dt.
def var v-sel as char.

run sel2 (" Акты сверок :", " 1. Выплаты по пенсиям и пособиям | 2. Выплата компенсаций по Семипалатискому полигону | 3. Выплата удержаний из пенсий и пособий | 4. Выход ", output v-sel).


  if v-sel = "4" then do:
     leave.
  end.


   define new shared stream m-out.

   output stream m-out to rpt.html.
   put stream m-out "<html><head><title></title>" skip
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

   {r-brfilial.i &proc = "r-gcvp5p (txb.bank, v-sel)" }




  output stream m-out close.
  unix silent cptwin rpt.html excel.
  pause 0.
