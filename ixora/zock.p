/* zock.p
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

/* checked */
/* zock.p
   OFFICIAL CHECK MAINTENANCE
*/

{mainhead.i "OCFILE"}

def var ans  as log.
def var vnew as log.
def var cmd as cha format "x(6)" extent 4
    initial ["NEXT","EDIT","DELETE","QUIT"].

form ock.ock
     ock.crc
     ock.gl 
     ock.geo  format "x(3)"   label "GEO#"
     ock.dam[1]  label "DEBIT" skip
     ock.cam[1]  label "CREDIT"
     ock.rdt
     ock.duedt   label "TO-DATE" format "99/99/99"
     ock.payee
     ock.zalog   label "ZALOG?"
     ock.lonsec  label "NODR."
     ock.risk    label "RISKS"
     ock.penny   label "PENNY%"
     ock.ncrc[3] label "ACCR.CURENCY" skip
     ock.dam[3]  label "ACCR.DEBIT"   skip
     ock.cam[3]  label "ACCR.CREDIT"
     ock.ref
     with row 3 centered 2 col frame ock.

form cmd
     with centered no-box no-label row 21 frame slct.

view frame ock.
pause 0.

outer:
repeat:
  clear frame ock.
  hide  frame slct.
  prompt-for ock.ock with frame ock.
  find ock using ock.ock no-error.
  if not available ock
    then do:
      bell.
      {mesg.i 1808} update ans.
      if ans eq false then next.
      create ock.
      assign ock.ock.
      update ock.crc with frame ock.
      vnew = yes.
    end.
  display 
     ock.gl 
     ock.geo format "x(3)"
     ock.dam[1]
     ock.cam[1]
     ock.rdt
     ock.duedt 
     ock.payee
     ock.zalog 
     ock.lonsec
     ock.risk  
     ock.penny 
     ock.ncrc[3]
     ock.dam[3] 
     ock.cam[3] 
     ock.ref
          with frame ock.
          
  display cmd auto-return with frame slct.

  inner:
  repeat:
      if vnew eq false then do:
         display 
           ock.gl 
           ock.geo format "x(3)"
           ock.dam[1]
           ock.cam[1]
           ock.rdt
           ock.duedt 
           ock.payee
           ock.zalog 
           ock.lonsec
           ock.risk  
           ock.penny 
           ock.ncrc[3]
           ock.dam[3] 
           ock.cam[3] 
           ock.ref
           with frame ock.
         choose field cmd with frame slct.
      end.
      if frame-value eq "EDIT" or vnew
      then do:
        set 
            ock.gl 
            ock.geo format "x(3)"
            ock.rdt
            ock.duedt 
            ock.payee
            ock.zalog 
            ock.lonsec
            ock.risk  
            ock.penny 
            ock.ref
            with frame ock.
            vnew = no.
      end.
    else if frame-value eq "QUIT" then return.
    else if frame-value eq "DELETE "
      then do:
        {mesg.i 0824} update ans.
        if ans eq false then next.
        find first jl where jl.acc = ock.ock and jl.jdt = g-today
        no-lock no-error.
        if  not available jl and
        ( ock.dam[1] eq ock.cam[1] ) and
        ( ock.dam[3] eq ock.cam[3] ) then
        delete ock.
        else do : bell. bell. message " Record wasn't deleted !!! ". end.
        pause.
        next outer.
      end.
    else if frame-value eq "NEXT"
      then do:
              next outer.
      end.
  end. /* inner */
end. /* outer */
