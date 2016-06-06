/* compils.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчёт по суммам свыше 5 млн тенгедля комплаенс контроля
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * BASES
        BANK COMM

 * AUTHOR
     04.09.2009 id0004

 * CHANGES

*/


{mainhead.i}

def var return_choice as logical.
def new shared var g_date as date.
def new shared var d_date as date.
def new shared  var d_date_fin as date.
def var v-account as char format "x(10)" label "Account".
def var out as char.
def var crlf as char.
def var file1 as char format "x(20)".
def var v-ost as decimal.
def var v-ost_fin as decimal.
def var acctype as logical.

  out = "find-lev.txt".

  d_date = g-today.
  d_date_fin = g-today.
  g_date = g-today.
  v-account = "".

  update d_date label "Дата с" with centered side-label.
  update d_date_fin label "по" with centered side-label.



  MESSAGE "Сформировать отчет за указанный период ?" 
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
  TITLE "ОТЧЕТ ЗА ПЕРИОД" UPDATE return_choice.
  if not return_choice then return.

  display "......Ж Д И Т Е ......."  with row 12 frame ww centered .
  pause 0 .


                   
  file1 = "file1.html". 
  output to value(file1).  
    {html-title.i} 
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Отчет по суммам свыше 5000000 ЗА ПЕРИОД с "d_date " по "d_date_fin " .</br>  </P>" skip.





  {r-branch.i &proc = "compls1"}  



    {html-end.i " "}
  output close.
  hide frame ww.
  unix silent cptwin value(file1) iexplore.

