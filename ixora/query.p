/* query.p
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

/*  the name of the program is QUERY.P
    this program need for form & send to SWIFT "Queries (Amendments)"
    messages
   autor  - A.Zagrebin   date - xx.xx.95   RKB     
   */
    
{global.i}
  def new shared var      msgtype  as char format "x(1)".
  def new shared var      dest     as char format "x(12)".
  def new shared var      priority as char format "x(1)" initial ["N"].  
  def new shared var      itype    as char format "x(5)" initial ["MT195"].
  def new shared var      trn      as char format "x(16)".
  def new shared var      relref   as char format "x(16)".
  
  def new shared var      relrel   as char format "x(16)".
 
  def new shared var      mt_send  as char format "x(3)".
  def new shared var      date_s   as char format "x(6)".
  def new shared var      sess_sequ   as char format "x(10)".
  def new shared var      cmdk     as char format "x(70)".
  def new shared var      sess     as char format "x(4)".
  def new shared var      sequ     as char format "x(6)".

  def new shared var masbox     as char extent 35 format "x(50)" initial [" "].
  def            var masdisp    as char extent 14 format "x(50)" initial [" "].
  def new shared var cp_msgbox  as char extent 60 format "x(64)" initial [" "].
  def new shared var cp_msgdisp as char extent 19 format "x(64)" initial [" "].
  
  def new shared var narr_box   as char extent 20 format "x(35)" initial [" "].
  def new shared var narr_disp  as char extent 7 format "x(35)" initial [" "].
  def var      live_ar    as char extent 3 format "x(29)" initial
  ["        LIVE archive",
   "        ALL  archive",
   "    From date  -  To date"].
  
  def new shared var query_6    as char extent  6 format "x(35)" initial [" "].
  
  def var      data       as char format "x(20)".
  def var      date1      as char format "x(20)".
  def var      fromdate   as char format "x(8)".
  def var      todate     as char format "x(8)".
  
  def new shared var sim_sim    as char format "x(1)"  initial ["N"].
  	
  def var      first_j  as int.  /* the first line of each screen */ 
  def var      j        as int.  /* work variable for masbox */
  def var      i        as int.  /* work variable for masdisp */
  def new shared var xyz as int.  /* work variable for exit to the n95 scr*/
  def var      u1       as int  format "99". /* work var.last line of scr*/
  def var      z        as int  format "99". /* var. for frame-index   */
  def var      y        as int  format "99". /* var. for negative counter */
  def var      a        as logical. /*  go to SWIFT ? */
  def var    quest      as logical. /*  is it related with SWIFT ? */

  def var      ibl1        as int format "99". 
     
  def var      b        as int.  /* var for count blank line  */
  def var      x        as int.  /* var for "do" looping blank line */  
  def new shared var rela as int.  /* it's sign about related or not msg  */

  def new shared var addrbank      as char format "x(70)".
  def var foundm                   as char format "x(50)".
  def new shared var foundd        as char format "x(12)".
  def var result   as int  format "9".  


form
	    "Message Type :" at 4
	    msgtype
	    format "x(1)"    at 19 no-label auto-return
	    help "Put digit from 1 to 9  "
	    "95"             at 20
	    "DESTINATION:"   at 30
	    dest
	    format "x(12)"   at 44 no-label auto-return
	    help "Format 6a6b"
	    "Priority:"      at 62
	    priority
	    format "x(1)"    at 72 no-label auto-return
	    help "Put only N(normal) or U(urgent)"
	    skip
	    "M :20 /transaction reference number :"    at 4
	    trn
	    format "x(16)"    at 41 no-label auto-return
	    help "Format 16x"
	    skip
	    "M :21 / related reference           :"    at 4
	    relref
	    format "x(16)"    at 41 no-label auto-return
	    help "Format 16x"
	    skip
	    "O :11"                                    at 4
	    sim_sim           at  9 no-label
	    help "  S - message sent, R - message received"
	    "/ MT and date of original msg :"          at 10
	    mt_send
	    format "x(3)"     at 41 no-label auto-return
	    skip
	    date_s
	    format "x(6)"     at 41 no-label auto-return
	    skip
	    sess_sequ
	    format "x(10)"    at 41 no-label auto-return
	 help "1-st line MT , 2-nd line date , 3-th line session & sequens #"
            skip	    
	    "M :75 / Queries                     :"    at 4
	    query_6           at 41 no-label
	    help " F1: SWIFT | cursor-up | cursor-down  "
            skip	    
	    "O :77A/ Narrative                   :"    at 4
            narr_disp         at 41 no-label
	    help "(Format 20*35)|F1:SWIFT |F9:INSERT |F10: DELETE"

      with frame n95 side-labels width 80
      title "    Q U E R I E S  (Amendments)   "
      row 1 centered down.
      
    form       masdisp  
        help "(Format 35*50x) F1:Send to SWIFT |F9:INSERT |F10:DELETE"
           no-label with overlay frame yy title 
 " O :79 / Narrative description of the message "
       	   scroll 1 width 52 row 6 column 1 down.
	
    form
          "from "             at 2
          fromdate
          format     "x(8)"   at 7  no-label auto-return
          help "   PUT DATE   - format  DD.MM.YY  "
          " to "              at 16
          todate
          format     "x(8)"   at 20  no-label auto-return
          help "   PUT DATE   - format  DD.MM.YY  "
          
          with frame arc side-labels width 40
          overlay title color normal " Range of dates "
          row 10 centered 1 down.
          
                    
/*  at the begining */
	
main:	
repeat on error undo,retry:

/*   preparation some variables and array fields  */ 

rela = 0.
quest = true.	   
a = true.
u1 = 0.
xyz = 0.
first_j = 0.
j = first_j + 1.
first_j = j.


do on error undo,retry:
      set msgtype GO-ON (PF4 )
      with overlay no-label frame n95.
      
        if keyfunction(lastkey) = "END-ERROR" then leave main.
      
      
	 if substr(msgtype,1,1) le "0" or substr(msgtype,1,1) gt "9"
	  then do:
	    bell.
	    undo,retry.
	   end.
end.	   
     display msgtype with frame n95.


do on error undo,retry :
   update dest
    with overlay no-label
    frame n95.

   run trtolat(INPUT-OUTPUT dest).
      dest = caps(trim(dest)).
       if (index(dest,  " ") ne 0)    or
	  (dest              eq "")   or
	  (length(dest)       le 7)   or
	  substr(dest,1,1) lt "A"  or substr(dest,1,1) gt "Z"  or
	  substr(dest,2,1) lt "A"  or substr(dest,2,1) gt "Z"  or
	  substr(dest,3,1) lt "A"  or substr(dest,3,1) gt "Z"  or
	  substr(dest,4,1) lt "A"  or substr(dest,4,1) gt "Z"

       then do:
	 bell.
	 undo,retry.
       end.


/*  checking bic code for destination    */

     display dest with frame n95.
  if msgtype eq "1" or msgtype eq "2" then do:
 	run swiftext(INPUT	dest,
	             INPUT	1,
  		     INPUT-OUTPUT result).

  	if result ne 0 then do: bell. undo,retry. end.
  end.	
  else do:
 	run swiftext(INPUT	dest,
	  	     INPUT	0,
  		     INPUT-OUTPUT result).

  	if result ne 0 then do: bell. undo,retry. end.  
  end.

end.       
     display dest with frame n95.

do on error undo,retry:
   update priority format "x(1)"
     with overlay no-label frame n95.
      priority = caps(priority).
	 if priority ne "U" and
	    priority ne "N"
	then do:
	 bell.
	 undo,retry.
	end.
end.
	    display priority with frame n95.

do on error undo,retry:
  update trn
  with  frame n95.
  
   run trtolat(INPUT-OUTPUT trn).
       trn = trim(trn).
  
    if (trn             eq "") or 
       substr(trn,1,1)  eq ":" or
       substr(trn,1,1)  eq "-"
     then do:
       bell.
       message "The first symbol must not be  :  or  -  ".
       undo,retry.
     end.
     
    if substr(trn,1,1)  eq "/"
       then do:
          bell.
          message "The first symbol must not be  /  ".
          undo,retry.
       end.
     
    if (index(trn,"//")  ne  0)
        then do:
           bell.
           message "Two consecutive slashes  //  are prohibited".
           undo,retry.
        end.
 
      i = length(trn).
    if substr(trn,i,1)  eq "/"
       then do:
          bell.
          message "The last symbol must not be  /  ".
          undo,retry.
       end.
       
     
end.
	   display trn with frame n95.

m21:	   
repeat on error undo,retry:
  update relref with frame n95.

      run trtolat(INPUT-OUTPUT relref).
          relref = trim(relref).  
          
      if (relref   eq  "")   then do:
         bell.
         undo,retry.
      end.
  
      if substr(relref,1,1)  eq ":" or
         substr(relref,1,1)  eq "-"
         then do:
           bell.
           message "The first symbol must not be  :  or  -  ".
          undo,retry.
      end.
      
    if substr(relref,1,1)  eq "/"
       then do:
          bell.
          message "The first symbol must not be  /  ".
          undo,retry.
       end.
     
    if (index(relref,"//")  ne  0)
        then do:
           bell.
           message "Two consecutive slashes  //  are prohibited".
           undo,retry.
        end.
 
      i = length(relref).
    if substr(relref,i,1)  eq "/"
       then do:
          bell.
          message "The last symbol must not be  /  ".
          undo,retry.
       end.
      
	   display relref with frame n95.

   relrel = trim(relref).
	   
pause 0.

      display sim_sim with overlay frame n95.
      
  message " Is this message related to a SWIFT message ? " update quest.

  if quest then do:

     rela = 1.
     
        /*      Field    11 -  'S'  or   'R'      */
        
    update sim_sim validate(sim_sim eq "S" or sim_sim eq "R","")
           with frame n95.
           
      sim_sim = caps(sim_sim).
      
      display sim_sim with frame n95.  
        
pause 0.        
/********************* SWIFT  msg ********************************/
        
         cmdk = "getsmfar ".
  
    if sim_sim eq "S" then
       cmdk = cmdk + "-o ".
    else if sim_sim eq "R" then
       cmdk = cmdk + "-i ".
       
       do on error undo,retry:
       
        form live_ar help " Choose one line from menu & hit ENTER "
             with row 5 3 col centered no-labels
             title color input "  Search in ...  "
             overlay frame archive.

              display live_ar with frame archive.
           
           choose field live_ar auto-return with frame archive.
           
              hide message no-pause.
              
                 if frame-index eq 1 then cmdk = cmdk + """" + relrel + """".
               
      else if frame-index eq 2 then cmdk = cmdk + "-a " + """" + relrel + """".   
                 
            else if frame-index eq 3 then do:
            
              sekta:
               do on error undo,retry:
                 update fromdate go-on (PF4) with frame arc.
                 
                   if keyfunction(lastkey) = "END-ERROR" then do:
                      xyz = 1.
                      leave sekta.
                   end.
                   
                     if substr(fromdate,1,2) lt "01" or
                        substr(fromdate,1,2) gt "31" or
                        substr(fromdate,3,1) ne "."  or      
                        substr(fromdate,4,2) lt "01" or
                        substr(fromdate,4,2) gt "12" or
                        substr(fromdate,6,1) ne "."  then do:
                        message " Format of date is WRONG ! ".
                        bell.
                        undo,retry.
                     end.

            todate = fromdate.
            
                 update todate go-on (PF4) with frame arc.
                 
                   if keyfunction(lastkey) = "END-ERROR" then do:
                      xyz = 1.
                      leave sekta.
                   end.
                   
                     if substr(todate,1,2) lt "01" or
                        substr(todate,1,2) gt "31" or
                        substr(todate,3,1) ne "."  or      
                        substr(todate,4,2) lt "01" or
                        substr(todate,4,2) gt "12" or
                        substr(todate,6,1) ne "."  then do:
                        message " Format of date is WRONG ! ".
                        bell.
                        undo,retry.
                     end.
                                       
               end.   /*     do   */
               
                 if xyz = 1 then do:
                    hide frame arc no-pause.
                    xyz = 0.
                    sim_sim = "N".
                   display sim_sim with overlay frame n95.
                    undo,retry.
                 end.
                 
cmdk = cmdk + "-f" + fromdate + " " + "-t" + todate + " " + """" + relrel + """".

           end.  /*  else if frame-index = 3  */
           
       end.      /*  do live_ar    */



/**********************/

  run getall (INPUT-OUTPUT cmdk).

/*******************************************************************/        

              if xyz = 1 then do:   /*   for repeat */
                 xyz = 0.
                 next m21.          /*   exit  F4  ,repeat M:21  */
                 undo,retry.
              end.
              if xyz = 2 then do:   /*   for repeat */
                 xyz = 0.
                 next main.         /*  exit automatically   */
                 undo.
              end.
              if xyz = 3 then do:   /*   go to M:75   */
                 xyz = 0.
       display mt_send date_s sess_sequ with frame n95.
                 leave m21.
                 undo,retry.
              end.
       

  input through value(cmdk) no-echo.

  
  set addrbank with frame indata  no-box no-labels width 80.
  
  
  if addrbank eq "NO FOUND" then do :
  
    message "CAN'T FIND MESSAGE WITH TRN " + "'" + relref + "'" +
             " IN THE SWIFT ARCHIVE ".
    bell.
    input close.
    undo,retry.
  end.
  
  if addrbank eq "USAGE:" then do :
  
    message "CAN'T FIND MESSAGE WITH 'USAGE' ".
    bell.
    input close.
    undo,retry.
    end.



        foundm = addrbank. /*  1-st line from file   */


          
/************************************
*   message find out                *
*************************************/
do i = 1 to 60:
  cp_msgbox[i] = "".
end.
do i = 1 to 19:
  cp_msgdisp[i] = "".
end.
  
cicke:

  repeat i = 1 to 60:
              
        set addrbank with no-box no-labels no-attr-space width 80.
        cp_msgbox[i] = addrbank.
        
    if substr(cp_msgbox[i],1,1)  eq "$" then do:
       cp_msgbox[i] = "".
       leave cicke.
    end.
        
  end.   /*   cicke   */

 input close.
 
     ibl1 = 8.
       
     if substr(foundm,1,ibl1) ne substr(dest,1,ibl1) then do:
        message "Destination " + "'" + dest + "'" + " is wrong.
The original msg has " + "'" + substr(foundm,1,ibl1) + "'" + " destination". 
        bell.
        undo,retry.
     end.
 
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

     
            if substr(foundd,9,1)  ne " " then do:
                  substr(foundd,12,1) = substr(foundd,11,1).
                  substr(foundd,11,1) = substr(foundd,10,1).
                  substr(foundd,10,1) = substr(foundd,9,1).
                  substr(foundd,9,1)  = "X".
            end.                   

     
        mt_send =   substr(foundm,ibl1 + 2,3).
       
     if msgtype ne substr(mt_send,1,1) then do:
        message "Category msg not equal category of the original msg".
        bell.
        undo,retry.
     end.
     
     date_s  =   substr(foundm,ibl1 + 6,6).
     sess    =   substr(foundm,ibl1 + 13,4).
     sequ    =   substr(foundm,ibl1 + 18,6).
       
     sess_sequ = sess + sequ. 

     display mt_send date_s sess_sequ with frame n95.
     
pause 0.

/***************************************************************
*      copy of the fields of the original message              *
****************************************************************/


                run fO95.

                
              if xyz = 1 then do:   /*   for repeat */
                 xyz = 0.
                 undo,retry.
              end.
              else 
                leave m21.
        
   
  end.   /*   if quest  */
          
end.       /*    repeat   m21    */


/*********************************************************************
*     QUERIES    ( field  75 )     *
**********************************************************************/
queries00:
do on error undo,retry:

  i = 1.
  
queries1:
repeat:

quest = true.

   display query_6 with frame n95.
   set query_6[i] go-on (F1 PF4 return cursor-up cursor-down) 
       with frame n95.


	       if keyfunction(lastkey) = "GO" then do:

			     message " Send to SWIFT ? " update a.
		           
			if a then do:
                           if (query_6[1]      eq "") then do:
                              message "Field M:75 must be fill out ".
                              bell.
                              undo,retry.
                            end.
			  leave queries00.
			end.
		           next queries1.		           
			     
	       end.  /*  end of   " GO"  */

     
     if lastkey = keycode ("ENTER") then do:
      
          if frame-index < 1 then do:
             bell.
             undo,retry.
          end.

          query_6[i] = frame-value.
          
         run trtolat(INPUT-OUTPUT query_6[i]).
             query_6[i] = trim(query_6[i]).
		          
           if (query_6[1]      eq "") then do:
             message " This field must be filled in ".
             bell.
             undo,retry.
           end.

           if substr(query_6[i],1,1) eq ":" or
              substr(query_6[i],1,1) eq "-" then do:
              message " The first symbol must not be ':' or '-'  ".
              bell.
              undo,retry.
           end.

            if substr(query_6[frame-index],1,1) eq "/" then do:
               if substr(query_6[frame-index],2,1) le "0" or 
                  substr(query_6[frame-index],2,1) gt "9" then do:
                  message " Only digit between slashs ".
                  bell.
                  undo,retry.
               end.
               if substr(query_6[frame-index],3,1) ne "/" then do:
                  if substr(query_6[frame-index],3,1) eq " " then do:
                     message " Where is second slash ?".
                     bell.
                     undo,retry.
                  end.
               
                  if substr(query_6[frame-index],3,1) le "0" or 
                     substr(query_6[frame-index],3,1) gt "9" then do:
                     message " Only digit between slashs ".
                     bell.
                     undo,retry.
                  end.
                  
                  if substr(query_6[frame-index],4,1) ne "/" then do:
                     message " Where is second slash ?".
                     bell.
                     undo,retry.
                  end.
                end.
            end.
            
          if substr(query_6[frame-index],1) ne "" then do:  

            if substr(query_6[frame-index],1,1) ne "/" then do:

               i = length(query_6[frame-index]).
               
               if substr(query_6[frame-index],i,1) eq "/" then do:
                  message " The last symbol must not be '/' ".
                  bell.
                  undo,retry.
               end.
            end.
          end.
          
               if substr(query_6[frame-index],1) eq ""  
                  then leave queries1.
           
          i = frame-index + 1.
       if i = 7 then leave queries1.
          next queries1.
       
     end.  /*  if "ENTER"  */
      
     if lastkey = keycode ("cursor-up") then do:
      
        if frame-index = 1 then do:
             query_6[i] = frame-value.
          
            run trtolat(INPUT-OUTPUT query_6[i]).
                query_6[i] = trim(query_6[i]).
		          
           if (query_6[1]      eq "") then do:
             message " This field must be filled in ".
             bell.
             undo,retry.
           end.
           
           if substr(query_6[i],1,1) eq ":" or
              substr(query_6[i],1,1) eq "-" then do:
              message " The first symbol must not be ':' or '-'  ".
              bell.
              undo,retry.
           end.

          bell.
          message " At the top ".
          undo.
          i = frame-index.
          next queries1.
        end.  
        
      i = frame-index - 1.
      next queries1.
     end.

        
     if lastkey = keycode ("cursor-down") then do:
      
        if frame-index = 6 then do:
             query_6[i] = frame-value.
          
            run trtolat(INPUT-OUTPUT query_6[i]).
                query_6[i] = trim(query_6[i]).
		          
           if substr(query_6[i],1,1) eq ":" or
              substr(query_6[i],1,1) eq "-" then do:
              message " The first symbol must not be ':' or '-'  ".
              bell.
              undo,retry.
           end.

          bell.
          message " At the bottom ".
          undo.
          i = frame-index.
          next queries1.
        end.  
             
      i = frame-index + 1.
      next queries1.
     end.
 
     if keyfunction(lastkey) = "END-ERROR" then next main.
          
end.   /*     queries1   */  
  

/*******************************************************************
             field 77A - Narrative
********************************************************************/
	   
              run f77A.p.  
	      
              if xyz = 1 then do:   /*   for repeat section1  */
                 xyz = 0.
                 undo,retry.
              end.
              
         else if xyz = 2 then do:
              xyz = 0.
              leave queries00. /* to SWIFT */
              end.

         do i = 1 to 7:
           narr_disp[i] = narr_box[i].
         end.
         
         display narr_disp with frame n95. 
pause 0.           

/*******************************************************************/
/*             general part for field # 79                         */	   
/*******************************************************************/

a = true.
u1 = 0.
xyz = 0.
first_j = 0.
j = first_j + 1.
first_j = j.


        	     first_j = j.
        	do i = 1 to 14:
	           masdisp[i] = masbox[j].
	           j = j + 1.
         	end.


   section2:
     repeat:

    z = 1.     /*   z - this is frame-index   */

	    section3:
	      repeat:

         if z < 1 then next section2.

       display masdisp with frame yy overlay.
       
       set masdisp[z]
       GO-ON (F1 F9 PF4 F10 return cursor-up cursor-down)
           with frame yy.       

               if keyfunction(lastkey) = "END-ERROR" then do:
                 xyz = 1.
                 leave section2.
               end.

               
/* it  was press F1 key     */

	       if keyfunction(lastkey) = "GO" then do:
	       

                              j = first_j.
			   do i = 1 to 14:
			   
                      run trtolat(INPUT-OUTPUT masdisp[i]).
			   
                               if substr(masdisp[i],1,1)  eq ":" or
                                  substr(masdisp[i],1,1)  eq "-"                               
                                 then do:
                                  bell.
                         message "The first symbol must not be  :  or  -   ".
                                  z = i.
                                  next section3.
                                 end.
                                 
                               if substr(masdisp[i],1) eq ""  
                                    then do:
                                     xyz = 14 - i + 1. /* rem.of strings*/
                                     y = i + 1.
                                     b = 1.
                                       do x = y to 14:
                                          if substr(masdisp[x],1) eq ""  
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
                                             next section3.
                                         end.
                               end.  
                                 
                                masbox[j] = masdisp[i].
				       j = j + 1.
			   end.

			     message " Send to SWIFT ? " update a.
		           
			if a then leave queries00.
		             next  section2.		           
			     
	       end.  /*  end of   " GO"  */
	       
/*  was put  F9 -key  */

	       if keyfunction(lastkey) = "new-line" then do:

                /*   this is pieces from "cursor-down"          */
				  
		  if frame-index = 14 then do:

			  if first_j + 13 = 35 then do:

					      j = first_j.
					do i = 1 to 14:
					   masbox[j] = masdisp[i].
					      j = j + 1.
					end.
			     bell.
			     message " At the bottom".
			     undo.
			     next section3.
			  end.

                          /* move from masdisp to masbox      */

				     j = first_j.
			      do i = 1 to 14:
				  masbox[j] = masdisp[i].
				     j = j + 1.
			      end.

                            /* form the next screen */

				j = first_j + 1.
				    first_j = j.
				do i = 1 to 14:
				    masdisp[i] = masbox[j].
					j = j + 1.
				end.
			     next section3.

		  end.
              /*   above it is pieces from "cursor-down"    */

		      /* sort massiv' masbox */

			y = first_j + frame-index.
			  do i = 34 to y by -1:
			    masbox[i + 1] = masbox[i].
			  end.

		      /* sort massiv' masdisp */

	         	      do i = 13 to frame-index + 1 by -1:
				  masdisp[i + 1] = masdisp[i].
			      end.
			     masdisp[frame-index + 1] = " ".
			     
			    z = frame-index + 1.
			   next section3.
			   
	       end.  /*   end "new-line  */

/*  was put  F10 -key  */

	       if keyfunction(lastkey) = "delete-line" then do:

				  
                          /* move from masdisp to masbox      */

				     j = first_j.
			      do i = 1 to 14:
				  masbox[j] = masdisp[i].
				     j = j + 1.
			      end.
			      
                          /*  delete line from screen */
                          
                            z = frame-index.
                            j = first_j + z.
                       do i = j to 35:
                          masbox[i - 1] = masbox[i].
                       end.   
                          masbox[35] = "". /*  last line into masbox */

                            /* form the next screen */

				j = first_j.
				do i = 1 to 14:
				    masdisp[i] = masbox[j].
					j = j + 1.
				end.
			     next section3.


	       end.  /*   end "delete-line  */



/* cursor - up */

	       if lastkey = keycode("cursor-up") then do:

		  if frame-index = 1 then do:

			   if first_j = 1 then do:
					   j = first_j.
				        do i = 1 to 14:
					   
                                 run trtolat(INPUT-OUTPUT masdisp[i]).
					   
					   masbox[j] = masdisp[i].
					     j = j + 1.
					end.

			      bell.
			      message  " At the top ".
			      undo.
			      next section2.
			   end.

       /* move from masdisp to masbox      */

				j = first_j.
			          do i = 1 to 14:
				  masbox[j] = masdisp[i].
				    j = j + 1.
			      end.

       /* form the next screen */                                              
				       j = first_j - 1.
				       first_j = j.
				       do i = 1 to 14:
				       masdisp[i] = masbox[j].
				       j = j + 1.
				     end.
			       next section2.

		  end.
		z = frame-index - 1.
		next section3.
	       end. /* end of "cursor-up" */


/* cursor - down */

	       if lastkey = keycode("cursor-down") then do:

		  if frame-index = 14 then do:

			  if first_j + 13 = 35 then do:

					      j = first_j.
					   do i = 1 to 14:
					   
                                 run trtolat(INPUT-OUTPUT masdisp[i]).
					   
					   masbox[j] = masdisp[i].
					      j = j + 1.
					end.
			     bell.
			     message " At the bottom".
			     undo.
			     next section3.
			  end.

       /* move from masdisp to masbox      */

				     j = first_j.
			          do i = 1 to 14:
				  masbox[j] = masdisp[i].
				     j = j + 1.
			      end.

       /* form the next screen */

				j = first_j + 1.
				    first_j = j.
				   do i = 1 to 14:
				    masdisp[i] = masbox[j].
					j = j + 1.
				end.
			     next section3.

		  end.
		z = frame-index + 1.
		next section3.
	       end. /* end of "cursor-down" */


/*    hit " Enter "   */

	       if lastkey = keycode("ENTER") then do:
	       
	            if frame-index < 1 then next section2.

	            if frame-index eq 1 and substr(masdisp[1],1) eq ""
	               then  do:
	               
			     message " Send to SWIFT ? " update a.
		           
			if a then leave queries00.
		             next  section2.		           
	               
	             end.  
	               
	             
		   masdisp[frame-index] = frame-value.
		   
                    run trtolat(INPUT-OUTPUT masdisp[frame-index]).

					   j = first_j.
					   do i = 1 to 14:
					   
                               if substr(masdisp[i],1,1)  eq ":"  or
                                  substr(masdisp[i],1,1)  eq "-"
                                  then do:
                                   bell.
                        message "The first symbol must not be  :  or   -   ".
                                   undo,retry.
                                end.
                                	   
                               if substr(masdisp[frame-index],1) eq ""  
                                  then do:  /*leave section2.*/
                                   bell.
                                message "The string must not be  blank  ".
                                   undo,retry.
                                end.
                                	   
                                	   
					   masbox[j] = masdisp[i].
					     j = j + 1.
					end.
			if frame-index = 14 then do:

	   /*     set up the next screen   */

				  j = first_j + 13.
				  first_j = j.
			         do i = 1 to 14:
				     masdisp[i] = masbox[j].
				     j = j + 1.
				 if j > 35 then do:
					   first_j = 22.                       
					   j = first_j.
				         do i =1 to 14:
					     masdisp[i] = masbox[j].
					     j = j + 1.
				      end.
					   if u1 = 1 then do: /*if 2-nd step*/
					      message " At the bottom".
					      u1 = 0.
					      next section3. /* it was 2*/
					   end.
					     u1 = 1. /* for the 2-nd step*/
				      z = 7.
				    next section3.
				 end.

			      end.      /*   repeat     */
			      z = 2.
			   next section3.
			end.            /*   index = 14  */

		       z = frame-index + 1.
		  next section3.
	       end.                     /*  enter        */
	       
	       
	      end. /*  section3   */
	      
	       
     end.          /*  section2   */

              if xyz = 1 then do:   /*   for repeat section1  */
                 xyz = 0.
                undo,retry.
              end.
              
end.  /* queries00 */

              if xyz = 1 then do:   /*   for repeat main loop  */
                 xyz = 0.
                undo,retry.
              end.

       substr(itype,3,1) = msgtype.

     output to value(itype).
     
/*====================================*/

       run outn95 (INPUT-OUTPUT itype).

/*====================================*/
 
     output close.
       pause 0.
      unix swsend -p value(itype).
       pause 0.
      unix silent /bin/rm -f value(itype).
       pause 0.
end.
