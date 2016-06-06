/* dil_util.i
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
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
*/

{get-dep.i}

function check_acc returns logical (input caccno as character, input c_amt as decimal, input com1 as logical):
def buffer faaa for aaa.
def buffer caaa for aaa.
  find aas where aas.aaa = caccno no-lock no-error.
  if avail aas 
     then 
       do: 
        if aas.chkamt = 0 
           then
             do:
                return false.                
             end.
           else   
             do:
                find faaa where faaa.aaa = caccno no-lock no-error.
                find caaa where caaa.aaa = faaa.craccnt no-lock no-error.
                if avail caaa 
                   then  
                     do:
                        if caaa.opnamt <> 0 
                           then
                             do:
                                if com1 then 
                                   do:
                                      if (caaa.opnamt - (caaa.dr[1]  - caaa.cr[1]) - faaa.hbal + tamount) < c_amt 
                                       then
                                         do: 
                                            message "К счету " caccno " применены специальные инструкции" skip 
                                            "Операция невозможна" view-as alert-box title "". 
                                            return true. 
                                         end.
                                       else
                                         do: 
                                            message "К счету " caccno " применены специальные инструкции" skip 
                                            aas.payee view-as alert-box title "". 
                                            return false.
                                         end.
                                   end.
                                        else
                                   do:
                                      if (caaa.opnamt - (caaa.dr[1]  - caaa.cr[1]) - faaa.hbal) < c_amt 
                                       then
                                         do: 
                                            message "К счету " caccno " применены специальные инструкции" skip 
                                            "Операция невозможна" view-as alert-box title "". 
                                            return true. 
                                         end.
                                       else
                                         do: 
                                            message "К счету " caccno " применены специальные инструкции" skip 
                                            aas.payee view-as alert-box title "". 
                                            return false.
                                         end.   
                                   end.
                             end.
                           else
                             do:
                                if com1 then 
                                   do:
                                      if (faaa.cr[1]  - faaa.dr[1] - faaa.hbal + tamount) < c_amt 
                                         then
                                           do: 
                                              message "К счету " caccno " применены специальные инструкции" skip 
                                              "Операция невозможна" view-as alert-box title "". 
                                              return true. 
                                           end.
                                         else
                                           do: 
                                              message "К счету " caccno " применены специальные инструкции" skip 
                                              aas.payee view-as alert-box title "". 
                                              return false.
                                           end.
                                   end. 
                                        else
                                   do:
                                      if (faaa.cr[1]  - faaa.dr[1] - faaa.hbal) < c_amt 
                                         then
                                           do: 
                                              message "К счету " caccno " применены специальные инструкции" skip 
                                              "Операция невозможна" view-as alert-box title "". 
                                              return true. 
                                           end.
                                         else
                                           do: 
                                              message "К счету " caccno " применены специальные инструкции" skip 
                                              aas.payee view-as alert-box title "". 
                                              return false.
                                           end.
                                   end. 
                             end.
                     end.
             end.
       end. 
     else return false. 
end.



function get_percent returns decimal (INPUT perc as decimal , INPUT amount as decimal).
   return ((amount / 100) * perc).
end function.

procedure generate_docno.
  find last dealing_doc exclusive-lock.
  repeat while docno > string(current-value(d_journal),"999999"):
     next-value(d_journal).
     documn = string(current-value(d_journal),"999999").
  end.
  if docno <= string(current-value(d_journal),"999999") then
   do:
      next-value(d_journal).
      documn = string(current-value(d_journal),"999999").
   end.
  documN = string(current-value(d_journal),"999999").
  find current dealing_doc share-lock.
end procedure.
