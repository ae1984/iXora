/* er_bd.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по кредитам БД
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
 * BASES
        BANK COMM        
 * AUTHOR
        17/01/2007 madiyar
 * BASES
        bank, comm
 * CHANGES
*/

{mainhead.i}


def input parameter v-lgr like lgr.lgr.
def input parameter v-sum as deci no-undo.
def input parameter v-srok as integer no-undo.
def input parameter v-rate as deci no-undo.
def input parameter v-rdt as date no-undo.
def input parameter v-pdt as date no-undo.
def input parameter v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def input parameter v-komv as deci no-undo. /* комиссия за ведение счета */
def input parameter v-komr as deci no-undo. /* комиссия за рассмотрение заявки */

def output parameter v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.



  def var i_date  as date.
  def var i_expdt as date.
  def var ev-date as date.
  def var all_proc as decimal.
  def var calc1 as decimal.
  def var calc2 as decimal.

  def var d_cap   as date.




{er.i}

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

Function EventInRange returns date (input event as char,
                                    input vdat1 as date,
                                    input vdat2 as date).
def var curdate as date.
def var e-fire as logi.
curdate = vdat1.
repeat:
  run EventHandler(event, curdate, v-rdt, i_expdt - 1, output e-fire).
  if e-fire then do:
     return curdate.
  end.
  curdate = curdate + 1.
  if curdate > vdat2 then return ?.   
end.        
End Function.



for each b2cl: delete b2cl. end.
for each cl2b: delete cl2b. end.

/* расчет */

v-dt0 = v-rdt.


/*  run er_depf(v-sum,v-srok,v-rate,v-rdt,v-pdt,v-komf,v-komv,v-komr,output v-er).  */

/*
do i = 1 to v-srok:
    
    if i = 1 then v-dt = v-pdt.
    else
    if i = v-srok then v-dt = get-date(v-rdt,v-srok).
    else
    v-dt = get-date(v-dt0,1).

   
    run day-360(v-dt0,v-dt - 1,360,output dn1,output dn2).
    v-prc = round(dn1 * v-sum * v-rate / 100 / 360,2).




  message v-dt - v-rdt.
    pause 333.       



    create cl2b.
    cl2b.dt = v-dt.
    cl2b.days = v-dt - v-rdt.
    cl2b.sum = round(v-sum / v-srok,2) + v-prc + v-komv.
    
    if i = v-srok then leave.
    else v-dt0 = v-dt.
    
end.   */






  d_cap = v-rdt.

  run EvaluateExpiryDate.


  find last lgr where lgr.lgr = v-lgr no-lock no-error.

  do i_date = v-rdt to i_expdt:
     ev-date = ?.
     calc2 = 0.
     calc2 =  (i_date - d_cap + 1) * v-rate * (v-sum + calc1) / 36500.

     /*капитализ*/

     ev-date = EventInRange(lgr.type, i_date, i_date).

     if ev-date <> ? then do:

        calc1 = calc1 + calc2.
        d_cap = i_date + 1.
        calc2 = 0.

     end.

     ev-date = ?.

     /* выплата */
     ev-date = EventInRange(lgr.intpay, i_date, i_date).
     if ev-date <> ? then do:

     /* all_sum = v-sum * (v-rdt) */






        create b2cl.
        b2cl.dt   = ev-date.
        b2cl.days = ev-date - v-rdt + 1.
   if i_date = i_expdt - 1 then
        b2cl.sum  = round(calc1 + calc2 + v-sum, 2).
   else
        b2cl.sum  = round(calc1 + calc2, 2).

if lgr.led = "CDA" then
        d_cap = i_date + 1.



/*message b2cl.dt   b2cl.sum calc2.
pause 555. */


/*    message ev-date  b2cl.sum  ev-date - v-rdt + 1.
      pause 5558.  */
        calc1 = 0.


     end.
  end. 



  


  v-er = get_er(0.0,0.0,v-sum,0.0).











Procedure EvaluateExpiryDate.
 def var years as inte initial 0.
 def var months as inte initial 0.
 def var days as inte.
 days = day(v-rdt).
 years = integer(v-srok / 12 - 0.5).
 months = v-srok - years * 12.
 months = months + month(v-rdt).
   if months > 12 then do:
      years = years + 1.
      months = months - 12.
   end.
   if month(v-rdt) <> month(v-rdt + 1) then do:
      months = months + 1.
      if months = 13 then do:
         months = 1.
         years = years + 1.
      end.
      days = 1.
   end.

   if months = 2 and days = 30 then do: months = 3. days = 1. end. 
   if months = 2 and days = 29  and  (( (year(v-rdt)  + years) - 2000) modulo 4) <> 0 then do:
      months = 3.  days = 1.  end.



   i_expdt = date(months, days, year(v-rdt) + years).
   if month(v-rdt) <> month(v-rdt + 1) then do:

      if month(i_expdt) = 3 and day(i_expdt) = 1 then do:

      end.
      else
         i_expdt = i_expdt - 1.  

   end.

End procedure.




Procedure EventHandler.
def input parameter e_period as char.
def input parameter e_date as date.
def input parameter a_start as date.
def input parameter a_expire as date.
def output parameter e_fire as logi.

def var vterm as inte.
def var e_refdate as date.
def var e_displdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.

def var t-years as inte initial 0.
def var t-months as inte initial 0.
def var t-days as inte initial 0.


def var i as integer initial 0.

e_fire = false.
if e_period  = "N" then return.
else if e_period = "S" and e_date = a_start then do:
   e_fire = true.
   return.    
end.
else if e_period = "F" and e_date = a_expire then do:
   e_fire = true.
   return.
end.
else if e_period = "M" or e_period = "Q" or e_period = "Y" 
     or e_period = "1" or e_period = "2" or e_period = "3"
     or e_period = "4" or e_period = "5" or e_period = "6"
     or e_period = "7" or e_period = "8" or e_period = "9" then do:
     if e_period = "M" then vterm = 1.
     else if e_period = "Q" then vterm = 3.
     else if e_period = "Y" then vterm = 12.
     else vterm = integer(e_period).
     t_date = a_start.
     i = 1.



     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.


       /*еЯКХ ЯВЕР НРЙПШР Б ОНЯКЕДМХИ ДЕМЭ ЛЕЯЪЖЮ МН МЕ Б ТЕБПЮКЕ*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do: 
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*еЯКХ ЯВЕР НРЙПШР 1-ЦН ВХЯКЮ*/
       if day(a_start) = 1 then do: /*еЯКХ дЮРЮ НРЙПШРХЪ 1 ВХЯКЮ*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*еЯКХ ЯВЕР НРЙПШР МЕ ОЕПБНЦН Х МЕ ОНЯКЕДМЕЦН */
       do: /*НАШВМЮЪ ДЮРЮ*/
 
          if months = 2 and (days = 29 or days = 30 or days = 31) then 
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.

       if e_displdate > e_date then return.
       else if e_displdate > a_expire then return.
       if e_date = e_displdate then do:
          e_fire = true.
          return.
       end.  


       t_date = date(months, 15, year(t_date) + years).
       i = i + 1.
     end.  /*repeat*/

end.
else if e_period = "D" then e_fire = true.
End procedure.

























