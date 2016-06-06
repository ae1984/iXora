/* r-risk.p
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

def  var v-otrasl as char.
def  var v-otrasl2 as decimal format 'zz9.9%'.
def  var v-obes as decimal format 'zz9.9%'.
def  var v-osenka as decimal format 'zz9.9%'.

def  var v-zalog as decimal.
def  var v-zalog2 as decimal.
def  var v-obor as decimal.
def  var v-obor2 as decimal.

def  var v-prd as integer.
def  var v-srok as decimal.
def  var v-history as decimal.

def var obespech as  decimal extent 7  initial [100,80,80,70,50,30,0] format 'zz9.9%'.
def var osenka as  decimal extent 6  initial [100,80,50,30,0,0].
def var hist as decimal extent 4 initial [100,70,30,0].
def var optimal as decimal extent 8 initial [80,90,80,80,80,60,70,80].
def var weight as decimal extent 8 initial [5,25,15,25,5,5,10,10].
/*def var risk as char extent 8 .*/

{global.i}

def buffer bcrc for crc.
def new shared var  v-cif as char.
def new shared var  koef_ust as decimal.

update v-cif format 'x(6)' label 'Введите код клиента ' with col 10 row 5.
  find cif where cif.cif = v-cif no-lock no-error.
if not avail cif 
then do: 
    message 'Клиент с кодом ' v-cif  'не найден !'  view-as alert-box. 
    undo,retry .
end.
    /* выберем юридические... */
    find first sub-cod where 
    sub-cod.d-cod = 'clnsts' and
    sub-cod.ccode = '0'      and 
    sub-cod.sub   = 'cln'    and
    sub-cod.acc   = string( cif.cif ) 
    no-lock no-error.
    if not avail sub-cod 
     then do: 
       message 'Клиент с кодом ' v-cif  'не является ЮЛ !'  view-as alert-box. 
       undo,retry. 
     end.
/*run comm-con.*/
def stream vcrpt.
output stream vcrpt to lon.html.
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted " <b> Матрица рисков на " + string(g-today, "99/99/9999") + "</b>" skip.

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


def var v-title as char.
define variable datums     as date.
def var cnt as decimal extent 2.

/*расчет среднемесячных оборотов*/
if month(g-today) > 1 then datums = date(string(day(g-today)) + "/" + string(month(g-today) - 1) + "/" + string(year(g-today))).
if month(g-today) = 1 then datums = date(string(day(g-today)) + "/12/" + string(year(g-today) - 1)).

/*расчет фин устойчивости (надежности)*/
run r-lncif1.p.
/*  for each aaa where aaa.cif = v-cif and not aaa.lgr begins '5' and aaa.crc = 1 no-lock.
      for each jl no-lock where jl.acc = aaa.aaa  and jl.jdt >= datums and jl.jdt <= g-today 
        and jl.crc = 1 and (jl.lev = 1 or jl.lev = 2) use-index acc .
        accumulate jl.cam (TOTAL).
      end.
      cnt[1] = cnt[1] + accum total jl.cam.
  end.
  for each lon where lon.cif = v-cif and lon.dam[1] <> lon.cam[1] no-lock.
   find crc where crc.crc = lon.crc no-lock no-error.
     cnt[2] = cnt[2] + (lon.dam[1] - lon.cam[1]) * crc.rate[1].
  end.
v-obor = cnt[1] / cnt[2].
  */

for each lon where lon.cif = v-cif and  lon.dam[1] <> lon.cam[1]   no-lock.

v-obor = 0. v-zalog = 0 .  v-obor2 = 0. v-zalog2 = 0 . v-prd = 0. 
/*обеспечение*/
    find first sub-cod where 
    sub-cod.sub   = 'lon'    and
    sub-cod.acc   = string( lon.lon ) and
    sub-cod.d-cod = 'lnobes' exclusive-lock no-error.
    if avail sub-cod and sub-cod.ccod <> 'msc' then  v-obes = integer(sub-cod.ccode).
    else  do: 
      {risk1.i}
     if not avail sub-cod 
      then do: 
       create sub-cod. 
        assign   sub-cod.sub   = 'lon'   
                sub-cod.acc   = lon.lon  
                sub-cod.d-cod = 'lnobes' 
                sub-cod.ccode   = string(obespech[prz]).
      end.
    else sub-cod.ccode   = string(obespech[prz]).
         v-obes = obespech[prz].
    end.
         release sub-cod.

  /*оценка проекта*/
  find first sub-cod where 
    sub-cod.sub   = 'lon'    and
    sub-cod.acc   = string( lon.lon ) and
    sub-cod.d-cod = 'lnprjct' exclusive-lock no-error.
    if avail sub-cod and sub-cod.ccod <> 'msc' then  v-osenka = integer(sub-cod.ccode).
    else  do: 
      {risk2.i}
     if not avail sub-cod 
      then do: 
       create sub-cod. 
        assign   sub-cod.sub   = 'lon'   
                sub-cod.acc   = lon.lon  
                sub-cod.d-cod = 'lnprjct' 
                sub-cod.ccode   = string(osenka[prz]).
      end.
    else sub-cod.ccode   = string(osenka[prz]).
         v-osenka = osenka[prz].
    end.
         release sub-cod.
/*кредитаня история*/
  find first sub-cod where 
    sub-cod.sub   = 'lon'    and
    sub-cod.acc   = string( lon.lon ) and
    sub-cod.d-cod = 'lnhist' exclusive-lock no-error.
    if avail sub-cod and sub-cod.ccod <> 'msc' then  v-history = integer(sub-cod.ccode).
    else  do: 
      {risk3.i}
     if not avail sub-cod 
      then do: 
       create sub-cod. 
        assign   sub-cod.sub   = 'lon'   
                sub-cod.acc   = lon.lon  
                sub-cod.d-cod = 'lnhist' 
                sub-cod.ccode   = string(hist[prz]).
      end.
    else sub-cod.ccode   = string(hist[prz]).
         v-history= hist[prz].
    end.
         release sub-cod.

/*отрасль заемщика*/
    find first sub-cod where 
    sub-cod.d-cod = 'ecdivis' and
    sub-cod.sub   = 'lon'    and
    sub-cod.acc   = string( lon.lon ) 
    no-lock no-error.
    if not avail sub-cod then v-otrasl = "". else v-otrasl = sub-cod.ccode.

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


 if lon.gua = "OD" then v-srok = 70.
 else do:
  v-prd = lon.duedt - lon.rdt.
   if v-prd < 365 then v-srok = 60.
    else if v-prd >= 365 and v-prd <= 1095  then v-srok = 50.
     else if v-prd > 1095  then v-srok = 30.
 end.
 
find zlzalog where zlzalog.lon = lon.lon no-lock no-error.
if avail zlzalog then do:
   find crc where crc.crc =  zlzalog.crc no-lock no-error.
   find bcrc where bcrc.crc =  lon.crc no-lock no-error.

   v-zalog = zlzalog.amount * crc.rate[1] / ((lon.dam[1] - lon.cam[1]) * bcrc.rate[1]).
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
  /* message lon.lon  v-obes v-zalog2.
   message   v-otrasl2 / optimal[1] koef_ust / optimal[2]  v-obes / optimal[3] v-zalog2 / optimal[4]  
      v-osenka / optimal[5]  v-srok / optimal[6]  v-history / optimal[7]  v-obor2 / optimal[8].  pause 400.
    */
{risk_out.i}

end.

{html-end.i " stream vcrpt "}

output stream vcrpt close.

/*удаление всех промежуточных файлов*/
 unix silent rm -f value("drb.1").  
 unix silent rm -f value("drb.2").  
 unix silent rm -f value("rpt.img").  

  unix silent value("cptwin lon.html excel").


