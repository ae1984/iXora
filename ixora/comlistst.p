/* comlistst.p
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
        29/04/09 id00205
        13.10.2010 k.gitalov перекомпиляция
 * CHANGES
       
*/

  
  
{classes.i}


def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей */
def var v-rec as char.
def var v-send as char.
def var v-tem as char.
def var v-mess as char.
def var rez as log.
def var pos as int.   

Doc = NEW COMPAYDOCClass(Base).

DEFINE BUFFER b-compaydoc FOR comm.compaydoc.
   
pos = 2.
      
  REPEAT on ENDKEY UNDO  , leave : 
   message "".
   CASE pos:
     WHEN 1 THEN 
     DO: 
           run yn("","Выйти из программы?","","", output rez). 
           if rez then do: leave. end.
           else do: pos = 2. end.
     END.
     WHEN 2 THEN 
     DO: 
        run List.
        if Doc:docno = ? then pos = 1.
        else pos = 3.
     END.
     WHEN 3 THEN 
     DO: 
      run ShowDoc(Doc).
      pos = 2.
     END.
    
   END CASE. 
     
  END.
   


 
if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.


FUNCTION GetState RETURNS CHAR (INPUT param1 AS INTEGER):
    
    def var State AS char.
   
    case param1:
             when -3 then do: State = "ПОМЕЧЕН НА ОТМЕНУ". end.
             when -1 then do: State = "НЕ ПРОВЕДЕН      ". end.
             when  0 then do: State = "НЕ ОТПРАВЛЕН     ". end.
             when  1 then do: State = "ОБРАБАТЫВАЕТСЯ   ". end.
             when  2 then do: State = "ПРОВЕДЕН         ". end.
             when  3 then do: State = "ПОМЕЧЕН НА ОТМЕНУ". end.
             when  4 then do: State = "ОТМЕНЕН          ". end.
             when  5 then do: State = "ОТМЕНЕН          ". end.
             when  6 then do: State = "СТОРНИРОВАН      ". end.
             when  7 then do: State = "СТОРНИРОВАН      ". end.
    end case.
   
   RETURN State.
END FUNCTION. 

procedure List:
  
     define query q_list for b-compaydoc.
    define browse b_list query q_list no-lock 
     display string(b-compaydoc.docno,"99999999") label "Документ" b-compaydoc.jh label "Транзакция" b-compaydoc.whn_cr label "  Дата"
     string(b-compaydoc.time_cr,"HH:MM:SS") label " Время" GetState(b-compaydoc.state) format "x(17)" label "Статус"
     with title "Платежи на отмену "  10 down centered overlay  no-row-markers.

    define frame f1 b_list with no-labels centered overlay view-as dialog-box.
          
    on return of b_list in frame f1
    do: 
        apply "endkey" to frame f1.
        Doc:docno = ?.
        if avail b-compaydoc then Doc:FindDocNo(string(b-compaydoc.docno)).
    end.  
    
    on END-ERROR of b_list in frame f1
    do: 
        apply "endkey" to frame f1.
        Doc:docno = ?.
    end. 
    
            
   open query q_list for each b-compaydoc where  ((b-compaydoc.jh <> ?) and (b-compaydoc.jh <> 0)) and
                                                   (b-compaydoc.state = -3 or b-compaydoc.state = 3)
                                                   no-lock BY whn_cr DESCENDING BY time_cr DESCENDING .
     
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    
    WAIT-FOR endkey of frame f1.
    hide frame f1.
   
end procedure.

/***************************************************************************************************************/
procedure SendRequest:
  def input param Doc as class COMPAYDOCClass.
  v-rec = Doc:who_cr + "@metrocombank.kz". /* получатель */
  v-send = g-ofc + "@metrocombank.kz".
  v-tem  = "Re:Заявка на отмену платежа".
  v-mess = "Согласно Вашей заявке на отмену платежа № " + string(Doc:docno) + "\n".
  v-mess = v-mess + "Статус платежа изменен на " + GetState(Doc:state).
  run mail(v-rec, v-send, v-tem, v-mess, "", "", "").
end procedure.
/***************************************************************************************************************/  
procedure ShowDoc:
  def input param Doc as class COMPAYDOCClass.
  
  define button BtnOk label "Не проведен сторнирован".
  define button BtnCancel label "Проведен сторнирован".
  define button BtnClose label "Отказано в отмене".
  
  define frame DataFrame
     skip
         suppname as char label  "Получатель платежа" FORMAT "x(10)" skip (1) 
         docNo as  char  label   "Номер документа   "  
         space(9) docJH as  char  label   "Номер проводки     "  skip (1)
         payname AS character FORMAT "x(24)" label "Плательщик"
         payacc as char format "x(12)"       label "№ телефона/счета   " skip (1)          
         summ AS decimal FORMAT "zzz,zzz,zz9.99-" label      "Сумма платежа      " 
         comm_summ AS decimal FORMAT "zz9.99-" label "Комиссия банка     " skip (1)
         summall AS decimal FORMAT   "zzz,zzz,zz9.99-" label "Общая сумма платежа" skip
         "_________________________________________________________________________" skip (1)
         space (2) BtnOk BtnCancel BtnClose
  WITH SIDE-LABELS centered overlay row 10 TITLE "Отмена коммунальных платежей".
 
          ON CHOOSE OF BtnOk IN FRAME DataFrame DO:
            run yn("","Вы уверены?","Подтвердите отмену документа","", output rez).
            if rez then 
            do:
              Doc:SetState(5," Не проведен сторнирован " + g-ofc).
              run SendRequest(Doc).
              apply "endkey" to frame DataFrame. 
            end.
          END.
          ON CHOOSE OF BtnCancel IN FRAME DataFrame DO:
            run yn("","Вы уверены?","Подтвердите отмену документа","", output rez).
            if rez then 
            do:
              if Doc:state = 3 then Doc:SetState(4," Проведен сторнирован "  + g-ofc).
              if Doc:state = -3 then 
              do:
               message "Документ не был проведен, статус установлен в (Не проведен сторнирован) !" view-as alert-box.
               Doc:SetState(5,"Не проведен сторнирован").
              end. 
              run SendRequest(Doc).
              apply "endkey" to frame DataFrame. . 
            end.
          END.
          ON CHOOSE OF BtnClose IN FRAME DataFrame DO:
            run yn("","Вы уверены?","Подтвердите отказ отмены","", output rez).
            if rez then 
            do:
              if Doc:state = 3 then Doc:SetState(2," Отказано в отмене "  + g-ofc).
              if Doc:state = -3 then Doc:SetState(-1,"").
              run SendRequest(Doc).
              apply "endkey" to frame DataFrame. 
            end.
           
           
          END.
         
         
          docNo = string(Doc:docNo,"99999999").
          docJH = string(Doc:jh,"999999").
          suppname = Doc:suppname.
          payname  = Doc:payname.
          payacc   = Doc:payacc.
          summ     = Doc:summ.
          comm_summ = Doc:comm_summ.
          summall   = Doc:summ + Doc:comm_summ.
           
          enable BtnOk BtnCancel BtnClose with frame DataFrame. 
          display suppname docNo docJH payname payacc summ comm_summ summall BtnOk BtnCancel BtnClose with frame DataFrame.
          
  WAIT-FOR endkey  of frame DataFrame.
  hide frame DataFrame. 
        
     
end procedure.