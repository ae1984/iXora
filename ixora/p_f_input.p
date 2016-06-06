/* p_f_input.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Пенсионные и прочие платежи - ввод платежа
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     19.06.2003 kanat Добавил печать чека при создании платежа
     09.10.2003 sasco автоматическая печать квитанции
     10.10.2003 sasco Запрос на ордер через "canprn"
     12.12.2003 sasco 1. Ввод вдреса плательщика в поле chval[1]
                      2. добавил функции GET-FIO () и GET-ADDR ()
                      3. Проверка на нулевые суммы
     12.12.2003 kanat Добавил ввод резидентсва при приеме квитанций (поле intval[1]) 1 - резидент, 2 - нерезидент
     23.12.03 sasco добавил обнуление счетчика распечатанных квитанций при изменении платежа
     03.03.04 kanat В comm-con передается screen-value от p_f_payment.amt.
     08/07/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользу юр лиц.
     09/07/04 dpuchkov - исключил возм оплаты юр. лиц если рнн=000000000000 .
     09/06/04 kanat  - добавил вывод общей суммы с комиссией при приеме, редактировании и просмотре платежей.
     11/06/04 dpuchkov - поставил leave вместо return
     18/06/04 kanat - перенес печать документов в p_f_list
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     09.02.2005 kanat - обработка количества плательщиков и проверки на тарифы
                        добавил обработку плательщиков ВОВ и приравненных им
     16.02.2005 kanat - добавил доплнительный вывод комиссий
     28.02.2005 kanat - добавил поле для ввода контактных телефонов (p_f_payment.chval[2])
     13.10.2005 sasco - исправил расчет суммы комиссии в зависимости от кол-ва вкладчиков для филиалов
     09.12.2005 u00121 - добавил поля для Акта изъятия денег по юридическим лицам согласно ТЗ ї 137 от 29/08/2005 г.
     08.02.2006 u00568 Evgeniy - автоматизация снятия комиссий по всем филиалам по ТЗ 175 от 16/11/2005 ДРР
     02.03.2006 u00568 Evgeniy - убрал возможность выбора льготной комиссии ТЗ 175, оптимизировал код
     02.03.2006 u00568 Evgeniy - стандартизация - добавил возможность выбора льготной комиссии вместо 09.12.2005 u00121 как везеде
                                 код комиссии сохраняю p_f_payment.diskont
     24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн

*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{p_f_com.i}
{p_f_gs.i}
{p_f_com1.i}
{comm-com.i}
{comm-rnn.i}
{trim.i}
{getfromrnn.i}


define shared variable g-ofc as character.
def var v-resident as integer init 1.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then canprn = yes.

def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter dat as date.
def new shared var pass_no as char.
def var cret as char init "".
def var lname as char.
def var fname as char.
def var mname as char.
def var amount as decim.
def var iscom as logical init false.
def var comsum as decimal init 0.
def var pf-name as char init ''.
def var comchar as char init "Без комиcсии".
/*def var doccomcode as char.*/
def var resultt as log init true.
/*def var l-strt as logical init false.*/

define variable oldrnn as character.

define buffer oldb for p_f_payment.
define variable candel as log.

def var l-ind as logical initial False.
def var v-whole-sum as decimal.


candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

def frame sfx
     "Номер акта изъятия денег и Ф.И.О. налогового инспектора" skip
     "----------------------------------------------------"  skip
     p_f_payment.act_withdrawal  label "Номер Акта  : "  format "x(45)"
     p_f_payment.inspektor_NK  label   "Ф.И.О. инсп.: "  format "x(45)"
     with side-labels centered view-as dialog-box.


define frame sf
               p_f_payment.rnn  label "РНН" format "x(12)" skip
               p_f_payment.name label "ФИО/Наименование" view-as text skip
               p_f_payment.chval[1] label "Адрес" format "x(55)" skip
               v-resident label "[1 - Резидент, 2 - Нерезидент]: " format "9" skip
               "--------------------------------------------------" skip
               p_f_payment.distr label "РНН П/Фонда (F2 - выбор)" format "x(12)" skip
               pf-name no-label format 'x(50)' view-as text skip
               /*"--------------------------------------------------" skip
                "по акту изъятия денег N " p_f_payment.act_withdrawal no-label skip
                "от инспектора НК " p_f_payment.inspektor_NK no-label " (Ф.И.О.)" skip*/
               "--------------------------------------------------" skip
               p_f_payment.cod  label "Код [П.Ф(10).- 100, П.Ф.(19)-200, П.Ф.(13) - 300, Прочие-400]" skip
               p_f_payment.chval[2] validate(trim(p_f_payment.chval[2]) <> ? and trim(p_f_payment.chval[2]) <> "", "Неверный номер телефона!") label "Номер конт. телефона клиента" format "x(35)"

               p_f_payment.amt  label "Сумма" format ">>>>>>9.99"
               p_f_payment.qty  validate (p_f_payment.qty > 0, "Неверное кол-во вкладчиков!") label "Кол-во вкладчиков "
               "Код комиссии (F2-выбор)" iscom  validate (true, "Выберите код комиссии!") format ":/:" no-label
               comsum format ">>>>>>>>9.99" label "Комиссия" skip
               p_f_payment.comiss format ">>>>>>>>9.99" label "Общая Комиссия" skip
               v-whole-sum format ">>>>>>>>9.99" label "Сумма + комиссия" skip
               with side-labels centered view-as dialog-box.

define frame getaddr
             p_f_payment.chval[1] format "x(60)" label "Адрес для возврата писем"
             with row 5 centered overlay title "Уточнение адреса".

define frame sf1
       lname skip
       fname skip
       mname skip
       with side-label centered overlay view-as dialog-box.

       
on help of p_f_payment.distr in frame sf
do:
    run p_f_rnn.
    p_f_payment.distr:screen-value = return-value.
    p_f_payment.distr = p_f_payment.distr:screen-value.
end.


on value-changed of v-resident in frame sf do:
        v-resident = integer(v-resident:screen-value).
        apply "value-changed" to self.
end.



  on value-changed of p_f_payment.amt in frame sf do:
    p_f_payment.amt = decimal(p_f_payment.amt:screen-value).
    run choose_doccomcode_calc_and_displ_sums.
    apply "value-changed" to self.
  end.


on help of iscom in frame sf do:
        /*if length(p_f_payment.act_withdrawal) = 0 then*/
        do: /*02.11.2005 u00121 если не введен номер акта изъятия денег то работаем с комиссией*/
          case seltxb:
            WHEN 0 then do:
              run comtar("7","09,42").
              /*message "Для данного типа квитанций выбор не предусмотрен" view-as alert-box title "Внимание".*/
            end.
            WHEN 1 then do:
              run comtar("7","09,42").
            end.
            WHEN 2 then do:
              run comtar("7","09,42").
            end.
            WHEN 3 then do:
              run comtar("7","09,42").
            end.
            WHEN 4 then do:
              run comtar("7","09,42").
            end.
            OTHERWISE do:
              run comm-coms.
            end.
          end case.
          if return-value <> "" then
            p_f_payment.diskont = return-value.
          if p_f_payment.diskont = "42" then do /*transaction*/:
            update
              p_f_payment.act_withdrawal
              p_f_payment.inspektor_NK
            with frame sfx.
            hide frame sfx.
            if trim(p_f_payment.inspektor_NK) = "" then do:
              message "Введите ФИО Инспектора" view-as alert-box title "Внимание".
              undo,retry.
            end.
            if trim(p_f_payment.act_withdrawal) = "" then do:
              message "Введите номер документа" view-as alert-box title "Внимание".
              undo,retry.
            end.
            p_f_payment.act_withdrawal = trim(p_f_payment.act_withdrawal).
            p_f_payment.inspektor_NK = trim(p_f_payment.inspektor_NK).
          end.
          run choose_doccomcode_calc_and_displ_sums.
        end.
        /*
        else do:
          message "Заполненно поле номера акта изъятия денег," skip "в этом случае комиссия не расчитывается!"
            view-as alert-box.
          comsum = 0.
        end.
        */
end.



/*
on value-changed of p_f_payment.act_withdrawal in frame sf do:
  p_f_payment.act_withdrawal = trim(p_f_payment.act_withdrawal:screen-value).
  run choose_doccomcode_calc_and_displ_sums.
end.
*/


on value-changed of p_f_payment.qty in frame sf do:
  p_f_payment.qty = integer(p_f_payment.qty:screen-value).
  p_f_payment.comiss = comsum * p_f_payment.qty.
  v-whole-sum = p_f_payment.comiss + p_f_payment.amt.
  displ
    p_f_payment.comiss
    v-whole-sum
  with frame sf.
end.


on return of p_f_payment.distr in frame sf
do:
        find first p_f_list where p_f_list.rnn = p_f_payment.distr no-lock no-error.
        if avail p_f_list then pf-name = p_f_list.name.
                          else pf-name = ' '.

        displ pf-name with frame sf.
end.

/*** KOVAL ***/
on return of p_f_payment.cod in frame sf
do:
  resultt = true.
  if p_f_payment.cod <= 300 then do:
   if length(p_f_payment.rnn:screen-value) <> 12 then do:
    message "РНН обязателен !". /*string(p_f_payment.cod) + " " + p_f_payment.cod:screen-value + " " + p_f_payment.rnn + " " + p_f_payment.rnn:screen-value.*/
    resultt = false.
   end.
  end.
end.

function GET-FIO returns character (vrnn as character).
   return getfio1(vrnn).
end function.


function GET-ADDR returns character (vrnn as character).
   return getadr1(vrnn).
end function.


/* main logic------------------------------------------------------------------- */


REPEAT:

    if newdoc then do: CREATE p_f_payment.
                       p_f_payment.txb = seltxb.
                       p_f_payment.rnn = "".
                       oldrnn = ''.
                       p_f_payment.qty = 0.
                   end.
              else do:
                   find last p_f_payment where rowid(p_f_payment)=rid.
                   if avail p_f_payment then
                   assign oldrnn = p_f_payment.rnn
                          v-resident = p_f_payment.intval[1]
                          comsum = integer(p_f_payment.comiss / p_f_payment.qty)
                          v-whole-sum = p_f_payment.amt + comsum * p_f_payment.qty.
              end.

    displ pf-name with frame sf.

        displ p_f_payment.rnn
              p_f_payment.name
              p_f_payment.chval[1]
              v-resident
              p_f_payment.cod
              p_f_payment.qty
              p_f_payment.chval[2]
              p_f_payment.amt
              p_f_payment.distr
              /*p_f_payment.act_withdrawal
              p_f_payment.inspektor_NK*/
              iscom
              p_f_payment.comiss
              comsum
              v-whole-sum
              with frame sf.


        if not newdoc then do:
           create oldb.
           buffer-copy p_f_payment to oldb.
           p_f_payment.chval[5] = "0".
           assign oldb.deldate = today
                  oldb.deltime = time
                  oldb.deluid = userid ("bank")
                  oldb.delwhy = "Изменение реквизитов"
                  oldb.deldnum = next-value(p_f_seq).
        end.

        if newdoc or candel then do:
        UPDATE
               p_f_payment.rnn validate (not comm-rnn(p_f_payment.rnn),
                                         "Не верный контрольный ключ РНН!")
               WITH FRAME sf.

               if newdoc then do:
                  p_f_payment.chval[1] = GET-ADDR (p_f_payment.rnn).
                  displ p_f_payment.chval[1] with frame sf.
               end.
               if p_f_payment.name = '' then do:
                  p_f_payment.name = GET-FIO (p_f_payment.rnn).
                  displ p_f_payment.name with frame sf.
               end.

        UPDATE
               p_f_payment.chval[1]
               v-resident validate(v-resident = 1 or v-resident = 2, "Не верный тип резиденства!")
               p_f_payment.distr validate (can-find(first p_f_list where p_f_list.rnn = p_f_payment.distr),
                                           "Не существующий РНН ПФ!")
               /*p_f_payment.act_withdrawal
               p_f_payment.inspektor_NK*/
               iscom
               p_f_payment.cod validate (resultt,"Не верный контрольный ключ РНН!")
               p_f_payment.chval[2] validate (trim(p_f_payment.chval[2]) <> "", "Неверный номер телефона!")
               p_f_payment.amt validate (p_f_payment.amt > 0, "Сумма должна быть больше нуля!")
               p_f_payment.qty validate (p_f_payment.qty > 0, "Неверное количество плательщиков!")
               iscom WITH FRAME sf.


               /* dpuchkov проверка реквизитов см тз 907 */
/*
               if not l-strt then do:
               run rekvin(p_f_payment.distr, "", "", p_f_payment.cod, p_f_payment.rnn).
               if not l-ind then do:
                 undo, return.
               end.
               l-strt = true.
               end.
*/
        end.

        else do:
        UPDATE
               p_f_payment.distr validate (can-find(first p_f_list where p_f_list.rnn = p_f_payment.distr),
                                           "Не существующий РНН ПФ!")
               /*p_f_payment.act_withdrawal
               p_f_payment.inspektor_NK*/
               iscom
               p_f_payment.cod validate (resultt,"Не верный контрольный ключ РНН!")
               p_f_payment.chval[2] validate (trim(p_f_payment.chval[2]) <> "", "Неверный номер телефона!")
               p_f_payment.qty
               iscom
               WITH FRAME sf.
        end.
        update p_f_payment.date = dat.

        p_f_payment.comiss = comsum * p_f_payment.qty.
        v-whole-sum = p_f_payment.comiss + p_f_payment.amt.


        MESSAGE "Сохранить?"
             VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel
             TITLE "Пенсионные и др. платежи " UPDATE choice as logical.

        if not choice then delete oldb.

        case choice:
            when true then do:
                 if p_f_payment.name = '' or p_f_payment.rnn <> oldrnn then p_f_payment.name = GET-FIO (p_f_payment.rnn).
                 if p_f_payment.name = '' then do:
                      message "Введенный РНН отсутствует в БД ПРАГМА. Введите данные клиента" .
                      update
                        lname format "x(35)" label "Фамилия/Организация" skip
                        fname format "x(20)" label "Имя"     skip
                        mname format "x(20)" label "Отчество"

                     WITH frame ins row 9 side-labels centered title "Ввод Ф.И.О./Наименования".
            
                     p_f_payment.name = GTrim(getfio()).
                     /*p_f_payment.name = GTrim (lname + ' ' + fname + ' ' + mname).*/

                 end.

                 if p_f_payment.rnn <> oldrnn or TRIM(p_f_payment.chval[1]) = '' then p_f_payment.chval[1] = GET-ADDR (p_f_payment.rnn).
                 if p_f_payment.cod <> 400 then do:
                    update p_f_payment.chval[1] with frame getaddr.
                    do while trim (p_f_payment.chval[1]) = '':
                       update p_f_payment.chval[1] with frame getaddr.
                    end.
                 end.

                 if newdoc then
                           assign p_f_payment.uid = userid("bank")
                                  p_f_payment.dnum = next-value(p_f_seq)
                                  p_f_payment.intval[1] = v-resident
                                  p_f_payment.comiss = p_f_payment.qty * comsum.
                           else
                           assign p_f_payment.dnum = oldb.deldnum
                                  p_f_payment.comiss = p_f_payment.qty * comsum
                                  p_f_payment.euid  = userid("bank")
                                  p_f_payment.edate = today
                                  p_f_payment.etim  = time.
                 
                 cret = string(rowid(p_f_payment)).
                 
                 if canprn then do:
                    MESSAGE "Распечатать ордер ?"
                    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                    TITLE "Внимание" UPDATE choice4 as logical.
                    case choice4:
                         when true then run p_f_kvit(string(rowid(p_f_payment))).
                    end case.
                 end. /*else run p_f_kvit(string(rowid(p_f_payment))).*/


                 leave.
        end.

        when false then undo.
        otherwise  undo, leave.
     end case.

END.

hide frame sf.
return cret.




procedure rekvin.
   def input parameter vrnnbn like commonls.rnnbn.
   def input parameter vknp like commonls.knp.
   def input parameter vkbe like commonls.kbe.
   def input parameter vkod like commonls.kod.
   def input parameter vrnnsnd like commonls.rnnbn.


   run sel('Статус','Юридическое лицо|Физическое лицо').

   if integer(return-value) = 1 then
   do:
        if vrnnsnd = "000000000000" and vkod = "400" then do:
          message "Ограничение платежей юр.лиц в пользу других юр. лиц. " view-as alert-box.
          l-ind = False.
          return.
        end.

        if vrnnbn = vrnnsnd then do:
          l-ind = True.
          return .
        end.
        else
          if vknp = "" then do:
            message "РНН Отправителя и бенефициара не совпадают " view-as alert-box.
            l-ind = False.
            return.
           end.

      if vkod <> "" and vkbe <> "" and vknp <> "" then
          if (vkod = "17" or vkod = "27") and (vknp = "911" or vknp = "010" or vknp = "013" or
          vknp = "019" or vknp = "912" or vknp = "913") and vkbe = "11" then do:
          l-ind = True.
          return.
        end.
        else
        do:
          message "Ограничение платежей юр.лиц в пользу других юр. лиц. " view-as alert-box.
          l-ind = False.
          return.
        end.
   end.
   l-ind = True.
end procedure.



procedure choose_doccomcode_calc_and_displ_sums:
    /*if length(p_f_payment.act_withdrawal) = 0 then*/
    do: /*если не введен номер акта изъятия денег то работаем с комиссией*/
      if p_f_payment.diskont <> "42" then do:
        case seltxb:
          WHEN 0 then do: /*алматы*/
            p_f_payment.diskont = "09".
          end.
          WHEN 1 then do: /*Астана*/
            p_f_payment.diskont = "09".
          end.
          WHEN 2 then do: /*Уральск*/
            p_f_payment.diskont = "09".
          end.
          WHEN 3 then do: /*Атырау*/
            p_f_payment.diskont = "09".
          end.
          WHEN 4 then do: /*Актобе*/
            p_f_payment.diskont = "09".
          end.
        end case.
      end.
      comsum = comm-com-1(p_f_payment.amt, p_f_payment.diskont, "7", comchar).
      p_f_payment.comiss = comsum * p_f_payment.qty.
      v-whole-sum = p_f_payment.comiss + p_f_payment.amt.
    end. /*else  comsum = 0.*/
    /*v-whole-sum = (comsum * p_f_payment.qty) + p_f_payment.amt.*/
    displ comsum
      p_f_payment.comiss
      v-whole-sum
    with frame sf.
end procedure.
