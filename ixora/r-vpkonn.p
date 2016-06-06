/* r-vpkonn.p
 * MODULE
        Отчет по Вал позиции
 * DESCRIPTION
        Отчет по Вал позиции
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
        BANK
 * AUTHOR
        14/04/06 nataly
 * CHANGES
*/

def button  btn1  label "Консол.валютная позиция".
def button  btn2  label "Таб-ца сравнения лимитов".
def button  btn3  label "Выход".
def new shared var prz as integer.
def new shared var fdt as date.

define  variable g-batch  as log initial false.
define var g-lang  like bank.lang.lang.

def new shared temp-table tsum 
       field crc as integer
       field vpval as decimal
       field vpkz as decimal.


def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Консол.валютная позиция" then prz = 1.
    else
    if self:label = "Таб-ца сравнения лимитов" then prz = 2.
       else prz = 3.
  end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.

if not connected ("comm") then run comm-con.

find sysc where sysc.sysc eq "BEGDAY" no-lock no-error.
 
fdt = today.
 if not g-batch then do:
   update fdt label 'Укажите дату ' validate (sysc.daval le fdt 
                    and  fdt <= today, 
                " В базе информация с  " + string(sysc.daval) + '.' + 
                " Последняя дата -  "  + string(today) )
                 with row 8 centered /*no-box*/ side-label frame opt.
      end.   
hide frame opt.                                   

     if prz = 1 then run r-vpkon2. 
      else if prz = 2 then do:  
                       run r-vpkon2. 
                       /*run r-poz.  */
                      end.
      else if prz = 3 then return.
 hide  frame frame1.
 pause 0.


