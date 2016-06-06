/* deptrx.f
 * MODULE
        Автоматизация проводки по страхованию        
 * DESCRIPTION
        Для deptrx.p
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


define new shared var v-sid like skladb.sid.
define new shared var v-pid like skladb.pid.
define new shared var v-des as char init "".
define new shared var v-cost like skladc.cost.

define variable subamt as integer.
define variable subcost as decimal.

define var can-exit as logical.
define var v-param as char.
define var v-del as char init "^".
define var v-doc as char.
define var v-dpr like skladh.dpr.
define var v-amt like skladh.amt.
define new shared var s-jh like jh.jh.
define var rcode as integer.
define var rdes as char.
define var yesno as logical.
define var totamt as decimal init 0.
define var totcost as decimal init 0.0.


/*def new  shared temp-table  wsk
     field dep as char
     field des as char 
     field sum as decimal format 'z,zzz,zzz,zz9.99'
     field gl  like gl.gl
     field arp like arp.arp
     field crc like crc.crc
     field rem  like jl.rem[1]
     field who as char
     field whn as date .
  */

def new  shared temp-table  wskitem
     field gl  like gl.gl
     field arp like arp.arp
     field crc like crc.crc
     field rem as char .

/*define frame fc bc help "Используйте стрелки для передвижения. F4 - Конец"
       skip (1) "По группе:"   totamt  format "zzzzzzzzzzzzzzzzz" view-as text
                "       По товару:" subamt  format "zzzzzzzzzzzzzzzzz" view-as text
       skip     "стоимость:"   totcost format "zz,zzz,zzz,zz9.99" view-as text
                "       стоимость:" subcost format "zz,zzz,zzz,zz9.99" view-as text
 with row 2 no-label title
" Наименование             Количество          Цена     Стоимость   ДатаПр ".
  */

/*------------------------------------------------------------------------*/

define var cost like skladh.cost.
define var gra1 as integer.
define var gra2 as integer.
define var grc1 as decimal.
define var grc2 as decimal.
define var grdx as decimal.
define var grd1 as decimal.
define var grd2 as decimal.
define var grstr as char.

define frame income
       "Департамаент  :" temptrx.dep  help "Введите номер деп-та. F2 - выбор"
       validate (can-find( codfr no-lock where codfr.codfr = 'sdep' and codfr.code = dep  ) , 'Деп-т не найден! ') 
       "Наименование  :" temptrx.des format 'x(25)' skip
       "Сумма         :" temptrx.sum
/*       validate(temptrx.sum > 0, "Сумма должна быть больше нуля!") */ skip
       "На счет ГК    :" temptrx.gl temptrx.des skip
       "Офицер        :" temptrx.who skip
       "Дата          :" temptrx.whn skip
"________________________________________________________________________"
       skip(1)
/*       " F4 - выход   |" byes2*/
       with no-labels title "ВВОД ДАННЫХ" row 4  .

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

define query qp for temptrx.

define buffer st_buf for temptrx.
define var st_amt as decimal format "z,zzz,zzz,zz9".
define var st_sum as decimal format "z,zzz,zzz,zz9.99".


define frame getlistp
            temptrx.dep label "Выберите Департамент (F2 - помощь)" skip
            temptrx.des label "Выберите товар (F2 - помощь) " 
            temptrx.sum label "Сумма для зачисления"
            temptrx.gl label "Счет ГК"  validate(temptrx.gl = 0 or can-find(first gl where gl.gl = 
                     temptrx.gl no-lock), "Счет главной книги не найден")
            with row 2 centered side-labels.

define browse bp query qp
       display
               temptrx.dep  label "Департамент" format "x(3)"
               temptrx.des  label "Наименование" format "x(30)"
               temptrx.sum label "Сумма" 
               temptrx.gl  label "Счет ГК"
       with 9 down /* size 80 by 9 */ no-label title "Ввод данных".

define frame st
               st_amt label "Итого"
               st_sum label "на сумму"
               with row 15 centered side-labels.
/*          
define frame fc bc help "Используйте стрелки для передвижения. F4 - Конец"
       skip (1) "По группе:"   totamt  format "zzzzzzzzzzzzzzzzz" view-as text
                "       По товару:" subamt  format "zzzzzzzzzzzzzzzzz" view-as text
       skip     "стоимость:"   totcost format "zz,zzz,zzz,zz9.99" view-as text
                "       стоимость:" subcost format "zz,zzz,zzz,zz9.99" view-as text
 with row 2 no-label title
" Наименование             Количество          Цена     Стоимость   ДатаПр ".
  */
def frame tmp 
              wskitem.arp label "ARP" help "Введите счет ARP(Кредит)" validate(can-find(first arp where arp.arp = wskitem.arp no-lock), "Счет ARP не найден!")
              wskitem.gl  label "G/L" help "Введите счет ГК(Дебет)"  validate(can-find(first gl where gl.gl = wskitem.gl no-lock), "Счет главной книги не найден!")
              wskitem.crc label "CRC"  help "Введите валюту проводки" validate(can-find(first crc where crc.crc = wskitem.crc no-lock), "Валюта не найдена!")
              wskitem.rem label "Примечание"  format "x(40)" help "Введите примечение "
         with  row 3 centered no-label title "Ввод реквизитов транзакции".

define frame ftp bp
help " [ENTER]-редакт, [INSERT]-добавление,F8-удаление,F4 - конец"
       skip (1) "ИТОГО"   totamt  format "zzzzzzzzzzzzzz.99" view-as text
       with row 2 centered /*no-box*/. 


define frame getlistp
            temptrx.dep label "Выберите Департамент (F2 - помощь)" skip
            temptrx.des label "Выберите товар (F2 - помощь) " 
            temptrx.sum label "Сумма для зачисления"
            temptrx.gl label "Счет ГК"  validate(skladp.gl = 0 or can-find(first gl where gl.gl = 
                     wsl.gl no-lock), "Счет главной книги не найден")
            with row 2 centered side-labels.


define var dfrom as date init today.
define var dto as date init today.

form 
             "Период: с" dfrom 
             validate (dfrom <= today, 
                       "Начало периода не может быть больше, чем сегодня!")
             " по" dto
             validate (dfrom <= dto, 
                      "Конец периода не может быть раньше его начала!")
             with no-label centered row 7 frame fdat.

