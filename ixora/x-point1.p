/* x-point1.p
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

/* x-point.p */

{mainhead.i  POINT}
{head-pty1.i

&var = "def new shared var vpoint like point.point.
        def var v-termlist as cha ."
&file = "point"
&where = " "
&form = " {point.f} "
&vseleform = "col 67 row 3 1 col no-label overlay"
&frame = "col 1 row 3 2 col width 66 "
&preupdt =
" update point.name point.regno
     validate(point.regno <> ' ' ,' Регистрационный номер !') with frame point.
  update point.licno
     validate(point.licno <> ' ' ,' Номер лицензии !') with frame point.
  update point.nalno
     validate(point.nalno <> ' ' ,' Налогов.номер !') with frame point.
  update point.addr point.contact point.tel with frame point."
&posupdt = "vpoint = point.point. "
&flddisp =
"point.point point.name point.regno point.licno point.addr point.contact
 point.tel point.nalno"
&newdft = " "
&delonly = " find ppoint where ppoint.point = point.point no-lock no-error.
             if not available ppoint then do :
                Message 'Сначала аннулируйте департаменты этого пункта.'.
                leave.
             end.
             "
&index = "point"
&prg1  = "p-term"
&prg2  = "p-dev"
&prg3  = "p-ofc"
&prg4  = "other"
&prg5  = "other"
&prg6  = "other"
&prg7  = "other"
&prg8  = "other"
&prg9  = "other"
&prg10 = "other"
&prg11 = "other"
&prg12 = "other"
&prg13 = "other"
&prg14 = "other"
&prg15 = "other"
&prg16 = "other"
&prg17 = "other"
&other1 = "Термлист"
&other2 = "Департамент"
&other3 = "Офицер"
&other4 = " "
&other5 = " "
&other6 = " "
&other7 = " "
&other8 = " "
&other9 = " "
&other10 = " "
&other11 = " "
&other12 = " "
&other13 = " "
&other14 = " "
&other15 = " "
&other16 = " "
&other17 = " "
}
