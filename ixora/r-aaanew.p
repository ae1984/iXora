/* r-aaanew.p
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

/* r-aaanew.p
   */

{mainhead.i BTRNEW}  /* REPORT NEW ACCOUNT */

def var vfwhn like aaa.whn label "С ".
def var vtwhn like aaa.whn label "ПО ".
def var gbal  like aaa.opnamt.
def var vterm as int form "zzz9" init "   ".

{image1.i rpt.img}

vfwhn = g-today.
vtwhn = g-today.
if g-batch eq false then do
  on error undo, retry:
  update vfwhn vtwhn with no-box side-label centered row 10.


{image2.i}

  end.

{report1.i 63}
vtitle = "НОВЫЕ СЧЕТА С " + string(vfwhn) + " ПО " + string(vtwhn).
for each aaa where (aaa.regdt ge vfwhn) and (aaa.regdt le vtwhn)
               and (aaa.aaa ne "") and (aaa.cif ne ""):

{report2.i 132}
find lgr where aaa.lgr eq lgr.lgr.
if aaa.expdt ne ? and aaa.regdt ne ?
  then vterm = aaa.expdt - aaa.regdt.
  else vterm = 0.
gbal = aaa.cr[1] - aaa.dr[1].

{r-aaanew.f}

display
     aaa.aaa label "СЧЕТ" 
     aaa.cif label "КИФ" 
     aaa.name label "НАИМЕНОВАНИЕ КЛИЕНТА"
     aaa.expdt label "ДАТА ЗАКРЫТИЯ"
     aaa.rate label "СТАВКА"
     aaa.lgr  label "ГРУППА" 
     lgr.des label "НАИМЕНОВАНИЕ ГРУППЫ"
     vterm  label "СРОК" 
     aaa.regdt label "ДАТА РЕГ."
     aaa.opnamt label "СУММА ОТКР."
     gbal label "ОСТАТОК"
     with frame faaa.

end.

{report3.i}
{image3.i}
