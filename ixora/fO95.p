/* fO95.p
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

/*  the name of the program is fO95.p
    this program need for form & send to SWIFT field "Copy of the original
    message" in the MT_95 "Queries (Amendments)" & MT_96 "Answers" messages
   autor  - A.Zagrebin   date - xx.xx.95   RKB     
   */

  def shared var mt_send   as char format "x(3)".
  def shared var date_s    as char format "x(6)".

  def shared var cp_msgbox  as char extent 60 format "x(64)" initial [" "].
  def        var cp_msgdisp as char extent 19 format "x(64)" initial [" "].
  
  	
  def var      first_j  as int.  /* the first line of each screen */ 
  def var      j        as int.  /* work variable for masbox */
  def var      i        as int.  /* work variable for masdisp */
  def shared var xyz as int.  /* work variable for exit to the n95 scr*/
  def var      u1       as int  format "99". /* work var.last line of scr*/
  def var      z        as int  format "99". /* var. for frame-index   */
  def var      y        as int  format "99". /* var. for negative counter */
  def var      a        as logical. /*  go to SWIFT ? */
     
  def var      b        as int.  /* var for count blank line  */
  def var      x        as int.  /* var for "do" looping blank line */  


	
    form       cp_msgdisp    
        help " ENTER: to next field | F4: BACK | F10:DELETE line"
          no-label with overlay frame y_copy title 
     "  Copy of the original message MT" + mt_send + " (date " + date_s + ")"
          scroll 1 width 66 row 1 column 1 down.


/***************************************************************
*      copy of the fields of the original message              *
****************************************************************/

u1 = 0.
xyz = 0.
first_j = 0.
j = first_j + 1.
first_j = j.

        	     first_j = j.
        	do i = 1 to 19:
	           cp_msgdisp[i] = cp_msgbox[j].
	           j = j + 1.
         	end.


questies4:              
repeat:


    z = 1.     /*   z - this is a frame-index of the last line   */

      questies5:              
      repeat:
  
         if z < 1 then next questies4.
  
    
       display cp_msgdisp with frame y_copy overlay.
       
       set cp_msgdisp[z]
       GO-ON (PF4 F10 return cursor-up cursor-down) with frame y_copy.       

               if keyfunction(lastkey) = "END-ERROR" then do:
                 xyz = 1.
                 leave questies4.
               end.
                 
	       if lastkey = keycode("ENTER") then do:
	       
                              j = first_j.
			   do i = 1 to 19:
			   
                      run trtolat(INPUT-OUTPUT cp_msgdisp[i]).
			   
                               if substr(cp_msgdisp[i],1) eq ""  
                                    then do:
                                     xyz = 19 - i + 1. /* rem.of strings*/
                                     y = i + 1.
                                     b = 1.
                                       do x = y to 19:
                                          if substr(cp_msgdisp[x],1) eq ""  
                                             then do:
                                            b = b + 1. /*counter string blank*/
                                          end.
                                       end.
                                       
                                         if b = xyz then do:
                                            xyz = 0.
                                            leave.
                                         end.
                                         
                                         if b < xyz then do:
                                            xyz = 0.
                                            bell.
                                     message "The string must not be  blank  ".
                                              z = i.
                                             next questies5.
                                         end.
                               end.  
                                 
                                cp_msgbox[j] = cp_msgdisp[i].
				       j = j + 1.
			   end.

/*                           xyz = 2.   /* to field 75 */  */
                           leave questies4.

	       end.  /*  end of   " GO"  */
               


/*  was put  F10 -key  */

	       if keyfunction(lastkey) = "delete-line" then do:

				  
                          /* move from cp_msgdisp to cp_msgbox      */

				     j = first_j.
			      do i = 1 to 19:
				  cp_msgbox[j] = cp_msgdisp[i].
				     j = j + 1.
			      end.
			      
                          /*  delete line from screen */
                          
                            z = frame-index.
                            j = first_j + z.
                       do i = j to 60:
                          cp_msgbox[i - 1] = cp_msgbox[i].
                       end.   
                          cp_msgbox[60] = "". /*  last line into cp_msgbox */

                            /* form the next screen */

				j = first_j.
				do i = 1 to 19:
				    cp_msgdisp[i] = cp_msgbox[j].
					j = j + 1.
				end.
			     next questies5.


	       end.  /*   end "delete-line  */



	      
/* cursor - up */

	       if lastkey = keycode("cursor-up") then do:

		  if frame-index = 1 then do:

			   if first_j = 1 then do:
					   j = first_j.
				        do i = 1 to 19:
					   
                                 run trtolat(INPUT-OUTPUT cp_msgdisp[i]).
					   
					   cp_msgbox[j] = cp_msgdisp[i].
					     j = j + 1.
					end.

			      bell.
			      message  " At the top ".
			      undo.
			      next questies4.
			   end.

       /* move from cp_msgdisp to cp_msgbox      */

				j = first_j.
			          do i = 1 to 19:
				  cp_msgbox[j] = cp_msgdisp[i].
				    j = j + 1.
			      end.

       /* form the next screen */                                              
				       j = first_j - 1.
				       first_j = j.
				       do i = 1 to 19:
				       cp_msgdisp[i] = cp_msgbox[j].
				       j = j + 1.
				     end.
			       next questies4.

		  end.
		z = frame-index - 1.
		next questies5.
	       end. /* end of "cursor-up" */




/* cursor - down */

	       if lastkey = keycode("cursor-down") then do:

		  if frame-index = 19 then do:

			  if first_j + 18 = 60 then do:

					      j = first_j.
					   do i = 1 to 19:
					   
                                 run trtolat(INPUT-OUTPUT cp_msgdisp[i]).
					   
					   cp_msgbox[j] = cp_msgdisp[i].
					      j = j + 1.
					end.
			     bell.
			     message " At the bottom".
			     undo.
			     next questies5.
			  end.

       /* move from cp_msgdisp to cp_msgbox      */

				     j = first_j.
			          do i = 1 to 19:
				  cp_msgbox[j] = cp_msgdisp[i].
				     j = j + 1.
			      end.

       /* form the next screen */

				j = first_j + 1.
				    first_j = j.
				   do i = 1 to 19:
				    cp_msgdisp[i] = cp_msgbox[j].
					j = j + 1.
				end.
			     next questies5.

		  end.
		z = frame-index + 1.
		next questies5.
	       end. /* end of "cursor-down" */



end.  /*  questies 5  */

end.  /*  questies 4 */

        
