/* bkaccpin.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Акцепт принятия пин-конвертов
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
        24.01.06 marinav 
 * CHANGES
*/

{bk.i}
{global.i}
{get-dep.i}

def var s_point as inte.
def var s_bank as char.
def var s_rowid1 as rowid.

define query q1 for bkcard .
define browse b1 query q1 
              display
                 bkcard.contract_number  format "x(16)"       label "Номер карты"
                 bkcard.nominal          format ">>>,>>>,>>9" label "Номинал "
                 bkcard.whn2 ne ?                             label "Принял" 
                 with 13 down no-labels.
define frame fr1 b1 
    help "<ENTER> Принять,    <F4> Выход" with side-labels centered title "АКЦЕПТ ПИН-КОНВЕРТОВ" row 2 .


find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.

s_point = get-dep(g-ofc, g-today).
                        
on "return" of browse b1
do:
    MESSAGE skip "Принять пин-конверт к карте " bkcard.contract_number " ?" 
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "АКЦЕПТ ПИН-КОНВЕРТА" UPDATE choice as logical.
          if choice = true then do:
            /* s_rowid1 = rowid(bkcard).*/
             find current bkcard exclusive-lock.
             assign bkcard.who2 = g-ofc
                    bkcard.whn2 = g-today.

             close query q1. 
             open query q1 for each bkcard where bkcard.bank = s_bank and bkcard.point = s_point and bkcard.whn2 = ? no-lock .
             browse b1:refresh().
          end.  
end.

                                                                        
   open query q1 for each bkcard where bkcard.bank = s_bank and bkcard.point = s_point and bkcard.whn2 = ? no-lock .
   enable all with frame fr1.
   wait-for "PF4" of frame fr1 focus browse b1.

