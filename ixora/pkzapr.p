/* pkzapr.p
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
   Запрос на определение суммы и срока кредита - для всех видов кредитов

   01.02.2003 marinav
   04.03.2003 nadejda - собственно update вынесен в отдельные проги для разных видов кредитов
   09.10.03   marinav - вынесение заявки на кредитный комитет
   04.06.2008 madiyar - валютный контроль 
*/

{global.i}
{pk.i}


if s-pkankln = 0 then return.


find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.sts > "10" or pkanketa.sts < "05" then do:
  message skip " Менять сумму нельзя !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

/* проверка на допустимые валюты */
if pkanketa.crc < 1 or pkanketa.crc > 3 then do:
    message skip " Некорректная валюта выдачи! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

run value ("pkzapr-" + s-credtype).

/*
{pk-sysc.i}

def var v-srokmin as deci.
def var v-sroktemp as deci.
def var v-summin as deci.

def shared frame pkank. 

{pkanklon.f}

find current pkanketa exclusive-lock.
do transaction on error undo, retry:

   find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksum" no-lock no-error.
   v-summin = deci(entry(1,pksysc.chval)).

   find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksrk" no-lock no-error.

   update pkanketa.sumq 
          validate((pkanketa.sumq <= pkanketa.summax and pkanketa.sumq > v-summin) or pkanketa.sumq = 0 , "
          Сумма не может быть больше максимальной и меньше " + trim(string(v-summin, ">>>,>>>,>>>,>>9.99")) + " тенге")
      with frame pkank.

   if pkanketa.sumq > 0 then do:
   v-sroktemp = pkanketa.sumq / (pkanketa.summax / int(entry(2,pksysc.chval))).
            if v-sroktemp - trunc(v-sroktemp, 0) > 0 
               then v-srokmin = trunc(v-sroktemp + 1, 0).
               else v-srokmin = v-sroktemp.

            if v-srokmin < int(entry(1,pksysc.chval)) and v-srokmin > 0 then v-srokmin = int(entry(1,pksysc.chval)).

            pkanketa.srokmin = v-srokmin.          
            pkanketa.srok = v-srokmin.          

    displ  pkanketa.sumq  
           pkanketa.srokmin 
           pkanketa.srok with frame pkank.

    update pkanketa.srok validate(pkanketa.srok >= pkanketa.srokmin and pkanketa.srok <= int(entry(2,pksysc.chval)),
                           "Срок должен быть больше минимального и меньше " + entry(2,pksysc.chval) + " месяцев")
                   with frame pkank.

    displ pkanketa.srok with frame pkank.
    end.
end.
release pkanketa.
*/

