/* pars_mt970.p
 * MODULE
        Монитор        
 * DESCRIPTION
        Обрабатываем 970 выписку 
 RUN
 * CALLER
        KIS_ps
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        6.1
 * AUTHOR
        16.11.2006 tsoy
 * CHANGES

*/


def input parameter p-file as char.

define shared var g-today  as date.

def var v-ref as char	no-undo. 
def var v-i as integer	no-undo. 
def var v-delete-id as integer	no-undo. 
def var v-amt as decimal	no-undo. 
def var v-delete as logi	no-undo. 
def var v-was-21 as logi	no-undo. 
def var v-vex as char	no-undo.

def var v-s        as char extent 20 no-undo.
def var v-fname    as char no-undo.
def var v-time     as char no-undo.
def var v-str      as char no-undo.
def var v-result   as char no-undo.
def var v-direct   as integer no-undo.
def var v-id       as integer no-undo.
def var j          as integer no-undo.
def var v-curfld   as char no-undo.
def var v-curtype  as char no-undo.


def var v-mttype as char no-undo.
def var v-paysys as char no-undo.

define stream m-infl.


input stream m-infl from value(p-file).

repeat transaction:
      
      j = j + 1.

      import stream m-infl unformatted v-str .

      if trim(v-str) begins "\{1:" then 
      do: 


      end.

      if trim(v-str) begins "\{2:" then 
      do: 
         if substr(v-str, 4, 1) = "I" then v-direct = 1.
                                      else v-direct = 2.

         v-mttype = substr(v-str, 5, 3).

         if v-direct = 1 then do:
            if substr(v-str, 8, 6)  = "SGROSS" then v-paysys = "GROSS".
                                               else v-paysys = "CLEAR".
         end.
         else do:
              if substr(v-str, 18, 6)  = "SGROSS" then v-paysys = "GROSS".
                                                  else v-paysys = "CLEAR".
         end.

      end.

      if trim(v-str) begins ":20:" then 
      do:
         find last mt100 where mt100.rdt = g-today and mt100.paysys = v-paysys and mt100.f20 = substr(v-str, 5) no-lock no-error.
         if avail mt100 then 
         do: /* видимо попал при обработке  выписки*/
            return. 
         end.

         v-id = next-value (mt100seq).
         create mt100.
         assign
                mt100.id     = v-id
                mt100.rdt    = g-today
                mt100.fname  = p-file
            	mt100.tim    = time
                mt100.direct = v-direct                
                mt100.paysys = v-paysys
                mt100.mttype = v-mttype.

         mt100.f20 = substr(v-str, 5).
         find current mt100 no-lock no-error. 

      end.

      if trim(v-str) begins ":23:" then v-curtype = substr(v-str, 5). 

      if trim(v-str) begins ":62F:" then do: 
         if v-curtype = "FINAL" then 
         do:
               
               find last mt100 where mt100.id = v-id exclusive-lock no-error.                                  

               assign
                   mt100.f50type   = substr(v-str, 6, 1)
                   mt100.f32valdt  = date (substr(v-str, 11, 2) + "/" + substr(v-str, 9, 2) + "/" +  substr(v-str, 7, 2))
                   mt100.f32crc    = substr(v-str, 13, 3)
                   mt100.f32amt    = deci(replace(substr(v-str, 16), ",", ".")). 

               find current mt100 no-lock no-error. 

         end.
      end.

      if trim(v-str) begins ":61:" then 
      do: 
         v-ref = substr(v-str, index(v-str,"S") + 13).
         if v-curtype = "FINAL" then 
         do:
            v-amt = deci(replace( substr(v-str, 19, index(v-str,"S") - 19), ",", ".")).   

            if substr(v-str, index(v-str,"S") + 1, 3) = "D" then next.

            find mt100 where mt100.rdt = g-today and mt100.paysys = "CLEAR" and mt100.f20 = v-ref no-lock no-error.

            if not avail mt100 then 
            do:
               create mt100.
               assign
                      mt100.id         = next-value (mt100seq)
                      mt100.f50type    = substr(v-str, 9, 1)
                      mt100.fname      = p-file
                      mt100.rdt        = g-today
                      mt100.f32valdt   = g-today
                      mt100.paysys     = "CLEAR"
                      mt100.tim        = time
                      mt100.mttype     = substr(v-str, index(v-str,"S") + 1, 3)
                      mt100.f20        = v-ref
                      mt100.f52b       = substr(v-str, index(v-str,"S") + 4, 9)
                      mt100.f70assign  = " Создано автоматически при обработке финальной выписки клиринга "
                      mt100.f32amt     = v-amt
                      mt100.direct     = if mt100.f50type = "D" then 1 else 2.

               find current mt100 no-lock no-error. 

            end.
         end.

         if v-curtype = "PRESENT" then 
         do:
            /* в текущих выписках обрабатываемтолько ожидаемый кредит */
            if substr(v-str, 9, 2) = "EC" then 
            do: 
               
               v-ref = substr(v-str, index(v-str,"S") + 16).
               
               v-amt = deci(replace( substr(v-str, 20, index(v-str,"S") - 20),",", ".")).   
               
               find mt100 where mt100.rdt = g-today and mt100.paysys = "CLEAR" and mt100.f20 = v-ref no-lock no-error.

               if not avail mt100 then 
               do:

                  create mt100.

                  assign
                         mt100.id         =  next-value (mt100seq)
                         mt100.fname      = p-file
                         mt100.rdt        = g-today
                         mt100.f32valdt   = g-today
                         mt100.f50type    = "C" 
                         mt100.paysys     = "CLEAR"
                         mt100.tim        = time
                         mt100.mttype     = substr(v-str, index(v-str,"S") + 1 , 3)
                         mt100.f20        = v-ref
                         mt100.f52b       = substr(v-str, index(v-str,"S") + 4, 9)
                         mt100.f70assign  = " Создано автоматически при обработке промежуточной выписки клиринга " 
                         mt100.f32amt     = v-amt
                         mt100.direct     = 2.

                  find current mt100 no-lock no-error. 

               end.

            end. 
            else 
            do:
                 /*
                 v-ref = substr(v-str, index(v-str,"S") + 16).

                 v-amt = deci(replace( substr(v-str, 20, index(v-str,"S") - 20),",", ".")).   

                 find mt100 where mt100.rdt = g-today and mt100.paysys = "CLEAR" and mt100.f20 = v-ref no-lock no-error.

                 if not avail mt100 then 
                 do:
                    create mt100.
                    assign
                           mt100.id  =  next-value (mt100seq)
                           mt100.rdt        = g-today
                           mt100.f32valdt   = g-today
                           mt100.f50type     = "D" 
                           mt100.paysys     = "CLEAR"
                           mt100.tim        = time
                           mt100.mttype     = substr(v-str, index(v-str,"S") + 1 , 3)
                           mt100.f20        = v-ref
                           mt100.f52b       = substr(v-str, index(v-str,"S") + 4, 9)
                           mt100.f70assign  = " Создано автоматически при обработке промежуточной выписки клиринга " 
                           mt100.f32amt     = v-amt
                           mt100.direct     = 1.

                    find current mt100 no-lock no-error. 

                 end.
                 */
            end.
         end.
      end.

      if trim(v-str) begins "-\}" then release mt100. 

end /*repeat transaction*/.

input stream m-infl close.


