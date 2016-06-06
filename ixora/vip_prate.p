/* vip_prate.p
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
        BANK
 * AUTHOR
        03.06.2009 k.gitalov
 * CHANGES
        
*/


{classes.i}
{vip_prate.i}
/* Установление льготных курсов безналичных валют */

def var rez as log.
def var VP AS CLASS VIPRATEClass.
def var Client AS CLASS ClientClass.  

define temp-table tmp-rate    field ClName as char  format "x(30)"
                              field Oper as char format "x(20)"
                              field Rate as deci format "zzz,zzz.9999"
                              field Valid_to as date format "99/99/99"
                              field cif as char format "x(6)"
                              field dt_cr as date
                              field tm_cr as int
                              field who_cr as char
                              field idrate as int.
                              
if not VALID-OBJECT(VP)    then  VP     = new VIPRATEClass(Base).
if not VALID-OBJECT(Client)then  Client = new ClientClass().
                              
/********************************************************************************************************************/   
/*Start program*/
  REPEAT on ENDKEY UNDO  , leave :
  
      run FindList.
      run ShowList(VP).
     
      if VP:cif = ? then
      do:
        run yn("","Выйти из программы?","","", output rez). 
        if rez then leave.
        else undo.
      end.
      
      run ShowData(VP). 
  END.   
/*End program*/
/********************************************************************************************************************/
if VALID-OBJECT(VP)  then DELETE OBJECT VP NO-ERROR .  
if VALID-OBJECT(Client)  then DELETE OBJECT Client NO-ERROR .
/********************************************************************************************************************/




procedure ShowData:
   /* Отображение данных текущего курса */
   DEF input param  VP AS Class VIPRATEClass.
   define button BtnSave label "Сохранить".
   define button BtnCancel label "Отмена".
   DEFINE VAR Oper AS CHARACTER VIEW-AS COMBO-BOX.

   
   define frame DataFrame
          cif AS char FORMAT "x(6)"                     label "ID клиента" skip
          ClName AS char FORMAT "x(30)"                 label "Клиент    " skip
          Oper                                          label "Операция  " FORMAT "x(20)" skip
          rate AS decimal FORMAT "->>,>>9.9999"         label "Курс      " skip
          summ AS decimal FORMAT "->>,>>>,>>>,>>9.99"   label "Сумма     " CRC as char format "x(3)" no-label skip 
          valid_to AS date FORMAT "99/99/99"            label "Дата      " skip
          "__________________________________________" skip(1)
          space (10) BtnSave BtnCancel
          WITH SIDE-LABELS centered overlay row 10 TITLE "Данные по льготному курсу".
          
          
          /****************************************************************************************************/
          ON CHOOSE OF BtnSave IN FRAME DataFrame DO:
            apply "endkey" to frame DataFrame.
            VP:cif = cif:SCREEN-VALUE.
            VP:rate = decimal(rate:SCREEN-VALUE).
            VP:summ = decimal(summ:SCREEN-VALUE).
            VP:oper = EncodeOper(Oper:SCREEN-VALUE).
            VP:valid_to = date(valid_to:SCREEN-VALUE).
            VP:Post().
          END.
          /****************************************************************************************************/
          ON CHOOSE OF BtnCancel IN FRAME DataFrame DO:
            apply "endkey" to frame DataFrame.
            VP:Free().
            VP:ClearData().
          END.
          /****************************************************************************************************/
          ON END-ERROR OF rate, cif, summ, valid_to in frame DataFrame DO:
            apply "endkey" to frame DataFrame.
            VP:Free().
            VP:ClearData().
          END.
          /****************************************************************************************************/
          ON RETURN, CURSOR-DOWN, CURSOR-UP OF cif IN FRAME DataFrame DO:
           if Client:FindClientNo(cif:SCREEN-VALUE) and CheckAccCount(Client) then
           do:
             ClName = Client:clientname.
             ASSIGN Oper:LIST-ITEMS IN FRAME DataFrame = ListOper(Client) .
             Oper:INNER-LINES = Oper:NUM-ITEMS.
             Oper:SCREEN-VALUE = Oper:ENTRY(1).
             enable cif Oper rate summ valid_to BtnSave BtnCancel with frame DataFrame.
             display ClName  with frame DataFrame.
           end.
           else do:
             enable cif with frame DataFrame. 
           end.  
          END.
          /****************************************************************************************************/
          ON VALUE-CHANGED, TAB OF Oper 
          DO:
            VP:oper = EncodeOper(SELF:SCREEN-VALUE).
            CRC = GetCRCcode(VP:oper).
            display CRC  with frame DataFrame.
          END.
          /****************************************************************************************************/
        
          rate     = VP:rate.
          cif      = VP:cif.
          summ     = VP:summ.
          valid_to = VP:valid_to.
        
                          
          if cif = ? or cif = "" then do: enable cif with frame DataFrame. end.
          else do:
            Client:FindClientNo(VP:cif).
            ClName = Client:clientname.
            
            ASSIGN Oper:LIST-ITEMS IN FRAME DataFrame = ListOper(Client) .
            Oper:INNER-LINES  = Oper:NUM-ITEMS.
            Oper:SCREEN-VALUE = DecodeOper(VP:oper).
            CRC = GetCRCcode(VP:oper).
            enable Oper rate summ valid_to BtnSave BtnCancel with frame DataFrame. 
          end.
          
          display cif Oper ClName rate summ CRC valid_to BtnSave BtnCancel with frame DataFrame.
          
                     
          WAIT-FOR endkey  of frame DataFrame.
          hide frame DataFrame. 
        
end procedure.    
/********************************************************************************************************************/

procedure ShowList: 
   /* Отображение списка активных льготных курсов */
   DEF input param  VP AS Class VIPRATEClass.
   
   define query q_list for tmp-rate.
   define browse b_list query q_list no-lock 
   display  tmp-rate.ClName label "Клиент" format "x(30)" tmp-rate.Oper label "Операция         " format "x(20)" 
     tmp-rate.Rate label "Курс        " format "zzz,zzz.9999" /*tmp-rate.Valid_to label "Дата"*/
          with title "Список активных льготных курсов" 15 down centered overlay  /*NO-ASSIGN SEPARATORS*/ no-row-markers.

   define frame f1 b_list skip space(18) "[Insert]-Добавить     [Delete]-Удалить" with no-labels centered overlay view-as dialog-box.
    /******************************************************************************/
    ON RETURN OF b_list in frame f1
    DO: 
     if avail tmp-rate then
     do:
       apply "endkey" to frame f1.
       /* Произведен выбор тарифа*/
       VP:Find-First("idrate = " + STRING(tmp-rate.idrate)).
       VP:Edit().
     end.  
    END.  
    /******************************************************************************/
    ON DELETE-CHARACTER OF b_list in frame f1 
    DO: 
      run yn("","Удалить выбранный курс?","","", output rez). 
      if rez then 
      do:
        if avail tmp-rate then
        do:
          find current tmp-rate.
          VP:Find-First("idrate = " + STRING(tmp-rate.idrate)).
         /*
          VP:Find-First("cif = '" + tmp-rate.cif + "' and dt_cr = " + string(tmp-rate.dt_cr) + " and tm_cr = " + string(tmp-rate.tm_cr) + " and who_cr = '" + tmp-rate.who_cr + "'"  ).
          */
          VP:Edit().
          VP:DelData().
          run FindList.
          open query q_list for each tmp-rate.
        end.  
      end.
    END.
    /******************************************************************************/
    ON INSERT-MODE OF b_list in frame f1 /*Добавить курс*/
    DO:
      run yn("","Добавить новый льготный курс ?","","", output rez). 
      if rez then 
      do:
       apply "endkey" to frame f1.
       VP:AddData().
       VP:cif = "".
       VP:summ = 0.0.
       VP:rate = 0.0.
      end.
    END.
    /******************************************************************************/
    ON END-ERROR OF b_list in frame f1
    DO:
      apply "endkey" to frame f1.
      VP:Free().
      VP:ClearData().
    END.
    /******************************************************************************/
        
    open query q_list for each tmp-rate. /* where viprate.del = no and viprate.valid_to >= g-today By viprate.cif.*/
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey of frame f1.
    hide frame f1.  

end procedure.    
/********************************************************************************************************************/
procedure FindList: 
  /* Заполнение темп таблицы данными из viprate*/   
  for each tmp-rate:
    delete tmp-rate.
  end.
  
  for each viprate where viprate.del = no and viprate.valid_to >= g-today By viprate.cif:
   create tmp-rate.
   tmp-rate.cif      = viprate.cif.
   Client:FindClientNo(viprate.cif).
   tmp-rate.ClName   = Client:clientname.
   tmp-rate.Oper     = DecodeOper(viprate.oper).
   tmp-rate.Rate     = viprate.rate.
   tmp-rate.Valid_to = viprate.valid_to.
   tmp-rate.dt_cr    = viprate.dt_cr.
   tmp-rate.tm_cr    = viprate.tm_cr.
   tmp-rate.who_cr   = viprate.who_cr.
   tmp-rate.idrate   = viprate.idrate.
  end.
  
end procedure.    
/********************************************************************************************************************/

