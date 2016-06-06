/* kassir.p
 * MODULE
        Касса
 * DESCRIPTION
       Привязка логинов кассиров к кассам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-12 Настройка кассиров
 * AUTHOR
        18.08.2005 dpuchkov
 * CHANGES
        03.09.05  dpuchkov добавил возможность переключения очередей.

*/

{global.i}

def var i-cas as integer.
def var v-cas as char.
  define frame fcas
      cashier.ofc format "x(6)" validate(cashier.ofc <> "", "Введите логин пользователя") label "Логин(F2-Помощь)"  help "F2-помощь" skip
      cashier.name format "x(35)" label                                                          "ФИО пользователя" skip
      cashier.kasnum format "x(17)" validate(lookup(cashier.kasnum,"ЗАВ КАССОЙ,КАССА-1,КАССА-2,КАССА-3,КАССА-4,КАССА-5,МЕНЕДЖЕР(ФИЗ.ЛИЦ),МЕНЕДЖЕР(ЮР.ЛИЦ)") <> 0 , "Выберите кассу") label  "Касса(F2-Помощь)"
  with side-labels centered row 5.



on help of cashier.kasnum in frame fcas do:
       run sel2(" КАССЫ ", " 1. ЗАВ КАССОЙ | 2. КАССА-1(ЮР. ЛИЦ) | 3. КАССА-2(ЮР. ЛИЦ) | 4. КАССА-3(ЮР. ЛИЦ) | 5. КАССА-4(ФИЗ.ЛИЦ) | 6. КАССА-5(ФИЗ.ЛИЦ) | 7. МЕНЕДЖЕР(ФИЗ.ЛИЦ) | 8. МЕНЕДЖЕР(ЮР.ЛИЦ) | ВЫХОД", output i-cas).
       if i-cas = 1 then v-cas = "ЗАВ КАССОЙ".
       if i-cas = 2 then v-cas = "КАССА-1".
       if i-cas = 3 then v-cas = "КАССА-2".
       if i-cas = 4 then v-cas = "КАССА-3".
       if i-cas = 5 then v-cas = "КАССА-4".
       if i-cas = 6 then v-cas = "КАССА-5".
       if i-cas = 7 then v-cas = "МЕНЕДЖЕР(ФИЗ.ЛИЦ)".
       if i-cas = 8 then v-cas = "МЕНЕДЖЕР(ЮР.ЛИЦ)".
       if i-cas = 9 then return.
       cashier.kasnum = v-cas.
 if (i-cas = 2 or i-cas = 3 or i-cas = 4  or i-cas = 8) then cashier.prim = "1".
 if (i-cas = 5 or i-cas = 7) then cashier.prim = "2".
 if i-cas = 1 then cashier.prim = "3".
       displ cashier.kasnum with frame fcas.
end.



on help of cashier.ofc in frame fcas do:
def var vkey as cha form "x(16)".
def var vpoint like ppoint.point label "PUNKTS".
def var vdep like ppoint.depart label "DEPARTAMENTS".
define variable vch as integer initial 1.
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
 cashier.ofc = frame-value.
 cashier.name = ofc.name.
 displ cashier.ofc cashier.name with frame fcas.
end.




  DEFINE QUERY q1 FOR cashier.
  define buffer buf for cashier.
  def browse b1
     query q1
     displ 
       cashier.ofc  format "x(6)" label "Логин "
       substr(cashier.name, 2, 50) format "x(35)" label "ФИО пользователя"
       cashier.kasnum format "x(17)" label " Касса"
  with 12 down title "НАСТРОЙКА офицеров касс" overlay.


  DEFINE BUTTON badd LABEL "Добавить"   .
  DEFINE BUTTON bRedakt LABEL "Изменить".
  DEFINE BUTTON brem LABEL "Удалить"    .
  DEFINE BUTTON bexit LABEL "Выход"     .

  def frame fr1 b1 skip badd /*bRedakt*/ brem bexit  with centered overlay row 3 top-only.

  ON CHOOSE OF badd IN FRAME fr1
  do:
      create cashier.
             update cashier.ofc cashier.name cashier.kasnum with frame fcas.
        find last ofc where ofc.ofc = cashier.ofc no-lock no-error.
        if avail ofc then do:
           cashier.name = ofc.name. 
        end.
cashier.name = cashier.prim + cashier.name.

      hide frame fcas.
      open query q1 for each cashier no-lock.
  end.

/*
  ON CHOOSE OF bRedakt IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (vnebal) exclusive-lock no-error.
     if avail buf then do:
        displ  cashier.ofc cashier.name cashier.kasnum with frame fcas.
        update cashier.ofc cashier.name cashier.kasnum with frame fcas.
        find last ofc where ofc.ofc = cashier.ofc no-lock no-error.
        if avail ofc then do:
           cashier.name = ofc.name. 
        end.
        hide frame fcas.
        open query q1 for each cashier no-lock.
     end.
  end.
*/


  ON CHOOSE OF brem IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (cashier) exclusive-lock no-error.
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


  open query q1 for each cashier no-lock by cashier.ofc DESCENDING.
  b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
  ENABLE all with frame fr1 centered overlay top-only.
  apply "value-changed" to b1 in frame fr1.
  WAIT-FOR WINDOW-CLOSE of frame fr1.











