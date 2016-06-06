/* stadin.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
        Процедура регистрации платежей станций диагностик

        ARP
        000076261 - таможня
        002076162 - тоже таможня

        единственое место, где общая сумма
        docsum = docsum * colord
        doccomsum = doccomsum * colord
        v_whole_sum = docsum + doccomsum.

  * AUTHOR
        31/12/99 pragma
 * CHANGES
        09/09/03 Kanat - автоматическая печать чека БКС при сохранении квитанции в очереди на сохранение
        23.09.03 sasco изменять платеж может только менеджер из sysc."COMDEL".chval
        08.10.03 sasco откорректировал изменение платежей + номер нового документа
        09.10.03 sasco автоматическая печать квитанции
        10.10.03 sasco Запрос на ордер через "canprn"
        15.10.03 kanat Перенес автоматическую печать чека КС в процедуру stadkvit.p
        21.10.03 sasco убрал запрос на создание еще одного платежа (do_while)
        22.10.03 sasco берет реквититы из посленего  документа
        31.10.03 sasco добавил вывод даты в форму
        08.12.03 kanat для таможенных платежей водится КБК по каждому виду платежа (таможенного) (поле dockbk)
                       для платежей в г. Уральск также вводятся абонентские или лицевые счета клиентов организаций (поле documber).
        12.12.03 kanat для ТОО Дана и ТОО Фотосистем печатается только квитанция
        13.12.03 sasco для ТОО Дана и ТОО Фотосистем печатается НЕ ТОЛЬКО квитанция :-)
        12.12.03 kanat добавил вывод описания кода бюджетной классификации при приеме и редакировании таможенных платежей (поле v-budcode)
        23.12.03 sasco добавил обнуление счетчика распечатанных квитанций при изменении платежа
        06.01.04 kanat убрал лишний цикл при формировании квитанции
        01.14.04 kanat добавил ввод для таможенных платежей номеров КТС, ДВС, контрактов (dockts)
        01.19.04 kanat Добавил отмену печати извещений для ТОО Дана, ТОО Прогресс, ТОО Фото - систем
        01.29.04 kanat убрал распечатку извещений по Транссервису
        02.04.04 kanat переделал вызов процедуры распечатки квитанций
        02.16.04 kanat добавил нераспечатку извещений для АГФ ФОНД БДТ РК
        19.04.04 kanat добавил нераспечатку извещений для получателей для филиала в г. Уральск.
        25/05/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользу юр лиц.
        07/06/04 kanat добавил вывод суммы с комиссией при вводе, просмотре и редактировании платежей
        09/06/04 kanat переделал выдачу на экран основной формы с комиссией
        17/06/04 kanat перенес автоматическую печать квитанций в stadlist
        04.08.04 saltanat - добавлено передача параметров в процедуру stadprn (rids, KOd, KBe, KNp)
        20.08.04 kanat - добавил дополнительную проверку при приеме таможенных платежей - поле КТС теперь обязтельно для заполнения
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        12.02.2005 kanat - автоматическое снятие комиссий с возможностью выбора льготных тарифов для ВОВ
        16.02.2005 kanat - добавил дополнительные сообщения для кассиров
        28.02.2005 kanat - изменил обработку комиссий, для удосбтва работы кассиров - теперь сумма от нескольких плательщиков
                           высчитывается автоматически.
        21.04.2005 kanat - добавил обработку таможни ВОДНИК
        18.05.2005 kanat - добавил обработку кодов комиссий для сумм свыше 1000000 тенге
        21.06.2005 sasco - добавил отдельный тариф для docarp = "010904718" РГП ИПЦ МинЮста
        04.08.2005 kanat - РГП ИПЦ МинЮста сделал бесплатный
        08.08.2005 kanat - добавил дополнительное условие по Мин.Юсту
         1.12.2005 u00568(Evgeniy) - Переделка вилок для начисления камиссии банка накомунальные платежи причем на станции диагностики.
                                     вообще странный алгоритмнуждающийся в переделке ибо эти вилки нормально работают при совпадении наименований комиссий
                                     а вот тут добавили жесткую проверку в код и почему-то тот кто ведет справочник комиссий и вилок не предерживается правила одинакового именования комиссий
        16/01/2006 u00568(Evgeniy) - теперь при вводе платежей РГП "Центр по недвижимости по г. Алматы" РНН "600700022288"
                   добавляются 2 обязательных поля.
                   def shared var dockts as char init "".  - "Номер заказа"
                   def var num-for-realty as integer init 0.  - "Номер продразделения"
                   которые сохраняются
                   commonpl.info[2] = dockts
                   commonpl.info[4] = num-for-realty
                   Эти поля нужны для формирования реестра платежей в РГП "Центр по недвижимости по г. Алматы"
                   информация вводится операционистом с квитанции
                   по тз 198 от 20/12/05 от ДРР
                   отменил печать квитанции и извещения для РГП "Центр по недвижимости по г. Алматы"
        31/01/2006 Evgeniy (u00568) по тз 230 от 27/01/2006 "Внесение изменений в тарифы"
                    добавил возможность выбора комиссии из 2-х вариантов, убрал возможность ввода в ручную, добавил отображение названия комиссии
        24/02/2006 u00568 Evgeniy - автоматизировал все филиалы по ТЗ 175 от 16/11/2005
                   изменение будет работать только с новым comm-com.i и comtar.p и rekv_pl.i
                   оптимизировал транакцию и проставил no-undo
        02/03/2006 u00568 Evgeniy - РНН! в справочник физ лиц РНН (rnn) в поле comm.rnn.info[1] = 'ВОВ, ветеран, номер уд. ' + v-vov-name
                   пишется номер удостоверения ВОВ, и при последующем платеже этого физика комиссия автоматом станет льготная.
        16/03/2006 u00568 evgeniy нашел баг и исправил
        12/04/06 u00568 Evgeniy ТОО "Digital Format" РНН 620200266200 имеет особую комиссию - код 740. - по служебке от 12/24/2006 от ДРР Идоятовой.
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
        28/04/06 u00568 Evgeniy - онлайн и офлайн одинаковые!
        04/05/2006 u00568 Evgeniy - по тз 328 от 03/05/2006 изменение тарифа в филиалах
        22.08.2006 sasco добавил для Уральска 250904269 запрос на ввод лицевого счета
                         (поправил в update docnumber и в распечатке stadkvit2)
        28/08/2006 u00568 Evgeniy - синхронизация с офлайном + разобрались и решили, что
                                  docsum = docsum * colord
                                  doccomsum = doccomsum * colord
                                  v_whole_sum = docsum + doccomsum.
                                  + Pensin c табличками rnn и rnnu работает эффективнее и уже обкатана его работа. переношу все алгоритмы сюда
        06/09/2006 u00568 Evgeniy + Талдыкорган
        07/09/2006 u00568 Evgeniy + Караганда
        15/09/06 u00568 Evgeniy - баг - перед вычислением комиссии надо (docsum / colord)
        25/09/2006 u00568 Evgeniy - Караганда - смена кодов комиссии.
        27/09/2006 u00568 Evgeniy - в уральске для ТОО Акжайыкэнергосауда код комиссии 710 (письмо по эл почте)
        20.10.2006 u00568 Evgeniy - устарела программа stadkvit2.p
        24.11.2006 u00568 Evgeniy - РГП "Центр по недвижимости Караганда" - имеет особые тарифы
        28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
*/

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

{get-dep.i}
{yes-no.i}
{comm-com.i}
{comm-rnn.i}
{rekv_pl.i}
{getfromrnn.i}

def var KOd_ as char  no-undo.
def var KBe_ as char  no-undo.
def var KNp_ as char  no-undo.

define shared variable g-ofc as character.

def input parameter g-today as date no-undo.
def input parameter newdoc as logical no-undo.
def input parameter rid as rowid no-undo.

define buffer oldb for commonpl.

/* может запрашивать ордер или нет */
define variable canprn as log initial no no-undo.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then
  if lookup (g-ofc, sysc.chval) > 0 then
    canprn = yes.

def var do_while as logical init true  no-undo.
def var evnt as logical initial false no-undo.
def var mark as int no-undo.
def var cret as char init "" no-undo.
def var rnnlg as logical no-undo.

def new shared var numtns as integer init 0 no-undo.
/*def new shared var riddolg as char init "0x000000000".*/

def var result_rnn as logical init false no-undo.
def shared var dat as date.
def shared var rnnValid   as logical initial false.
def shared var doctype as int format ">9".
def shared var docfio  as char format "x(30)".
def shared var docadr  as char format "x(50)".
def shared var docfioadr  as char format "x(80)".
def shared var docbik  as integer format "999999999".
def shared var dociik  as integer format "999999999".
def shared var dockbk  as char format "x(6)".
def shared var docbn   as char format "x(35)".
def shared var docbank  as char.
def shared var dockbe   as char format "x(2)".
def shared var dockod   as char format "x(2)".
def shared var docrnn   as char format "x(12)".
def shared var docrnnbn as char format "x(12)".
def shared var docnpl   as char format "x(120)".
def shared var docnum   as integer format ">>>>>>>9".
def shared var docgrp   as integer.
def shared var doctgrp  as integer.
def shared var docarp   as char    format "x(10)".
def shared var docsum      as decimal format ">>,>>>,>>9.99".
def shared var doccomsum   as decimal format ">,>>9.99".
def        var doccomcode  like commonpl.comcode init '##'.
def shared var docprc   as integer  format "9.9999". /* Процент с АРП */
def shared var bsdate   as date.
def shared var esdate   as date.
def shared var selgrp   as integer init 1 . /* Платежи станции диагностики */
def shared var docnumber as char.
def shared var dockts as char init "".
def var num-for-realty as integer init 0  no-undo. /*u00568 evgeniy РГП "Центр по недвижимости по г. Алматы" РНН "600700022288" */




def var s-rnn    as char init "" no-undo.
def var rids     as char initial "" no-undo.
def var nkname   as char no-undo.
def var sumchar  as char no-undo.
def var sumchar1 as char no-undo.
def var docnpl1  as char format "x(40)" no-undo.
def var docnpl2  as char format "x(40)" no-undo.
def var sumchar2 as char no-undo.
def var comchar  as char no-undo.
def var v-budcode as char no-undo.

def var lcom as logical init false no-undo.
def var colord as int init 1 format "zzz9" no-undo.
def var cdate as date init today no-undo.

def var s_rid as char no-undo.
def var s_payment as char no-undo.

define variable candel as log no-undo.

def var v_whole_sum as decimal no-undo.

def var v-vov-name as char init "" no-undo.
def var juridical_person as logical init no no-undo. /* для снятия разных комиссий. */


def var commonpl_chval_5 as char init "" no-undo.
def var oldb_deldate like commonpl.deldate no-undo.
def var oldb_deltime like commonpl.deltime no-undo.
def var oldb_deluid like commonpl.deluid no-undo.
def var oldb_delwhy like commonpl.delwhy no-undo.
def var oldb_deldnum like commonpl.deldnum no-undo.
def var rid_rnn as rowid no-undo.
def var vov_str as char init 'ВОВ, ветеран, номер уд. ' no-undo.
def var rnn_error_str as char init "Не верный контрольный ключ РНН! Чтобы редактировать РНН - нажмите F<3>" no-undo.

def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.



candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then
  if lookup (userid("bank"), sysc.chval) = 0 then
    candel = no.

define buffer bcommpl for commonpl.

  function chkrnn returns logical:
    IF  rnnValid
         or
         ( length(docrnn) = 12
           and not comm-rnn (docrnn)
           and yes-no("", "РНН не найден в справочнике.~nЧтобы редактировать РНН - нажмите F<3>.~nПродолжить с введенным РНН?")
         )
         then result_rnn = true.
         else result_rnn = false.
    return( result_rnn ).
  end function.


def frame sf
    g-today         view-as text                    no-label
    docnum          view-as text format '>>>>>9'    no-label
    docbn           view-as text format 'x(42)'     no-label                         at 10
    dockbe          view-as text format 'x(2)'         label "КБе"                   at 54
    docrnnbn        view-as text format 'x(12)'        label "РНН"                   at 62 skip
    docbank         view-as text format "x(35)"        label "Наименование банка"    at 10 skip
    dociik          view-as text                       label "ИИК бенефициара"       at 10
    docbik          view-as text                       label "            БИК"       at 50 skip
    dockbk                       format 'x(6)'         label "КБК"                   at 10
    v-budcode       view-as text format 'x(35)'        label ""                      at 30 skip
    docnumber                    format 'x(12)'        label "Абонент/Лиц.счет"      at 10 skip
    docrnn validate(chkrnn(), rnn_error_str)   format "999999999999" label "РНН Отправителя денег" at 10 help "F2 - ПОИСК,  F3 - РЕДАКТИРОВАНИЕ"
    dockod          view-as text format "x(2)"         label "Koд "                  at 62 skip
    docfioadr                    format "x(55)"        label "ФИО, Адрес "      at 10 skip
    "---------------------------------------------------------------------"     at 10 skip
    "         Вид платежа                         |  Дата  |    Сумма"          at 10 skip
    "---------------------------------------------------------------------"     at 10 skip
    docnpl1         view-as text format "x(40)"     no-label                    at 10
                                                                  '|        |'  at 55
    docsum                  format ">>>,>>>,>>9.99" no-label                    at 65 skip
    docnpl2         view-as text format "x(40)" at 10 no-label     '|        |' at 55 skip
    "---------------------------------------------------------------------"     at 10 skip
    sumchar1        view-as text format "x(50)"        label "Сумма прописью"   at 10 skip
    sumchar2        view-as text format "x(50)"     no-label                    at 27 skip
    lcom                         format ":/:"       label "Тип комиссии "
    comchar         view-as text format 'x(30)'     no-label
    colord          validate (colord > 0, "Не верное количество плательщиков!") label "Количество"
    doccomsum       view-as text format ">>>,>>9.99"   label "Сумма комиссии"
    v_whole_sum     view-as text format ">>>,>>>,>>9.99"   label "Сумма + комиссия"  skip
    num-for-realty format ">>>>" label "Н.п."
    dockts format "x(35)" label "Дополнит."


    with side-labels centered title "Платежи станций диагностик, ОМП, таможни".



    on value-changed of docnumber in frame sf do:
        docnumber = docnumber:screen-value.
        apply "value-changed" to docnumber.
    end.



    on value-changed of dockbk in frame sf do:
        dockbk = dockbk:screen-value.
      find first budcodes where budcodes.code = integer(dockbk) no-lock no-error.
      if avail budcodes then do:
        v-budcode = budcodes.name.
        displ v-budcode with frame sf.
      end.
      else do:
        v-budcode = "No data".
        displ v-budcode with frame sf.
      end.
      apply "value-changed" to dockbk.
    end.



    on value-changed of docsum in frame sf do:
      if docsum <> decimal(docsum:screen-value) then colord = 1.
      docsum = decimal(docsum:screen-value).
      run choose_doccomcode_calc_and_displ_sums.
      run Sm-vrd(docsum, output sumchar).
      sumchar = sumchar + ' тенге ' +
        string(int((docsum - int(docsum)) * 100)) + " тиын".
      if length(sumchar) > 50 then do:
        mark = R-INDEX(sumchar, " ", 50).
        sumchar1 = SUBSTR(sumchar,1, mark).
        sumchar2 =  SUBSTR(sumchar, mark + 1).
      end. else do:
        sumchar1 = sumchar.
        sumchar2 = "".
      end.
      displ
        sumchar1
        sumchar2
        colord
      with frame sf.
      apply "value-changed" to self.
    end.



    on value-changed of docrnn in frame sf do:
        docrnn =  docrnn:screen-value.
        if newdoc and doccomcode='24' then do:
          doccomcode = "##".
          v-vov-name = ''.
          run choose_doccomcode_calc_and_displ_sums.
        end.
        juridical_person = is_it_jur_person_rnn(docrnn).

        if not juridical_person then do:
          find first rnn where rnn.trn = docrnn no-lock no-error.
          if avail rnn then do:
            if newdoc and entry(1,rnn.info[1],',') = 'ВОВ' then do:
              rid_rnn = rowid(rnn).
              v-vov-name = rnn.info[1].
              v-vov-name = substr(v-vov-name, length(vov_str + ' '), length(v-vov-name)) no-error.
              doccomcode = "24".
              run choose_doccomcode_calc_and_displ_sums.
            end.
          end.
        end.

        docFIO    = caps(getfio1(docrnn)).
        docADR    = caps(getadr1(docrnn)).
        docfioadr = docfio + ", " + docadr.
        rnnValid  = not (docfioadr = ', ').
        displ docfioadr with frame sf.
    end.

    on help of docrnn in frame sf do:
        disable all with frame sf.
        run taxfind.
        enable all
            except doccomsum docfioadr docnum g-today
                with frame sf.
        if return-value <> "" then do:
            update docrnn:screen-value = return-value with frame sf.
            update docrnn = return-value with frame sf.
        end.
        apply "value-changed" to self.
    end.



    on "enter-menubar" of docrnn in frame sf do:
         if yes-no ("", "Редактировать РНН " + docrnn:screen-value + " ?") then do:
           run taxrnnin (docrnn:screen-value).
           apply "value-changed" to docrnn in frame sf.
         end.
    end.



    on return of docrnn in frame sf do:
      apply "value-changed" to docrnn in frame sf.
    end.



   on help of docbn in frame sf do:
        run ChooseType.
        docsum:screen-value = string(docsum).
        apply "value-changed" to self.
        apply "value-changed" to docbik.
        apply "value-changed" to docsum.
        disp g-today docnum docrnnbn docbik dociik dockod dockbe docnpl1 docnpl2 doccomsum
        with frame sf.
    end.



    on value-changed of docbik in frame sf do:
        find first bankl where bankl.bank = string(docbik) USE-INDEX bank no-lock no-error.
        if avail bankl then update docbank = bankl.name.
        apply "value-changed" to self.
        disp docbik docbank with frame sf.
    end.


    on value-changed of colord in frame sf do:
      if newdoc and integer(colord:screen-value) >= 1 then do:
        doccomsum = doccomsum / colord no-error.
        docsum = docsum / colord no-error.
        colord = integer(colord:screen-value).
        doccomsum = doccomsum * colord no-error.
        docsum = docsum * colord no-error.
        v_whole_sum = docsum + doccomsum.
        displ
            docsum
            doccomsum
            v_whole_sum
        with frame sf.
        /*apply "value-changed" to docsum in frame sf.*/
      end.
    end.


    on value-changed of dockts in frame sf do:
        dockts = dockts:screen-value.
        apply "value-changed" to dockts.
    end.



    on help of lcom in frame sf do:
      case seltxb:
        WHEN 0 then do:
          if docarp <> "000076261" /*and docarp <> "000076575"*/ and docarp <> "002076162" then
            run comtar("7","24,##").
          else
            message "Для данного типа квитанций выбор не предусмотрен" view-as alert-box title "Внимание".
        end.
        WHEN 1 then do:
          run comtar("7","24,##").
        end.
        WHEN 2 then do: /*уральск*/
          run comtar("7","24,##").
        end.
        WHEN 3 then do: /*атырау*/
            run comtar("7","24,ju,ph").
        end.
        WHEN 4 then do: /*Актобе*/
          run comtar("7","24,ju,ph").
        end.
        WHEN 5 then do:
          run comtar("7","24,##"). /*Караганда*/
        end.
        WHEN 6 then
        do:
          run comtar("7","24,##"). /*Талдыкорган*/
        end.
        OTHERWISE do:
          run comm-coms.
        end.
      end case.
      if return-value <> "" then
        doccomcode = return-value.
      if doccomcode = "24" then do:
        update
          v-vov-name
        with frame sfx.
        hide frame sfx.
        if trim(v-vov-name) = "" then do:
          message "Введите номер и дату выдачи документа" view-as alert-box title "".
          undo,retry.
        end.
      end. else do:
        juridical_person = return-value = "ju".
      end.
      run choose_doccomcode_calc_and_displ_sums.
    end.



/*Main logic ------------------------------------------------------------------*/

do while do_while:

   do_while = false.

   dockts:label = "Дополнит.".
   num-for-realty:screen-value = "".
   num-for-realty:label = "".

   if newdoc then do:
        {stadsel.i}
        run ChooseType.
        if return-value = "" or return-value = ? then leave.
        docrnn = ''.
        find last bcommpl where bcommpl.date = g-today
                            and bcommpl.dnum > 0
                            and bcommpl.dnum < 10000
                            and bcommpl.txb = seltxb
                            and bcommpl.grp = selgrp
                          use-index datenum no-lock no-error.
        if avail  bcommpl then do:
                                  docnum = bcommpl.dnum + 1.
                                  find last bcommpl where bcommpl.date = g-today
                                                      and bcommpl.txb = seltxb
                                                      and bcommpl.grp = selgrp
                                                      and bcommpl.uid = userid ("bank")
                                                    use-index datenum no-lock no-error.
                                  if available bcommpl then do:
                                     docrnn = bcommpl.rnn.
                                     update docrnn:screen-value = docrnn with frame sf.
                                     apply "value-changed" to docrnn.
                                  end.
        end.
        else docnum = 1.
   end.
   else do:
        find commonpl where rowid(commonpl) = rid.
        assign
          seltxb    = commonpl.txb
          docnum    = commonpl.dnum
          doctype   = commonpl.type
          docnpl1   = trim(substring(commonpl.npl,1,40))
          docnpl2   = trim(substring(commonpl.npl,41,40))
          docnpl    = commonpl.npl
          docsum    = commonpl.sum
          doccomsum = commonpl.comsum
          docarp    = commonpl.arp
          docgrp    = commonpl.grp
          doctgrp   = commonpl.typegrp
          docrnnbn  = commonpl.rnnbn
          docrnn    = commonpl.rnn
          docfio    = commonpl.fio
          docadr    = commonpl.adr
          docfioadr = commonpl.fioadr
          dockbk    = string(commonpl.kb,"999999")
          doccomcode = commonpl.comcode
          colord    = commonpl.z
          docnumber = string(commonpl.accnt)
          dockts    = commonpl.info[2]
          num-for-realty:screen-value = commonpl.info[4] /*28/12/2005*/
          no-error.

        if trim(docfioadr) = "" then
          docfioadr = trim(docfio)  + ", " + trim(docadr).
        update docbn:screen-value = docbn  with frame sf.
        apply "value-changed" to docbik.

        update docrnn:screen-value = docrnn with frame sf.
        apply "value-changed" to docrnn.

        update dockts:screen-value = dockts with frame sf.
        apply "value-changed" to dockts.

        find first budcodes where budcodes.code = commonpl.kb no-lock no-error.
        if avail budcodes then
        v-budcode = budcodes.name.

        find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.type = doctype
             and commonls.visible = yes no-lock no-error.
        if avail   commonls then
           assign
            dockod = commonls.kod
            dockbe = commonls.kbe
            dociik = commonls.iik
            docbik = commonls.bikbn
            docbn  = commonls.bn
            no-error.

   end.

   if docrnnbn = "600700022288" then do:       /*28/12/05 РГП "Центр по недвижимости по г. Алматы" РНН "600700022288"*/
          num-for-realty:label = "Н.п.".
          dockts:label = "Ном. зак.".
   end.
   v_whole_sum = docsum + doccomsum.

   /* dpuchkov проверка реквизитов см тз 907 */
   /*доработка u00568 Evgeniy*/
   if newdoc then do:
     run rekvin_1(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod, output juridical_person).
     if not l-ind then return.
   end.



   display
            docnum
            g-today
            docnumber
            dockbk
            v-budcode
            docrnnbn
            docbik
            dociik
            dockod
            dockbe
            docnpl1
            docnpl2
            docsum
            doccomsum
            comchar
            colord
            dockts
        WITH side-labels FRAME sf.

   /*        docsum:screen-value = string(docsum). */
   /*        apply "value-changed" to docsum    in frame sf.*/
   apply "value-changed" to dockbk    in frame sf.
   apply "value-changed" to docnumber in frame sf.
   apply "value-changed" to docrnn    in frame sf.
   apply "value-changed" to docbn     in frame sf.
   apply "value-changed" to docbik    in frame sf.
   apply "value-changed" to docbn     in frame sf.
   apply "value-changed" to docsum    in frame sf.
   apply "value-changed" to doccomsum    in frame sf.
   apply "value-changed" to dockts    in frame sf.



   if newdoc then do:
     display
            v_whole_sum
     WITH side-labels FRAME sf.
     apply "value-changed" to v_whole_sum  in frame sf.
   end.

   /*
   if seltxb <> 0 then do:
     find first tarif2 where tarif2.num = '7' and tarif2.kod = doccomcode
                       and tarif2.stat = 'r' no-lock no-error.
     if available tarif2 then do:
           comchar = tarif2.pakalp.
           doccomsum = comm-com(docsum, tarif2.kod) * integer(colord).
           displ doccomsum comchar with frame sf.
      end.
   end.
   */
   if (newdoc or (commonpl.joudoc = ? and commonpl.comdoc = ? and commonpl.prcdoc = ? and commonpl.rmzdoc = ?)) then do:

     if not newdoc then do:
       find last bcommpl where bcommpl.txb = seltxb and
                         bcommpl.date = commonpl.date and
                         bcommpl.grp = selgrp
                         and bcommpl.dnum > 0
                         and bcommpl.dnum < 10000
                         use-index datenum no-lock no-error.
       if avail bcommpl then docnum = bcommpl.dnum + 1.
                        else docnum = 1.
       /*
       create oldb.
       buffer-copy commonpl to oldb.
       commonpl.chval[5] = "0".
       assign oldb.deldate = today
              oldb.deltime = time
              oldb.deluid = userid ("bank")
              oldb.delwhy = "Изменение реквизитов"
              oldb.deldnum = docnum.
       */
       commonpl_chval_5 = "0".
       oldb_deldate = today.
       oldb_deltime = time.
       oldb_deluid = userid ("bank").
       oldb_delwhy = "Изменение реквизитов".
       oldb_deldnum = docnum.
     end.

     if newdoc or candel then do:

       /* проверка на Уральские АРП счета телекома - ввод лицевого счета */
       if lookup (selarp, "250904324,250904625,250904926,250904269") > 0 then do:
          update
              docnumber
          WITH FRAME sf editing:
             readkey.
             apply lastkey.
             if frame-field = "docnumber" then
             apply "value-changed" to docnumber in frame sf.
          end.
       end.

       if (selarp = "000076261") or (selarp = "002076162") then do:
         update
             dockbk
         WITH FRAME sf editing:
             readkey.
             apply lastkey.
           if frame-field = "dockbk" then
             apply "value-changed" to dockbk in frame sf.
         end.
       end.

       if (selarp <> "000076261") or (selarp = "002076162") then do:

         update
             docbn
             docrnn
             docfioadr
             docsum
             lcom
             colord
             WITH FRAME sf editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "colord" then
                     apply "value-changed" to colord in frame sf.
                 if frame-field = "docsum" then
                     apply "value-changed" to docsum in frame sf.
                 if frame-field = "docbn" then
                     apply "value-changed" to docbn in frame sf.
                 if frame-field = "docrnn" then
                     apply "value-changed" to docrnn in frame sf.
             end.
       end.


       if (selarp = "000076261") or (selarp = "002076162") then do:
         dockts:label = "Поле КТС ".
         update
             docbn
             docrnn
             docfioadr
             docsum
             lcom
             colord
             dockts validate(trim(dockts) <> "","Поле обязательно для заполнения!")
             WITH FRAME sf editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "colord" then
                     apply "value-changed" to colord in frame sf.
                 if frame-field = "docsum" then
                     apply "value-changed" to docsum in frame sf.
                 if frame-field = "docbn" then
                     apply "value-changed" to docbn in frame sf.
                 if frame-field = "docrnn" then
                     apply "value-changed" to docrnn in frame sf.
                 if frame-field = "dockts" then
                     apply "value-changed" to dockts in frame sf.
             end.
       end.
       /*u00568 28/12/05*/
       if docrnnbn = "600700022288" then do: /*РГП "Центр по недвижимости по г. Алматы" РНН "600700022288"*/
         enable dockts with frame sf.
         enable num-for-realty with frame sf.
         num-for-realty:label = "Н.п.".
         dockts:label = "Ном. зак.".
         update
           num-for-realty validate(trim(num-for-realty) <> "", "Поле ""Номер продразделения"" обязательно для заполнения!")
           dockts validate(trim(dockts) <> "", "Поле ""Номер заказа"" обязательно для заполнения!")
             WITH FRAME sf editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "dockts" then
                     apply "value-changed" to dockts in frame sf.
                 if frame-field = "num-for-realty" then
                     apply "value-changed" to num-for-realty in frame sf.
             end.
       end.
     end.
     else
     update
       docbn
       lcom
       /*colord*/
       WITH FRAME sf editing:
           readkey.
           apply lastkey.
           if frame-field = "colord" then
               apply "value-changed" to colord in frame sf.
           if frame-field = "docbn" then
               apply "value-changed" to docbn in frame sf.
       end.

     if yes-no("","Сохранить?") then do:
     do transaction:
         if commonpl_chval_5 <> "" then do:
           create oldb.
           buffer-copy commonpl to oldb.
           assign
              commonpl.chval[5] = commonpl_chval_5
              oldb.deldate = oldb_deldate
              oldb.deltime = oldb_deltime
              oldb.deluid = oldb_deluid
              oldb.delwhy = oldb_delwhy
              oldb.deldnum = oldb_deldnum.
         end.
         do:
           if newdoc then
             CREATE commonpl no-error.

           if newdoc then do:
              commonpl.credate = today.
              commonpl.cretime = time.
              commonpl.dnum    = docnum.
              commonpl.rko     = get-dep(userid("bank"), g-today).
              commonpl.uid     = userid("bank").
           end.
           else do:
              commonpl.rko     = get-dep(commonpl.uid, g-today).
              commonpl.dnum    = docnum.
              commonpl.euid    = userid ("bank").
              commonpl.edate   = today.
              commonpl.etim    = time.
           end.

           if docarp <> "000076261" and docarp <> "002076162" and doccomcode = "24" and trim(v-vov-name) = "" then do:
             message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
             undo,retry.
           end. else do:
             commonpl.info[3] = v-vov-name.
             run update_rnn_for_veteran.
           end.
           assign
              commonpl.sum     = docsum
              commonpl.date    = g-today
              commonpl.kb      = integer(dockbk)
              commonpl.accnt   = integer(docnumber)
              commonpl.txb     = seltxb
              commonpl.type    = doctype
              commonpl.comsum  = doccomsum
              commonpl.arp     = docarp
              commonpl.grp     = docgrp
              commonpl.typegrp = doctgrp
              commonpl.valid   = rnnValid
              commonpl.npl     = docnpl
              commonpl.rnn     = docrnn
              commonpl.rnnbn   = docrnnbn
              commonpl.fio     = docfio
              commonpl.adr     = docadr
              commonpl.fioadr  = docfioadr
              commonpl.comcode = doccomcode
              commonpl.info[1] = if colord > 1 then "Плательщиков = " + string(colord) else ""
              commonpl.z       = colord
              commonpl.info[2] = dockts
              commonpl.info[4] = string(num-for-realty) /*28/12/05*/
              no-error.

              if docrnnbn = "600700022288" then
               commonpl.info[4] = string(num-for-realty). /*28/12/05*/


           cret = string(rowid(commonpl)).
           rids = rids + cret.
         end.
       end. /* transaction */
     end.
   end.     /* While */

   /*
    if newdoc then do:
        MESSAGE "Создать еще один?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Стан.Диаг." UPDATE do_while.
    end.
    */
   do_while = false.
   find current commonpl no-lock.
   s-rnn = docrnn.
END.

hide frame sf.
if rids <> "" then do:
    if canprn then do:
       case yes-no("","Распечатать Извещение/Квитанцию?"):
           when true then do:
             if docrnnbn = "600700022288" then  do:
               /*u00568 16/01/06  РГП "Центр по недвижимости по г. Алматы" РНН "600700022288"*/
               find first commonls where commonls.txb = seltxb
                                     and commonls.grp = commonpl.grp
                                     and commonls.type = commonpl.type
                                     and commonls.rnnbn = commonpl.rnnbn
                                   no-lock no-error.
                 if avail commonls then
                   s_rid = commonls.bn.
                 else
                   s_rid = "".
                 s_payment = string(commonpl.dnum) + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT" .
                 run bks(s_payment,"NO" + "#" + commonpl.rnnbn + "#" + s_rid + "#" + commonpl.rnn + "#" + commonpl.fioadr ).
                 /*s_rid = string(commonpl.dnum).*/
             end. else
               run stadkvit(rids).
               /*if commonpl.arp = "010904705" or
                  commonpl.arp = "000076575" or
                  commonpl.arp = "010904514" or
                  commonpl.arp = "010904307" or
                  commonpl.arp = "010904404" or
                  commonpl.arp = "250904829" or*/   /* Для филиала в г. Уральск - Управление Водоканала */
                  /*commonpl.arp = "250904324" or*/   /* О А О Жайыктеплоэнерго */
                  /*commonpl.arp = "250904227" or*/   /* Р К П Спецавтобаза */
                  /*commonpl.arp = "250904625" or*/  /* О А О Уральскэнерго */
                  /*commonpl.arp = "250904269" then*/ /* еще один горячий Уральский платеж */
                 /*run stadkvit2(rids).
               else
                 run stadkvit(rids).*/
           end.
       end case.

    end.

   case yes-no("","Распечатать ордер?"):
      when true then do:
        find first commonls where commonls.txb = seltxb and commonls.grp = selgrp
                              and commonls.type = doctype no-lock no-error.

        /* saltanat запоминаем КОД, КБЕ, КНП для передачи на печать */
        if avail commonls then do:
          assign
                KOd_ = commonls.kod
                KBe_ = commonls.kbe
                KNp_ = commonls.knp
          no-error.
          run stadprn(rids, KOd_, KBe_, KNp_).
        end.
      end.
    end case.
end.

return cret.

procedure ChooseType.

 DEFINE QUERY q1 FOR commonls.

 def browse b1
    query q1 no-lock
    display
        commonls.type   format '>>>9'
        commonls.bn     label "Получатель" format 'x(15)'
        commonls.npl    label "Назначение платежа" format 'x(40)'
        commonls.sum    label "Сумма"  format ">>,>>9.99"
        with no-labels 15 down title "Выберите вид платежа".

 def frame fr1
    b1
    with centered overlay view-as dialog-box.

 on return of b1 in frame fr1
    do:
      rid = rowid(commonls).
      find first commonls where rowid(commonls) = rid no-lock no-error.

       assign
         seltxb     = commonls.txb
         doctype    = commonls.type
         docnpl     = commonls.npl
         docnpl1    = trim(substring(commonls.npl,1,40))
         docnpl2    = trim(substring(commonls.npl,41,40))
         docsum     = commonls.sum
         doccomsum  = commonls.comsum
         docbn      = commonls.bn
         docbik     = commonls.bikbn
         dockod     = commonls.kod
         dockbe     = commonls.kbe
         docarp     = commonls.arp
         docgrp     = commonls.grp
         doctgrp    = commonls.typegrp
         docrnnbn   = commonls.rnnbn
         dociik     = commonls.iik
         dockbk     = string(commonls.kbk)
         no-error.

         dockts = "".

        find first bankl where bankl.bank = string(docbik) USE-INDEX bank no-lock no-error.
        if avail bankl then docbank = bankl.name.
        apply "value-changed" to docbik in frame sf.

       apply "endkey" to frame fr1.
    end.
        
 open query q1 for each commonls where commonls.txb = seltxb and commonls.visible = yes and commonls.grp = selgrp and
                                       commonls.arp = selarp use-index type no-lock.

   b1:SET-REPOSITIONED-ROW (7, "CONDITIONAL").
   ENABLE all with frame fr1.
   if (not candel) and (not newdoc) then disable docrnn docsum with frame sf.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR endkey of frame fr1.

 hide frame fr1.
 return "ok".
end.

procedure update_rnn_for_veteran:
  if v-vov-name<> '' then do:
    do transaction:

      find comm.rnn where rowid(rnn) = rid_rnn.
      if comm.rnn.trn = docrnn then do:
        assign
          comm.rnn.info[1] = vov_str + v-vov-name
        no-error.
      end.
    end. /* transaction */
  end.
end.


procedure choose_doccomcode_calc_and_displ_sums:
      if doccomcode <> "24" then do:
        doccomcode = get_tarifs_common(seltxb, selgrp, docrnnbn, juridical_person).
      end.
      /* calc_and_displ_sums считаем и выводим суммы */
      doccomsum = comm-com-1( (docsum / colord) , doccomcode, "7", comchar) * colord.
      v_whole_sum = docsum + doccomsum.
      displ
        doccomsum
        v_whole_sum
        comchar
      with frame sf.
end.
