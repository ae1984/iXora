/* compay1.p
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
        26/03/09 id00205
        13.10.2010 k.gitalov перекомпиляция
        25.10.2010 k.gitalov проверка на доступность сервиса
 * CHANGES
       
*/


/*
Локальный провайдер (без авангард-плат)
Казахтелеком
 ключевое поле Лицевой счет
 Обязательные поля -  РНН, ФИО, Домашний адрес, Домашний телефон
 РНН и ФИО берутся из локальной базы
*/ 

{classes.i}



def input param  Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей */
def output param iRez as log init no.

/************************************************************************************/
find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then
do:
  if comm.pksysc.loval = no then
  do:
    message "Прием платежей Авангард-Plat в данное время недоступен!" view-as alert-box title "Внимание".
    return.
  end.
end.
else do:
  message "Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.          
/************************************************************************************/


DEFINE FRAME MainFrame 
         skip (1)
         docNo as char label  "Номер документа"         space(15)  docJH as char label  "Номер проводки" skip
         suppname as char label  "Получатель платежа" FORMAT "x(30)" knp AS char FORMAT "x(3)" label "КНП" skip 
         suppbname AS character FORMAT "x(30)" label "Банк получателя   " suppiik as char  FORMAT "x(21)" label "ИИК" skip 
         "_____________________________________________________________________________" skip(1)
         payname AS character FORMAT "x(35)" label "Плательщик  " 
         payrnn AS character FORMAT "999999999999" label " РНН" skip
         "_____________________________________________________________________________" skip(1)
         
                   
         payacc as char format "x(12)" label "Лицевой счет       "  payphone AS char format "x(8)" label "           Телефон "  skip 
         payaddr AS character FORMAT "x(45)" label "Адрес              " skip
         
         summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label      "Сумма платежа      " skip
         "_____________________________________________________________________________" skip(1)
         comm_summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label "Комиссия банка     " skip
         summall AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label   "Общая сумма платежа" skip(2)
 WITH SIDE-LABELS centered overlay row 8 TITLE "Прием коммунальных платежей".
 
  def var rez as log init no. 
  def var pos as int init 1. 
  def var err as integer no-undo.
  def var errdes as char no-undo. 
  def var Usr as class ACCOUNTClass.    /* Класс данных плательщиков */
  define shared   var s-jh like jh.jh .
  
     if Doc:docno = ? then 
     do:
      Usr = NEW ACCOUNTClass(Base,Doc:supp_id).
      pos = 1.
     end.
     else pos = 6.

/***********************************************************************************************************/
  on help of payname in frame MainFrame do:
    message "".
    Usr:name = payname:SCREEN-VALUE.
   
    run help-rnn(Usr).
    
    if trim(Usr:rnn) <> "" then 
    do:
      Doc:payname  = Usr:name.
      Doc:payrnn   = Usr:rnn.
      Doc:payaddr  = Usr:addr.
    end.
    run ShowFrame(Doc).
  end.
/***********************************************************************************************************/ 
          
      REPEAT on  ENDKEY UNDO  , leave :
        run ShowFrame(Doc). 
        CASE pos:
        
          WHEN 1 THEN 
          DO:    
                /* Ввод лицевого счета и поиск владельца в базе */
                 set payacc with frame MainFrame.
                 if payacc entered then 
                 do:
                   /*Проверка правильности введенного счета */
                   if not Doc:CheckAcc(payacc) then undo.
                   /*********************************************/
                   /*
                   if Doc:ap_check > 0 then
                   do: 
                     run ap_check(Doc:supp_id,payacc,output err, output errdes).
                     if err <> 0 then
                     do:
                       message errdes view-as alert-box.
                       undo.
                     end.
                   end.
                   */
                   /*********************************************/
                  
                   if Usr:FindAcc(payacc) then
                   do: /*Нашли по номеру счета плательщика*/
                     Doc:SetUsrData(Usr).
                     pos = 5. /* Все ок, можно вводить сумму*/
                   end.
                   else do:
                     Doc:payacc = payacc. 
                     pos = 2. /*Клиент у нас первый раз */
                   end.
                 end.
                 else do: Usr:ClearData(). undo. end.
          
          END.
          WHEN 2 THEN 
          DO:
               /* Лицевой  счет не найден, поиск плательщика в базе рнн*/
                   message " 'F2' - поиск в базе РНН". 
                   set payname with frame MainFrame.
                   if payname entered then 
                   do:
                      if trim(Usr:rnn) <> "" and trim(Usr:name) <> "" then  pos = 3. 
                      else  do: Usr:ClearData(). undo. end.
                   end.
                   else  do: Usr:ClearData(). undo. end.      
           
          END.
          WHEN 3 THEN 
          DO:      /*Для провайдеров где нужен номер домашнего телефона*/
                  set payphone with frame MainFrame.
                  if payphone entered then do: Doc:payphone = payphone. pos = 4. end.
                  else  do: Usr:ClearData(). undo. end.              
             
          END.
          WHEN 4 THEN 
          DO:     /*Для провайдеров где нужен домашний адрес*/
                  if trim(payaddr) = "" then
                  do: 
                    set payaddr with frame MainFrame.
                    if payaddr entered then do: Doc:payaddr = payaddr. pos = 5. end.
                    else  do: Usr:ClearData(). undo. end. 
                  end.
                  pos = 5 . 
                 
          END.
          WHEN 5 THEN 
          DO:     
                  /* run ShowFrame(Doc).*/
                   set summ with frame MainFrame.
                   if summ entered then 
                   do:
                     if Doc:minsum > 0 then
                     do:
                       if summ < Doc:minsum then do: message "Минимальная сумма платежа - " + string(Doc:minsum) + " тенге" view-as alert-box. undo. end.
                     end.
                     
                     Doc:summ = summ.
                        
                     if Usr:acc_id = ? then
                     do:
                       Usr:AddData().
                       Usr:acc     = Doc:payacc.
                       Usr:phone   = Doc:payphone.
                       Usr:addr    = Doc:payaddr.
                       if Usr:Post() then 
                       do: 
                         Doc:SetUsrData(Usr).
                       end.
                       else do: message "Ошибка при добавлении счета!" view-as alert-box. Usr:ClearData(). undo. end.
                     end.  
                   end.
                   else  undo. 
                                  
                   if Doc:Post() then
                   do:
                   
                     run ShowFrame(Doc).
                                        
                    pos = 7.
                      
                   end. 
                   else do:
                     message "Ошибка при сохранении документа!" view-as alert-box.
                     undo.   
                   end. 
                   
                pause 0 .          
          END.
          WHEN 6 THEN 
          DO:
             /* Просмотр существующего документа*/ 
             run ShowFrame(Doc).
             message "[F5] - печать клише, [F6] - печать БКС и ПКО".
             READKEY.
             IF LASTKEY = KEYCODE("F5") then do:  Doc:PrintCLS(). undo. end.
             IF LASTKEY = KEYCODE("F6") then do:  Doc:PrintPKO(). /*Doc:PrintBKS().*/ 
              run bks (string(Doc:jh,"zzzzzzz9") + "#" + "Платежи " + Doc:suppname + "#" + string(Doc:summ) + "#" + string(Doc:comm_summ) + "#1#KZT","COM#" + string(Doc:docno,"99999999")).
              undo. end.
             IF keyfunction(lastkey) = "END-ERROR" then do: LEAVE. end.
          END.
          WHEN 7 THEN
          DO:
             rez = no.
             run compay_trx(Doc,output rez).
             if rez then 
             do:
              /* Doc:PrintBKS().*/
               run bks (string(Doc:jh,"zzzzzzz9") + "#" + "Платежи " + Doc:suppname + "#" + string(Doc:summ) + "#" + string(Doc:comm_summ) + "#1#KZT","COM#" + string(Doc:docno,"99999999")).
               Doc:PrintPKO().
               iRez = Yes.
             end.
             else do: /* Ошибка при формировании проводки */
                message "Ошибка при формировании проводки" view-as alert-box.
               iRez = No.
             end.
             
             LEAVE.
          END.
        END CASE. 
        
        
      END. /*REPEAT*/
  
/***********************************************************************************************************/
  
  if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR . 
  HIDE FRAME MainFrame.
   
 

/***********************************************************************************************************/
 
procedure ShowFrame:
           def input param Doc as COMPAYDOCClass.

           if Doc:docNo = ? then docNo = "00000000".
           else docNo = string(Doc:docNo,"99999999").
           
           if Doc:jh = ? then docJH = "000000".
           else docJH = string(Doc:jh,"999999").
           
           suppname  = Doc:suppname.
           suppiik   = Doc:suppiik.
           knp       = Doc:knp.
           suppbname = Doc:suppbname.
           payname   = CAPS(Doc:payname).
           payrnn    = Doc:payrnn.
           payacc    = Doc:payacc.
           payphone  = Doc:payphone.
           payaddr   = CAPS(Doc:payaddr).
           summ      = Doc:summ.
           comm_summ = Doc:comm_summ.
           if Doc:summ = 0 then summall = 0.
           else summall   = Doc:summ + Doc:comm_summ.
           
           DISPLAY docNo docJH suppname  suppiik knp  suppbname 
                       payname payrnn 
                       payacc  
                       payphone
                       payaddr
                       summ comm_summ summall WITH  FRAME MainFrame.
   
end procedure. 
