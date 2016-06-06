/* pensin.p
 * MODULE
       Пенсионные платежи
       И
       Социальные отчисления
 * DESCRIPTION
       Процедура регистрации пенсионных платежей
 * AUTHOR
        13/01/05 kanat
 * CHANGES
        24/01/05 kanat - добавил обязательный ввод месяца и года
        14/02/05 kanat - переделал обработку количества вкладчиков и снятие комисиий
        29/03/05 kanat - добавил обязательный ввод номеров телефонов для клиентов
        14/04/05 kanat - поменял тарифы при приеме платежей
        09.12.2005 u00121 - добавил поля для Акта изъятия денег по юридическим лицам согласно ТЗ ї 137 от 29/08/2005 г., для этого задействовано дополнительное поле которое
                                сохраняется в commonpl.info[2]
        12/12/2005 u00568 (Евгений) - проверка на соответствие, чтобы с одного плательщика не сняли больше 1380 теньге. (ТЗ ї156 от 31/10/2005 "Ввод ограничения по сумме в модуле приема социальных отчислений")
        14/12/2005 u00568 (Евгений) - разрешаем вводить 2005 и 2006 год по ТЗ ї195 от 13/12/2005 "прием социальных платежей за 2006"
         2/02/2006 u00568 (Евгений) - (ТЗ ї156 от 31/10/2005 "Ввод ограничения по сумме в модуле приема социальных отчислений") 1380 заменил на sysc.sysc = "max_limit_for_one_payer"
        17/02/2006 u00568 (evgeniy) - (служебная записка от 17/02/06 от ДРР Идоятовой) снять блокировку  от юридичесских лиц
        07/03/2006 u00568 (evgeniy) - добавил возможность введения льготного тарифа для платежей согласно Акту изъятия денег у налогового инспектора
                                    оптимизировал транзакцию
        28/03/2006 u00568 Evgeniy чтобы верно считало количество вкладчиков
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
        30/06/06 u00568 Evgeniy - по тз 369 пенсионные платежи отправляем в ГЦВП + оптимизация
        05/07/06 u00568 Evgeniy - добавил подсказку - как вводить новые РНН, переделал определение юр/физ по РНН  + оптимизация.
        07/07/06 u00568 Evgeniy - убрал лишний message. исправил ошибки просмотра.
        28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
*/
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{yes-no.i}
{comm-com.i}
{comm-rnn.i}
{getfromrnn.i}


def var num-nk as char format "x(20)" label "Изъятие денег согласно акта N".
def var fio-nk as char format "x(31)" label "от инспектора  НК ".

define shared variable g-ofc as character.

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter is_it_pens as integer.  /*0 - платежи в ГЦВП*/ /*1 - платежи в пенсионный фонд*/

def var vpens_or_soc as char init "010,019,013". /*КНП - как пенсионные платежи, остальные считаются социальными*/

define buffer oldb for commonpl.

def var v-dep-code as integer.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then canprn = yes.

/*u00568 Evgeniy максимальный предел платежа на одного человека по ТЗ 156*/
define variable max_limit_for_one_payer as dec initial 0.
find last sysc where sysc.sysc = "mlfop" no-lock no-error.
if available sysc then max_limit_for_one_payer = sysc.deval.

def var do_while as logical init true.
def var evnt as logical initial false.
def var mark as int.
def var cret as char init "".
def var rnnlg as logical.

def new shared var numtns as integer init 0.
/*def new shared var riddolg as char init "0x000000000".*/

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
def shared var docrnnnk as char format "x(12)".
def shared var docrnnbn as char format "x(12)".
def shared var docnpl   as char format "x(120)".
def shared var docnum   as integer format ">>>>>>>9".
def shared var docgrp   as integer.
/*def shared var doctgrp  as integer.*/
def shared var docarp   as char    format "x(10)".
def shared var docsum      as decimal format ">>,>>>,>>9.99".

def shared var docknp   as char format "x(3)".

def shared var doccomsum   as decimal format ">,>>9.99".
def var doccomcode  like commonpl.comcode init '27'.
def shared var docprc   as integer  format "9.9999". /* Процент с АРП */
def shared var bsdate   as date.
def shared var esdate   as date.
def shared var selgrp   as integer init 1. /* Платежи станции диагностики */
def shared var docnumber as char.
def shared var dockts as char init "".

def shared var docphone as char format "x(20)".

def var s-rnn    as char init "".
def var rids     as char initial "".
def var nkname   as char.
def var sumchar  as char.
def var sumchar1 as char.
def var docnpl1  as char format "x(40)".
def var docnpl2  as char format "x(40)".
def var sumchar2 as char.
def var comchar  as char.

def shared var doctypegrp as integer format "99". /* месяц для соц. отчислений */
def shared var doccounter as integer format "9999". /* год для соц. отчислений */

def var v-budcode as char.

def var lcom as logical init false no-undo.
def var colord as int init 1 format "zzz9".
def var cdate as date init today.

def var s_rid as char.
def var s_payment as char.

define variable candel as log.
def var v-whole-sum as decimal.

def var KOd_ as char.
def var KBe_ as char.
def var KNp_ as char.

{rekv_pl.i}

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

define buffer bcommpl for commonpl.

def var v-vov-name as char init "".
def var v-vov-number as char init "".
def var lis_it_pens as logical no-undo.

def var valrnn as char init "Не верный контрольный ключ ???!".

lis_it_pens = is_it_pens = 1.
doccomcode = get_tarifs_common(seltxb, selgrp, string(is_it_pens), false).

    function chkrnn returns logical:
      def var result_rnn as logical init false.
      IF  rnnValid
          or
          (  length(docrnn) = 12 and yes-no("", "РНН не найден в справочнике.~nЧтобы редактировать РНН - нажмите F<3>.~nПродолжить с введенным РНН?")
             and
             not comm-rnn (docrnn)
          )
      then result_rnn = true.
      else result_rnn = false.

      if is_it_jur_person_rnn(docrnn) and lookup(docknp, "010,019") > 0 then do:
        message 'КНП ''010'' и ''019'' нельзя принимать от Юр. Лиц.' view-as alert-box title "!!!".
        return(false).
      end.
      return( ( rnnValid or
                length(docrnn) = 12 and result_rnn
               )  and
               (not comm-rnn (docrnn))
            ).
    end function.


def frame sfx
     "Номер акта изъятия денег и Ф.И.О. налогового инспектора" skip
     "----------------------------------------------------"  skip
     v-vov-number  label "Номер Акта  : "  format "x(45)"
     v-vov-name  label   "Ф.И.О. инсп.: "  format "x(45)"
     with side-labels centered view-as dialog-box.


def frame sf
    g-today         view-as text                       label " Дата"
    docnum          view-as text format '>>>>>9'       label " Номер квитанции"
    docbn           view-as text format 'x(42)'     no-label                         at 10
    dockbe          view-as text format 'x(2)'         label "КБе"                   at 54
    docrnnbn        view-as text format 'x(12)'        label "РНН"                   at 62 skip
    docbank         view-as text format "x(35)"        label "Наименование банка"    at 10 skip
    dociik          view-as text                       label "ИИК бенефициара"       at 10
    docbik          view-as text                       label "            БИК"       at 50 skip
    docknp          view-as text format 'x(3)'         label "КНП"                   at 10
    doctypegrp                   format '99'           label "Месяц"
validate (doctypegrp <> 0 and doctypegrp >= 1 and doctypegrp <= 12, "Неверный месяц")
    doccounter                   format '9999'         label "Год"                   validate (doccounter <> 0 and ( doccounter = 2005  or doccounter = 2006) , "Неверный год") skip
    docrnn                       format "999999999999" label "РНН Отправителя денег" validate (chkrnn(), valrnn) at 10 help "F2 - ПОИСК,  F3 - РЕДАКТИРОВАНИЕ"
    dockod          view-as text format "x(2)"         label "Koд "             at 62 skip
    docfioadr                    format "x(55)"        label "ФИО, Адрес "  validate (not (trim(docfioadr) = '' or docfioadr = ?), "Неверный ФИО плательщика!") at 10 skip
    docphone  validate (trim(docphone) <> "", "Неверный номер телефона!")       format "x(20)"        label "Номер телефона"   at 10 skip
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
    "Комиссия" at 10 lcom        format ":/:"       no-label
    comchar         view-as text format 'x(30)'     no-label
    doccomsum       view-as text format ">>>,>>9.99"   label "Сумма комиссии"  skip
    v-whole-sum  at 10 view-as text format ">>>,>>>,>>9.99"   label "Сумма + комиссия"
    colord  validate (colord > 0, "Неверное количество плательщиков!") label "Количество" skip
    dockts at 10  format "x(60)" label "Дополн."
    with side-labels centered.


    on help of lcom in frame sf do:
        run comtar("7","42,##").
        if return-value <> "" then do:
          doccomcode = return-value.
        end.
        if doccomcode = "42" then do transaction:
          update
            v-vov-number
            v-vov-name
          with frame sfx.
          hide frame sfx.
          if trim(v-vov-name) = "" then do:
            message "Введите ФИО Инспектора" view-as alert-box title "Внимание".
            undo,retry.
          end.
          if trim(v-vov-number) = "" then do:
            message "Введите номер документа" view-as alert-box title "Внимание".
            undo,retry.
          end.
          v-vov-number = trim(v-vov-number).
          v-vov-name = trim(v-vov-name).
        end.
        apply "value-changed" to docsum in frame sf.
    end.


    on value-changed of docsum in frame sf do:
        docsum = decimal(docsum:screen-value).
        run Sm-vrd(docsum, output sumchar).
        sumchar = sumchar + ' тенге ' +
          string(int((docsum - int(docsum)) * 100)) + " тиын".
        if length(sumchar) > 50 then do:
            mark = R-INDEX(sumchar, " ", 50).
            sumchar1 = SUBSTR(sumchar,1, mark).
            sumchar2 =  SUBSTR(sumchar, mark + 1).
        end.
        else do:
            sumchar1 = sumchar.
            sumchar2 = "".
        end.
        if doccomcode <> "42" then do:
          doccomcode = get_tarifs_common(seltxb, selgrp, '', false).
        end.
        doccomsum = comm-com-1(docsum, doccomcode, "7", comchar) * colord.
        v-whole-sum = docsum + doccomsum.
        displ
          doccomsum
          v-whole-sum
          sumchar1
          sumchar2
          comchar
        with frame sf.
        apply "value-changed" to self.
    end.


    on value-changed of docrnn in frame sf do:
      update docrnn  =  docrnn:screen-value with frame sf.
      docFIO    = caps(getfio1(docrnn)).
      docADR    = caps(getadr1(docrnn)).
      docfioadr = docfio + ", " + docadr.
      rnnValid  = not (docfioadr = ', ').
      update docfioadr:screen-value = docfioadr with frame sf.
    end.


    on return of docrnn in frame sf do:
      apply "value-changed" to docrnn in frame sf.
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
        apply "value-changed" to docrnn in frame sf.
    end.



    on "enter-menubar" of docrnn in frame sf do:
       if not comm-rnn (docrnn) and length(docrnn) = 12 then
       do:
       if yes-no ("", "Редактировать РНН " + docrnn + " ?") then
       do:
          run taxrnnin (docrnn).
          apply "value-changed" to docrnn in frame sf.
       end.
       end.
       else message "Не верный РНН!~nНельзя редактировать!" view-as alert-box title "".
    end.

   on help of docbn in frame sf do:
        run ChooseType.

        docsum:screen-value = string(docsum).
        apply "value-changed" to self.
        apply "value-changed" to docbik.
        apply "value-changed" to docknp.
        apply "value-changed" to docsum.

        disp g-today docnum docrnnbn docbik docknp doctypegrp doccounter dociik dockod dockbe docnpl1 docnpl2 doccomsum
        with frame sf.
    end.

    on value-changed of docbik in frame sf do:
        find first bankl where bankl.bank = string(docbik) USE-INDEX bank no-lock no-error.
        if avail bankl then update docbank = bankl.name.
        apply "value-changed" to self.
        disp docbik docbank with frame sf.
    end.

    on value-changed of colord in frame sf do:
      if integer(colord:screen-value) >= 1 then do:
        doccomsum = doccomsum / colord no-error.
        colord = integer(colord:screen-value).
        doccomsum = doccomsum * colord.
        v-whole-sum = docsum + doccomsum.
        displ
          doccomsum
          v-whole-sum
        with frame sf.
      end.
    end.

    on value-changed of dockts in frame sf do:
        dockts = dockts:screen-value.
        apply "value-changed" to dockts.
    end.



/*Main logic ------------------------------------------------------------------*/

    doctypegrp = 0.
    doccounter = year(g-today).

if newdoc then do:
  do while do_while:
     do_while = false.
     colord = 1.
     /*doccounter = 2005.*/
     {pens_sel.i}
     run ChooseType.
     if return-value = "" or return-value = ? then
       return.
     docrnn = ''.
     find last bcommpl where bcommpl.date = g-today and bcommpl.dnum < 1000000 and bcommpl.txb = seltxb
                       and bcommpl.grp = selgrp use-index datenum no-lock no-error.
     if avail bcommpl then do:
       docnum = bcommpl.dnum + 1.
       find last bcommpl where bcommpl.date = g-today and
                               bcommpl.txb = seltxb and
                               bcommpl.grp = selgrp and
                               bcommpl.uid = userid ("bank")
                               use-index datenum no-lock no-error.
       if available bcommpl then do:
          docrnn = bcommpl.rnn.
          update docrnn:screen-value = docrnn with frame sf.
          apply "value-changed" to docrnn.
       end.
     end. else
       docnum = integer(string(v-dep-code,"99") + "0001").
     run displ_all.
     run update_all.

     if yes-no("", "Сохранить?") then do:
       do transaction:
         CREATE commonpl no-error.
         run save_all.
       end. /* transaction */
     end.
     else leave.
     do_while = false.
  END. /* While */
end. else do:
  /*------------------------------------------------------------------*/
  do while do_while:
    do transaction:
       do_while = false.
       do:
            find commonpl where rowid(commonpl) = rid exclusive-lock no-error.
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
              doctypegrp = commonpl.typegrp
              doccounter = commonpl.counter
              docrnnbn  = commonpl.rnnbn
              docrnn    = commonpl.rnn
              docfio    = commonpl.fio
              docadr    = commonpl.adr
              docfioadr = commonpl.fioadr
              dockbk    = string(commonpl.kb,"999999")
              doccomcode = commonpl.comcode
              colord   = commonpl.z
              docnumber = string(commonpl.accnt)
              dockts    = commonpl.info[2]
              docphone  = commonpl.chval[4]
              lis_it_pens = commonpl.abk = 1
              no-error.

            if trim(docfioadr) = "" then
              docfioadr = trim(docfio)  + ", " + trim(docadr).
            update docbn:screen-value = docbn  with frame sf.
            apply "value-changed" to docbik.
            /*
            update docrnn:screen-value = docrnn with frame sf.
            apply "value-changed" to docrnn.
            */
            update doctypegrp:screen-value = string(doctypegrp) with frame sf.
            apply "value-changed" to doctypegrp.

            update doccounter:screen-value = string(doccounter) with frame sf.
            apply "value-changed" to doccounter.

            find first budcodes where budcodes.code = commonpl.kb no-lock no-error.
            if avail budcodes then
              v-budcode = budcodes.name.

            find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.type = doctype no-lock no-error.
            if avail   commonls then
              assign
                dockod = commonls.kod
                dockbe = commonls.kbe
                dociik = commonls.iik
                docknp = commonls.knp
                docbik = commonls.bikbn
                docbn  = commonls.bn
              no-error.

       end.
       run displ_all.

       if (commonpl.joudoc = ? and commonpl.comdoc = ? and commonpl.prcdoc = ? and commonpl.rmzdoc = ?) then do:
          if candel then do:
            run update_all.
          end. else
            update
                docbn
                lcom
                colord
                WITH FRAME sf editing:
                    readkey.
                    apply lastkey.
                    if frame-field = "colord" then
                        apply "value-changed" to colord in frame sf.
                    if frame-field = "docbn" then
                        apply "value-changed" to docbn in frame sf.
                end.

          if yes-no("", "Сохранить?") then do:
            /*do transaction:*/
              run save_all.
            /*end.*/ /* transaction */
          end.
          else leave.
       end.
       do_while = false.
    END. /* transaction */
  END. /* While */
end.

if avail commonpl then do:
  find current commonpl no-lock.
end.
s-rnn = docrnn.

hide frame sf.
if rids <> "" then do:
    if canprn and yes-no("", "Распечатать Извещение/Квитанцию?") then
      run penskvit(rids).

    if yes-no("", "Распечатать ордер?") then do:
        find first commonls where commonls.txb = seltxb and commonls.grp = selgrp
                              and commonls.type = doctype no-lock no-error.
        /* saltanat запоминаем ??", ??:, ??? длЯ передачи на печать */
        if avail commonls then do:
          assign
                KOd_ = commonls.kod
                KBe_ = commonls.kbe
                KNp_ = commonls.knp
          no-error.
          run pensprn(rids, KOd_, KBe_, KNp_).
        end.
    end.
end.
return cret.


/*---------------------------------------------------------------------------------*/

procedure update_all.
  REPEAT:
    update
       docbn
       doctypegrp
       doccounter
       docrnn
       docfioadr
       docphone
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
    if doccomcode = '42' then do:
      dockts = "Изъятие денег согласно акта N " + v-vov-number + " от инсп. НК " + v-vov-name.
    end.
       /*9/12/20005  evgeniy (u00568) по тз ї 156 от 31.10.2005*/
    if max_limit_for_one_payer <> 0
           and decimal(docsum:screen-value) / decimal(colord:screen-value) > max_limit_for_one_payer
           and not lis_it_pens
    then
    do:
       MESSAGE "Оплата платежей в ГЦВП по социальным отчислениям на одного плательщика не должна превышать " + string(max_limit_for_one_payer) + "тг. в месяц."
       VIEW-AS ALERT-BOX
       TITLE "Ограничение " + string(max_limit_for_one_payer) + "тг."   .
     end. else
       LEAVE.
  END. /* REPEAT  */
end.

/*---------------------------------------------------------------------------*/
procedure save_all.
  if newdoc then do:
     commonpl.credate = today.
     commonpl.cretime = time.
     commonpl.dnum    = docnum.
     commonpl.rko     = get-dep(userid("bank"), g-today).
     commonpl.uid     = userid("bank").
  end. else do:
     commonpl.rko     = get-dep(commonpl.uid, g-today).
     commonpl.dnum    = docnum.
     commonpl.euid    = userid("bank").
     commonpl.edate   = today.
     commonpl.etim    = time.
  end.
  assign
     commonpl.date    = g-today
     commonpl.kb      = integer(dockbk)
     commonpl.accnt   = integer(docnumber)
     commonpl.txb     = seltxb
     commonpl.type    = doctype
     commonpl.sum     = docsum
     commonpl.comsum  = doccomsum
     commonpl.arp     = docarp
     commonpl.grp     = docgrp
     commonpl.typegrp = doctypegrp
     commonpl.counter = doccounter
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
     commonpl.chval[4] = docphone
     commonpl.abk = integer(lis_it_pens)
     no-error.

  cret = string(rowid(commonpl)).
  rids = rids + cret.
end.


/*---------------------------------------------------------------------------*/
procedure displ_all.
   display
            docnum
            g-today
            docrnnbn
            docrnn
            docbik
            docknp
            doctypegrp
            doccounter
            dociik
            dockod
            docphone
            dockbe
            docnpl1
            docnpl2
            docsum
            doccomsum
            v-whole-sum
            comchar
            colord
            dockts
   WITH side-labels FRAME sf.
   apply "value-changed" to docrnn    in frame sf.
   apply "value-changed" to docbn     in frame sf.
   apply "value-changed" to docbik    in frame sf.
   apply "value-changed" to docknp    in frame sf.
   apply "value-changed" to doctypegrp in frame sf.
   apply "value-changed" to doccounter in frame sf.
   apply "value-changed" to docbn     in frame sf.
   apply "value-changed" to docsum    in frame sf.
   apply "value-changed" to dockts    in frame sf.
   apply "value-changed" to docphone  in frame sf.
end.

/*---------------------------------------------------------------------------*/
procedure ChooseType.
  DEFINE QUERY q1 FOR commonls.
  def browse b1
  query q1 no-lock
  display
        commonls.type   format '>9'
        commonls.bn     label "Получатель" format 'x(15)'
        commonls.npl    label "Назначение платежа" format 'x(50)'
  with no-labels 15 down title "Выберите тип платежа".

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
         docknp     = commonls.knp
         dockod     = commonls.kod
         dockbe     = commonls.kbe
         docarp     = commonls.arp
         docgrp     = commonls.grp
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

  open query q1 for each commonls where commonls.txb = seltxb and commonls.visible = no and commonls.grp = selgrp and lis_it_pens = (lookup(commonls.knp,vpens_or_soc) > 0)  no-lock.

    b1:SET-REPOSITIONED-ROW (7, "CONDITIONAL").
    ENABLE all with frame fr1.
    if (not candel) and (not newdoc) then disable docrnn docsum with frame sf.
    apply "value-changed" to b1 in frame fr1.
    WAIT-FOR endkey of frame fr1.

  hide frame fr1.
  return "ok".
end.
