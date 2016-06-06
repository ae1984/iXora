/* zock1.p
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
/* zock1.p
   OFFICIAL CHECK MAINTENANCE
*/

{mainhead.i "OCFILE"}

def var ans  as log.
def var acrbal like jl.dam.
def var vnew as log.
def var cmd as cha format "x(6)" extent 4
    initial ["NEXT","EDIT","DELETE","QUIT"].

form ock.ock
     ock.crc
     ock.gl 
     ock.geo format "x(3)"    label "GEO#"
       validate(can-find(geo where geo.geo eq geo),"")
     ock.dam[1]  label "DEBIT" skip
     ock.cam[1]  label "CREDIT"
     ock.rdt
     ock.duedt   label "BEIG.DATA" format "99/99/99"
     ock.payee
     ock.zalog   label "IEґ§L…TS AKT.?"
     ock.lonsec  label "NODRO№."
        validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
        or ock.lonsec eq 0, "")
     ock.risk    label "RISKS"
        validate(can-find(risk where risk.risk eq risk) 
        or ock.risk eq 0, "")
     ock.penny   label "SODA%"  validate(penny <= 100,"")
     ock.ncrc[3] label "UZKR.VAL®TA"  skip
     acrbal      label "UZKR.BILANCE"  skip
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
      message "Record not found !".
      next.
    end.
  acrbal = ock.cam[3] - ock.dam[3].
  display 
     ock.gl
     ock.crc 
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
     acrbal 
     ock.ref
          with frame ock.
          
  display cmd auto-return with frame slct.

  inner:
  repeat:
      if vnew eq false then do:
         display 
           ock.gl
           ock.crc 
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
           acrbal 
           ock.ref
           with frame ock.
         choose field cmd with frame slct.
      end.
      if frame-value eq "EDIT" or vnew
      then do:
        set 
            /*ock.gl */
             ock.geo format "x(3)"
            /*ock.rdt*/
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
        bell. bell. message " Record wasn't deleted !!! ".
        pause.
        next outer.
      end.
    else if frame-value eq "NEXT"
      then do:
              next outer.
      end.
  end. /* inner */
end. /* outer */
