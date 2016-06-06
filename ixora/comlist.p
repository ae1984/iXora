/* comlist.p
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

 * CHANGES
        13.10.2010 k.gitalov перекомпиляция
        24/05/2012 k.gitalov добавил платежи без комиссии (тип 4)
        08.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.

*/



{classes.i}


def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
def var SP  as class SUPPCOMClass.    /* Класс данных поставщиков */
def new shared var s-jh like jh.jh.   /* Номер проводки */
DEFINE BUFFER b-compaydoc FOR comm.compaydoc.

Doc = NEW COMPAYDOCClass(Base).
SP  = NEW SUPPCOMClass(Base).
SP:txb = Doc:b-txb.

def var rez as log.
def var pos as int.

pos = 1.



  REPEAT on ENDKEY UNDO  , leave :
   message "".
   CASE pos:
     WHEN 1 THEN
     DO:
        HIDE FRAME MainFrame.
        SP:supp_id = ?.
        if Base:g-fname = "COMNOTAX" then run help-suppay(SP,"no_tax").
        else run help-suppay(SP,"pay").
        if SP:supp_id = ? then
        do:
           run yn("","Выйти из программы?","","", output rez).
           if rez then do: leave. end.
           else do: undo. end.
        end.
        else do:
           pos = 2.
        end.
     END.
     WHEN 2 THEN
     DO:
        /* CLEAR FRAME MainFrame.*/
        HIDE FRAME MainFrame.
        run List( SP:supp_id ).
        if Doc:docno = ? then
        do:
         pos = 1.
         /*SP:name = "".*/
        end.
        else pos = 3.
     END.
     WHEN 3 THEN
     DO:
        case Doc:type:
                    when 1 then run compay1(Doc,output rez). /*Казахтелеком*/
                    when 2 then run compay2(Doc,output rez). /*Dalacom, Pathword, NEO, City  | Alma TV, Digital TV, ICON*/
                    when 3 then run compay3(Doc,output rez). /*Алсеко*/
                    when 4 then run compay4(Doc,"",output rez). /*без комиссии*/
                    when 5 then run compay5(Doc,output rez). /*Нурсат,ШыгысЭнергоТрейд*/
        end case.

        pos = 2.
     END.

   END CASE.

  END.




if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
if VALID-OBJECT(SP)   then DELETE OBJECT SP  NO-ERROR .

FUNCTION GetState RETURNS CHAR (INPUT param1 AS INTEGER):

    def var State AS char.
    /*

    */
    case param1:
             when -3 then do: State = "ПОМЕЧЕН НА ОТМЕНУ". end.
             when -1 then do: State = "НЕ ПРОВЕДЕН      ".  end.
             when  0 then do: State = "НЕ ОТПРАВЛЕН     ". end.
             when  1 then do: State = "ОБРАБАТЫВАЕТСЯ   ".  end.
             when  2 then do: State = "ПРОВЕДЕН         ".  end.
             when  3 then do: State = "ПОМЕЧЕН НА ОТМЕНУ". end.
             when  4 then do: State = "ОТМЕНЕН          ". end.
             when  5 then do: State = "ОТМЕНЕН          ". end.
             when  6 then do: State = "СТОРНИРОВАН      ". end.
             when  7 then do: State = "СТОРНИРОВАН      ". end.
    end case.

   RETURN State.
END FUNCTION.

procedure List:
   def input param supp as int.

     define query q_list for b-compaydoc.
    define browse b_list query q_list no-lock
     display string(b-compaydoc.docno,"99999999") label "Документ" b-compaydoc.jh label "Транзакция" b-compaydoc.whn_cr label "  Дата"
     string(b-compaydoc.time_cr,"HH:MM:SS") label " Время" GetState(b-compaydoc.state) format "x(17)" label "Статус"
     with title "Платежи " + SP:name   10 down centered overlay  no-row-markers.

    define frame f1 b_list with no-labels centered overlay view-as dialog-box.

    on return of b_list in frame f1
    do:
        apply "endkey" to frame f1.
        if avail b-compaydoc then Doc:FindDocNo(string(b-compaydoc.docno)).
    end.

    on END-ERROR of b_list in frame f1
    do:
        apply "endkey" to frame f1.
        Doc:docno = ?.
    end.


   open query q_list for each b-compaydoc where (  b-compaydoc.who_cr = g-ofc and
                                                  (( b-compaydoc.jh <> ?) and
                                                   (b-compaydoc.jh <> 0 )) and
                                                   b-compaydoc.supp_id = supp ) and
                                                   b-compaydoc.state <> -2 /* Удаленные без штамповки*/ and
                                                   b-compaydoc.note <> "Cancel" /*Перепроведенные документы*/
                                                   no-lock BY whn_cr DESCENDING BY time_cr DESCENDING .

    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.

    WAIT-FOR endkey of frame f1.
    hide frame f1.

end procedure.