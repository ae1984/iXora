/* catlist.p

 * MODULE
        
 * DESCRIPTION
        список категорий клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK      
 * AUTHOR
        14.09.2010 k.gitalov
 * CHANGES
        
*/
def input param alloff as int.

  define temp-table wrk
  field name as char
  field code as char.
 if alloff = 0 then
 do:
  create wrk.
  wrk.name = "Все".
  wrk.code = "ALL".
 end.
  
  for each codfr where codfr.codfr = 'cifkat' /*by codfr.code*/:
  create wrk.
    wrk.code = codfr.code.
    wrk.name = codfr.name[1].
  end.  

   define query q_list for wrk.
   define browse b_list query q_list no-lock 
   display wrk.name format "x(30)" no-label with title "Выбор категории клиента" 10 down centered overlay  /*NO-ASSIGN SEPARATORS*/ no-row-markers.

   define frame f1 b_list with no-labels centered overlay view-as dialog-box.

    /******************************************************************************/
    on return of b_list in frame f1
    do: 
        apply "endkey" to frame f1.
        return string(wrk.code).
    end.  
    ON END-ERROR OF b_list in  frame f1
    DO:
        return string("EXIT").
    END.
    /******************************************************************************/
            
    open query q_list for each wrk.
   
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey of frame f1.
    hide frame f1.
    
    

