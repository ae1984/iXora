/* seif.p
 * MODULE
        ДЕПОЗИТАРИЙ(Аренда сейфовых ячеек)
 * DESCRIPTION
        Пролонгация срока аренды сейфовой ячейки
 * RUN
        верхнее меню (mmoent - SIFSUB)
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        18.05.2005 dpuchkov
 * CHANGES
*/

  {global.i}
  def variable v-aaa as char .
  def var i_ind as integer init 0.
  def var dt_date as date.
  def var iiday   as integer.
  def var iimonth as integer.
  def var iiyear  as integer.
  def var dsum as decimal decimals 2.
  define buffer b-depo for depo.
  def var return_choice as logical.


  MESSAGE "Вы хотите продлить срок аренды сейфовой ячейки?" 
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
  TITLE "ДЕПОЗИТАРИЙ" UPDATE return_choice.
  if not return_choice then return.


  update v-aaa format "x(9)" label "Введите номер счета" validate (can-find (aaa where aaa.aaa = v-aaa no-lock), "Данного счета не существует" ) with centered side-label row 12 no-box.
  hide all.


  find last aaa where aaa.aaa = v-aaa no-lock no-error.

  for each b-depo where b-depo.aaa = v-aaa no-lock break by b-depo.f1  :
    i_ind =  f1.
  end.

  find last b-depo where b-depo.aaa = v-aaa and b-depo.f1 = i_ind no-lock no-error .

/*
  if not avail b-depo then do:
     message "Не обнаружено зарегистрированных сейфовых ячеек по данному счету".
     pause .
     return.
  end.
*/

  define frame fr2
    v-aaa label   "Номер счета            " format "x(9)" skip
    depo.cellnum format "x(20)" label    "Номер арендуемой ячейки" skip
    depo.cellsize format "x(20)" label   "Тип ячейки             " skip
    depo.lstdt label  "Дата начала пролонгации"  skip
    depo.prlngdate label    "Дата оконч. пролонгации"  skip
    depo.flag label      "Льготный тариф         "      skip
    depo.sum format "->>>,>>>,>>>,>>9.99" label   "Сумма аренды за период " 
  with side-labels centered row 6.

on help of depo.cellsize in frame fr2 do:
     run sel ("Выберите тип сейфовой ячейки", "Маленькая|Средняя|Большая").
     if int(return-value) = 1 then depo.cellsize = "Маленькая".
     if int(return-value) = 2 then depo.cellsize = "Средняя". 
     if int(return-value) = 3 then depo.cellsize = "Большая".
     display depo.cellsize with frame fr2.
end.


do transaction:
          create depo.
          depo.aaa = v-aaa.

          if avail b-depo then do:
             depo.lstdt = b-depo.prlngdate.
             depo.f1    = b-depo.f1 + 1.
             depo.cellsize = b-depo.cellsize.
             depo.cellnum  = b-depo.cellnum.
          end.

          if avail b-depo then do:
             displ v-aaa depo.cellnum depo.cellsize with frame fr2.
             update depo.lstdt validate (depo.lstdt <> ?, "Введите дату начала пролонгации" )
                    depo.prlngdate validate (depo.prlngdate <> ?, "Введите дату окончания пролонгации" )
                    depo.flag with frame fr2.
          end.
          else
          do:
             displ v-aaa  with frame fr2.
             update depo.cellnum validate (depo.cellnum <> "", "Введите номер ячейки" )  depo.cellsize validate (depo.cellsize = "Маленькая" or depo.cellsize = "Средняя" or depo.cellsize = "Большая", "Неверный тип. Используйте - F2 для выбора ")
                    depo.lstdt validate (depo.lstdt <> ? , "Дата начала пролонгации должна быть >= текущего дня")
                    depo.prlngdate validate (depo.prlngdate <> ?, "Введите дату окончания пролонгации" )
                    depo.flag with frame fr2.
             depo.f1 = 1.
          end.


          if depo.flag = True then do:  /*Льготный тариф*/
             update depo.sum with frame fr2.
          end.
          else
          do:
            run DayCount(depo.lstdt , depo.prlngdate , output iiyear, output iimonth, output iiday).
            depo.mon = (iiyear * 12) + iimonth.
            {depo.i}
            depo.sum = dsum.
            displ depo.sum with frame fr2.
            /*update depo.sum with frame fr2.*/
            pause .
         end.
         /* Срок меньше одного месяца */
         if (iimonth = 0 and iiyear = 0 and iiday <> 0) or (iimonth = 1 and iiyear = 0 and iiday = 0)  then do:
            message "Срок аренды не превышает 1 месяц" skip "комиссия не будет списана автоматически" view-as alert-box title "".
            delete depo.
         end.
end.


                




Procedure DayCount. /*возвращает количество дней за целое число месяцев*/
def input parameter a_start  as date.
def input parameter a_expire as date.
def output parameter iiyear  as integer .
def output parameter iimonth as integer .
def output parameter iiday   as integer .

def var vterm as inte.
def var e_refdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.
def var i as inte initial 0.

def var e_fire as logical init False.
def var t-days as date.
def var e_date as date.
iiday = 0. iiyear = 0. iimonth = 0.

e_refdate = a_start.

if a_start = a_expire then do: return. end.

do e_date = a_start to a_expire:     
   iiday = iiday + 1.


   if day(e_date) = day(e_refdate) and e_date <> a_start then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   /* февраль высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) = 0) and ( day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 29) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.
   /* февраль не высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) <> 0) and ( day(e_refdate) = 30 or day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 28) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   
   if iimonth = 12 then do:
      iiyear = iiyear + 1.
      iimonth = 0.
      iiday = 0.
   end.
end.
    iiday = iiday - 1. 
    if iiday < 0 then iiday = 0.

End procedure.
