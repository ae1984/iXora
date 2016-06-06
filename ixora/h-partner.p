/* h-partner.p
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

/* h-partner.p Валютный контроль
   help на инопартнеров

   18.10.2002 nadejda создан
   17.03.2008 galina добавлен return
*/

{vc.i}
{global.i}
define var vselect as cha format "x".
def var vcnt as int.
def var vvname as cha . 
/*message "N) Название" update vselect.*/


/*if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" 
then do:*/
 {itemlist.i 
   &updvar  = "def var vname like vcpartners.name.
               {imesg.i 2808} update vname.
               vvname = '*' + vname + '*' . "
   &where = "  caps(trim(vcpartners.name))  MATCHES vvname "
   &form = " vcpartners.partner vcpartners.name vcpartners.formasob format 'x(5)' vcpartners.country "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "name"
   &chkey = "partner"
   &chtype = "string"
   &file = "vcpartners"
   &flddisp = " vcpartners.partner vcpartners.name vcpartners.formasob vcpartners.country "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "N"
   }
   
   return frame-value.
/*end.*/


