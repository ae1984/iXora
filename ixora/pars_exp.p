/* pars_exp.p
 * MODULE
        Монитор        
 * DESCRIPTION
        разбор файлов из каталога exp 
 RUN
 * CALLER
        KIS_ps
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        16.11.2006 tsoy
 * CHANGES
*/

def input parameter p-file as char.

define shared var g-today  as date.

def var v-100host   as char	no-undo. 
def var v-100path   as char	no-undo.
def var v-100path1  as char	no-undo.
def var v-ref as char	no-undo. 
def var v-i as integer	no-undo. 
def var v-delete-id as integer	no-undo. 
def var v-amt as decimal	no-undo. 
def var v-delete as logi	no-undo. 
def var v-was-21 as logi	no-undo. 
def var v-vex as char	no-undo.

define stream m-cpfl.
define stream m-infl.

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
def var v-21f      as char no-undo.

def var v-mttype as char no-undo.
def var v-paysys as char no-undo.

input stream m-infl from value(p-file).
repeat transaction:
      
      import stream m-infl unformatted v-str .

      find last mt100 where mt100.id = v-id exclusive-lock no-error.                                  

      if trim(v-str) begins "\{1:" then 
      do: 
         v-id = next-value (mt100seq).
         v-was-21 = false.
         next.
      end.

      if trim(v-str) begins "\{2:" then 
      do: 
         if substr(v-str, 4, 1) = "I" then v-direct = 1.
                                      else v-direct = 2.

         v-mttype = substr(v-str, 5, 3).

         if v-direct = 1 then do:
            if substr(v-str, 8, 6)     = "SGROSS" then v-paysys = "GROSS".
                                                  else v-paysys = "CLEAR".
         end.
         else do:
              if substr(v-str, 18, 6)  = "SGROSS" then v-paysys = "GROSS".
                                                  else v-paysys = "CLEAR".
         end.

         next.

      end.

      if trim(v-str) begins ":20:" then 
      do:

         find last mt100 where mt100.rdt = g-today and mt100.paysys = v-paysys and mt100.f20 = substr(v-str, 5) exclusive-lock no-error.
         if avail mt100 then do:
             delete mt100.
         end.
         release mt100.

         create mt100.
         assign
                mt100.id     = v-id
                mt100.rdt    = g-today
                mt100.fname  = p-file
                mt100.tim    = time
                mt100.direct = v-direct
                mt100.mttype = v-mttype
                mt100.paysys = v-paysys
                mt100.f20    = substr(v-str, 5).
         next.

      end.

      if avail mt100 then do: 
         if mt100.mttype = "910" and trim(v-str) begins ":21:" then mt100.f20 = substr(v-str, 5).
      end.

      if trim(v-str) begins ":32A:" then 
      do: 

         mt100.f32valdt  = date (substr(v-str, 10, 2) + "/" + substr(v-str, 8, 2) + "/" +  substr(v-str, 6, 2)).
         mt100.f32crc    = substr(v-str, 12, 3). 
         mt100.f32amt    = deci(replace(substr(v-str, 15), ",", ".")). 

      end.

      if trim(v-str) begins "\/P1\/" then 
      do: 
         if not ( index(v-str,"SET") > 0 or index(v-str,"UPDATE") > 0 ) then 
            mt100.f32amt    = deci(replace(substr(v-str, 9), ",", ".")). 
      end.

      if trim(v-str) begins ":50:" then 
      do: 

         mt100.f50type = substr(v-str, 6, 1).

         if not v-was-21 then  
            mt100.f50acc  = substr(v-str, 8, 9).

         if v-was-21 then 
         do: 
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then 
            	mt102.f50acc  = substr(v-str, 8, 9).
            find current mt102 no-lock no-error.
         end.

         /*  Операции прямого дебета */
         if substr(v-str, 8, 9) = "700161466" then 
         do:
            if substr(v-str, 6, 1) = "C"  then mt100.direct = 1.
         end. 
         if substr(v-str, 8, 9) = "100904100" then 
         do:
            if substr(v-str, 6, 1) = "C"  then mt100.direct = 1.
         end. 
         /* Это сумма чистых позиций клиринга по гроссу. Не учитываем т.к расчитываем в другом месте. */
         if substr(v-str, 8, 9) = "125162502" then 
         do:
            if substr(v-str, 6, 1) = "C"  then mt100.direct = 3.
         end. 
      end.

      if trim(v-str) begins "\/NAME\/" then 
      do: 

         if not v-was-21 then 
         do:
            if v-curfld = "50" then mt100.f50name = substr(v-str, 7).
            if v-curfld = "59" then mt100.f59name = substr(v-str, 7).
         end.

         if v-was-21 and v-curfld = "70" then 
         do: /* пенсионка */
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then mt102.f50name = substr(v-str, 7).
            find current mt102 no-lock no-error.
         end.

         if v-was-21 and v-curfld = "50" then 
         do: /* отправитель  */
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then mt102.f50name = substr(v-str, 7).
            find current mt102 no-lock no-error.
            mt100.f50name = "".
            mt100.f59name = "".
         end.

         if v-was-21 and v-curfld = "59" then do: /* отправитель  */
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then mt102.f59name = substr(v-str, 7).
            find current mt102 no-lock no-error.
            mt100.f50name = "".
            mt100.f59name = "".
         end.

      end.

      if trim(v-str) begins "\/RNN\/" then do: 
         if v-curfld = "50" then mt100.f50rnn = substr(v-str, 6).
         if v-curfld = "59" then mt100.f59rnn = substr(v-str, 6).
      end.

      if trim(v-str) begins "\/CHIEF\/" then mt100.f50chief = substr(v-str, 8).

      if trim(v-str) begins "\/MAINBK\/" then mt100.f50mainbk = substr(v-str, 9).

      if trim(v-str) begins "\/IRS\/" then do: 

         if v-curfld = "50" then mt100.f50irs = substr(v-str, 6).
         if v-curfld = "59" then mt100.f59irs = substr(v-str, 6).

      end.

      if trim(v-str) begins "\/SECO\/" then mt100.f50seco = substr(v-str, 7).

      if trim(v-str) begins ":52" then mt100.f52b = substr(v-str, 6).

      if trim(v-str) begins ":53" then mt100.f53 = substr(v-str, 6).

      if trim(v-str) begins ":54" then mt100.f54 = substr(v-str, 6).

      if trim(v-str) begins ":57" then mt100.f57b = substr(v-str, 6).

      if trim(v-str) begins ":59:" then 
      do: 
         mt100.f59b = substr(v-str, 5).
         v-curfld = "59" .
      end.

      if trim(v-str) begins ":59:" then 
      do: 
         if not v-was-21 then mt100.f59b = substr(v-str, 5).
         if v-was-21 then 
         do: 
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then mt102.f59rnn = substr(v-str, 5).
            find current mt102 no-lock no-error.
         end.
         v-curfld = "59" .
      end.

      if trim(v-str) begins ":70:" then v-curfld = "70".

      if avail mt100 then do: 
           if mt100.mttype = "102" and trim(v-str) begins ":21:" then 
           do: 
              v-21f      = substr(v-str, 5).
              v-curfld = "21" .
              v-was-21 = true.

              create mt102.
              assign
                     mt102.mtid = v-id
                     mt102.f21  = substr(v-str, 5).                    
           end.
      end.
      
      if trim(v-str) begins ":32B:" then do:
         find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
         if avail mt102 then 
         do:
                mt102.f32amt = deci(replace(substr(v-str, 9), ",", ".")).                    
                find current mt102 no-lock no-error.
         end.
      end.  

      if trim(v-str) begins "\/DATE\/" then mt100.f70date = date (substr(v-str, 11, 2) + "/" + substr(v-str, 9, 2) + "/" +  substr(v-str, 7, 2)).

      if trim(v-str) begins "\/VO\/" then mt100.f70vo = substr(v-str, 5).

      if trim(v-str) begins "\/PSO\/" then mt100.f70pso = substr(v-str, 6).

      if trim(v-str) begins "\/KNP\/" then mt100.f70knp = substr(v-str, 6).

      if trim(v-str) begins "\/SEND\/" then mt100.f70send = substr(v-str, 7).


      if trim(v-str) begins "\/PRT\/" then mt100.f70prt = substr(v-str, 6).

      if trim(v-str) begins "\/ASSIGN\/" then 
      do: 
         if not v-was-21 then mt100.f70assign = substr(v-str, 9).
         if v-was-21 then 
         do: 
            find last mt102 where mt102.mtid = v-id and mt102.f21 = v-21f exclusive-lock no-error.
            if avail mt102 then 
            do:
                mt102.f70rnn = substr(v-str, 9).
                find current mt102 no-lock no-error.
            end.
         end.
      end.


end /*repeat transaction*/.

input stream m-infl close.





