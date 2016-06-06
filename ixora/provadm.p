/* provadm.p
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
        22.04.2009 id00205
        07.05.2012 k.gitalov расширил поле Телефонные кода до 20 символов
 * CHANGES

*/



{classes.i}

def input param other as char.
def var v-txb as char no-undo.
def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
def var ListBank as char format "x(25)" VIEW-AS COMBO-BOX LIST-ITEMS "ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
                                     "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал".

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
/***********************************************************************************************************/

DEF VAR SP AS Class SUPPCOMClass.
SP = new SUPPCOMClass(Base).
def var rez as log.


  REPEAT on ENDKEY UNDO  , leave :
      run ShowSupp(SP).
      if  SP:txb = ? then
      do:
       if other = "" then run yn("","Выйти из программы?","","", output rez).
       else rez = true.
       if rez then leave.
       else do:
        SP:txb = v-txb.
        undo.
       end.
      end.
      else run ShowData(SP).
  END.

if VALID-OBJECT(SP) then delete object SP no-error.

/***********************************************************************************************************/
procedure ShowData:
     DEF input param  SP AS Class SUPPCOMClass.
     def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".

     if LOOKUP(SP:txb,ListCod) = 0 then
     do:
      message "Не найден код филиала " SP:txb  view-as alert-box title "Ошибка!".
      SP:txb = "TXB00". /* По умолчанию ЦО*/
     end.     /*Кокшетау TXB07*/
     def var ListBank as char format "x(25)" VIEW-AS COMBO-BOX LIST-ITEMS "ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
                                     "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал".

     DEFINE BUTTON save-button LABEL "Сохранить".
     DEFINE BUTTON cancel-button LABEL "Отмена".
     def var txb as char format "x(5)".
     define frame Form1
     ListBank                               label "Филиал банка "   txb label "Код" skip
     name AS character FORMAT "x(30)"       label "Наименование поставщика услуг            " skip
     bname AS character FORMAT "x(30)"      label "Наименование банка поставщика услуг      " skip
     iik AS character FORMAT "x(21)"        label "ИИК поставщика услуг                     " skip
     bik AS character FORMAT "x(21)"        label "БИК поставщика услуг                     " skip
     rnn AS character FORMAT "x(12)"        label "РНН поставщика услуг                     " skip
     nds-cer AS character FORMAT "x(6)"     label "Регистрация по НДС серия                 " skip
     nds-no AS character FORMAT "x(12)"     label "Регистрация по НДС номер                 " skip
     nds-date AS date FORMAT "99/99/99"     label "Регистрация по НДС дата                  " skip
     knp AS character FORMAT "x(3)"         label "Код назначения платежа                   " skip
     paycod AS character FORMAT "x(3)"      label "Код комиссии с физ лиц                   " skip
     supcod AS decimal FORMAT "->>,>>9.99"  label "Комиссия поставщику услуг                " skip
    /* cod AS integer FORMAT ">>>>>9"         label "Код вида платежа (1)                     " skip*/
     arp AS character FORMAT "x(21)"        label "АРП счет для поставщика                  " skip
     type AS integer FORMAT "->>>>>>9"      label "Тип поставщика                           " skip
     ap_code AS integer FORMAT "->>>>>>9"   label "Код провайдера в системе Авнгард-Плат    " skip
     ap_type AS integer FORMAT "->>>>>>9"   label "Тип провайдера в системе Авангард-Плат   " skip
     ap_tc AS character FORMAT "x(20)"      label "Телефонные кода провайдеров              " skip
     minsum AS decimal FORMAT "->>,>>9.99"  label "Минимальная сумма платежа                " skip
     minlen AS integer FORMAT "->>>>>>9"    label "Минимальная длина номера лицевого счета  " skip
     maxlen AS integer FORMAT "->>>>>>9"    label "Максимальная длина номера лицевого счета " skip
     ap_check AS integer FORMAT "->>>>>>9"  label "Наличие онлайн проверки по авангард плат " skip
     "-------------------------------------------------------------------------" skip
      space(25) save-button  cancel-button
     WITH SIDE-LABELS centered overlay row 4 TITLE "Данные поставщика услуг".

     ListBank:SCREEN-VALUE  = ListBank:ENTRY( LOOKUP(SP:txb,ListCod) ) no-error.

     ON VALUE-CHANGED OF ListBank
     DO:
      txb = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), ListCod) no-error.
      SP:txb = txb.
      display txb with frame Form1.
     END.


     ON RETURN OF ap_tc in  frame Form1
     DO:
       message "Установить кода для всех провайдеров данного типа?" view-as alert-box question buttons ok-cancel title "" update choice as logical.
       if choice then do:
          for each comm.suppcom where comm.suppcom.ap_code = ap_code and comm.suppcom.ap_type = ap_type  exclusive-lock:
            comm.suppcom.ap_tc = ap_tc:SCREEN-VALUE.
          end.
       end.
     END.

     ON RETURN OF supcod in  frame Form1
     DO:
       message "Установить комиссию для всех провайдеров данного типа?" view-as alert-box question buttons ok-cancel title "" update choice as logical.
       if choice then do:
          for each comm.suppcom where comm.suppcom.ap_code = ap_code and comm.suppcom.ap_type = ap_type  exclusive-lock:
            comm.suppcom.supcod = decimal(supcod:SCREEN-VALUE).
          end.
       end.
     END.

     ON RETURN OF paycod in  frame Form1
     DO:
       message "Установить код комиссии для всех провайдеров данного типа?" view-as alert-box question buttons ok-cancel title "" update choice as logical.
       if choice then do:
          for each comm.suppcom where comm.suppcom.ap_code = ap_code and comm.suppcom.ap_type = ap_type  exclusive-lock:
            comm.suppcom.paycod = paycod:SCREEN-VALUE.
          end.
       end.
     END.

     ON CHOOSE OF save-button
     DO:
        apply "endkey" to frame Form1.
        SP:name     = name:SCREEN-VALUE.
        SP:bname    = bname:SCREEN-VALUE.
        SP:iik      = iik:SCREEN-VALUE.
        SP:bik      = bik:SCREEN-VALUE.
        SP:rnn      = rnn:SCREEN-VALUE.
        SP:nds-cer  = nds-cer:SCREEN-VALUE.
        SP:nds-no   = nds-no:SCREEN-VALUE.
        SP:nds-date = nds-date.
        SP:knp      = knp:SCREEN-VALUE.
        SP:paycod   = paycod:SCREEN-VALUE.
        SP:supcod   = decimal(supcod:SCREEN-VALUE).
       /* SP:cod      = integer(cod:SCREEN-VALUE).*/
        SP:arp      = arp:SCREEN-VALUE.
        SP:type     = integer(type:SCREEN-VALUE).
        SP:ap_code  = integer(ap_code:SCREEN-VALUE).
        SP:ap_type  = integer(ap_type:SCREEN-VALUE).
        SP:ap_tc    = ap_tc:SCREEN-VALUE.
        SP:minsum   = decimal(minsum:SCREEN-VALUE).
        SP:minlen   = integer(minlen:SCREEN-VALUE).
        SP:maxlen   = integer(maxlen:SCREEN-VALUE).
        SP:ap_check = integer(ap_check:SCREEN-VALUE).

        SP:Post().
     END.
     ON CHOOSE OF cancel-button
     DO:
        apply "endkey" to frame Form1.
        SP:Free().
     END.

     txb       = SP:txb.
     name      = SP:name.
     bname     = SP:bname.
     iik       = SP:iik.
     bik       = SP:bik.
     rnn       = SP:bik.
     nds-cer   = SP:nds-cer.
     nds-no    = SP:nds-no.
     nds-date  = SP:nds-date.
     knp       = SP:knp.
     paycod    = SP:paycod.
     supcod    = SP:supcod.
    /* cod       = SP:cod.*/
     arp       = SP:arp.
     type      = SP:type.
     ap_code   = SP:ap_code.
     ap_type   = SP:ap_type.
     ap_tc     = SP:ap_tc.
     minsum    = SP:minsum.
     minlen    = SP:minlen.
     maxlen    = SP:maxlen.
     ap_check  = SP:ap_check.

   if other = "1" then do:
    enable  supcod  save-button  cancel-button
    with frame Form1.
   end.
   else do:
    enable name bname iik bik rnn nds-cer nds-no nds-date knp paycod supcod /*cod*/ arp type
     ap_code ap_type ap_tc minsum minlen maxlen ap_check save-button  cancel-button
    with frame Form1.
   end.
    display ListBank txb name bname iik bik rnn nds-cer nds-no nds-date knp paycod supcod /*cod*/ arp type
     ap_code ap_type ap_tc minsum minlen maxlen ap_check
    with frame Form1.

    WAIT-FOR endkey of frame Form1.
    hide frame Form1.

end procedure.
/***********************************************************************************************************/

procedure ShowSupp:  /* Список поставщиков услуг */
   DEF input param  p-SP AS Class SUPPCOMClass.

   define query q_list for comm.suppcom.
   define browse b_list query q_list no-lock
   display comm.suppcom.name label "Наименование" comm.suppcom.knp label "КНП" comm.suppcom.txb label "Код филиала"
          with 15 down centered overlay  /*NO-ASSIGN SEPARATORS*/ no-row-markers.

   define frame f1 "Филиал банка " ListBank  v-txb skip
   b_list skip space(5) "[Insert] - Добавить | [Delete] - Удалить " with title "Список поставщиков услуг" no-labels centered overlay view-as dialog-box.


   ListBank:SCREEN-VALUE  = ListBank:ENTRY( LOOKUP(SP:txb,ListCod) ) no-error.
   v-txb = p-SP:txb.


     ON VALUE-CHANGED OF ListBank
     DO:
      v-txb = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), ListCod) no-error.
      p-SP:txb = v-txb.
      open query q_list for each comm.suppcom where comm.suppcom.type <> 0 and comm.suppcom.txb = p-SP:txb By comm.suppcom.name .
      display v-txb with frame f1.
     END.

    /******************************************************************************/
    on return of b_list in frame f1
    do:
     find current comm.suppcom no-lock no-error.
     if avail comm.suppcom then
     do:
       p-SP:Find-First("supp_id = " + string(comm.suppcom.supp_id) ).
       p-SP:Edit().
       apply "endkey" to frame f1.
     end.
    end.
    /******************************************************************************/
    ON DELETE-CHARACTER OF b_list in frame f1 /*Удалить поставщика*/
    DO:
      run yn("","Удалить выбранного поставщика?","","", output rez).
      if rez then
      do:
       find current comm.suppcom exclusive-lock.
       find first comm.compaydoc where comm.compaydoc.supp_id = comm.suppcom.supp_id no-lock no-error.
       if not avail comm.compaydoc then do:
         delete comm.suppcom.
       end.
       else message "По данному провайдеру имеются проведенные платежи~n Удаление невозможно!" view-as alert-box.

      /* open query q_list for each comm.suppcom .*/
       open query q_list for each comm.suppcom where comm.suppcom.type <> 0 and comm.suppcom.txb = p-SP:txb By comm.suppcom.name.
      end.
    END.
    /******************************************************************************/
    ON INSERT-MODE OF b_list in frame f1 /*Добавить поставщика*/
    DO:
      run yn("","Добавить нового поставщика?","","", output rez).
      if rez then
      do:
       apply "endkey" to frame f1.
       p-SP:AddData().
       SP:txb = v-txb.
      end.
    END.
    /******************************************************************************/
    ON END-ERROR OF b_list , ListBank in frame f1
    DO:
      apply "endkey" to frame f1.
      p-SP:Free().
      p-SP:ClearData().
    END.
    /******************************************************************************/

    open query q_list for each comm.suppcom where comm.suppcom.type <> 0 and comm.suppcom.txb = p-SP:txb By comm.suppcom.name .
    display v-txb with frame f1.
    enable  b_list ListBank with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey , INSERT-MODE of frame f1.
    hide frame f1.

end procedure.
/***********************************************************************************************************/
