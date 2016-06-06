/* r-risk2.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def shared var v-otrasl as char.
def shared var v-otrasl2 as decimal format 'zz9.9%'.
def shared var v-obes as decimal format 'zz9.9%'.
def shared var v-osenka as decimal format 'zz9.9%'.

def shared var v-zalog as decimal.
def shared var v-zalog2 as decimal.
def shared var v-obor as decimal.
def shared var v-obor2 as decimal.

def shared var v-prd as integer.
def shared var v-srok as decimal.
def shared var v-history as decimal.
def shared var optimal as decimal extent 8 initial [80,90,80,80,80,60,70,80].
def shared var weight as integer extent 8 initial [5,25,15,25,5,5,10,10].

def var obespech as  decimal extent 7  initial [100,80,80,70,50,30,0] format 'zz9.9%'.
def var osenka as  decimal extent 6  initial [100,80,50,30,0,0].
def var hist as decimal extent 4 initial [100,70,30,0].

define shared var g-today  as date.

def buffer bcrc for txb.crc.
def new shared var  v-cif as char.
def shared var  koef_ust as decimal.

/*run comm-con.*/
/*def stream vcrpt.
output stream vcrpt to lon.html.
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted " <b> Матрица рисков на " + string(g-today, "99/99/9999") + "</b>" skip.
  */
def var prz as integer.
   def button  btn1  label "Депозит ".
   def button  btn2  label "Недв-ть ".
   def button  btn3  label "Автомобиль ".
   def button  btn4  label "Обор-ие ".
   def button  btn5  label "Товары в обороте ".
   def button  btn6  label "Товары, поступ в будущем ".
   def button  btn7  label "Без обеспечения ".
   def button  btn8  label "Выход".

   def button  btn9  label "Больш положит потоки по всем срокам".
   def button  btn10  label "Небольш положит потоки по всем срокам".
   def button  btn11  label "Небольш отриц потоки по некот срокам".
   def button  btn12  label "Больш отриц потоки по некот срокам".
   def button  btn13  label "Проект убыточен".
   def button  btn14  label "Нет достаточных данных о проекте".

   def button  btn15  label "Безупречная".
   def button  btn16  label "Хорошая".
   def button  btn17  label "Плохая".
   def button  btn18  label "Нет".

def input parameter v-lon as char.


def var v-title as char.
define variable datums     as date.
def var cnt as decimal extent 2.

/*расчет среднемесячных оборотов*/
if month(g-today) > 1 then datums = date(string(day(g-today)) + "/" + string(month(g-today) - 1) + "/" + string(year(g-today))).
if month(g-today) = 1 then datums = date(string(day(g-today)) + "/12/" + string(year(g-today) - 1)).

/*расчет фин устойчивости (надежности)*/
find  txb.lon where txb.lon.lon = v-lon  no-lock.
find  txb.cif where txb.cif.cif = txb.lon.cif  no-lock no-error.
v-cif = txb.cif.cif.
run r-lncif2.

/*обеспечение*/
    find first txb.sub-cod where 
    txb.sub-cod.sub   = 'lon'    and
    txb.sub-cod.acc   = string( txb.lon.lon ) and
    txb.sub-cod.d-cod = 'lnobes' exclusive-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then  v-obes = integer(txb.sub-cod.ccode).
    else v-obes = 0. 
  /*  else  do: 
      {risk1.i}
     if not avail txb.sub-cod 
      then do: 
       create txb.sub-cod. 
        assign  txb.sub-cod.sub   = 'lon'   
                txb.sub-cod.acc   = txb.lon.lon  
                txb.sub-cod.d-cod = 'lnobes' 
                txb.sub-cod.ccode   = string(obespech[prz]).
      end.
    else txb.sub-cod.ccode   = string(obespech[prz]).
         v-obes = obespech[prz].
    end. */
         release txb.sub-cod.

  /*оценка проекта*/
  find first txb.sub-cod where 
    txb.sub-cod.sub   = 'lon'    and
    txb.sub-cod.acc   = string( txb.lon.lon ) and
    txb.sub-cod.d-cod = 'lnprjct' exclusive-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then  v-osenka = integer(txb.sub-cod.ccode).
     else v-osenka = 0. 
/*    else  do: 
      {risk2.i}
     if not avail txb.sub-cod 
      then do: 
       create txb.sub-cod. 
        assign  txb.sub-cod.sub   = 'lon'   
                txb.sub-cod.acc   = txb.lon.lon  
                txb.sub-cod.d-cod = 'lnprjct' 
                txb.sub-cod.ccode   = string(osenka[prz]).
      end.
    else txb.sub-cod.ccode   = string(osenka[prz]).
         v-osenka = osenka[prz].
    end.*/
         release txb.sub-cod.
/*кредитаня история*/
  find first txb.sub-cod where 
    txb.sub-cod.sub   = 'lon'    and
    txb.sub-cod.acc   = string( txb.lon.lon ) and
    txb.sub-cod.d-cod = 'lnhist' exclusive-lock no-error.
    if avail sub-cod and txb.sub-cod.ccod <> 'msc' then  v-history = integer(txb.sub-cod.ccode).
    else  v-history = 0.
/*    else  do: 
      {risk3.i}
     if not avail txb.sub-cod 
      then do: 
       create txb.sub-cod. 
        assign  txb.sub-cod.sub   = 'lon'   
                txb.sub-cod.acc   = txb.lon.lon  
                txb.sub-cod.d-cod = 'lnhist' 
                txb.sub-cod.ccode   = string(hist[prz]).
      end.
    else txb.sub-cod.ccode   = string(hist[prz]).
         v-history= hist[prz].
    end.*/
         release txb.sub-cod.

/*отрасль заемщика*/
    find first txb.sub-cod where 
    txb.sub-cod.d-cod = 'ecdivis' and
    txb.sub-cod.sub   = 'lon'    and
    txb.sub-cod.acc   = string( txb.lon.lon ) 
    no-lock no-error.
    if not avail txb.sub-cod then v-otrasl = "". else v-otrasl = txb.sub-cod.ccode.

 if v-otrasl = '65' then v-otrasl2 = 100. 
  else if v-otrasl = '11' then v-otrasl2 = 90.
   else if v-otrasl = '51' then v-otrasl2 = 80. 
     else if v-otrasl = '45'  then v-otrasl2 = 70. 
      else if v-otrasl = '40' then v-otrasl2 = 70. 
       else if v-otrasl = '15' then v-otrasl2 = 70. 
        else if v-otrasl = '16' then v-otrasl2 = 70. 
         else if v-otrasl = '23'  or v-otrasl = '24' or v-otrasl = '25' then v-otrasl2 = 70. 
          else if v-otrasl = '52' then v-otrasl2 = 60. 
           else if v-otrasl = '55' then v-otrasl2 = 60. 
            else if v-otrasl = '60'or v-otrasl = '61' then v-otrasl2 = 50. 
             else if v-otrasl = '62'or v-otrasl = '63' then v-otrasl2 = 50. 
              else if v-otrasl = '17'or v-otrasl = '18' then v-otrasl2 = 50. 
               else if v-otrasl = '19' then v-otrasl2 = 50. 
                else if v-otrasl = '64' then v-otrasl2 = 40. 
                 else if v-otrasl = '01' or v-otrasl = '02' or v-otrasl = '05' then v-otrasl2 = 30.
                  else v-otrasl2 = 20.


 if txb.lon.gua = "OD" then v-srok = 70.
 else do:
  v-prd = txb.lon.duedt - txb.lon.rdt.
   if v-prd < 365 then v-srok = 60.
    else if v-prd >= 365 and v-prd <= 1095  then v-srok = 50.
     else if v-prd > 1095  then v-srok = 30.
 end.
 
find comm.zlzalog where comm.zlzalog.lon = txb.lon.lon no-lock no-error.
if avail comm.zlzalog then do:
   find txb.crc where txb.crc.crc =  comm.zlzalog.crc no-lock no-error.
   find bcrc where bcrc.crc =  txb.lon.crc no-lock no-error.

   v-zalog = comm.zlzalog.amount * txb.crc.rate[1] / ((txb.lon.dam[1] - txb.lon.cam[1]) * bcrc.rate[1]).
end.

if v-zalog > 2 then v-zalog2 = 100.
 else if v-zalog > 1.5 and v-zalog <= 2 then v-zalog2 = 80.
  else if v-zalog > 1 and v-zalog <= 1.5 then v-zalog2 = 50.
   else if v-zalog > 0.5 and v-zalog <= 1 then v-zalog2 = 30.
    else if v-zalog > 0 and v-zalog <= 0.5 then v-zalog2 = 0.

if v-obor > 2 then v-obor2 = 100.
 else if v-obor > 1.5 and v-obor <= 2 then v-obor2 = 90.
  else if v-obor > 1 and v-obor <= 1.5 then v-obor2 = 80.
   else if v-obor > 0.5 and v-obor <= 1 then v-obor2 = 70.
    else if v-obor > 0 and v-obor <= 0.5 then v-obor2 = 0.

/*{risk_out.i}
  */
/*end. for each lon*/

/*{html-end.i " stream vcrpt "}

output stream vcrpt close.
  */
/*удаление всех промежуточных файлов*/
 unix silent rm -f value("drb.1").  
 unix silent rm -f value("drb.2").  
 unix silent rm -f value("rpt.img").  

/* unix silent value("cptwin lon.html excel").*/




