/* doxras2.p
 * MODULE

 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def new shared var vmc1 as integer.
def new shared var vmc2 as integer.
def new shared var vgod as integer.

def shared var seltxb as int.
def  shared var vprofit as char.
def  shared var v-name as char.
def  shared var v-dep as char format "x(3)".
def  shared var dt11 as date.
def  shared var dt22 as date.

def shared var sum11 as decimal.
def new shared var prz as integer.

/*def shared frame opt 
     v-dep label "Код департамента" 
        vprofit  label "Профит-центр" skip
       dt1 as date label  "ДАТА ОТЧЕТА С ..."
       dt2 as date label  "ПО ..."
       with row 8 centered side-labels.
  */
def var vgod1 as integer.
def var vgod2 as integer.

if not connected ("alga") then do:

  find txb where txb.txb = seltxb and txb.city = 998 no-lock no-error.
  if not avail txb then do:
     message "Не найдены настройки БД Alga~nв таблице COMM.TXB"
     view-as alert-box title "ОШИБКА". pause 300.
     return "0".
  end.
  connect value("-db " + txb.path + " -H " + txb.host + " -S " + txb.service + " -ld alga ").
end.
vmc1 = month(dt11).
vmc2 = month(dt22).
vgod1 = year(dt11).
vgod2 = year(dt22).

if vgod1 <> vgod2 then do:
  vmc1 = month(dt11). vmc2 = 12. vgod = vgod1.
  run list.p.
  vmc1 = 1. vmc2 =  month(dt22). vgod = vgod2.
  run list.p.
end.
else do:
  vmc1 = month(dt11). vmc2 = month(dt22). vgod = vgod1.
  run list.p.
end.

disconnect "alga".
