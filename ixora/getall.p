/* getall.p
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

/*  the name of the program is getall.p
    this program need for form & send to SWIFT "Queries (Amendments)"
    messages
   autor  - A.Zagrebin   date - xx.xx.95   RKB     
   */

  def shared var msgtype               as char format "x(1)".
  def shared var dest                  as char format "x(12)".
  def shared var mt_send   as char format "x(3)".
  def shared var date_s    as char format "x(6)".
  def shared var sess_sequ as char format "x(10)".  
  def input-output parameter cmdk      as char format "x(70)".
  def shared var sess                  as char format "x(4)".
  def shared var sequ                  as char format "x(6)".
  def shared var relref                as char format "x(16)".
  def shared var relrel                as char format "x(16)".
  def shared var cp_msgbox  as char extent 60 format "x(64)".
  def shared var cp_msgdisp as char extent 19 format "x(64)".
  def var    fromdate       as char format "x(8)".
  def var    todate         as char format "x(8)".
  def var      first_j  as int.  /* the first line of each screen */ 
  def var      j        as int.  /* work variable for masbox */
  def var      i        as int.  /* work variable for masdisp */
  def shared var xyz as int.  /* work variable for exit to the n95 scr*/
  def var      z        as int  format "99". /* var. for frame-index   */
  def var      ibl1         as int format "99". 
  def var      b            as int.  /* var for count blank line  */

  def shared var     addrbank      as char format "x(70)".
  def shared var     foundd        as char format "x(12)".
  def var foundm                   as char format "x(70)".

  def var       mtdat   as char format "x(10)".
  def var      masmsg   as char extent 20 format "x(29)" initial [" "].
  def var      msgdis   as char extent 5  format "x(29)" initial [" "].

  
/*******************************************************************/

main:
do on error undo,retry:

  input through value(cmdk) no-echo.

  
  set addrbank with frame indata  no-box no-labels width 80.
  
  
  if addrbank eq "NO FOUND" then do :
  
    message "CAN'T FIND MESSAGE WITH TRN " + "'" + relref + "'" +
             " IN THE SWIFT ARCHIVE ".
    bell.
    input close.
    xyz = 2.
    leave main.
    undo.
  end.
  
  if addrbank eq "USAGE:" then do :
  
    message "CAN'T FIND MESSAGE WITH 'USAGE' ".
    bell.
    input close.
    xyz = 2.
    leave main.
    undo.
    end.


    number:
    repeat i = 1 to 20:
    

          if substr(addrbank,9,1) eq " " then do:
             ibl1 = 8.
             foundd = substr(addrbank,1,8).
             end.
          else if substr(addrbank,10,1) eq " " then do:
             ibl1 = 9.
             foundd = substr(addrbank,1,9).
             end.
          else if substr(addrbank,11,1) eq " " then do:
             ibl1 = 10.
             foundd = substr(addrbank,1,10).     
             end.
          else if substr(addrbank,12,1) eq " " then do:
             ibl1 = 11.
             foundd = substr(addrbank,1,12).
             end.
         
         mtdat = substr(addrbank,ibl1 + 2,10). /*  MT + data  */
         
         if ibl1 > 8  then masmsg[i] = "   " + foundd + "  " + mtdat.
         
         else masmsg[i] = "   " + foundd + "      " + mtdat.

         repeat j = 1 to 60:
         
          set addrbank with no-box no-labels no-attr-space width 80.
        
            if substr(addrbank,1,1)  eq "$" then do:
                 set addrbank with no-box no-labels no-attr-space width 80.
               if substr(addrbank,1,2)  eq "-}" then do:
                  leave number.
               end.
             next number.
            end.
        end.  /*   repeat  (check) */
    end.      /*  number  */
    
  input close.


  b = 0.
  
  do i = 1 to 20:
     if substr(masmsg[i],1) ne "" then b = b + 1.
  end.
  
if b = 1 then leave main.

  
  form msgdis help " Choose one line & hit ENTER "
       with row 5 3 col centered no-labels
       title " Sender/Dest   MT   Date  "
       overlay frame swarmsg.
       
  xyz = 0.
  first_j = 0.
  j = first_j + 1.
  first_j = j.
  
            do i = 1 to 5:
              msgdis[i] = masmsg[j].
              j = j + 1.
            end.
            
       run2:
       repeat:
       
         z = 1.
         
             run3:
             repeat:
             
             if z < 1 then next run2.
             
             display msgdis with frame swarmsg overlay.
             
             set msgdis[z]
             go-on (PF4 return cursor-up cursor-down)
             with frame swarmsg.
             
               if keyfunction(lastkey) = "END-ERROR" then do:
                 xyz = 1.
                 leave main.
               end.
                       
           /* cursor - up */

	       if lastkey = keycode("cursor-up") then do:

		  if frame-index = 1 then do:

			   if first_j = 1 then do:
					   j = first_j.
				        do i = 1 to 5:
					   masmsg[j] = msgdis[i].
					     j = j + 1.
					end.

			      bell.
			      message  " At the top ".
			      undo.
			      next run2.
			   end.

       /* move from masdisp to masbox      */

				j = first_j.
			          do i = 1 to 5:
				  masmsg[j] = msgdis[i].
				    j = j + 1.
			      end.

                    /* form the next screen */                                              
				       j = first_j - 1.
				       first_j = j.
				       do i = 1 to 5:
				       msgdis[i] = masmsg[j].
				       j = j + 1.
				     end.
			       next run2.

		  end.
		z = frame-index - 1.
		next run3.
	       end. /* end of "cursor-up" */


        /* cursor - down */

	       if lastkey = keycode("cursor-down") then do:

		  if frame-index = 5 then do:

			  if first_j + 4 = 20 then do:

					      j = first_j.
					   do i = 1 to 5:
					   masmsg[j] = msgdis[i].
					      j = j + 1.
					end.
			     bell.
			     message " At the bottom".
			     undo.
			     next run3.
			  end.

       /* move from masdisp to masbox      */

				     j = first_j.
			          do i = 1 to 5:
				  masmsg[j] = msgdis[i].
				     j = j + 1.
			      end.

       /* form the next screen */

				j = first_j + 1.
				    first_j = j.
				   do i = 1 to 5:
				    msgdis[i] = masmsg[j].
					j = j + 1.
				end.
			     next run3.

		  end.
		z = frame-index + 1.
		next run3.
	       end. /* end of "cursor-down" */

        /*    hit " Enter "   */

	       if lastkey = keycode("ENTER") then do:
	       
	            if frame-index < 1 then next run2.

	             
		   msgdis[frame-index] = frame-value.
		   
		   msgdis[frame-index] = trim(msgdis[frame-index]).
		   			   
                            if substr(msgdis[frame-index],1) eq ""  
                                  then do:  /*leave section2.*/
                                   bell.
                                message "The string must not be  blank  ".
                                   undo,retry.
                             end.
					
		  

  input through value(cmdk) no-echo.

  
  set addrbank with frame indata  no-box no-labels width 80.
  
  
  if addrbank eq "NO FOUND" then do :
  
    message "CAN'T FIND MESSAGE WITH TRN " + "'" + relref + "'" +
             " IN THE SWIFT ARCHIVE ".
    bell.
    input close.
    xyz = 2.
    leave main.
    undo.
  end.
  
  if addrbank eq "USAGE:" then do :
  
    message "CAN'T FIND MESSAGE WITH 'USAGE' ".
    bell.
    input close.
    xyz = 2.
    leave main.
    undo.
    end.

    if frame-index <> 1 then do:
   
      do i = 1 to frame-index - 1:
       mda:
        repeat:
            set addrbank with no-box no-labels no-attr-space width 80.    
                 if substr(addrbank,1,1)  eq "$" then do:
                    leave mda.
                 end.          
        end.
      end.  
   
        set addrbank with no-box no-labels no-attr-space width 80.
    end.  


    foundm = addrbank.
    
       
   do i = 1 to 60:
      cp_msgbox[i] = "".
   end.
   
   do i = 1 to 19:
      cp_msgdisp[i] = "".
   end.

/**************************************/

         if substr(addrbank,1,8) ne substr(dest,1,8) then do:
            message "Destination " + "'" + dest + "'" + " is wrong.
The original msg has " + "'" + substr(foundm,1,8) + "'" + " destination".
            bell.
            xyz = 2.
            input close.
            leave run2.
        end.

/****************************************/

        
       solo:
       repeat i = 1 to 60:
       
          set addrbank with no-box no-labels no-attr-space width 80.
              cp_msgbox[i] = addrbank.
              
               if substr(addrbank,1,1)  eq "$" then do:
                  cp_msgbox[i] = "".
                  leave solo.
               end.
       end.
           
  input close.

          if substr(foundm,9,1) eq " " then do:
             ibl1 = 8.
             foundd = substr(foundm,1,8).
             end.
          else if substr(foundm,10,1) eq " " then do:
             ibl1 = 9.
             foundd = substr(foundm,1,9).
             end.
          else if substr(foundm,11,1) eq " " then do:
             ibl1 = 10.
             foundd = substr(foundm,1,10).     
             end.
          else if substr(foundm,12,1) eq " " then do:
             ibl1 = 11.
             foundd = substr(foundm,1,12).
             end.
             

                if substr(foundd,9,1) ne " " then do:
                   substr(foundd,12,1) = substr(foundd,11,1).
                   substr(foundd,11,1) = substr(foundd,10,1).
                   substr(foundd,10,1) = substr(foundd,9,1).
                   substr(foundd,9,1)  = "X".
                end.
                
            mt_send = substr(foundm,ibl1 + 2,3).
            
            if msgtype ne substr(mt_send,1,1) then do:
              message "Category msg not equal category of the original msg".
              bell.
              xyz = 2.
              leave main.
              undo.
            end.
            
            date_s = substr(foundm,ibl1 + 6,6).     
            sess   = substr(foundm,ibl1 + 13,4).     
            sequ   = substr(foundm,ibl1 + 18,6).     

           sess_sequ = sess + sequ.
           

                
/*********************************************/

    run fO95.  /* show copy of msg   */
    
/*********************************************/    
        
        
        if xyz = 1 then do:
           xyz = 0.
           msgdis[z] = "   " + msgdis[z].
           next run3.
           undo.
        end.
        
        

            xyz = 3.
            leave main.

	       end.                     /*  enter        */
	       
	      end. /*  run3   */
	       
     end.          /*  run2   */

/*******************************************************************/        
end.   /*   main   */
