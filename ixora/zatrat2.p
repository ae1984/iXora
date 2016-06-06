/* zatrat2.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        zatratdat.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-12
 * AUTHOR
        06/06/05 nataly
 * CHANGES
        22.06.06 nataly ускорила отчет 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/



def shared var seltxb as int.
def shared var v-dep as char.
def shared var depzl as char.

def shared var m1 as integer.
def shared var m2 as integer.
def shared var y1 as integer.

def new shared var vmc1 as integer.
def new shared var vmc2 as integer.
def new shared var vgod1 as integer.
def new shared var v-name as char.

def new shared var sum11 as decimal.
def new shared var prz as integer.

/*def shared frame opt 
     v-dep label "Код департамента" 
        vprofit  label "Профит-центр" skip
       dt1 as date label  "ДАТА ОТЧЕТА С ..."
       dt2 as date label  "ПО ..."
       with row 8 centered side-labels.
  */

/*message 'seltxb= ' seltxb.*/

find bank.codfr where codfr.codfr = 'sproftcn' and codfr.code = v-dep no-lock no-error.
if avail bank.codfr then v-name = codfr.name[1].
if not connected ("alga") then do:

  find txb where txb.txb = seltxb and txb.city = 998 no-lock no-error.
  if not avail txb then do:
     message "Не найдены настройки БД Alga~nв таблице COMM.TXB"
     view-as alert-box title "ОШИБКА". pause 300.
     return "0".
  end.
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga ").
end.
vmc1 = m1.
vmc2 = m2.
vgod1 = y1.
/*if depzl <> "" then  run zatrat3.
 else run zatrat31.*/
/*запускаем для всех департаментов  - считаем кол-во сотрудников по деп-ту и по банку в целом */

run zatrat31.

disconnect "alga".
