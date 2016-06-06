/* m_valop.p
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
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        10.11.2010 k.gitalov - добавил расчет курсовой разницы при Кросс конвертации
        22.12.2010 k.gitalov - для кредитного департамента - без комиссии
        09.02.2011 Luiza     - добавила режим поиска клиента в on help .....
        10.02.2011 Luiza     - добавила update для клиента  .....
        20/07/2011 lyubov    - исключила из выводимого списка счетов счета О/Д
        25.07.2011 k.gitalov - изменил алгоритм транзакций по обычной покупке/продаже по ТЗ1014
        03/08/2011 evseev    - на основании С.З. запрет конвертации 478,479,480,481,482,483
        05.05.2012 damir     - добавил кнопку <Заявление>. Новые форматы заявлений.
        21.05.2012 evseev - добавил цель покупки/продажи
        11.10.2012 evseev - изменил поиск по netbank
        16/02/2013 Luiza - ТЗ № 825 шаблон dil0066 при продаже валюты день в день (п.м. 2.3.3) заменила на dil0070
                            при продаже валюты на след день (п.м. 2.3.4) шаблон dil0020 заменила на dil0071 (Зачисление средств от продажи валюты)
        20.03.2013 damir - Исправлена техническая ошибка.
        20/05/2013 Luiza - ТЗ 1596 и ТЗ 1613 Изменения шаблонов по счету 1858
        11.06.2013 evseev - tz-1402
        18.06.2013 evseev - tz-1845
        02.10.2013 damir - Внедрено Т.З. № 1550.
*/

{classes.i}
{srvcheck.i}

def input param DocNo as char.

def var v-select as char.
def var v-tempstr as char.

DEF VAR Doc AS CLASS ConvDocClass.
def new shared var s-jh like jh.jh.
def var v-sts like jh.sts no-undo.
def var note as char.
def var rez as log.
def shared var dType as integer.
def var  diff_tamount as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Курсовая разница*/
def var  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".       /* Сумма в тенге по курсу нац банка начальная*/
def var  avg_tamount2   as decimal  format "zzz,zzz,zzz,zzz.99".       /* Сумма в тенге по курсу нац банка конечная*/
def var trxcode as char.
def var sb as int.  /* признак определения валюты ввода суммы  */
/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE VARIABLE v-cif1 AS char.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 25 width 89 NO-BOX.
/*  help for cif */
&scoped-define ShowMenu assign current-window:menubar = menu m_menu:handle.


def var Caption as char extent 6 initial  ["Срочная покупка ин. валюты",
                                           "Обычная покупка ин. валюты",
                                           "Срочная продажа ин. валюты",
                                           "Обычная продажа ин. валюты",
                                           "                          ",
                                           "Кросс-конвертация"].

 def var  csLabel as char format "x(34)" init "                                 :".
 def var  rsLabel as char format "x(34)" init "                                 :".
 def var curLabel as char format "x(13)" init "            :".
 def var purposeLabel as char format "x(14)" init "             :".


   case dType:
        when 1 OR
        when 2 OR
        when 6 then purposeLabel = "Цель покупки :".

        when 3 OR
        when 4 then purposeLabel = "Цель продажи :".
   end.

def stream v-out.
def var v-file      as char init "Applicationconvert.htm".
def var v-inputfile as char init "".
def var v-naznplat  as char.
def var v-str       as char.
def var decAmount   as deci decimals 2.
def var strAmount   as char init "".
def var temp        as char init "".
def var str1        as char init "".
def var str2        as char init "".
def var strTemp     as char init "".
def var v_rezid     as char.
def var v_crc       as inte.
def var V-KOD       as char init "".

 DEFINE FRAME MainFrame
         documN      as char label  "Номер документа" skip
         clientno as char label  "ID клиента" validate(can-find(first cif where cif.cif = clientno no-lock),"Нет такого ID клиента! F2-помощь")
         clientname as char format "x(45)" label "Клиент" skip
         from_accno as char format "x(20)"  label "Счет клиента для снятия средств     "  from_lab0 no-label as char format "x(3)" skip
         to_accno as char format "x(20)"    label "Счет клиента для зачисления средств "  to_lab0 no-label as char format "x(3)"skip
         com_accno as char format "x(20)"   label "Счет клиента для снятия комиссии    "  com_lab0 no-label as char format "x(3)"skip (1)
         currency as integer label "Валюта " format ">9" space (5) currate as decimal label "Курс" format "zzz,zzz.9999" space (5)
         curLabel no-label currate2 as decimal no-label format "zzz,zzz.9999" skip(1)
         csLabel no-label conv_summ as decimal format "zzz,zzz,zzz,zzz.99" no-label from_lab no-label as char format "x(3)" skip
         rsLabel no-label result_summ as decimal format "zzz,zzz,zzz,zzz.99" no-label to_lab no-label as char format "x(3)" skip(1)
         comm_summ as decimal      label "Комиссия за конвертацию          " format "zzz,zzz,zzz,zzz.99"
         com_lab no-label as char format "x(3)"  skip
         conv_int as decimal     label "Процент комиссии за конвертацию  " skip
         purposeLabel no-label skip purpose as char format "x(60)" no-label skip (2)
         Mess as char no-label format "x(60)"
 WITH SIDE-LABELS centered overlay row 8 TITLE Caption[dType].



PROCEDURE ShowFrame :
def input param Doc as ConvDocClass.
clear frame MainFrame NO-PAUSE.

     CASE Doc:DocType:
        WHEN  1 THEN DO:
         /*Срочная покупка ин. валюты*/
         csLabel = "Сумма на конвертацию в тенге     :".
         rsLabel = "Сумма на конвертацию в валюте    :".
         curLabel = "".
         from_accno    = Doc:tclientaccno.
         to_accno      = Doc:vclientaccno.
         conv_summ     = Doc:t_amount.
         result_summ   = Doc:v_amount.
         from_lab = Doc:CRCC:get-code(Doc:tclientaccno).
         to_lab   = Doc:CRCC:get-code(Doc:vclientaccno).
        END.
        WHEN 2 THEN DO:
         /*Обычная покупка ин. валюты*/
         csLabel = "Сумма на конвертацию в тенге     :".
         rsLabel = "Сумма на конвертацию в валюте    :".
       /*  curLabel = "Текущий курс:".*/
         from_accno    = Doc:tclientaccno.
         to_accno      = Doc:vclientaccno.
         conv_summ     = Doc:t_amount.
         result_summ   = Doc:v_amount.
         from_lab = Doc:CRCC:get-code(Doc:tclientaccno).
         to_lab   = Doc:CRCC:get-code(Doc:vclientaccno).
        END.
        WHEN 3 THEN DO:
         /*Срочная продажа ин. валюты*/
         csLabel = "Сумма на конвертацию в валюте    :".
         rsLabel = "Сумма на конвертацию в тенге     :".
         curLabel = "".
         from_accno    = Doc:vclientaccno.
         to_accno      = Doc:tclientaccno.
         conv_summ     = Doc:v_amount.
         result_summ   = Doc:t_amount.
         from_lab = Doc:CRCC:get-code(Doc:vclientaccno).
         to_lab   = Doc:CRCC:get-code(Doc:tclientaccno).
        END.
        WHEN 4 THEN DO:
         /*Обычная продажа ин. валюты*/
         csLabel = "Сумма на конвертацию в валюте    :".
         rsLabel = "Сумма на конвертацию в тенге     :".
        /* curLabel = "Текущий курс:".*/
         from_accno    = Doc:vclientaccno.
         to_accno      = Doc:tclientaccno.
         conv_summ     = Doc:v_amount.
         result_summ   = Doc:t_amount.
         from_lab = Doc:CRCC:get-code(Doc:vclientaccno).
         to_lab   = Doc:CRCC:get-code(Doc:tclientaccno).
        END.
        WHEN 6 THEN DO:
         /*Кросс конвертация*/
         csLabel = "Сумма на конвертацию начальная   :".
         rsLabel = "Сумма на конвертацию конечная    :".
         curLabel = "".
         from_accno    = Doc:tclientaccno.
         to_accno      = Doc:vclientaccno.
         conv_summ     = Doc:t_amount.
         result_summ   = Doc:v_amount.
         from_lab = Doc:CRCC:get-code(Doc:tclientaccno).
         to_lab   = Doc:CRCC:get-code(Doc:vclientaccno).
        END.
     END CASE.

       com_lab  = Doc:CRCC:get-code(Doc:com_accno).

       documN        = Doc:DocNo.
       clientno      = Doc:Client:clientno.
       clientname    = Doc:Client:clientname.
       com_accno     = Doc:com_accno.
       currency      = Doc:crc.
       currate       = Doc:rate.
       currate2      = Doc:rate2.
       comm_summ     = Doc:com_conv.
       conv_int      = Doc:conv_int.

       purpose       = Doc:purpose.

       from_lab0     = from_lab.
       to_lab0       = to_lab.
       com_lab0      = com_lab.

       Mess          = Doc:Mess.

  IF Doc:DocType = 2 OR Doc:DocType = 4 THEN
  DO:
   DISPLAY documN
           clientno
           clientname
           from_accno
           from_lab0
           to_accno
           to_lab0
           com_accno
           com_lab0
           currency
           currate
           curLabel
         /*  currate2 */
           csLabel
           conv_summ
           rsLabel
           from_lab
           result_summ
           to_lab
           comm_summ
           com_lab
           conv_int
           purposeLabel
           purpose
           Mess
   WITH  FRAME MainFrame.
  END.
  ELSE DO:
    IF Doc:DocType = 1 OR Doc:DocType = 3 OR Doc:DocType = 6 THEN
    DO:
      DISPLAY documN
           clientno
           clientname
           from_accno
           from_lab0
           to_accno
           to_lab0
           com_accno
           com_lab0
           currency
           currate
           csLabel
           conv_summ
           rsLabel
           from_lab
           result_summ
           to_lab
           comm_summ
           com_lab
           conv_int
           purposeLabel
           purpose
           Mess
      WITH  FRAME MainFrame.
    END.
  END.
END PROCEDURE. /* ShowFrame */



 def  var rcode  as int.
 def  var rdes   as char.
 def  var dlm    as char init "|".
 def  var vparam as char.

 /* menu-item d_open   label "Изменить"*/

define sub-menu m_document.
    menu-item d_create label "Новый"
    menu-item d_view   label "Поиск..."
    menu-item d_delete label "Удалить"
    menu-item d_exit   label "Выход".

define sub-menu m_inet.
    menu-item i_reject  label "Отказ".
    menu-item i_print   label "Печать".

define sub-menu m_transaction.
    menu-item t_create  label "Создать"
    menu-item t_create2 label "Вторая транзакция"
    menu-item t_delete  label "Удалить"
    menu-item t_print   label "Печать".

define sub-menu sub_app
    menu-item c_appli label "&Заявление".

define menu m_menu menubar
    sub-menu m_document     label "Документ"
    sub-menu m_inet         label "Интернет-заявки"
    sub-menu m_transaction  label "Транзакция"
    sub-menu sub_app        label "Заявление".


/******************************************************************************************************/
  if DocNo <> "" then do: /* Интернет конвертация */

     if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR .
     Doc = NEW ConvDocClass(dType , Base ).
     sub-menu m_inet:SENSITIVE = TRUE.

     if Doc:FindDoc(DocNo) then
     do:

        if  Doc:CalcDoc() = false then
        do:
          MENU-ITEM t_create:SENSITIVE = FALSE.
          MENU-ITEM t_create2:SENSITIVE = FALSE.
        /*  MENU-ITEM i_reject:SENSITIVE = FALSE.*/
          MENU-ITEM i_print:SENSITIVE = FALSE.
        end.


        run ShowFrame(Doc).

        if Doc:DocType = 1 or Doc:DocType = 3 or Doc:DocType = 6 then
        do:
           MENU-ITEM t_create2:SENSITIVE = FALSE.
        end.
           MENU-ITEM d_create:SENSITIVE = FALSE.
           MENU-ITEM d_view:SENSITIVE = FALSE.
     end.
     else do:

       CLEAR FRAME MainFrame.
       HIDE FRAME MainFrame.
       return.
     end.
  end.
  else do:

    sub-menu m_inet:SENSITIVE = FALSE.
    if dType = 1 or dType = 3 or dType = 6 then do: MENU-ITEM t_create2:SENSITIVE = FALSE. end.
  end.


/******************************************************************************************************/
on choose of menu-item i_reject
do:

    /* if dealing_doc.who_cr = "inbank" and dealing_doc.jh = ? and dealing_doc.jh2 = ? then do:*/
   if VALID-OBJECT(Doc) then
   do:
    if Doc:who_cr = "inbank" and Doc:jh = ? and Doc:jh2 = ? then
    do:
        run connib.
        run dil_irej(DocNo).
        if connected("ib") then disconnect "ib".
        {&ShowMenu}
    end.
    else message "Документ имеет транзакции или не интернет конвертация!" view-as alert-box.
   end.
   else message "Нет активного документа!" view-as alert-box.
end.
/******************************************************************************************************/
on choose of menu-item i_print
do:
  if VALID-OBJECT(Doc) then
  do:
    if Doc:who_cr = "inbank" then do:
        run connib.
        run dil_iprt(DocNo).
        if connected("ib") then disconnect "ib".
        {&ShowMenu}
    end.
  end.
  else message "Нет активного документа!" view-as alert-box.
end.
/******************************************************************************************************/

on choose of menu-item d_create do:
    /* Создание нового документа на конвертацию*/

    sub-menu m_transaction:SENSITIVE IN MENU m_menu = FALSE.
    sub-menu m_inet:SENSITIVE IN MENU m_menu = FALSE.
    sub-menu m_document:SENSITIVE IN MENU m_menu = FALSE.
    sub-menu sub_app:SENSITIVE IN MENU m_menu = FALSE.

    if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR .
    Doc = NEW ConvDocClass(dType ,Base ).

    Doc:AddData().

    /*  help for cif */
    on help of clientno in frame MainFrame do:
        run h-cif PERSISTENT SET phand.
        hide frame xf.
        clientno = frame-value.
        displ  clientno with frame MainFrame.
        DELETE PROCEDURE phand.
    end.
    /*  help for cif */

    on help of currency in frame MainFrame do:
        run help-crc1.
    end.

    /*---------------------*/

    repeat on ENDKEY UNDO  , leave :
        run ShowFrame(Doc).
        /*Ввод id клиента */
        hide frame f-help.
        update clientno with frame MainFrame.
        find first cif where cif.cif  =  trim(clientno) no-lock no-error.
        if available cif then do:
            clientname =  cif.sname.
            displ clientname with frame MainFrame.
            pause 0.
        end.
        if dType = 1 or dType = 2 then find first aaa where aaa.cif = clientno and aaa.sta <> "C" and aaa.sta <> "E" and
        aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock no-error.
        if dType = 3 or dType = 4 or dType = 6 then find first aaa where aaa.cif = clientno and aaa.sta <> "C" and
        aaa.sta <> "E" and aaa.crc <> 1 and length(aaa.aaa) >= 20 no-lock no-error.
        if available aaa then do:
            if dType = 1 or dType = 2 then OPEN QUERY  q-help FOR EACH aaa where aaa.cif = clientno and aaa.sta <> "C" and
            aaa.sta <> "E" and aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock,each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA"
            no-lock.
            if dType = 3 or dType = 4 or dType = 6 then OPEN QUERY  q-help FOR EACH aaa where aaa.cif = clientno and aaa.sta <> "C"
            and aaa.sta <> "E" and aaa.crc <> 1 and length(aaa.aaa) >= 20 no-lock,each lgr where aaa.lgr = lgr.lg and
            lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help FOCUS b-help IN FRAME f-help.
            from_accno = aaa.aaa.
            hide frame f-help.

            if lookup(aaa.lgr,"478,479,480,481,482,483,A38,A39,A40,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") > 0  then do:
                message "Внимание: Конвертация данного счета запрещена" view-as alert-box buttons OK .
                undo.
            end.
            displ from_accno with frame MainFrame.
        end.
        else do:
            from_accno = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            undo.
        end.
        /* Ввод счета для снятия средств
        set from_accno with frame MainFrame.
        if from_accno entered then do: */
        if Doc:FindClient(from_accno) then do:
            if Doc:DocType = 1 or Doc:DocType = 2 or Doc:DocType = 6 then Doc:tclientaccno = from_accno.
            if Doc:DocType = 3 or Doc:DocType = 4 then Doc:vclientaccno = from_accno.
        end.
        else do: from_accno = "". undo. end.
        /* end.
        else undo,retry.
        */

        /**********************************************************************************************************/
        run ShowFrame(Doc).
        /* Ввод валюты */
        /**********************************************************************************************************/
        /******************************************  Покупка валюты  **********************************************/
        if Doc:DocType = 1 or Doc:DocType = 2 then do:
            set currency with frame MainFrame.
            if currency entered then do:
                if currency = 1 then do: message "Введите счет в валюте!" view-as alert-box. undo. end.
                run sel1("Выберите счет для зачисления средств", Doc:Client:FindAcc(currency)).
                Doc:vclientaccno = return-value.
                if Doc:vclientaccno = "" then do: Doc:crc = 0. undo. end.
                else do:
                    Doc:crc = currency.
                end.
            end.
            else undo ,retry.
        end.
       /**********************************************************************************************************/
       /******************************************  Продажа валюты  **********************************************/
        if Doc:DocType = 3 or Doc:DocType = 4 then do:
            run sel1("Выберите счет для зачисления средств", Doc:Client:FindAcc(1)).
            Doc:tclientaccno = return-value.
            if Doc:CRCC:get-crc(Doc:tclientaccno) <> 1 then do: Doc:crc = 0. /*leave*/ undo. end.
            else do:
                Doc:crc = Doc:CRCC:get-crc(Doc:vclientaccno).
            end.
        end.
        /**********************************************************************************************************/
        /****************************************** Кросс конвертация *********************************************/
        if Doc:DocType = 6 then do:
            set currency with frame MainFrame.
            if currency entered then do:
                if currency = 1 then do: message "Введите счет в валюте!" view-as alert-box. undo. end.
                if currency = Doc:CRCC:get-crc(Doc:tclientaccno) then do:
                    message "Введите счет в другой валюте!" view-as alert-box. undo.
                end.
                run sel1("Выберите счет для зачисления средств", Doc:Client:FindAcc(currency)).
                Doc:vclientaccno = return-value.
                if Doc:vclientaccno = "" then do: Doc:crc = 0. undo. end.
                else do:
                    Doc:crc = currency.
                end.
            end.
        end.

        /**********************************************************************************************************/

        run ShowFrame(Doc).

        /**********************************************************************************************************/
        /*Для кредитного администрирования без комиссии*/
        if Base:g-fname = "DILDKA1" or Base:g-fname = "DILDKA3" then do:
            Doc:com_accno = Doc:tclientaccno.
            if Doc:FindRate()  = false then undo.
            Doc:rate = Doc:cur_rate.
            doc:purpose = "212414 «Выполнение обязательств по займам»".

        end.
        else do:
            /* Ввод счета для снятия комиссии */
            run sel1("Выберите счет для снятия комиссии", Doc:Client:FindAcc()).
            Doc:com_accno = return-value.

            if Doc:com_accno = "" then undo.
            else do: /*Поиск тарифов и перевод мин.суммы комиссии в валюту счета снятия комиссии*/
                if Doc:FindTarif() = false then undo.
                if Doc:FindRate()  = false then undo.
                Doc:rate = Doc:cur_rate.
            end.
        end.
        /**********************************************************************************************************/

        run ShowFrame(Doc).

        /************************ Выбор валюты ввода суммы ********************************************************/
        run sel1("Выберите валюту ввода суммы", Doc:CRCC:get-code(Doc:tclientaccno) + "|" + Doc:CRCC:get-code(Doc:vclientaccno)).
        Doc:input_crc = Doc:CRCC:get-id-crc( return-value ).
        if Doc:input_crc = 0 then  undo, retry.

        if Doc:DocType = 1 or Doc:DocType = 2 or Doc:DocType = 6 then do:
            if Doc:CRCC:get-crc(Doc:tclientaccno) =  Doc:input_crc then do:
                sb = 1. /* выбрана начальная сумма  */
                set conv_summ with frame MainFrame.
                if conv_summ entered then do:
                    Doc:f_amount = conv_summ.
                end.
                else undo,retry.
            end.
            else do:
                sb = 2. /* выбрана конечная сумма  */
                set result_summ with frame MainFrame.
                if result_summ entered then do:
                    Doc:f_amount = result_summ.
                end.
                else undo,retry.
            end.
        end.

        if Doc:DocType = 3 or Doc:DocType = 4 then do:
            if Doc:CRCC:get-crc(Doc:tclientaccno) =  Doc:input_crc then do:
                set result_summ with frame MainFrame.
                if result_summ entered then do:
                    Doc:f_amount = result_summ.
                end.
                else undo,retry.
            end.
            else do:
                set conv_summ with frame MainFrame.
                if conv_summ entered then do:
                    Doc:f_amount = conv_summ.
                end.
                else undo,retry.
            end.
        end.

        if ((aaa.gl >= 220300 and aaa.gl <= 220399) or (aaa.gl >= 220400 and aaa.gl <= 220499)) and
           ((cif.geo = "022" and (dType = 3 or dType = 4)) or (dType = 1 or dType = 2 or dType = 6))  then do:
            run ShowFrame(Doc).
            run sel2 (purposeLabel, "в пользу нерезидента|в пользу резидента", output v-select).
            if v-select = "0" then undo,retry.
            if v-select = "1" then v-tempstr = 'purpose_nr'. else v-tempstr = 'purpose_r'.

            find first sysc where sysc.sysc = v-tempstr  no-lock no-error.
            run sel2 (purposeLabel, sysc.chval, output v-select).
            if v-select = "0" then undo,retry.
            doc:purpose = entry(int(v-select) , sysc.chval , "|").
        end. else do:
            doc:purpose = "".
        end.

       /**********************************************************************************************************/
        if Doc:CheckDoc() = false then undo,retry.
        run ShowFrame(Doc).
       /**********************************************************************************************************/
        Doc:NewDoc(). /* Сохранение документа */
        if not Doc:FindDoc(Doc:DocNo) then undo,retry.
        if not Doc:CalcDoc() then undo,retry.
        run ShowFrame(Doc).

        /**********************************************************************************************************/
        message "Печатать заявление?" view-as alert-box buttons yes-no update v-chang as logi format "да/нет".
        if v-chang then run print_application.
        /**********************************************************************************************************/
        pause.
        run yn("","Сделать транзакцию?","","", output rez).
        if rez then do:
            if Doc:DocType = 1 or Doc:DocType = 3 or Doc:DocType = 6 then do:
                /* срочная покупка - продажа валюты  и кросс конвертация */
                run do_exprtrans.
            end.
            else do:
                /* Обычная покупка продажа валюты */
                run do_trans1.
            end.
        end.
        /**********************************************************************************************************/
        LEAVE.
    end.

    CLEAR FRAME MainFrame.
    HIDE FRAME MainFrame.

    if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.

    sub-menu m_transaction:SENSITIVE IN MENU m_menu = TRUE.
    sub-menu m_inet:SENSITIVE IN MENU m_menu = TRUE.
    sub-menu m_document:SENSITIVE IN MENU m_menu = TRUE.
    sub-menu sub_app:SENSITIVE IN MENU m_menu = TRUE.
end.
/******************************************************************************************************/
on choose of menu-item d_view do:
    /* Поиск,просмотр документов */
    CLEAR FRAME MainFrame.
    HIDE FRAME MainFrame.
    if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR .
    Doc = NEW ConvDocClass(dType , Base ).

    DEFINE FRAME FindDocFrame documN as char label  "Номер документа" skip
    WITH  SIDE-LABELS  TITLE "Поиск документа".

    on help of documN in frame FindDocFrame do:
        run help-convdoc.
        documN = return-value.
        displ documN with frame FindDocFrame.
    end.

    repeat on ENDKEY UNDO , leave:
        /*****************************************/
        set documN with frame FindDocFrame.
        if documN entered then do:
            if Doc:FindDoc(documN) then do:
                if  Doc:CalcDoc() = false then do:
                    sub-menu m_transaction:SENSITIVE IN MENU m_menu = FALSE.
                end.
                hide frame FindDocFrame.
                run ShowFrame(Doc).
                leave.
            end.
            else do:
                documN = "".
                displ documN with frame FindDocFrame.
                CLEAR FRAME MainFrame.
                HIDE FRAME MainFrame.
                undo,retry.
            end.
        end.
        else undo,retry.
        /*****************************************/
    end.
    hide frame FindDocFrame.
    if Doc:DocNo ="" then DELETE OBJECT Doc NO-ERROR .

end.
/******************************************************************************************************/
on choose of menu-item d_delete do:
    /* Удаление  документа */
    if VALID-OBJECT(Doc) then do:
        run yn("", "Вы уверены что хотите удалить документ?", "","" ,output rez).
        if rez then do:
            if Doc:DeleteDoc() then do:
                CLEAR FRAME MainFrame.
                HIDE FRAME MainFrame.
                if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
            end.
        end.
    end.
    else do:
        message "Нет активного документа!" view-as alert-box.
        return.
    end.
end.
/******************************************************************************************************/
on choose of menu-item d_exit do:

end.
/******************************************************************************************************/
on choose of menu-item t_delete do:
    run delete_trans.
end.
/******************************************************************************************************/
on choose of menu-item t_create do:
    if VALID-OBJECT(Doc) then do:
        if Doc:DocType = 1 or Doc:DocType = 3 or Doc:DocType = 6 then do:
            /* Срочная покупка - продажа валюты */
            run do_exprtrans.
        end.
        if Doc:DocType = 2 or Doc:DocType = 4 then do:
            /* Обычная покупка - продажа валюты */
            run do_trans1.
        end.
        /**************************************************************/
        if s-jh <> 0 then do:

            find last netbank where netbank.rmz = Doc:DocNo and date(netbank.rem[4])>= today - 3 /* dealing_doc.docno*/ exclusive-lock no-error.

            if avail netbank then do:

                def buffer b-crcc for crc.

                def buffer b-sonic for sysc.

                DEFINE VARIABLE ptpsession AS HANDLE.

                DEFINE VARIABLE messageH AS HANDLE.

                run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
                if isProductionServer() then run setbrokerurl in ptpsession ("172.16.3.5:2507").
                else run setbrokerurl in ptpsession ("172.16.2.77:2507").

                run setUser in ptpsession ("SonicClient").
                run setPassword in ptpsession ("SonicClient").

                RUN beginSession IN ptpsession.


                run createXMLMessage in ptpsession (output messageH).

                run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").

                run appendText in messageH ("<DOC>").

                run appendText in messageH ("<CURRENCY_EXCHANGE>").

                run appendText in messageH ("<ID>" + netbank.id + "</ID>").

                run appendText in messageH ("<STATUS>5</STATUS>").

                run appendText in messageH ("<DESCRIPTION>Исполнен</DESCRIPTION>").

                run appendText in messageH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").

                run appendText in messageH ("</CURRENCY_EXCHANGE>").


                run appendText in messageH ("</DOC>").

                RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).

                RUN deleteMessage IN messageH.

                netbank.sts = "5".

                netbank.rem[1] = "Исполнен" .
            end.
        end.
        /**************************************************************/
    end.
    else message "Нет активного документа!" view-as alert-box.
end.
/******************************************************************************************************/
on choose of menu-item t_create2 do: /* При обычной покупке - продаже */
    if VALID-OBJECT(Doc) then do:
        if Doc:DocType = 2 or Doc:DocType = 4 then run do_trans2.
    end.
    else message "Нет активного документа!" view-as alert-box.
end.
/******************************************************************************************************/
on choose of menu-item t_print do:
    run print_doc.
end.

on choose of menu-item c_appli do:
    run print_application.
end.

assign current-window:menubar = menu m_menu:handle.



wait-for choose of menu-item d_exit .

/***********************************************************************************************************************/
procedure do_exprtrans:
  /* При срочной покупке-продаже и кросс конвертации */
  if VALID-OBJECT(Doc) then
  do:
       vparam = "".
       s-jh = 0.
       rcode = 0.
       rdes = "".
       note = "".
       def var diff_summ as decimal format "zzz,zzz,zzz,zzz.99". /* Сумма в тенге с учетом курсовой разницы (Для снятия с АРП счета)*/

        find dealing_doc where dealing_doc.docno = Doc:DocNo share-lock no-error.
         if dealing_doc.jh = ? or dealing_doc.jh = 0 then
         do:
           find current dealing_doc no-lock no-error.
         end.
         else do:
           find current dealing_doc no-lock no-error.
           message "Транзакция уже сделана!  jh = " dealing_doc.jh  view-as alert-box.
           return.
         end.

       do transaction:

       /**********************************************************************************************************/


       /**********************************************************************************************************/
       if Doc:DocType = 1 then do: /* Срочная покупка */
          /* Определение курсовой разницы */
         avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc). /*Сумма в тенге по курсу нацбанка*/
         diff_tamount = avg_tamount - Doc:t_amount. /* Курсовая разница */   /*Doc:CRCC:DifCourse(Doc:t_amount ,Doc:v_amount, Doc:crc).*/

         /***********************/
         if diff_tamount > 0 then
         do:  /* Списание расходов 553010*/
            run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
            end.

         end.

         /***********************/
                         vparam = string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                      Doc:tclientaccno + dlm +
                                      Doc:ACC:arpacc() + dlm +
                      "На конвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm +
                                  string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                                      Doc:vclientaccno + dlm +
                         "Зачисление на валютный счет по курсу " + string(dealing_doc.rate) + dlm +
                                  string(/*avg_tamount */ Doc:t_amount) + dlm +
                                  string(Doc:v_amount).
                                  note = "Срочная покупка валюты".
          trxcode = "dil0066".
       end.
       /**********************************************************************************************************/

       if Doc:DocType = 3 then do: /* Срочная продажа */
         /* Определение курсовой разницы */
         avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc). /*Сумма в тенге по курсу нацбанка*/
         diff_tamount = avg_tamount - Doc:t_amount. /* Курсовая разница */   /*Doc:CRCC:DifCourse(Doc:t_amount ,Doc:v_amount, Doc:crc).*/

         /***********************/
         if diff_tamount < 0 then
         do:  /* Списание расходов 553010*/
            run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.
            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
            end.

         end.
         /***********************/

                         vparam = string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                                      Doc:vclientaccno + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                    "На реконвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm +
                                  string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                      Doc:ACC:arpacc() + dlm +
                                      Doc:tclientaccno + dlm +
                   "Зачисление тенге на счет клиента по курсу " + string(dealing_doc.rate) + dlm +
                                  string(Doc:v_amount) + dlm +
                                  string(/*avg_tamount*/ Doc:t_amount).
                                  note = "Срочная продажа валюты".
          trxcode = "dil0070". /* было trxcode = "dil0066".*/
       end.
       /**********************************************************************************************************/
       if Doc:DocType = 6 then do: /* Кросс конвертация */
          /* Определение курсовой разницы */

          avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:t_amount, Doc:CRCC:get-crc(Doc:tclientaccno)).
          avg_tamount2 = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc).
          diff_tamount = avg_tamount - avg_tamount2.


         /***********************/
         if diff_tamount < 0 then
         do:  /* Списание расходов 553010*/
            if sb = 1 then run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            else run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               message " Ошибка проводки dil0045 rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
            end.

         end.

         /***********************/
         /* ввод суммы на конвертацию 'начальная', значит берем учетный курс первой валюты sb = 1 */

        if sb = 1 then  vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                      Doc:tclientaccno + dlm + /*счет клиента начальный*/
                "На кросс-конвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm + /**/
                                 string( avg_tamount ) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                string( avg_tamount /*avg_tamount2*/ ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                      Doc:vclientaccno + dlm + /*счет клиента конечный*/
                         "Зачисление на валютный счет по курсу " + string(dealing_doc.rate).        /**/

         /* ввод суммы на конвертацию 'конечная', значит берем учетный курс второй валюты sb = 2 */

         else   vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                      Doc:tclientaccno + dlm + /*счет клиента начальный*/
                "На кросс-конвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm + /**/
                                 string( avg_tamount2) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                 string(avg_tamount2 ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                      Doc:vclientaccno + dlm + /*счет клиента конечный*/
                         "Зачисление на валютный счет по курсу " + string(dealing_doc.rate).        /**/

          note = "Кросс конвертация".  /**/
          trxcode = "dil0069".
       end.
       /**********************************************************************************************************/

        run trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then
        do:
          message " Ошибка проводки " trxcode " rcode = " string(rcode) ":" rdes  " " s-jh.
          pause.
          undo,return.
        end.
        else do:

          if Doc:com_conv > 0 then do:
           /* снятие комиссии */
               if Doc:CRCC:get-code(Doc:com_accno) <> "KZT" then do: /* комиссия с валютного счета, значит используем шаблон с ковертацией */
                    run trxgen ('dil0072', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         message " Ошибка проводки dil0072 rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
                         undo,return.
                      end.
               end.
               else do:
                    run trxgen ('dil0022', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         message " Ошибка проводки dil0022 rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
                         undo,return.
                      end.
               end.
          end.

            /* Зачисление доходов при срочной покупке*/
            if Doc:DocType = 1 then do: /* Срочная покупка */
              if diff_tamount < 0 then
              do: /* Зачисление доходов 453010*/
                run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then
                do:
                   message " Ошибка проводки dil0044 rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                end.
                run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                   message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                end.
              end.
            end.
            /* Зачисление доходов при срочной продаже*/
            if Doc:DocType = 3 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    message " Ошибка проводки dil0044 rcode = " string(rcode) ":" rdes  " " s-jh.
                    pause.
                    undo,return.
                 end.
                 run trxsts (input s-jh, input 0, output rcode, output rdes).
                 if rcode ne 0 then do:
                   message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                 end.
               end.
            end.
            /* Зачисление доходов при кроссконвертации*/
            if Doc:DocType = 6 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 if sb = 1 then run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                 else run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    message " Ошибка проводки dil0044 rcode = " string(rcode) ":" rdes  " " s-jh.
                    pause.
                    undo,return.
                 end.
                 run trxsts (input s-jh, input 0, output rcode, output rdes).
                 if rcode ne 0 then do:
                   message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                 end.
               end.
            end.
           run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then
            do:
              message " Ошибка штамповки rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
              undo,return.
            end.
            else do:

                 message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.

                /*******************************************************************************************/
                 if Doc:id_viprate <> 0 then
                 do:
                    find first viprate where viprate.idrate = Doc:id_viprate exclusive-lock no-error.
                    if avail viprate then
                    do:
                      viprate.summ = Doc:summ_vip - Doc:v_amount.
                      viprate.jh = s-jh.
                    end.
                 end.
                /*******************************************************************************************/



                find dealing_doc where dealing_doc.docno = Doc:DocNo share-lock no-error.
                dealing_doc.jh = s-jh.
                find current dealing_doc no-lock no-error.
                 create trgt.
                 trgt.jh = s-jh.
                 trgt.rem1 = "Осуществление платежей в пользу резидентов".
                 trgt.rem2 = note.
                 run printvouord(2). /*run print_doc.*/


            end.
        end.

      end. /*transaction*/
   end.
   else message "Нет активного документа!" view-as alert-box.

end procedure.
/***********************************************************************************************************************/

procedure do_trans1.
   /* Первая транзакция при обычной покупке-продаже */
   if VALID-OBJECT(Doc) then do:

     find dealing_doc where dealing_doc.docno = Doc:DocNo share-lock no-error.
     if dealing_doc.jh = ? or dealing_doc.jh = 0 then
     do:
       find current dealing_doc no-lock no-error.
     end.
     else do:
       find current dealing_doc no-lock no-error.
       message "Документ уже имеет первую транзакцию! jh = " dealing_doc.jh  view-as alert-box.
       return.
     end.

     vparam = "".
     s-jh = 0.
     rcode = 0.
     rdes = "".
     note = "".
     def var TRX as char.

     do transaction:
     /**********************************************************************************************************/
     /* Определение курсовой разницы */
        avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc). /*Сумма в тенге по курсу нацбанка*/
        diff_tamount = avg_tamount - Doc:t_amount. /* Курсовая разница */
     /**********************************************************************************************************/


     if Doc:DocType = 2 then /* Обычная покупка валюты */
     do:
         vparam =  string(Doc:t_amount) + dlm +
                       Doc:tclientaccno + dlm +
                       Doc:ACC:arpacc() + dlm +
       "На конвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm +
                  string(/*avg_tamount*/ Doc:t_amount)  + dlm +
                   string(Doc:v_amount) + dlm +
                        string(Doc:crc) + dlm +
                         Doc:ACC:valacc(Doc:crc).
         TRX = 'dil0068'.
         note = "Снятие средств для покупки валюты".


         if diff_tamount > 0 then
         do:  /* Списание расходов 553010*/
            run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
            end.
         end.
     end. /* Обычная покупка валюты */

     /************************************************************************************************************/
     if Doc:DocType = 4 then  /* Обычная продажа валюты */
     do:
          vparam = string(Doc:v_amount) + dlm +
                        string(Doc:crc) + dlm +
                       Doc:vclientaccno + dlm +
                Doc:ACC:valacc(Doc:crc) + dlm +
     "На реконвертацию согласно заявки по курсу " + string(dealing_doc.rate) + dlm +
                   string(Doc:v_amount) + dlm +
                   string(/*avg_tamount*/ Doc:t_amount) + dlm +
                                    "1" + dlm +
                           Doc:ACC:arpacc().
         TRX = 'dil0067'.
         note = "Снятие средств для продажи валюты".


         if diff_tamount < 0 then
         do:  /* Списание расходов 553010 при продаже валюты*/
            run trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "185900" /* Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.
            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
               message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
               pause.
               undo,return.
            end.
         end.

     end. /* Обычная продажа валюты */
     /************************************************************************************************************/


         run trxgen(TRX, dlm, vparam, "DIL" , Doc:DocNo, output rcode, output rdes, input-output s-jh).
         if rcode ne 0 then
         do:
           message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
           pause.
           undo,return.
         end.
         else do:


           if Doc:com_conv > 0 then
           do:
           /* снятие комиссии */
               if Doc:CRCC:get-code(Doc:com_accno) <> "KZT" then do: /* комиссия с валютного счета, значит используем шаблон с ковертацией */
                    run trxgen ('dil0072', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         message " Ошибка проводки dil0072 rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
                         undo,return.
                      end.
               end.
               else do:
                    run trxgen ('dil0022', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
                     if rcode ne 0 then
                     do:
                        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
                        undo,return.
                     end.
               end.
           end.


           if Doc:DocType = 4 then do: /* Обычная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
                    pause.
                    undo,return.
                 end.
                 run trxsts (input s-jh, input 0, output rcode, output rdes).
                 if rcode ne 0 then do:
                   message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                 end.
               end.
           end.

           if Doc:DocType = 2 then do:  /* Обычная покупка */
              if diff_tamount < 0 then
              do: /* Зачисление доходов 453010*/
                run trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then
                do:
                   message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                end.
                run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                   message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                   pause.
                   undo,return.
                end.
              end.
            end.


           run trxsts (input s-jh, input 6, output rcode, output rdes).
           if rcode ne 0 then
           do:
             message " Ошибка штамповки rcode = " string(rcode) ":" rdes  " " s-jh.
             pause.
             undo,return.
           end.
           else do:

             /*******************************************************************************************/
                 if Doc:id_viprate <> 0 then
                 do:
                    find first viprate where viprate.idrate = Doc:id_viprate exclusive-lock no-error.
                    if avail viprate then
                    do:
                      viprate.summ = Doc:summ_vip - Doc:v_amount.
                      viprate.jh = s-jh.
                    end.
                 end.
             /*******************************************************************************************/
             find dealing_doc where dealing_doc.docno = Doc:DocNo exclusive-lock no-error.
             dealing_doc.jh = s-jh.
             find current dealing_doc no-lock.
              create trgt.
              trgt.jh = s-jh.
              trgt.rem1 = "Осуществление платежей в пользу резидентов".
              trgt.rem2 = note.

              message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.

              run printvouord(2).

           end.
         end. /*rcode ne 0*/
      end. /*transaction*/

     /************************************************************************************************************/
   end.  /*VALID-OBJECT(Doc)*/
   else message "Нет активного документа!" view-as alert-box.
end procedure.
/***********************************************************************************************************************/
procedure do_trans2.
   /* Вторая транзакция при обычной покупке-продаже*/
   if VALID-OBJECT(Doc) then do:

     find dealing_doc where dealing_doc.docno = Doc:DocNo share-lock no-error.
     if dealing_doc.jh2 = ? or dealing_doc.jh2 = 0 then
     do:
       find current dealing_doc no-lock no-error.
     end.
     else do:
       find current dealing_doc no-lock no-error.
       message "Документ уже имеет вторую транзакцию!! jh2 = " dealing_doc.jh2 view-as alert-box.
       return.
     end.

     if dealing_doc.jh = ? or dealing_doc.jh = 0 then
     do:
       message "Нет первой транзакции!" view-as alert-box.
       return.
     end.

      if Doc:whn_cr < g-today then
      do:
        /* Все ОК*/
         vparam = "".
         s-jh = 0.
         rcode = 0.
         rdes = "".
         note = "".
         def var TRX as char.

         do transaction:

         /*Обычная покупка валюты*/
         if Doc:DocType = 2 then
         do:
           vparam = string(Doc:v_amount) + dlm + Doc:ACC:valacc(Doc:crc) + dlm  + Doc:vclientaccno .
           TRX = 'dil0020'.
           note = "Зачисление средств от покупки валюты".
         end.
         /*Обычная продажа валюты*/
         if Doc:DocType = 4 then
         do:
           vparam = string(Doc:t_amount) + dlm + Doc:ACC:arpacc() + dlm  + Doc:tclientaccno .
           TRX = 'dil0071'. /* было TRX = 'dil0020'. */
           note = "Зачисление средств от продажи валюты".
         end.

         run trxgen(TRX, dlm, vparam, "DIL" , Doc:DocNo, output rcode, output rdes, input-output s-jh).
         if rcode ne 0 then
         do:
           message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
           undo,return.
         end.
         else do:
           /*
           if Doc:com_conv > 0 then
           do:
            снятие комиссии
             run trxgen ('dil0022', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,  output rcode, output rdes, input-output s-jh).
              if rcode ne 0 then
              do:
                 message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
                 undo,return.
              end.
           end.
           */


           run trxsts (input s-jh, input 6, output rcode, output rdes).
           if rcode ne 0 then
           do:
             message " Ошибка штамповки проводки rcode = " string(rcode) ":" rdes  " " s-jh view-as alert-box.
             undo,return.
           end.
           else do:
             find dealing_doc where dealing_doc.docno = Doc:DocNo exclusive-lock no-error.
             dealing_doc.jh2 = s-jh.
             find current dealing_doc no-lock.
              create trgt.
              trgt.jh = s-jh.
              trgt.rem1 = "Осуществление платежей в пользу резидентов".
              trgt.rem2 = note.

              message "Транзакция сделана" skip  "jh2 " s-jh view-as alert-box.
              run printvouord(2).
           end.
         end.
        end. /*transaction*/
      end.
      else do:
          message "Вторую транзакцию нельзя проводить в этот же день!" view-as alert-box.
      end.
   end.
   else message "Нет активного документа!" view-as alert-box.
end procedure.
/***********************************************************************************************************************/

procedure delete_trans:
 /* Удаление транзакции */
 /* в принципе без изменений из существующей программы */
 if VALID-OBJECT(Doc) then
 do:
  do transaction:

   find dealing_doc where dealing_doc.docno = Doc:DocNo and dealing_doc.doctype = Doc:DocType share-lock no-error.
   if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
     else do:
        find jh where jh.jh = dealing_doc.jh2 no-lock no-error.
        if available jh
           then
             do:
                if dealing_doc.who_mod <> g-ofc
                   then do:
                     message "Вы не можете удалять документы принадлежащие" dealing_doc.who_mod view-as alert-box.
                     return.
                   end.
                message "Удаляется вторая транзакция" view-as alert-box title "".
                if jh.jdt < g-today
                   then do:
                     run yn("","Дата транзакции. Сторно?",
                     string(jh.jdt),"",output rez).
                     if not rez then undo, return.
                     run trxstor(input dealing_doc.jh2, input 6,
                     output s-jh, output rcode, output rdes).
                     if rcode ne 0 then do:
                        message rdes.
                        undo, return.
                     end.
                     else
                       do:
                          dealing_doc.jh2 = ?.
                          run x-jlvo.
                       end.
                   end.
                   else do:
                      run yn("","Вы уверены ?","","", output rez).
                      if not rez then undo, return.
                      v-sts = jh.sts.
                      run trxsts (input dealing_doc.jh2, input 0, output rcode, output rdes).
                      if rcode ne 0 then do:
                         message rdes.
                         undo, return.
                      end.
                      run trxdel (input dealing_doc.jh2, input true, output rcode, output rdes).
                      if rcode ne 0 then do:
                         message rdes.
                         if rcode = 50 then do:
                                            run trxstsdel (input dealing_doc.jh2, input v-sts, output rcode, output rdes).
                                            return.
                                       end.
                         else undo, return.
                      end.
                      else dealing_doc.jh2 = ?.
                   end. /*if*/
             end.
           else
             do:
                find jh where jh.jh = dealing_doc.jh no-lock no-error.
                if not available jh then do: message "У документа отсутствует транзакция" view-as alert-box title "". undo,return. end.
                  else do:
                   if dealing_doc.who_mod <> g-ofc
                      then do:
                        message "Вы не можете удалять документы принадлежащие" dealing_doc.who_cr view-as alert-box.
                        return.
                      end.

                   if jh.jdt < g-today
                       then do:
                         run yn("","Дата транзакции. Сторно?",
                         string(jh.jdt),"",output rez).
                         if not rez then undo, return.
                         run trxstor(input dealing_doc.jh, input 6,
                         output s-jh, output rcode, output rdes).
                         if rcode ne 0 then do:
                            message rdes.
                            undo, return.
                         end.
                         else
                             do:
                                dealing_doc.jh = ?.
                                run x-jlvo.
                             end.
                       end.
                       else do:
                          run yn("","Вы уверены ?","","", output rez).
                          if not rez then undo, return.
                          v-sts = jh.sts.
                          run trxsts (input dealing_doc.jh, input 0, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             undo, return.
                          end.
                          run trxdel (input dealing_doc.jh, input true, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             if rcode = 50 then do:
                                                run trxstsdel (input dealing_doc.jh, input 0, output rcode, output rdes).
                                                return.
                                           end.
                             else undo, return.
                          end.
                          else dealing_doc.jh = ?.
                       end. /*if*/
                  end.
             end.

           if dealing_doc.doctype = 1 or dealing_doc.doctype = 2 or dealing_doc.doctype = 6 then
           do:
            if Doc:Client:check-debsald(Doc:tclientaccno) = false then
            do:
              message "На счете дебетовое сальдо, удаление транзакции невозможно.". pause. undo, return.
            end.
            else message "Транзакция удалена!".
           end.
           else do:
            if Doc:Client:check-debsald(Doc:vclientaccno) = false then
            do:
              message "На счете дебетовое сальдо, удаление транзакции невозможно.". pause. undo, return.
            end.
            else message "Транзакция удалена!".
           end.

   end.
 end.

 end. /*VALID-OBJECT*/
 else message "Нет активного документа!" view-as alert-box.
end procedure.
/*****************************************************************************************************************************************/
procedure print_doc.
    if VALID-OBJECT(Doc) then do:
       if not Doc:FindDoc(Doc:DocNo) then do: message "Документ не найден!" view-as alert-box. return. end.
       if Doc:jh <> ? and Doc:jh <> 0 then
       do:
         s-jh  = Doc:jh.
         run printvouord(2).
       end.
       if Doc:jh2 <> ? and Doc:jh2 <> 0 then
       do:
         s-jh  = Doc:jh2.
         run printvouord(2).
       end.

    end. /* VALID-OBJECT */
    else message "Нет активного документа!" view-as alert-box.
end procedure.

procedure print_application:
    if dType = 1 then do:
        find aaa where aaa.aaa = trim(from_accno) no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205") then do:
            {DocNo1print.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {DocNo1-1print.i}
        end.
    end.
    else if dType = 2 then do:
        find aaa where aaa.aaa = trim(from_accno) no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205") then do:
            {DocNo2print.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {DocNo2-1print.i}
        end.
    end.
    else if dType = 3 then do:
        find aaa where aaa.aaa = trim(from_accno) no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205") then do:
            {DocNo3print.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {DocNo3-1print.i}
        end.
    end.
    else if dType = 4 then do:
        find aaa where aaa.aaa = trim(from_accno) no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205") then do:
            {DocNo4print.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {DocNo4-1print.i}
        end.
    end.
    else if dType = 6 then do:
        find aaa where aaa.aaa = trim(from_accno) no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205") then do:
            {DocNo6print.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {DocNo6-1print.i}
        end.
    end.
end procedure.