/* eknp_ps.p
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

/* eknp_ps.p
   ввод значений ЕКНП
   изменения от 01.07.00
*/

def input-output parameter v-r as char.
def var skp as char format 'x(2)' label 'КОд-отправитель'.
def var bkp as char format 'x(2)' label 'КБе-получатель '.
def var knp as char format 'x(3)' label 'Код назначения       '.

form skp bkp knp with frame pp side-label row 5   overlay 
    1  COLUMN  centered.

if v-r ne '' then do :
    skp = entry(1,v-r,',').
    bkp = entry(2,v-r,',').
    knp = entry(3,v-r,',').
end.

displ skp bkp knp with frame pp. pause 0.
                           
update skp  validate(
   can-find(codfr where codfr.codfr = 'locat' and codfr.code = substr(skp,1,1))    and 
   can-find(codfr where codfr.codfr = 'secek' and codfr.code = substr(skp,2)),
  'Ошибка в коде: 1 знак - признак резиденства (1 или 2), 2 знак - сектор экономики (от 0 до 9), без  пробелов!') with frame pp.
update bkp validate(
   can-find(codfr where codfr.codfr = 'locat' and codfr.code = substr(bkp,1,1))
   and
   can-find(codfr where codfr.codfr = 'secek' and codfr.code = substr(bkp,2)),
  'Ошибка в коде: 1 знак - признак резиденства, 2 знак - сектор экономики (без пробелов)') with frame pp.
update knp validate(
   can-find(codfr where codfr.codfr = 'spnpl' and codfr.code = knp),
  'Ошибка в коде, F2 - помощь.') with frame pp.
v-r = trim(skp) + ',' + trim(bkp) + ',' + trim(knp).
hide frame pp.

