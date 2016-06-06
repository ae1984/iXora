/* kztcin2.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Прием платежей Казахтелеком
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.1, 3.1.5.1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     13.07.03 kanat внес изменение во ввод платежей - теперь вводится только счет - извещение и сумма
     23.09.03 sasco изменять платеж может только менеджер из sysc."COMDEL".chval
     23.12.03 sasco добавил обнуление счетчика распечатанных квитанций при изменении платежа
     01.14.04 kanat добавил ввод лицевых счетов
     12.04.04 kanat поменял комиссии для приема платежей
     19.04.04 kanat добавил выбор комиссии из тарификатора при приеме платежей
     25/05/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользу юр лиц.
     07/06/04 kanat - добавил общей суммы с комиссией при вводе платежей
     04.08.04 saltanat - добавлено передача параметров в процедуру kztcprn (rids, KOd_, KBe_, KNp_)
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     09/02/2005 kanat - добавил выбор комисиий и убрал ручной ввод комиссий
                        добавил обработку плательщиков ВОВ и приравненных им
     07/04/2005 kanat - убрал все что сделал 09/02/2005
     01/09/2005 kanat - добавил прием платежей АО Казактелеком в филиале г. Астана
     02/12/2005 marinav - выбор двух комиссий
      7/12/2005 evgeniy(u00568)
     18/04/2006 u00568 Evgeny - по дополнению к ТЗ 175 вместо 710 кода комиссии использовать 717 +  no-undo + переделка автоматизации, чтобы было как везде
     11/05/2006 u00568 Evgeny - сохраняет код комиссии
     31.07.06 dpuchkov - убрал комиссию 50 тг для сервисных точек
     08.09.2006 dpuchkov - добавил печать квитанций и извещений.
     11.08.2006 dpuchkov - сделал номер телефона обязательным для заполнения
     08.09.2006 dpuchkov - запретил редактировать лицевой счет.
     08.09.2006 dpuchkov - перевод на онлайн-систему сервисных точек АлматыТелеком . 
                           (java скрипт TelecomCient.class)
                           (используемые Веб-сервисы IRegitration,IReport,IPayment,)
                           (Команда для импорта сертификатов - keytool -import -alias jwm1 -keystore jwm -file)
                           kspw:  qqqqqq
     11.09.2006 dpuchkov - оптимизация запросов
     18.09.2006 dpuchkov - добавил предупреждение о получении баланса
     20.09.2006 dpuchkov - добавил параметр в запрос в связи с тем что Realsoft изменил приложение.
     25.09.2006 dpuchkov - если биллинг запрет на редактирование лицевого счета
     26.09.2006 dpuchkov - изменил формат запроса к web-сервисам 
     20.10.2006 u00124   - изменил ORACLE на NTORACLE
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{yes-no.i}
{rekv_pl.i}
{comm-com.i}

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def var rids as char initial "".
define frame sf with side-labels centered view-as dialog-box.

def var KOd_ as char no-undo.
def var KBe_ as char no-undo.
def var KNp_ as char no-undo.

/*def var commtel like commonpl.comsum.*/
def var cret as char init "" no-undo.
def var temp as char init "" no-undo.

/*def var cdate as date init today no-undo.*/
def var selgrp  as integer init 3.  /* Определяем номер группы в таблице commonls */


define variable candel as log no-undo.

define buffer oldb for commonpl.
define buffer cmpb for commonpl.
define buffer b-sysclg for sysc.
define buffer b-syscpw for sysc.
define buffer b-sysonl for sysc.


def var v-whole-sum as decimal.

def var comchar  as char.
def var lcom as logical init false no-undo.
def var doccomsum  as decimal.
def var doccomcode  as char.
def var v-vov-name as char init "" no-undo.

if seltxb = 1 then
   selgrp = 10.

def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.


candel = yes.

find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.


if seltxb = 0 then do: /*Для алматы*/
   find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
              commonls.visible = yes and commonls.type = 1 no-lock no-error.
end.
else do:
   find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
              commonls.visible = yes no-lock no-error.
end.



/* dpuchkov проверка реквизитов см тз 907 */
run rekvin(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod).
if not l-ind then return.

/* saltanat запоминаем КОД, КБЕ, КНП для передачи на печать */
assign
        KOd_ = commonls.kod
        KBe_ = commonls.kbe
        KNp_ = commonls.knp
no-error.

def var d_begn as decimal decimals 2.
def var d_real as decimal decimals 2.

def frame sf
     commonpl.date    view-as text label "Дата"              skip
     commonpl.fioadr               label "Сч. извещение"     format "x(15)" skip
     commonpl.counter validate(commonpl.counter <> 0, "Введите номер телефона ") /*view-as text*/ label "Телефон"           format "999999" skip
     commonpl.accnt                label "Лиц. счет"         format "99999999999" skip
d_begn label "На начало месяца "         format "->>>,>>>,>>9.99" skip
d_real label "На текущий момент"         format "->>>,>>>,>>9.99" skip

     commonpl.sum                  label "Сумма"             format ">>>,>>9.99" skip
     lcom                          label "Код комиссии"      format ":/:"  skip
     doccomsum       view-as text  format ">>>,>>9.99"       label "Сумма комиссии"  skip
     v-whole-sum                   label "Общая сумма "  format ">>>,>>>,>>9.99" skip
     with side-labels centered.


    on value-changed of commonpl.fioadr in frame sf do:
        commonpl.fioadr = commonpl.fioadr:screen-value.

        find first kaztelsp where kaztelsp.statenmb = commonpl.fioadr
                   USE-INDEX statenmb no-lock no-error.

        if avail kaztelsp then do:
        commonpl.counter = kaztelsp.phone.
        commonpl.accnt = kaztelsp.accnt.
        end.
        else do:
        commonpl.counter = 0.
        commonpl.accnt = 0.
        end.

        displ commonpl.counter with frame sf.
        displ commonpl.accnt with frame sf.
        apply "value-changed" to self.
    end.

    /*
    on value-changed of commonpl.counter in frame sf do:
        commonpl.counter = integer(commonpl.counter:screen-value).
        apply "value-changed" to self.
    end.
    
    on value-changed of commonpl.accnt in frame sf do:
        commonpl.accnt = integer(commonpl.accnt:screen-value).
        apply "value-changed" to self.
    end.
    */
    
    on help of commonpl.fioadr in frame sf do:
       run kztcfind.
       commonpl.fioadr:screen-value = return-value.
       commonpl.fioadr = return-value.
       apply "value-changed" to commonpl.fioadr in frame sf.
    end.


    on help of lcom in frame sf do:
        run comtar("7","17,24").
        if return-value <> "" then
          doccomcode = return-value.
        if doccomcode = "24" then do:
          update
             v-vov-name
             with frame sfx.
          hide frame sfx.
          if trim(v-vov-name) = "" then do:
            message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
            undo,retry.
          end.
        end.
        run choose_doccomcode_calc_and_displ_sums.
    end.

  on value-changed of commonpl.sum in frame sf do:
    commonpl.sum = decimal(commonpl.sum:screen-value) no-error.
/*    run choose_doccomcode_calc_and_displ_sums.*/
    apply "value-changed" to self.
  end.

/*main-------------------------------------------------------------------------*/

/*REPEAT:*/
do transaction:


    if newdoc then CREATE commonpl.
               else find commonpl where rowid(commonpl)=rid.


       commonpl.date = g-today.
/*
       commonpl.comsum = commonls.comsum.
       v-whole-sum = commonpl.sum + commonpl.comsum.
       doccomsum = commonpl.comsum.
*/

       DISPLAY
               commonpl.date
               commonpl.counter
               commonpl.accnt

               lcom

               doccomsum
               v-whole-sum
               WITH side-labels FRAME sf.

        if not newdoc then do:
           create oldb.
           buffer-copy commonpl to oldb.
           commonpl.chval[5] = "0".
           assign oldb.deldate = today
                  oldb.deltime = time
                  oldb.deluid = userid ("bank")
                  oldb.delwhy = "Изменение реквизитов"
                  oldb.deldnum = next-value(kztd).
        end.

        displ commonpl.sum
              doccomsum
              v-whole-sum
              with frame sf.

 if not newdoc then do:
    message "Изменение транзакции невозможно!" . pause.
    return.
 end.



        if newdoc then do:

           UPDATE commonpl.fioadr
                  commonpl.counter
               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf.
               end.

/*Запрос в RealSoft*/
 def var v-s  as char no-undo.
 def var v-phones as char no-undo.
 def var v-ind as integer.
 def var v-bal as char.
 def var v-bal1 as char.
 def var v-sts as char.
 def var v-id  as char.
 def var v-dtn  as char.

 def var v-attrx as char.
 def var v-ataid as char.

if comm-cod() = 0 then do:
   v-attrx = string(next-value(attrx)).
   v-ataid = string(next-value(ataid)). 
end.

 if comm-cod() = 0 then do:
    find b-sysclg where b-sysclg.sysc = "KZTLG" no-lock no-error.
    find b-syscpw where b-syscpw.sysc = "KZTPW" no-lock no-error.
    find b-sysonl where b-sysonl.sysc = "ONL" no-lock no-error.
    v-phones = " 3272" + string(commonpl.counter).
 end.
if comm-cod() = 0 then do:
if b-sysonl.chval = "1" then do:
if commonpl.counter <> 0 then do:
    message "Ждите идет запрос текущего баланса...".

    v-bal = "0".
/*  run ConnectWebServices("2","HALYKBANKOMAT","TXB_ATM",v-phones,"0","0","0","0", "txbbankom","txbbankom","0","v-dtn"). */
    run ConnectWebServices("2","TXB_KASSA","TXB_ATM",v-phones,"0","0","0","0", b-sysclg.chval, b-syscpw.chval,"0","v-mon","v-day").

    if v-sts = "OK" then do:
       v-ind = 0.

       v-bal1 = "0".
/*     run ConnectWebServices("1","HALYKBANKOMAT","TXB_ATM",v-phones,"0","0","0",v-id, "txbbankom","txbbankom","0","v-dtn"). */

 message "Запросить баланс на начало месяца?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Внимание" UPDATE l_chs as logical.
 if not l_chs then do: v-sts = "OK". end.
 if l_chs = True  then do :
      run ConnectWebServices("1","TXB_KASSA","TXB_ATM",v-phones,"0","0","0",v-id, b-sysclg.chval,b-syscpw.chval,"0","v-mon","v-day").
 end.

       if v-sts = "OK" then do:
       message "". pause 0.
       message "".

          d_begn = decimal(v-bal1).
          d_real = decimal(v-bal).
          commonpl.accnt = decimal(v-id).
          if decimal(v-bal1) > 0 then 
             commonpl.sum = decimal(v-bal1).
          else
             commonpl.sum = 0.
          displ commonpl.accnt commonpl.sum d_begn d_real with frame sf.
        end.
        else do:
           d_begn = 0.
           d_real = 0.
           message "". pause 0.
           message "Запрос не прошел.".
           run savelog ("KTERROR", v-sts).
           displ d_begn d_real with frame sf.
        end.

    end.
    else do:
       d_begn = 0.
       d_real = 0.
       message "". pause 0.
       message "Запрос не прошел.".
       run savelog ("KTERROR", v-sts).
       displ d_begn d_real with frame sf.
    end.

end.
end.
end.
/*Запрос в RealSoft*/

if b-sysonl.chval = "1" then do:
     UPDATE
/*                commonpl.accnt*/
                  commonpl.sum
                  lcom


               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf.
               end.
       message "".
       message "".
end.
else do:
     UPDATE
                  commonpl.accnt
                  commonpl.sum
                  lcom


               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf.
               end.
       message "".
       message "".
end.


end.
        else
do:
if b-sysonl.chval = "1" then do:
        UPDATE commonpl.fioadr
               commonpl.counter
/*               commonpl.accnt*/
               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf.
               end.
end.
else
do:
        UPDATE commonpl.fioadr
               commonpl.counter
               commonpl.accnt
               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf.
               end.

end.
end.



        doccomsum = commonpl.comsum.
        v-whole-sum = commonpl.sum + doccomsum.
        displ v-whole-sum with frame sf.

        temp =  trim(commonls.npl) + " по сч-извещ. " + trim(commonpl.fioadr).


    if doccomcode = "24" and trim(v-vov-name) = "" then do:
    message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
    undo,retry.
    end.
    else
    commonpl.info[3] = v-vov-name.


        MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel TITLE "Внимание" UPDATE choice as logical.

        if not choice then delete oldb.

        case choice:

            when true then do :

            find first cmpb where cmpb.txb = seltxb and cmpb.grp = selgrp and cmpb.date = g-today and
                            cmpb.rnnbn = commonls.rnnbn and cmpb.fioadr = commonpl.fioadr and
                            cmpb.counter = commonpl.counter and cmpb.accnt = commonpl.accnt and
                            cmpb.sum = commonpl.sum and cmpb.dnum <> commonpl.dnum and cmpb.deluid = ? no-lock no-error.
            if available cmpb then do:
               message "Повторный платеж за дату валютирования!" view-as alert-box title ''.
               delete oldb.
               undo, return.
            end.

            if trim(commonpl.fioadr) = "" then do:
               MESSAGE "Не введен счет - извещение!" VIEW-AS ALERT-BOX TITLE "Внимание".
               return.
            end.

            if commonpl.accnt = 0 then do:
               MESSAGE "Не введен лицевой счет!" VIEW-AS ALERT-BOX TITLE "Внимание".
               return.
            end.


/*  run ConnectWebServices("3","HALYKBANKOMAT","TXB_ATM",v-phones,"TEST_TX",v-attrx,string(commonpl.sum),"TXB_ATM", "txbbankom","txbbankom",v-ataid,"v-dtn").
*/
                              /*TXB_KASSA*/
/*    run ConnectWebServices("3","HALYKBANKOMAT","TXB_ATM",v-phones,string(get-dep(userid("bank"), g-today)),v-attrx,string(commonpl.sum),"TXB_ATM", "txbbankom","txbbankom",v-ataid,"v-dtn"). */

            if newdoc then do:
                UPDATE
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.uid = userid("bank")
                commonpl.date    = g-today
                commonpl.credate = today
                commonpl.cretime = time
                commonpl.type    = commonls.type
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.npl     = temp
                commonpl.comcode = doccomcode
                commonpl.dnum    = next-value(kztd).
if comm-cod() = 0 then do:
if (b-sysonl.chval = "1") or (b-sysonl.chval = "2") then do:
                commonpl.billing = "1".
                commonpl.billdoc = v-ataid.
                commonpl.billtrx = v-attrx. 
end.
end.
                update commonpl.rko = get-dep(userid("bank"), g-today).
                cret = string(rowid(commonpl)).
                rids = rids + cret.
            end. /* newdoc */
            else do:

                UPDATE
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.euid  = userid("bank")
                commonpl.edate = today
                commonpl.etim  = time
                commonpl.type    = commonls.type
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.npl     = temp
                commonpl.comsum  = doccomsum
                commonpl.comcode = doccomcode
                commonpl.dnum    = oldb.deldnum.
                update commonpl.rko = get-dep(commonpl.uid, g-today).
                cret = string(rowid(commonpl)).
                rids = rids + cret.
            end. /* update */
            end.
            when false then
                undo.
            otherwise
                undo, leave.
        end case.
/*        MESSAGE "Печатать квитанцию?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel TITLE "Внимание" UPDATE choice1 as logical.
        if not choice1 then do: end.
        case choice1:
           when true then do :
               run stadkvit3(rids).
                   
           end.
            when false then do: end.
            otherwise do: end.
        end case.*/
END.

do transaction:
if choice = True then do:
        if comm-cod() = 0 then do:
        if (b-sysonl.chval = "1") or (b-sysonl.chval = "2") then do:
            message "Ждите идет Оплата    ЗАПРЕЩЕНО НАЖИМАТЬ F4 или CTRL+С...".

 run ConnectWebServices("3","TXB_KASSA","TXB_ATM",v-phones,string(get-dep(userid("bank"), g-today)),v-attrx,string(commonpl.sum),string(commonpl.accnt), b-sysclg.chval,b-syscpw.chval,v-ataid,string(month(g-today)),string(day(g-today))).


        /*  run ConnectWebServices("3","TXB_KASSA","TXB_ATM",v-phones,string(get-dep(userid("bank"), g-today)),v-attrx,string(commonpl.sum),"TXB_ATM", b-sysclg.chval,b-syscpw.chval,v-ataid,"v-dtn"). */
            if v-s = "OK" then do:
               message "". pause 0.
               message "Оплата прошла успешно!".
            end.
            else do:
               message "". pause 0.
               run savelog ("KTERROR", v-s).
               message "Запрос не прошел ошибка в биллинговой системе.".
        delete commonpl. 

        return.
            end.
        end.
        end.

        MESSAGE "Печатать квитанцию?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel TITLE "Внимание" UPDATE choice1 as logical.
        if not choice1 then do: end.
        case choice1:
           when true then do :
               run stadkvit3(rids).
                   
           end.
            when false then do: end.
            otherwise do: end.
        end case.
end.
end.


hide frame sf.

/*
if rids <> "" then do:
    MESSAGE "Распечатать ордер?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Внимание" UPDATE choice4 as logical.
    case choice4:
        when true then
            run kztcprn (rids, KOd_, KBe_, KNp_).
    end case.
end. */

return cret.



procedure choose_doccomcode_calc_and_displ_sums:
      if doccomcode <> "24" then do:
         doccomcode = "17".
      end.
      doccomsum = comm-com-1(commonpl.sum, doccomcode, '7', comchar).
      commonpl.comsum = doccomsum.
      v-whole-sum = commonpl.sum + doccomsum.
      displ
        doccomsum
        v-whole-sum
      with frame sf.
end.



Procedure ConnectWebServices.
   def input parameter e1  as char. /* 1-нач месяца 2-текущий 3-оплата */
   def input parameter e2  as char. /* источник HALYKBANKOMAT */
   def input parameter e3  as char. /* TXB_ATM */
   def input parameter e4  as char. /* телефон */
   def input parameter e5  as char. /* TEST_TX */
   def input parameter e6  as char. /* сиквенс */
   def input parameter e7  as char. /* сумма   */
   def input parameter e8  as char. /* aid     */
   def input parameter e9  as char. /* логин   */
   def input parameter e10 as char. /* пароль  */
   def input parameter e11 as char. /* сиквенс */
   def input parameter e12 as char. /* месяц */
   def input parameter e13 as char. /* день */

                            /*TXB-A1503A ORACLE*/
  input through value ("rsh NTORACLE java -classpath 
'C://Java//jdk1.5.0_02//bin;C://Kaztelecom//lib//axis.jar;C://Kaztelecom//lib//.jar;C:
//Kaztelecom//lib//.jar;C://Kaztelecom//lib//log4j-1.2.8.jar;C://Kaztelecom/
/lib//realsoft.jar;C://Kaztelecom//lib//axis-schema.jar;C://Kaztelecom//lib//axi
s-ant.jar;C://Kaztelecom//lib//jaxrpc.jar;C://Kaztelecom//lib//commons-logging-1
.0.4.jar;C://Kaztelecom//lib//commons-discovery-0.2.jar;C://Kaztelecom//lib//saa
j.jar;C://Kaztelecom//lib//activation.jar;C://Kaztelecom//lib//wsdl4j-1.5.1.jar;
C://Kaztelecom//lib//activation.jar;C://Kaztelecom//lib//mail.jar;C://Kaztelecom
//lib;C://Kaztelecom//lib//commons-codec-1.3.jar;C://Kaztelecom//lib//saxon.jar;
C://Kaztelecom//lib' TelecomClient " 
      + " " + e1 
      + " " + e2 
      + " " + e3 
      + " " + e4 
      + " " + e5 
      + " " + e6 
      + " " + e7 
      + " " + e8 
      + " " + e9 
      + " " + e10 
      + " " + e11 
      + " " + e12
      + " " + e13).
  repeat:
      v-ind = v-ind + 1.
      import unformatted v-s.

/* if e1 = "3" then do:
   displ  v-s format "x(60)". pause 333.
 end. */

      if v-ind = 1 then v-sts  = v-s.
if e1 = "2" then do:
      if v-ind = 2 then v-id   = v-s.
      if v-ind = 3 then v-bal  = v-s.
end.
if e1 = "1" then do:
      if v-ind = 1 then v-sts  = v-s.
      if v-ind = 2 then v-bal1  = v-s.
end.
    end.
end.



/*'C://jdk1.3.1_08//bin;C://Kaztelecom//lib//axis.jar;C://Kaztelecom//lib//.jar;C:*/
