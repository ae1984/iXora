/* help-rnn.p

 * MODULE
        
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса
                  
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM       
 * AUTHOR
        15/04/2009 id00205
 * CHANGES
        
*/

   def input param Usr as ACCOUNTClass.
   if not VALID-OBJECT(Usr)  then do: message "Объект не инициализирован!" view-as alert-box. return. end.
   
   define query q_list for comm.rnn.
   define browse b_list query q_list no-lock 
   display trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname)   format "x(30)" label "Ф.И.О." comm.rnn.trn label "РНН"
           with  12 down  centered overlay  no-row-markers.  
   DEFINE VARIABLE qh AS HANDLE. 
   qh = QUERY q_list:HANDLE.
   DEFINE VARIABLE Val AS CHAR.   
     
   /*******************************************************************************************************/
   DEFINE FRAME SearchFrame  skip(1)
        lname AS character FORMAT "x(15)"        label " Фамилия  " skip
        fname AS character FORMAT "x(15)"        label " Имя      " skip
        mname AS character FORMAT "x(15)"        label " Отчество " skip
        rnn   AS character FORMAT "x(12)"        label " РНН      " skip(1)
        b_list skip
        addr AS character FORMAT "x(40)" label " Адрес " 
         WITH SIDE-LABELS centered overlay row 7 title "Поиск плательщика  (F1-выполнить поиск)" view-as dialog-box.
    /*******************************************************************************************************/
    if Usr:name <> "" then lname:SCREEN-VALUE = Usr:name.
    /*******************************************************************************************************/    
    on return of b_list in frame SearchFrame
    do: 
      apply "endkey" to frame SearchFrame.
      if  avail comm.rnn then
      do:
        Usr:name   = trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname).
        Usr:rnn    = comm.rnn.trn.
        Usr:addr   = trim(comm.rnn.dist1) + " "  + trim(comm.rnn.city1)+ " " +
                     trim(comm.rnn.street1)+ " " + trim(comm.rnn.housen1)+ " " + trim(comm.rnn.apartn1) .
        if Usr:addr = ? then Usr:addr = "".             
      end.
    end.
    /*******************************************************************************************************/
    on CURSOR-DOWN of b_list in frame SearchFrame
    do:
      qh:GET-NEXT().
      run ShowAddr.
    end.
    on CURSOR-UP of b_list in frame SearchFrame
    do:
      qh:GET-PREV().
      run ShowAddr.
    end.
    /*******************************************************************************************************/
    on GO of lname in frame SearchFrame
    do:
      qh:QUERY-CLOSE().
      Val = "comm.rnn.lname = '" + lname:SCREEN-VALUE + "'".
       if fname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.fname = '" + fname:SCREEN-VALUE + "'".
       if mname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.mname = '" + mname:SCREEN-VALUE + "'".
       if rnn:SCREEN-VALUE   <> "" then Val = Val + " and comm.rnn.trn   = '" + rnn:SCREEN-VALUE + "'".
      qh:QUERY-PREPARE("for each comm.rnn where " + Val).
      qh:QUERY-OPEN.
      run ShowAddr.
    end.
    on GO of fname in frame SearchFrame
    do:
      qh:QUERY-CLOSE().
      Val = "comm.rnn.fname = '" + fname:SCREEN-VALUE + "'".
       if lname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.lname = '" + lname:SCREEN-VALUE + "'".
       if mname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.mname = '" + mname:SCREEN-VALUE + "'".
       if rnn:SCREEN-VALUE   <> "" then Val = Val + " and comm.rnn.trn   = '" + rnn:SCREEN-VALUE + "'".
      qh:QUERY-PREPARE("for each comm.rnn where " + Val).
      qh:QUERY-OPEN.
      run ShowAddr.
    end.
    on GO of mname in frame SearchFrame
    do:
      qh:QUERY-CLOSE().
      Val = "comm.rnn.mname = '" + mname:SCREEN-VALUE + "'".
       if fname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.fname = '" + fname:SCREEN-VALUE + "'".
       if lname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.lname = '" + lname:SCREEN-VALUE + "'".
       if rnn:SCREEN-VALUE   <> "" then Val = Val + " and comm.rnn.trn   = '" + rnn:SCREEN-VALUE + "'".
      qh:QUERY-PREPARE("for each comm.rnn where " + Val).
      qh:QUERY-OPEN.
      run ShowAddr.
    end.
    on GO of rnn in frame SearchFrame
    do:
      qh:QUERY-CLOSE().
      Val = "comm.rnn.trn = '" + rnn:SCREEN-VALUE + "'".
       if fname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.fname = '" + fname:SCREEN-VALUE + "'".
       if mname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.mname = '" + mname:SCREEN-VALUE + "'".
       if lname:SCREEN-VALUE <> "" then Val = Val + " and comm.rnn.lname = '" + lname:SCREEN-VALUE + "'".
      qh:QUERY-PREPARE("for each comm.rnn where " + Val).
      qh:QUERY-OPEN.
      run ShowAddr.
    end.
   
    /*******************************************************************************************************/
    
    qh:QUERY-CLOSE().
    if Usr:name <> "" then qh:QUERY-PREPARE("for each comm.rnn where comm.rnn.lname = '" + Usr:name + "'").
    else  qh:QUERY-PREPARE("for each comm.rnn ").
    qh:QUERY-OPEN.
      
    qh:GET-FIRST().
    run ShowAddr.
    
    
    enable lname fname mname rnn b_list with frame SearchFrame.
    apply "value-changed" to b_list in frame SearchFrame.
   
    WAIT-FOR endkey of frame SearchFrame.
    hide frame SearchFrame.
   
procedure ShowAddr:
  if avail comm.rnn then
  do:
    find current comm.rnn.
    addr   = trim(comm.rnn.dist1) + " "  + trim(comm.rnn.city1)+ " " +
             trim(comm.rnn.street1)+ " " + trim(comm.rnn.housen1)+ " " + trim(comm.rnn.apartn1) .
    displ addr with frame SearchFrame.
  end.  
end procedure.


