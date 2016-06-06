/* cif-dep.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14.06.2013 evseev
 * BASES
        BANK
 * CHANGES
        10.07.2013 evseev - перекомпиляция
        28/10/2013 Luiza  - ТЗ 1932 изменила параметры шаблона cda0003 и uni0048
*/

{global.i}
{convgl.i "bank"}

define  shared variable v-flag as char.

run savelog('cif-dep', '29. ' + g-cif).

def var v-lgrlist as char init "151,152,153,154,171,172,157,158,176,177,173,175,174".
def var v-aaa as char.
def var v-month as int.
def var v-rate as deci.
def var v-efrate as deci.
def var v-amount as deci.

def var v-expdt as date.
def var v-val as char.
def var for_1level as deci.
def var for_nalog as deci.

def var v-ans1 as logi.



/*************************/

    Function GetHoldAmount returns decimal (input v-aaa as char).
        find aas where aas.aaa = v-aaa and aas.ln = 7777777 no-lock no-error.
        if available aas then return aas.chkamt.
        else return 0.0.
    End Function.

    Procedure EvaluateExpiryDate.
     def var years as inte initial 0.
     def var months as inte initial 0.
     def var days as inte.
     days = day(g-today).
     years = integer(v-month / 12 - 0.5).
     months = v-month - years * 12.
     months = months + month(g-today).
       if months > 12 then do:
          years = years + 1.
          months = months - 12.
       end.
       if month(g-today) <> month(g-today + 1) then do:
          months = months + 1.
          if months = 13 then do:
             months = 1.
             years = years + 1.
          end.
          days = 1.
       end.
       if months = 2 and days = 29 and  (( (year(g-today)  + years) - 2000) modulo 4) <> 0 then do:
          months = 3.  days = 1.
       end.
       /* nataly ------------------ */
       v-expdt = date(months, days, year(g-today) + years).
       if month(g-today) <> month(g-today + 1) then v-expdt = v-expdt - 1.
    End procedure.

/*************************/


def button btnAdd label "Добавить".
def button btnSave label "Сохранить".
def button btnExit   label "Выход".
def button btnEdt label "Изменить несниж. остаток".
def button btnCancel   label "Досрочное расторжение".

def frame fProp
        v-aaa    format "x(20)"            label '                                  Счет клиента  ' skip
        v-month  format ">9"               label 'Срок действия неснижаемого остатка (в месяцах)  ' skip
        v-rate   format ">9.99"            label '                          Стака вознаграждения  ' skip
        v-efrate format ">9.9"             label '                            Эффективная ставка  ' skip
        v-amount format ">>>,>>>,>>>,>>9.99"  label '                           Неснижаемый остаток  ' skip(2)
        with side-labels centered row 8 width 80.


def QUERY q_aaa  FOR aaa .
def browse b_aaa query q_aaa displ
        aaa.lgr     format "x(5)"  label 'Группа'
        aaa.crc     label 'Валюта'
        aaa.aaa  format "x(20)"  label 'Счет'
        with 20 down SEPARATORS title "" overlay.
def frame faaa  b_aaa with centered overlay row 3 width 45 top-only.


def QUERY q_aaa1  FOR aaa, acvolt .
def browse b_aaa1 query q_aaa1 displ
        aaa.lgr     format "x(5)"  label 'Группа'
        aaa.crc     label 'Валюта'
        aaa.aaa  format "x(20)"  label 'Счет'
        acvolt.x1 label 'Начало'
        acvolt.x3 label 'Окончание'
        aaa.rate  label 'Ставка'
        with 8 down SEPARATORS title "" overlay.
def frame fMain  b_aaa1 skip(2) btnAdd btnCancel btnEdt btnExit with centered overlay row 3 width 75 top-only.


on help of v-aaa in frame fProp do:
   run procSelect.
end.


on "ENTER" of b_aaa1 IN FRAME fMain do:
    if length(aaa.aaa) <> 20 then leave.
    v-aaa = aaa.aaa.
    v-amount = GetHoldAmount(aaa.aaa).
    v-rate = aaa.rate.
    find last acvolt where acvolt.aaa = v-aaa and acvolt.x7 <> 100 no-lock no-error.
    v-month = int( acvolt.x4 ).
    v-efrate = deci( acvolt.x2 ).
    displ v-aaa v-month v-rate v-efrate v-amount with frame fProp.
    hide frame fProp.
end.

ON CHOOSE OF btnAdd IN FRAME fMain do:
   if v-flag = '1' then run procAdd. else message "Для выполнения пройдите в п.м. 1.1.2!" view-as alert-box question buttons ok.
end.

ON CHOOSE OF btnEdt IN FRAME fMain do:
   if v-flag = '1' then run procEdt. else message "Для выполнения пройдите в п.м. 1.1.2!" view-as alert-box question buttons ok.
end.

ON CHOOSE OF btnCancel IN FRAME fMain do:
   if length(aaa.aaa) <> 20 then leave.
   /*message "Вы действительно хотите расторгнуть доп. соглашение по счету " + aaa.aaa + "?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
   if v-ans then do:*/
    if v-flag = '2' then run procCancel. else message "Для выполнения пройдите в п.м. 1.1.4!" view-as alert-box question buttons ok.
   /*end.*/
end.

OPEN QUERY q_aaa1 FOR EACH aaa, each acvolt of aaa where aaa.cif = g-cif and lookup(aaa.lgr,v-lgrlist) > 0 and acvolt.x7 <> 100 and aaa.sta <> "C".
enable all with frame fMain.
WAIT-FOR CHOOSE OF btnExit.


/************************/

    procedure procSelect:
        OPEN QUERY q_aaa FOR EACH aaa where aaa.cif = g-cif and lookup(aaa.lgr,v-lgrlist) > 0 and aaa.sta <> "C".
        enable all with frame faaa.
        WAIT-FOR RETURN OF frame faaa FOCUS b_aaa IN FRAME faaa.
        hide frame faaa.
        v-aaa = aaa.aaa.
        displ v-aaa with frame fProp.
    end procedure.

    procedure procEdt:
        if length(aaa.aaa) <> 20 then leave.
        v-aaa = aaa.aaa.
        v-amount = GetHoldAmount(aaa.aaa).
        v-rate = aaa.rate.
        find last acvolt where acvolt.aaa = v-aaa and acvolt.x7 <> 100 no-lock no-error.
        v-month = int( acvolt.x4 ).
        v-efrate = deci( acvolt.x2 ).
        displ v-aaa v-month v-rate v-efrate v-amount with frame fProp.
        update v-amount with frame fProp.

        if v-amount = ? then do:
           message "Укажите сумму!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 1 then if v-amount < 100000 then do:
           message "Неснижаемый остаток должен быть не менее 100000 KZT!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 2 then if v-amount < 1000 then do:
           message "Неснижаемый остаток должен быть не менее 1000 USD!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 3 then if v-amount < 1000 then do:
           message "Неснижаемый остаток должен быть не менее 1000 EUR!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.

        if aaa.cr[1] - aaa.dr[1] - aaa.hbal < v-amount - GetHoldAmount(aaa.aaa) then do:
           message "На счете недостаточно средств!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        run tdaremholda(v-aaa).
        run tdasethold(v-aaa,v-amount).

        hide frame fProp.

        message "Неснижаемый остаток изменен!" view-as alert-box question buttons ok.
    end procedure.


    procedure procAdd:
        v-aaa    = ''.
        v-month  = ?.
        v-rate   = ?.
        v-efrate = ?.
        v-amount = ?.

        displ v-aaa
              v-month
              v-rate
              v-efrate
              v-amount with frame fProp.

        update v-aaa v-month with frame fProp.
        find first aaa where aaa.aaa = v-aaa and lookup(aaa.lgr,v-lgrlist) > 0 and aaa.sta <> "C" exclusive-lock no-error.
        if not avail aaa then do:
           message "Счет " + v-aaa + " не найден!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        find first acvolt where acvolt.aaa = v-aaa and acvolt.x7 <> 100 no-lock no-error.
        if avail acvolt then do:
           message "Счет уже настроен как депозит!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc > 3 then do:
           message "По данной валюте вклад не предусмотрен!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.

        if aaa.crc = 1 then v-val = "KZT".
        if aaa.crc = 2 then v-val = "USD".
        if aaa.crc = 3 then v-val = "EUR".

        find last rtur where rtur.cod = v-val and rtur.trm = v-month and rtur.rem = "ForteSpecial"  no-lock no-error.
        if not avail rtur then do:
           message "Срок указан неверно!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        v-rate = rtur.rate.

        update v-amount with frame fProp.
        if v-amount = ? then do:
           message "Укажите сумму!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 1 then if v-amount < 100000 then do:
           message "Неснижаемый остаток должен быть не менее 100000 KZT!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 2 then if v-amount < 1000 then do:
           message "Неснижаемый остаток должен быть не менее 1000 USD!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.
        if aaa.crc = 3 then if v-amount < 1000 then do:
           message "Неснижаемый остаток должен быть не менее 1000 EUR!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.

        if aaa.cr[1] - aaa.dr[1] - aaa.hbal < v-amount then do:
           message "На счете недостаточно средств!" view-as alert-box question buttons ok.
           hide frame fProp.
           leave.
        end.


        run EvaluateExpiryDate.
        v-efrate = v-rate.
        displ v-rate v-efrate with frame fProp.
        pause.
        hide frame fProp.
        /*v-aaa = v-aaa:screen-value.*/
        aaa.rate = v-rate.
        aaa.cla = v-month.
        aaa.lstmdt = g-today.
        create acvolt.
           assign
              acvolt.aaa = v-aaa
              acvolt.x1 = string(g-today) /*дата открытия*/
              acvolt.x2 = string(v-efrate)  /*Эффективная ставка*/
              acvolt.x3 = string(v-expdt) /*дата закрытия*/
              acvolt.x4 = string(v-month).

        run tdasethold(v-aaa,v-amount).

        message "Депозит создан!" view-as alert-box question buttons ok.
        run dogovorEx(v-aaa,'1').
        OPEN QUERY q_aaa1 FOR EACH aaa, each acvolt of aaa where aaa.cif = g-cif and lookup(aaa.lgr,v-lgrlist) > 0  and acvolt.x7 <> 100 and aaa.sta <> "C".
        /*browse b_aaa1:refresh().*/
    end procedure.

    procedure procCancel:
      find crc where crc.crc = aaa.crc no-lock no-error.
      find last acvolt where acvolt.aaa = aaa.aaa and acvolt.x7 <> 100 exclusive-lock no-error.
      if date(acvolt.x1) < g-today then do:
         if date(acvolt.x3) <= g-today then do:
            message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string(GetHoldAmount(aaa.aaa),'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(0,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
                 "Подтвердите закрытие депозита." view-as alert-box question buttons yes-no title "" update v-ans1.
            if v-ans1  then do:
                run procTrx(aaa.aaa,0,0,0).
                run tdaremhold(aaa.aaa,GetHoldAmount(aaa.aaa)).
                acvolt.x7 = 100.
                message "Расторгнут!" view-as alert-box  buttons ok.
            end.
         end.
         if aaa.crc = 1 then do:
            for_1level = GetHoldAmount(aaa.aaa) * 0.1 * (g-today - date(acvolt.x1)) / 365 / 100.
            for_nalog = for_1level * 15 / 100.
            message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string(GetHoldAmount(aaa.aaa) + for_1level - for_nalog ,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(for_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
                 "Подтвердите закрытие депозита." view-as alert-box question buttons yes-no title "" update v-ans1.
            if v-ans1  then do:
               run tdaremhold(aaa.aaa,GetHoldAmount(aaa.aaa)).
               run procTrx(aaa.aaa,0,for_1level,for_nalog).
               acvolt.x7 = 100.
               message "Расторгнут!" view-as alert-box  buttons ok.
            end.
         end. else do:
            message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
                 "Сумма в размере" trim(string(GetHoldAmount(aaa.aaa),'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
                 "Налог в размере" trim(string(0,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
                 "Подтвердите закрытие депозита." view-as alert-box question buttons yes-no title "" update v-ans1.
            if v-ans1  then do:
               run procTrx(aaa.aaa,0,0,0).
               run tdaremhold(aaa.aaa,GetHoldAmount(aaa.aaa)).
               acvolt.x7 = 100.
               message "Расторгнут!" view-as alert-box  buttons ok.
            end.

         end.
      end. else if date(acvolt.x1) = g-today then do:
         message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА" skip
              "Сумма в размере" trim(string(GetHoldAmount(aaa.aaa),'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет доступна к выплате" skip
              "Налог в размере" trim(string(0,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
              "Подтвердите закрытие депозита." view-as alert-box question buttons yes-no title "" update v-ans1.
         if v-ans1  then do:
            run tdaremhold(aaa.aaa,GetHoldAmount(aaa.aaa)).
            acvolt.x7 = 100.
            message "Расторгнут!" view-as alert-box  buttons ok.
         end.
      end.

      OPEN QUERY q_aaa1 FOR EACH aaa, each acvolt of aaa where aaa.cif = g-cif and lookup(aaa.lgr,v-lgrlist) > 0 and acvolt.x7 <> 100 and aaa.sta <> "C".
    end procedure.


    procedure procTrx:
        def input parameter aaa% as char.
        def input parameter d_1% as deci.  /* Проводка с 1 на 2 уровень */
        def input parameter d_3% as deci.  /* Проводка с 2 на 1 уровень */
        def input parameter d_tssum_nalog as deci. /*Налог*/
        define buffer b-lgr for lgr.
        define buffer b-aaa for aaa.
        define buffer b-cif for cif.
        find first b-aaa where b-aaa.aaa = aaa% no-lock no-error.
        if not avail b-aaa then do:
            message "Счет не найден!" view-as alert-box question buttons ok.
            return.
        end.
        find first b-lgr where b-lgr.lgr = b-aaa.lgr no-lock no-error.
        if not avail b-lgr then do:
            message "Группа не найдена!" view-as alert-box question buttons ok.
            return.
        end.
        find first b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
        if not avail b-cif then do:
            message "Клиент не найден!" view-as alert-box question buttons ok.
            return.
        end.

        def var v-jh like jh.jh.
        def var rcode as inte.
        def var rdes as char.
        def var vdel as char initial "^".
        define var s-amt1 as decimal decimals 2.
        def var s-amt2 as decimal decimals 2.
        def var s-amt11 as decimal decimals 2.
        def var vparam as char.
        def var v-nlg as char.
        define buffer bnlg-sysc for sysc.
        def var v-rate as deci no-undo.
        find last crc where crc.crc = b-aaa.crc no-lock no-error.
        v-rate  = crc.rate[1].

          /* Проводка с 2 на 1 уровень */
          if d_3% > 0 and d_3% <= (b-aaa.cr[2] - b-aaa.dr[2]) then do:
             run savelog( "cif-dep", b-aaa.aaa + " Проводка с 2 на 1 уровень").
             v-jh = 0.
             run trxgen("TDA0001", vdel, string(d_3%) + vdel + b-aaa.aaa + vdel + string(b-lgr.autoext,"999"), "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                run savelog( "cif-dep", b-aaa.aaa + " TDA0001 " + rdes).
                message "TDA0001" rdes. pause. undo,retry.
             end.
             else do:
                run trxsts(v-jh, 6, output rcode, output rdes).
                if rcode ne 0 then do:
                   run savelog( "cif-dep", b-aaa.aaa + " " + rdes).
                   message rdes view-as alert-box title "". undo,retry.
                end.
             end.
          end.


          v-jh = 0.
          /* Проводка с 1 на 2 уровень */
          if d_1% > 0 and (b-aaa.cr[1] - b-aaa.dr[1]) >= d_1% then do:
             run trxgen("UNI0074", vdel, string(d_1%) + vdel + b-aaa.aaa + vdel + "Удержание процентов с 1 уровня" + vdel + string(b-lgr.autoext,"999"), "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "UNI0074 " rdes. pause. undo,retry.
             end.
          end.


          s-amt2 = b-aaa.cr[2] - b-aaa.dr[2]. s-amt11 = 0.
          run savelog('cif-dep', '596. ' + b-aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          find first trxbal where trxbal.subled = 'cif' and trxbal.acc = b-aaa.aaa and trxbal.level = 11 no-lock no-error.
          s-amt11 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1], 2).
          run savelog('cif-dep', '599. ' + b-aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          if s-amt2 > s-amt11 then s-amt1 = s-amt2 - s-amt11.
          else do : s-amt1 = 0. s-amt11 = s-amt2. end.
          run savelog('cif-dep', '602. ' + b-aaa.aaa + ' ' + string(s-amt11) + ' ' + string(s-amt2) + ' ' + string(s-amt1) ).
          /*!!!!!!*/
          /* Проводка со 2 на 11 уровень */
          if s-amt11 > 0 then do:
             v-jh = 0.
             /* vparam = string(0) + vdel + b-aaa.aaa + vdel + string(s-amt11).*/
             if aaa.crc = 1 then vparam = string(0) + vdel + b-aaa.aaa + vdel + string(0) + vdel + b-aaa.aaa + vdel + "0" + vdel + string(s-amt11) + vdel + b-aaa.aaa.
             else vparam = string(0) + vdel + b-aaa.aaa + vdel + string(s-amt11) + vdel + b-aaa.aaa + vdel + string(round(s-amt11 * v-rate,2)) + vdel + string(0) + vdel + b-aaa.aaa.
             run trxgen ("cda0003", vdel, vparam, "CIF" , b-aaa.aaa ,  output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "cda0003" ' ' rdes. pause. undo,retry.
             end. else
             do: /* штамповка транзакции */
                  run trxsts(v-jh, 6, output rcode, output rdes).
                  if rcode ne 0 then do:
                     message rdes view-as alert-box title "". return.
                  end.
             end.
          end.

          /* Урегулируем разность если на 2 ур > чем на 11 */
          if s-amt1 > 0 then do:
             v-jh = 0.
             /*vparam = string(s-amt1) + vdel + b-aaa.aaa + vdel + "Удержание процентов ".*/
            if aaa.crc = 1 then vparam = string(s-amt1) + vdel + b-aaa.aaa + vdel + "Удержание процентов " + vdel +
                                    string(0) + vdel + b-aaa.aaa + vdel + "" + vdel + "0".
            else vparam = string(0) + vdel + b-aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + b-aaa.aaa + vdel + "Удержание процентов" + vdel + string(round(s-amt1 * v-rate,2)).
             run trxgen ("uni0048", vdel, vparam, "CIF" , b-aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then do:
                message "uni0048" ' ' rdes. pause. undo,retry.
             end.
          end.

          if d_tssum_nalog > 0 then do:
               if b-cif.geo = '022' and b-cif.type = 'B' then do:
                  v-nlg = "".
                  find last bnlg-sysc where bnlg-sysc.sysc = "nlg022"  no-lock no-error.
                  if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                  if b-aaa.crc <> 1 then do:
                     vparam = string(d_tssum_nalog)
                         + vdel + b-aaa.aaa
                         + vdel + string(getConvGL(b-aaa.crc,"C"))
                         + vdel + string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin)
                         + vdel + v-nlg
                         + vdel + string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin).
                     /*message vparam. pause.*/
                     v-jh = 0.
                     run trxgen("vnb0083", vdel, vparam, "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode <> 0 then do:
                        message "Произошла ошибка при удержании налога. Не настроен ARP счет. [1] " rdes.
                        pause 555.
                     end.
                  end.
                  else do:
                     vparam = string(d_tssum_nalog) + vdel + string(b-aaa.crc) + vdel +  b-aaa.aaa + vdel + string(v-nlg) + vdel +
                              string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin) + vdel + "390".
                     v-jh = 0.
                     run trxgen("uni0113", vdel, vparam, "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode <> 0 then do:
                        message "Произошла ошибка при удержании налога. Не настроен ARP счет. [2] " rdes.
                        pause 555.
                     end.
                  end. /*b-aaa.crc <> 1*/
               end.
               else do:
                  find last bnlg-sysc where bnlg-sysc.sysc = "nlg"  no-lock no-error.
                  if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                  if b-aaa.crc <> 1 then do:
                     /*run trxgen("vnb0024", vdel, vparam, "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).*/
                     vparam = string(d_tssum_nalog)
                          + vdel + b-aaa.aaa
                          + vdel + string(getConvGL(b-aaa.crc,"C"))
                          + vdel + string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin)
                          + vdel + v-nlg
                          + vdel + string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin).
                     v-jh = 0.
                     run trxgen("vnb0083", vdel, vparam, "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).

                  end. else do:
                     vparam = string(d_tssum_nalog) + vdel + string(b-aaa.crc) + vdel +  b-aaa.aaa + vdel +  string(v-nlg) + vdel +
                              string("Налог у источника выплаты 15%. " + b-cif.prefix + " " + b-cif.name + " " + b-cif.bin) + vdel + "390".
                     v-jh = 0.
                     run trxgen("uni0113", vdel, vparam, "CIF", b-aaa.aaa, output rcode, output rdes, input-output v-jh).

                  end. /*b-aaa.crc <> 1*/
                  if rcode ne 0 then do:
                     message "Произошла ошибка при удержании налога. Не настроен ARP счет. [3] " rdes.
                     pause 555.
                  end.

               end.
          end.

    end procedure.