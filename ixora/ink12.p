/* ink12.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Настрока счетов внебаланса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.6.2.10
 * BASES
        BANK
 * AUTHOR
        07/10/2004 dpuchkov
 * CHANGES
        01.08.2005 dpuchkov перекомпиляция.
        19/05/2010 galina - увеличила формат вывода поля vnebal.usr и поля vnebal.k2
*/

{global.i}
def var str_p as char.

  define frame fdetails
      vnebal.usr format "x(7)" validate(vnebal.usr <> "", "Введите логин пользователя") label "Логин(F2-Помощь)"  help "F2-помощь" skip
      vnebal.k2 format "x(60)" label                                                          "ФИО пользователя" skip
      vnebal.gl format "x(6)" validate(vnebal.gl <> "", "Введите счет внебаланса")label       "Cчет внебаланса "
  with side-labels centered row 5 width 80.



on help of vnebal.usr in frame fdetails do:

def var vkey as cha form "x(16)".
def var vpoint like ppoint.point label "PUNKTS".
def var vdep like ppoint.depart label "DEPARTAMENTS".
define variable vch as integer initial 1.

/* bell. */
/* sasco {mesg.i 0951} update vkey. */

message "Поиск по 1)логину; 2)ФИО " update vch.
case vch:
   when 1 then message "Введите логин " update vkey.
   when 2 then message "Введите часть ФИО " update vkey.
   otherwise undo, return.
end case.

/* if keyfunction(lastkey) = "go" then do: */
if vch = 2 then do:
  vkey = "*" + vkey + "*".
  {itemlist.i &where = "ofc.name matches vkey "
         &file = "ofc"
         &frame = "row 5 centered scroll 1 12 down overlay "
         &predisp = " vpoint = ofc.regno / 1000 - 0.5.
                      vdep = ofc.regno - vpoint * 1000. "
         &flddisp = "ofc.ofc ofc.name vpoint vdep ofc.tit "
         &chkey = "ofc"
         &chtype = "string"
         &index  = "ofc"
         &funadd = "if frame-value = "" "" then do:
                      {imesg.i 9205}.
                      pause 1.
                      next.
                    end."
         &set = "a"}
end.
else
if vch = 1 then do:
  {itemlist.i
         &where = "ofc.ofc ge vkey"
         &file = "ofc"
         &frame = "row 5 centered scroll 1 12 down overlay "
         &predisp = " vpoint = ofc.regno / 1000 - 0.5.
                      vdep = ofc.regno - vpoint * 1000. "
         &flddisp = "ofc.ofc ofc.name vpoint vdep ofc.tit"
         &chkey = "ofc"
         &chtype = "string"
         &index  = "ofc"      /*       &file */
         &funadd = "if frame-value = "" "" then do:
                      {imesg.i 9205}.
                      pause 1.
                      next.
                    end."
         &set = "b"}
 end.
 vnebal.usr = frame-value.
 vnebal.k2 = ofc.name.
 displ vnebal.usr vnebal.k2 with frame fdetails.
end.






  DEFINE QUERY q1 FOR vnebal.
  define buffer buf for vnebal.
  def browse b1
     query q1
     displ
      vnebal.usr  format "x(7)" label "Логин "
      vnebal.k2 format "x(60)" label  "ФИО пользователя"
      vnebal.gl format "x(6)" label " Внеб счет"
  with 12 down title "Счета внебаланса" overlay.

  DEFINE BUTTON badd LABEL "Добавить"   .
  DEFINE BUTTON bRedakt LABEL "Изменить".
  DEFINE BUTTON brem LABEL "Удалить"    .
  DEFINE BUTTON bexit LABEL "Выход"     .

  def frame fr1 b1 skip badd bRedakt brem bexit  with centered overlay row 3 top-only  width 87.

  ON CHOOSE OF badd IN FRAME fr1
  do:
      create vnebal.
             update vnebal.usr vnebal.k2 vnebal.gl with frame fdetails.
        find last ofc where ofc.ofc = vnebal.usr no-lock no-error.
        if avail ofc then do:
           vnebal.k2 = ofc.name.
        end.

      hide frame fdetails.
      open query q1 for each vnebal no-lock.
  end.

  ON CHOOSE OF bRedakt IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (vnebal) exclusive-lock no-error.
     if avail buf then do:
        displ  vnebal.usr vnebal.gl vnebal.k2 with frame fdetails.
        update vnebal.usr vnebal.k2 vnebal.gl with frame fdetails.
        find last ofc where ofc.ofc = vnebal.usr no-lock no-error.
        if avail ofc then do:
           vnebal.k2 = ofc.name.
        end.
        hide frame fdetails.
        open query q1 for each vnebal no-lock.
     end.

  end.



  ON CHOOSE OF brem IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (vnebal) exclusive-lock no-error.
     if avail buf then do:
        delete buf.
        browse b1:refresh().
     end.
  end.

  ON CHOOSE OF bexit IN FRAME fr1
  do:
     hide frame fr1.
     APPLY "WINDOW-CLOSE" TO BROWSE b1.
  end.


  open query q1 for each vnebal no-lock by vnebal.usr DESCENDING.
  b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
  ENABLE all with frame fr1 centered overlay top-only.
  apply "value-changed" to b1 in frame fr1.
  WAIT-FOR WINDOW-CLOSE of frame fr1.

