 /* taxin.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Прием налоговых платежей
 * RUN

 * CALLER
        taxlist
 * SCRIPT

 * INHERIT

 * MENU
        п.3.2.10.10.4 и 3.1.5.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        31/07/02 sasco - можно править базу РНН во всех филиалах (в смысле, добавлять новые записи)
        09/09/03 Kanat - автоматическая печать чека БКС при сохранении квитанции в очереди на сохранение
        17/09/03 sasco - отключил редактирование РНН для головного офиса
        23.09.03 sasco изменять платеж может только менеджер из sysc."COMDEL".chval
        08.10.2003 sasco откорректировал изменение платежей
        09.10.2003 sasco автоматическая печать квитанций
        10.10.2003 sasco запрос на квитанцию через "canprn"
        15.10.2003 kanat перенес печать чека БКС в taxkvit
        21.10.2003 sasco убрал запрос на создание еще одного платежа (choice2)
        12.12.2003 sasco перенос fio в chval[1]
        29.01.2004 kanat добавил ввод КНП для платежей, убрал проверку на повторение КБК в одной квитанции, поставил проверку на
                         неповторение типа платежа на один КБК в одной строке.
        14/06/2004 kanat Убрал неправильный вывод комиссий для ЮЛ
        17/06/04 kanat перенес автоматическую печать квитанций в taxlist
        23/06/04 kanat вывод сумм с комиссией перед сохранением платежа на 1 или несколько КБ.
        08/09/04 kanat убрал проверку на ввод отправителем РНН НК
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        11.02.2005 kanat - автоматическое снятие комиссий в зависимости от КБК с возможностью ее накапливания в одной
                           квитанции в по нескольким КБК, а также обработка льготных тарифов для участников ВОВ
                           с записью реквизитов ветеранов ВОВ по всем КБК кроме таможенных ...
                           а также предусмотрен выбор бесплатных услуг для платежей не ОМП, не для регистрации и не таможенных платежей
                           выбор льготных тарифов для прочих КБК ...
         16.02.2005 kanat - перенес выбор кодов комиссий под КБК
         28.03.2005 kanat - убрал лишние message чтобы не нервировать юзеров
         15.04.2005 kanat - добавил проверку по КБК 204105 на поле Дополнительно,
                            уничтожил все share-lock
         20.04.2005 kanat - добавил проверку на 204105 на значение ?
         18.05.2005 kanat - добавил код КБК 204101 для кодов обработки ОМП и обработку код комиссии 28.
         30/11/2005 evgeniy - добавлен новый код по налоговым
         01/12/2005 marinav - для адм штрафов КБК 204105 новые комиссии
         12/12/05   marinav - добавила КБК = 106105
         13/02/06   u00568 Evgeniy - оптимизировал код, изменил списки КБК по ТЗ 188 от 30/11/2005 ДРР,
                    автоматизировал все филиалы по ТЗ 175 от 16/11/2005
                    изменение будет работать только с новым taxcom.i
         24/02/06 u00568 добавил раздел по юрикам и физикам.
                  нужен новый comm-com.i
                  добавил  льготный триф для для гаи в Уральске ТЗ 175
         27/02/06 u00568 Evgeniy - переделал сумма + комиссия
         28/02/06 u00568 Evgeniy - РНН! в справочник физ лиц РНН (rnn) в поле comm.rnn.info[1] = 'ВОВ, ветеран, номер уд. ' + v_vov_name
                       пишется номер удостоверения ВОВ, и при последующем платеже этого физика комиссия автоматом станет льготная.
         27/03/06 u00568 Evgeniy - Баг прогреса если {disable all with frame sf. ... enable all} то резидент не сохранялся
                                   и потому закоментировал.
         24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
         02/05/2006 u00568 Evgeniy - вместа 701 тарифа для инспектора НК создан специальный тариф 742
         04/05/2006 u00568 Evgeniy - по тз 328 от 03/05/2006 изменение тарифа в филиалах
         06/05/2006 u00568 Evgeniy - по тз XXX теперь сохраняет код комиссии

           11/05/2006 u00568 Evgeniy - по тз 328 от 03/05/2006 изменение тарифа в филиалах + теперь сохраняет код комиссии + СВЕРИЛСЯ С ОНЛАЙНОМ
           15/05/2006 u00568 Evgeniy - проверка на кбк 108101 по тз 334 от 11/05/2006 + навел красоту + вывел часть кода в процедуры, чтобы при компилении ошибок небыло.
           17/05/2006 u00568 Evgeniy - проверка на кбк 108101 по тз 334 от 11/05/2006
           18/05/2006 u00568 Evgeniy - проверка на кбк редкие КБК и запрос у клиента акцепта по тз 238 от 9/02/2006
           23/05/2006 u00568 Evgeniy - проверка на кбк недопустимые в алматинские налоговые по тз 302 от 06/04/2006. + оптимизация и исправление валидэйтов
           29/05/2006 u00568 Evgeniy - едмонобразие проверки на кбк и оптимизация процедуры.
           07/06/2006 u00568 Evgeniy - исправление ошибки при редактировании КБК введеной платежки
           08/06/2006 u00568 Evgeniy - предпринята попытка оптимизации и  исключения дублирующего кода. 16 часов убил
           08/06/2006 u00568 Evgeniy - исправил ошибку которая пояалялась при редактировании платежки с несколькими платежами - возникла она из- за сохранения кодов комиссий.
           14/06/2006 u00568 Evgeniy - немного соптимиЗИЛ
           15/06/2006 u00568 Evgeniy - нашел ошибку с льготниками, исправил
         15/06/2006 u00568 Evgeniy - в качестве сверки с офлайном перенес из офлайна изменения
         16/06/2006 u00568 Evgeniy - исправил баг - ввод РНН НК выдавал ошибки и мешал работать.
         23/06/2006 u00568 Evgeniy - исправил баг - если пришел ВОВ, то это снова сохраняется в базе РНН
         26/06/2006 u00568 Evgeniy - добавил в yes-no.i вопрос который нельзя оставить без ответа.
         31/08/2006 u00568 Evgeniy - Синхронизация с офлайном.
                                   + запрет редактирования документа принятого по акту изъятия тз 345
                                   + ТЗ 413 от 24/07/2006 дрр привязка комиссии по таможенным платежам
                                   + c табличками rnn и rnnu работает эффективнее
                                   + transaction
         04/09/2006 u00568 Evgeniy - не сохранялось фио если РНН не из базы РНН.
                                   + закрыл дырку, когда можно было не водить ФИО
         05/09/2006 u00568 Evgeniy - ДРР с ТЗ - не торопится, а кассиры мучаются, поэтому
                                   + открыл редактирование справочника РНН. раз уж всегда была такая возможность, то пусть и сейчас она будет. тем более что ТЗ о том как болжно быть в разработке у Ажар.
                                   + если РНН нет в базе РНН, но его все равно внесли, то при повторном создании документа пусть этот РНН и фамилия повторно подтягиваются.
         06/09/2006 u00568 Evgeniy + Талдыкорган
         07/09/2006 u00568 Evgeniy + Караганда
         08/09/2006 u00568 Evgeniy - disable ... enable - без этого форма сбоит. а с этим - сбрасывает все screen-value поэтому надо описывать on value-changed.
         11/09/2006 u00568 Evgeniy - КБК 301103 => запросить ещё инормацию. по ТЗ 335 от 11/05/2006 ДОП "Контроль за вводом КБК 301103"
                                   + вынес диалог из транзакции.
                                   + можно вернуться к редактированию - если что.
         12/09/2006 u00568 Evgeniy -  не обрабатывает заблокированные НК.
         13/09/2006 u00568 Evgeniy - по ТЗ 347 требует паспорт от нерезидентов.
         19/09/2006 u00568 Evgeniy - баг при поиске рнн
         26/09/2006 u00568 Evgeniy - поменял "обращайтесь в ДОП" на "обращайтесь в ДРР"
*/


  {comm-com.i}
  {taxcom_dop.i}
  {get-dep.i}
  {yes-no.i}
  {comm-txb.i}
  {comm-rnn.i}
  {getfromrnn.i}

  def var seltxb as int  no-undo.
  seltxb = comm-cod().

  define shared variable g-ofc as character.

  def input parameter g-today as date.
  def input parameter newdoc as logical.
  def input parameter rid as rowid.
  def input parameter alldoc as logical.

  /*def var choice2 as logical init true no-undo.*/
  def var evnt as logical initial false no-undo.
  def var mark as int no-undo.


  /* может запрашивать ордер или нет */
  define variable canprn as log initial no no-undo.
  find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
  if available sysc then
    if lookup (g-ofc, sysc.chval) > 0 then
      canprn = yes.

  def var update_mode as int init 0 no-undo.
  /* 0 - новый документ, который не отправленный */
  /* 1 - зачисленный на АРП, который смотрит гл. кассир */
  def var ukbn as logical init yes extent 5 no-undo. /* коды, которых первоначально не было вовсе введено */

  def new shared var tValidRnn as logical initial false no-undo.
  def new shared var fio as char no-undo.
  def new shared var docrnn  as char init "" no-undo.
  def new shared var docrnnnk as char no-undo.
  def new shared var docnum as integer init 0 no-undo.
  def var            doctns as integer init 0  no-undo.
  def new shared var kbchar as char extent 5 no-undo.
  def new shared var numtns as integer init 0 no-undo.
  def new shared var tsum   as decimal init 0 no-undo.
  def new shared var bsdate as date no-undo.
  def new shared var esdate as date no-undo.
  def new shared var riddolg as char init "0x000000000" no-undo.
  def var            doccolord as int init 1 no-undo.
  def var            docinfo as char no-undo.
  def var            doccomsum as decimal init 0 no-undo.
  def var            doccomcode as char.
  def var            alldoccomcodes as char no-undo.
  def var            docbud like  tax.bud extent 5 no-undo.
  def new shared var doccomu as logical init yes no-undo.
  def new shared var docresid as logical init yes no-undo.
  def var            docuid as char no-undo.
  def var            olddocnum as int init 0 no-undo.
  def var            wastns as logical extent 5 init no no-undo.
  def var juridical_person as logical init yes no-undo.
  docuid = userid ("bank").

  define variable candel as log no-undo.

  candel = yes.
  find sysc where sysc.sysc = "COMDEL" no-lock no-error.
  if available sysc then
    if lookup (userid("bank"), sysc.chval) = 0 then
      candel = no.

  def var doctaxdoc as char init ? no-undo.
  def var doccomdoc as char init ? no-undo.
  def var docsenddoc as char init ? no-undo.

  def var docrnn2 as char no-undo.

  /*def var s-rnn as char init "" no-undo.*/
  def var rids as char initial "" no-undo.
  def var nkname as char no-undo.

  def var sumchartmp  as char no-undo.
  def var sumchar1 as char no-undo.
  def var sumchar2 as char no-undo.
  def var comchar as char no-undo.
  def var ourbank as char no-undo.    /* Code of th bank TXB00 */
  def var ourcode as integer no-undo. /* Number of the branch 0 */
  def var kazna   as char no-undo.
  def var sumdec as decimal format "9.99" no-undo.

  def var lcom as logical init false no-undo.
  def var cdate as date no-undo.
  def var ctime as int no-undo.
  cdate = g-today.

  def var result_rnn as logic init true no-undo.
  def var result_rnnnk as logic init true no-undo.
  def var result_kb as logic extent 5 init true no-undo.
  def var err_rnn as char init "Не верный контрольный ключ РНН!" no-undo.
  def var errkb as char init "" no-undo.

  def var totsum as decimal format ">>,>>>,>>9.99" label "Итого" init 0 no-undo.

  def var kbud   as integer format "999999" extent 5 label "КБК" init 0 no-undo.
  def var temp_kbud as char format "999999" init 0 no-undo.
  def var oldsum as decimal format ">>,>>>,>>9.99" extent 5 label "Недоимка" init 0 no-undo.
  def var cursum1 as decimal format ">>,>>>,>>9.99" label "Сумма платежа" init 0 no-undo.
  def var cursum2 as decimal format ">>,>>>,>>9.99" label "Сумма платежа" init 0 no-undo.
  def var cursum3 as decimal format ">>,>>>,>>9.99" label "Сумма платежа" init 0 no-undo.
  def var cursum4 as decimal format ">>,>>>,>>9.99" label "Сумма платежа" init 0 no-undo.
  def var cursum5 as decimal format ">>,>>>,>>9.99" label "Сумма платежа" init 0 no-undo.
  def var fine1  as decimal format ">>,>>>,>>9.99" extent 5 label "Штраф" init 0 no-undo.
  def var fine2  as decimal format ">>,>>>,>>9.99" extent 5 label "Пеня" init 0 no-undo.
  def var knp  as integer format "999" extent 5 label "КНП" init 0 no-undo.

  def var err_knp as char no-undo.

  /*def var s_full_name as char no-undo.*/

  define buffer btax for tax.
  define buffer btaxnk for taxnk.
  /*
  def var v-dep-code as integer no-undo.

  find first sysc where sysc = "ofcstp" no-lock no-error.
  if avail sysc then
    v-dep-code = sysc.inval.
  else
    message "Отсутствуют параметры офицера" view-as alert-box title "".
  */
  ourbank = comm-txb().
  ourcode = comm-cod().

  def var i as int no-undo.
  def var i1 as int no-undo.


  def var v-comsum-temp as decimal no-undo.

  def var v-custom-kb as char no-undo.
  def var v-omp-kb as char no-undo.
  def var v-reg-kb as char no-undo.
  def var v_not_for_almaty_kb as char no-undo.
  def var v_almaty_docrnnnk as char no-undo.

  def var v-temp-com as decimal extent 5 init 0 no-undo.
  def var v-temp-tot as decimal extent 5 init 0 no-undo.
  def var v-icount as integer no-undo.

  v-custom-kb = "105102,105105,105106,105107,105255,105270,106101,106102,106103,106104,106201,106202,106203,106204,105241,105242,105243,105244,105245,105246,105247,105248,105250,106105". /*по таможенным платежам*/
  v-omp-kb    = "108105,108106,108107,108110,108112,204105".
  v-reg-kb    = "108111,108104,108108".
  v_not_for_almaty_kb = "104303,105103,105304,105310,105313,105422". /*кбк недопустимые в алматинские налоговые*/
  v_almaty_docrnnnk = "600". /*рнн алматинские налоговые, куда недопустимы кбк, недопустимые в алматинские налоговые*/

  def var v_vov_name as char init "" no-undo.
  def var cut_com as char no-undo. /* комиссия льготная */
  def var rid_rnn as rowid no-undo.
  def var vov_str as char init 'ВОВ, ветеран, номер уд. ' no-undo.


  def var fam3 as char init '' no-undo.
  def var nam3 as char init '' no-undo.
  def var otch3 as char init '' no-undo.
  def var Adr3 as char init '' no-undo.
  def var cost3 as char init '' no-undo.
  def var fio_n as char init '' no-undo.
  def var pass_n as char init '' no-undo.

  def frame sfx
  "Номер и дата выдачи удостоверения участника ВОВ" skip
  "----------------------------------------------------"  skip
  v_vov_name  label "Участник ВОВ"  format "x(45)"
  with side-labels centered view-as dialog-box.


  def frame sfd
  "Номер удостоверения и ФИО уполномоченного лица НК/ ГУВД" skip
  "----------------------------------------------------"  skip
  v_vov_name  label "НК/ ГУВД"  format "x(45)"
  with side-labels centered view-as dialog-box.

  def frame sf301103
  "Контроль за вводом КБК 301103" skip
  "----------------------------------------------------" skip
  fam3   label "*Фамилия                "  format "x(33)" skip
  nam3   label "*Имя                    "  format "x(33)" skip
  otch3  label " Отчество               "  format "x(33)" skip
  Adr3   label "*Адрес ПОКУПАЕМОГО жилья"  format "x(33)" skip
  cost3  label "*Полная стоимость жилья "  format "x(33)"
  with side-labels centered view-as dialog-box.

  def frame sf_n
  "Контроль за нерезидентами." skip
  "----------------------------------------------------" skip
  fio_n  label "ФИО             "  format "x(41)" skip
  pass_n label "Данные паспорта "  format "x(41)"
  with side-labels centered view-as dialog-box.


  def var v-cst-count as integer init 0 no-undo.
  def var v-others-count as integer init 0 no-undo.
  def var v-omp-count as integer init 0 no-undo.
  def var v-reg-count as integer init 0 no-undo.
  def var v-docm as decimal extent 5 init 0 no-undo.

  def var valKBK as char init 'Здесь нельзя ввести такой КБК!' no-undo.

  def var valdocinfo as char init 'ошибка в поле дополнительно!' no-undo.
  def var valdoccolord as char init 'Не верное количество плательщиков!' no-undo.
  def var valdocrnnnk as char init "РНН не найден в справочн. НК" no-undo.
  def var tire0 as char format "x(78)" init "------------------------------------------------------------------------------" no-undo.
  def var tire1 as char format "x(78)" init "------------------------------------------------------------------------------" no-undo.
  def var tire2 as char format "x(78)" init "------------------------------------------------------------------------------" no-undo.
  def var tire3 as char format "x(78)" init " КБК     Описание     Недоимка      Сумма         Штраф         Пеня      КНП " no-undo.

  function _is_kbk_from_list RETURNS logical (vkbk as int):
    return (lookup(string(vkbk,'999999'),'105402,105420,104402,104401,303101,201904,105315,105316,105308,101202') > 0).
  end.

  function chk2 returns logical (input vi as int):
    /*17/05/2006/ u00568 ТЗ 334*/
    if SUBSTRING(docrnnnk, 1, 3) = v_almaty_docrnnnk then
    do:
      if lookup(string(kbud[vi],'999999'),v_not_for_almaty_kb) > 0 then
        assign result_kb[vi] = false
          errkb = "Платежи по КБК " + string(kbud[vi],'999999') + " нельзя отправлять в Алматинские НК.".
      else
        assign result_kb[vi] = true.
    end.
    /* end 17/05/2006/ u00568*/
    if result_kb[vi] then
      valKBK = 'Здесь нельзя ввести такой КБК!'.
    else
      valKBK = errkb.

    return (
      (update_mode = 1 and kbud[vi] = 0 and ukbn[vi] and vi<>1)
      or (kbud[vi] = 0 and update_mode = 0 and vi<>1)
      or ( can-find (budcodes no-lock where budcodes.code = kbud[vi])
         and kbud[vi] <> 0
         and (update_mode = 0
              or (update_mode = 1 and not ukbn[vi])
              or vi = 1))) and result_kb[vi].

  end function.

  function chk_docinfo returns logical:
    def var ai as int no-undo.
    def var err_docinfo as log init true no-undo.

    /* для кода 204105 поле Дополнительно является обазтельным для заполнения */
    do ai = 1 to 5:
      if kbud[ai] = 204105 and (trim(docinfo) = "" or docinfo = ?) then
         assign
         err_docinfo = false
         valdocinfo = "для кода 204105 поле Дополнительно является обазтельным для заполнения!".
    end.
    return (err_docinfo).
  end function.


  function chk6 returns logical:
    return (can-find(first taxnk where taxnk.rnn = docrnnnk)).
  end function.

  function chk_knp returns logical (input vi as int):
    def var result_knp as logical init true no-undo.
    if knp[vi] <> 0 then
    do:
      find first codfr where codfr.codfr = 'spnpl' and codfr.code = string(knp[vi],"999") no-lock no-error.
      if avail codfr then
      do:
        result_knp = true.
      end.
      else
      do:
        message "КНП не найден" view-as alert-box title "!!!".
        assign
        result_knp = true
        err_knp = "Неправильный КНП".
      end.
    end.
    return(result_knp).
  end.

  function chk_rnn returns logical:
    IF  tValidRnn
         or
         ( length(docrnn) = 12
           and not comm-rnn (docrnn)
           /*and yes-no("", "РНН не найден в справочнике.~nЧтобы редактировать РНН - нажмите F<3>.~nПродолжить с введенным РНН?")*/
         )
         then result_rnn = true.
         else result_rnn = false.
    return( result_rnn ).
  end function.

  def frame sf
  docnum view-as text format '>>>>>9'     no-label
  nkname view-as text format 'x(50)' at 10 no-label
  docrnnnk label "РНН" validate( chk6() , valdocrnnnk) format "999999999999" at 62 skip
  doctns at 1 view-as text format '>>>>>>9' no-label
  "Наименование банка: " at 10
  kazna view-as text format "x(40)" no-label at 30 skip
  cdate no-label
  "ИИК бенефициара: " at 10
  btaxnk.iik view-as text format "999999999" at 27 no-label
  "          БИК: " at 40
  btaxnk.bik view-as text format "999999999" at 55 no-label skip
  docrnn at 10 label "РНН Отправителя денег" validate(chk_rnn(), err_rnn) format "999999999999" help "F2 - ПОИСК,  F3 - РЕДАКТИРОВАНИЕ"

  docresid label "    Резидент РК?" help "Признак резиденства (YES-резидент, NO-нет)" skip
  fio view-as text format "x(53)" label "ФИО, Адрес "     at 10 skip
  doccolord at 10 validate (doccolord > 0, valdoccolord) label "Количество плательщиков" format "zzz9" skip
  tire0 view-as text no-label skip
  tire3 view-as text no-label skip

  kbud[1] format '999999' no-label validate (chk2(1), valKBK) help "F2 - ВЫБОР"  '|'
  kbchar[1] view-as text no-label format "x(10)"    '|'
  oldsum[1] no-label format ">>>>>>>>9.99" help "Недоимка прошлых лет"
  cursum1 no-label format ">>>>>>>>9.99" help "Сумма платежей текущего года"
  fine1[1] no-label format ">>>>>>>>9.99" help "Штраф"
  fine2[1] no-label format ">>>>>>>>9.99" help "Пеня"
  knp[1] no-label validate (chk_knp(1), err_knp) help "КНП" skip

  kbud[2] format '999999' no-label validate (chk2(2), valKBK) help "F2 - ВЫБОР"  '|'
  kbchar[2] view-as text no-label format "x(10)"    '|'
  oldsum[2] no-label format ">>>>>>>>9.99" help "Недоимка прошлых лет"
  cursum2 no-label format ">>>>>>>>9.99" help "Сумма платежей текущего года"
  fine1[2] no-label format ">>>>>>>>9.99" help "Штраф"
  fine2[2] no-label format ">>>>>>>>9.99" help "Пеня"
  knp[2] no-label validate (chk_knp(2), err_knp) help "КНП"   skip

  kbud[3] format '999999' no-label validate (chk2(3), valKBK) help "F2 - ВЫБОР"  '|'
  kbchar[3] view-as text no-label format "x(10)"    '|'
  oldsum[3] no-label format ">>>>>>>>9.99" help "Недоимка прошлых лет"
  cursum3 no-label format ">>>>>>>>9.99" help "Сумма платежей текущего года"
  fine1[3] no-label format ">>>>>>>>9.99" help "Штраф"
  fine2[3] no-label format ">>>>>>>>9.99" help "Пеня"
  knp[3] no-label  validate (chk_knp(3), err_knp) help "КНП"   skip

  kbud[4] format '999999' no-label validate (chk2(4), valKBK) help "F2 - ВЫБОР"  '|'
  kbchar[4] view-as text no-label format "x(10)"    '|'
  oldsum[4] no-label format ">>>>>>>>9.99" help "Недоимка прошлых лет"
  cursum4 no-label format ">>>>>>>>9.99" help "Сумма платежей текущего года"
  fine1[4] no-label format ">>>>>>>>9.99" help "Штраф"
  fine2[4] no-label format ">>>>>>>>9.99" help "Пеня"
  knp[4] no-label  validate (chk_knp(4), err_knp) help "КНП"   skip

  kbud[5] format '999999' no-label validate (chk2(4), valKBK) help "F2 - ВЫБОР"  '|'
  kbchar[5] view-as text no-label format "x(10)"    '|'
  oldsum[5] no-label format ">>>>>>>>9.99" help "Недоимка прошлых лет"
  cursum5 no-label format ">>>>>>>>9.99" help "Сумма платежей текущего года"
  fine1[5] no-label format ">>>>>>>>9.99" help "Штраф"
  fine2[5] no-label format ">>>>>>>>9.99" help "Пеня"
  knp[5] no-label  validate (chk_knp(5), err_knp) help "КНП"   skip

  tire1 view-as text no-label skip
  lcom format ":/:" label "Тип комиссии " skip
  doccomsum label "Сумма комиссии" format ">>>,>>9.99" skip
  "Дополнительно:" docinfo no-label validate (chk_docinfo(), valdocinfo) format "x(62)"  skip
  tire2 view-as text no-label skip
  totsum label "Сумма + комис." ":" sumchar1 view-as text no-label  format "x(50)" skip
  sumchar2 view-as text no-label at 21 format "x(50)" skip

  with side-labels centered.


  on help of docinfo in frame sf do:
    if (kbud[1] = 203111) or
    (kbud[2] = 203111) or
    (kbud[3] = 203111) or
    (kbud[4] = 203111) or
    (kbud[5] = 203111) then
    do:
      run sel ("Код 203111 - адм. штраф", "СЭС                           |" +
      "ГАИ                           |" +
      "Государственная пожарная часть|" +
      "Военкомат                     |" +
      "Паспортный стол               |" +
      "Народный суд                  |" +
      "ЛОВД                          |" +
      "Миграционная полиция").
      docinfo:screen-value = entry(integer(return-value),
      "СЭС                           |" +
      "ГАИ                           |" +
      "Государственная пожарная часть|" +
      "Военкомат                     |" +
      "Паспортный стол               |" +
      "Народный суд                  |" +
      "ЛОВД                          |" +
      "Миграционная полиция"
      + "|", "|").
      docinfo = docinfo:screen-value.
    end.
  end.

  on value-changed of docinfo in frame sf do:
    docinfo = docinfo:screen-value.
  end.

  on value-changed of docresid in frame sf do:
    if logical(docresid:screen-value) = false then do:
      displ docresid with frame sf.
      docrnn = '600900050984'.
      docrnn:screen-value = '600900050984'.
      update
        fio_n pass_n
      with frame sf_n.
      hide frame sf_n.
      if trim(fio_n) = "" OR trim(pass_n) = "" then
      do:
        message "Поля обязятельны для заполниния" view-as alert-box title "Внимание".
        undo, retry.
      end.
      fio = fio_n + ' Паспорт - ' + pass_n.
      docresid = false.
      displ docresid fio with frame sf.
    end.
    docresid = logical(docresid:screen-value).
  end.

  /* ---------------------------------------------------------------- */
  /* ------                                                  -------- */
  /* ---                                                          --- */


  on value-changed of cursum1 in frame sf do:
    cursum1 = decimal(cursum1:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of cursum2 in frame sf do:
    cursum2 = decimal(cursum2:screen-value).
    run init_doccomsum_totsum(yes).
  end.


  on value-changed of cursum3 in frame sf do:
    cursum3 = decimal(cursum3:screen-value).
    run init_doccomsum_totsum(yes).
  end.


  on value-changed of cursum4 in frame sf do:
    cursum4 = decimal(cursum4:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of cursum5 in frame sf do:
    cursum5 = decimal(cursum5:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of oldsum in frame sf do:
    oldsum[1] = decimal(oldsum[1]:screen-value).
    oldsum[2] = decimal(oldsum[2]:screen-value).
    oldsum[3] = decimal(oldsum[3]:screen-value).
    oldsum[4] = decimal(oldsum[4]:screen-value).
    oldsum[5] = decimal(oldsum[5]:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of fine1 in frame sf do:
    fine1[1] = decimal(fine1[1]:screen-value).
    fine1[2] = decimal(fine1[2]:screen-value).
    fine1[3] = decimal(fine1[3]:screen-value).
    fine1[4] = decimal(fine1[4]:screen-value).
    fine1[5] = decimal(fine1[5]:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of fine2 in frame sf do:
    fine2[1] = decimal(fine2[1]:screen-value).
    fine2[2] = decimal(fine2[2]:screen-value).
    fine2[3] = decimal(fine2[3]:screen-value).
    fine2[4] = decimal(fine2[4]:screen-value).
    fine2[5] = decimal(fine2[5]:screen-value).
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of doccolord in frame sf do:
    doccolord = integer(doccolord:screen-value).
  end.


  /* ---                                                          --- */
  /* ------                                                  -------- */
  /* ---------------------------------------------------------------- */

  on help of lcom in frame sf do:
    /*disable all with frame sf.*/
    case seltxb:
      WHEN 0 then
      do:
        /*если кбк есть в списке1 */
        do v-icount = 1 to 5:
          if lookup(string(kbud[v-icount]),v-custom-kb) > 0 then
            v-cst-count = v-cst-count + 1.
          if lookup(string(kbud[v-icount]),v-omp-kb) > 0 then
            v-omp-count = v-omp-count + 1.
          if lookup(string(kbud[v-icount]),v-reg-kb) > 0 then
            v-reg-count = v-reg-count + 1.
          if lookup(string(kbud[v-icount]),v-custom-kb) = 0
          and lookup(string(kbud[v-icount]),v-omp-kb) = 0
          and lookup(string(kbud[v-icount]),v-reg-kb) = 0 then
            v-others-count = v-others-count + 1.
        end.
        if v-cst-count <> 0 then
          /*если хотябы один из введенных КБК нашелся в списке 1 , то*/
          message "Выбор комиссий для данного КБК не предусмотрен" view-as alert-box title "Внимание".
        else
          if (v-omp-count <> 0 or v-reg-count <> 0 or v-others-count <> 0) and v-cst-count = 0 then
          do:
            /*если в списке 1 не нашелся, но нашелся в одном из других списков*/
            if v-others-count <> 0 then
              run comtar("7","24,42,##").
            if v-omp-count <> 0
            and (kbud[1] = 108108 or kbud[2] = 108108 or kbud[3] = 108108 or kbud[4] = 108108 or kbud[5] = 108108) then
              run comtar("7","24,42,##").
            if v-reg-count <> 0 then
              run comtar("7","24,##").
          end.
      end.
      WHEN 1 then
      do:
        run comtar("7","24,##"). /*Алматы*/
      end.
      WHEN 2 then
      do:
        run comtar("7","24,42,##"). /*уральск*/
      end.
      WHEN 3 then
      do:
        run comtar("7","24,##"). /*атырау*/
      end.
      WHEN 4 then
      do:
        run comtar("7","24,##"). /*Актобе*/
      end.
      WHEN 5 then
      do:
        run comtar("7","24,##"). /*Караганда*/
      end.
      WHEN 6 then
      do:
        run comtar("7","24,##"). /*Талдыкорган*/
      end.
      OTHERWISE do:
        run comm-coms. /*прочие*/
      end.
    end.
    if return-value <> "" then
    do:
      doccomcode = return-value.
      juridical_person = doccomcode = "ju".
    end.
    run init_doccomsum_totsum(yes).
    enable all
    except totsum doccomsum cdate nkname kbchar fio docnum tire0 tire1 tire2 tire3 with frame sf.
    if (not candel) and (not newdoc) then
      disable docrnn cursum1 cursum2 cursum3 cursum4 cursum5 oldsum fine1 fine2 with frame sf.
    if cut_com = "YES" then
    do:
      /*REPEAT ON ENDKEY UNDO, RETRY:*/
      if doccomcode = "42" then
      do:
        update
        v_vov_name
        with frame sfd.
        hide frame sfd.
        if trim(v_vov_name) = "" then
        do:
          message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
          undo, retry.
        end.
        else
          leave.
      end.
      else
        if doccomcode = "24" then
        do:
          update
          v_vov_name
          with frame sfx.
          hide frame sfx.
          if trim(v_vov_name) = "" then
          do:
            message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
            undo, retry.
          end.
        else
          leave.
      end.
      else
        leave.
      /*END.*/  /* REPEAT  */
    end.
  end.


    on value-changed of kbud in frame sf do:
    /*18/05/2006/ u00568 ТЗ 238*/
    do i1 = 1 to 5:
      case i1:
        when 1 then
          temp_kbud = kbud[1]:screen-value.
        when 2 then
          temp_kbud = kbud[2]:screen-value.
        when 3 then
          temp_kbud = kbud[3]:screen-value.
        when 4 then
          temp_kbud = kbud[4]:screen-value.
        when 5 then
          temp_kbud = kbud[5]:screen-value.
      end case.
      find first budcodes where code = int(temp_kbud) use-index code no-lock no-error.
      if avail budcodes then
        kbchar[i1] = budcodes.name1.
      else
        kbchar[i1] = "".
      displ kbchar[i1] with frame sf.
      if _is_kbk_from_list(int(temp_kbud)) and not _is_kbk_from_list(kbud[i1]) then do:
          if only_yes_or_no("!!!", "Уточните у клиента вид платежа.~nКлиент хочет оплатить КБК " + temp_kbud + " """ + kbchar[i1] + """?") ne true then do:
            kbud[i1] = 000000.
            displ kbud[i1] with frame sf.
          end.
      end.
      kbud[i1] = int(temp_kbud).
    end.
    /* end 18/05/2006/ u00568*/
    /*
    kbud[1] = int(kbud[1]:screen-value).
    kbud[2] = int(kbud[2]:screen-value).
    kbud[3] = int(kbud[3]:screen-value).
    kbud[4] = int(kbud[4]:screen-value).
    kbud[5] = int(kbud[5]:screen-value).
    */
    /*17/05/2006/ u00568 ТЗ 334*/
    do i1 = 1 to 5:
      if kbud[i1] = 108101 then  do:
        message "Платежи по КБК 108101 следует набирать в~nПРОЧИХ ПЛАТЕЖАХ~nКБК изменен." view-as alert-box title "!!!".
        kbud[i1] = 000000.
        displ kbud[i1] with frame sf.
      end.
    end.
    /* end 17/05/2006/ u00568*/
  end.


  on value-changed of docrnn in frame sf do:
    def var docrnn_value_changed as logical no-undo.
    docrnn_value_changed = docrnn <> docrnn:screen-value.
    if newdoc and lookup(doccomcode,'24,42') <> 0 and docrnn_value_changed then
    do:
      doccomcode = "##".
      v_vov_name = ''.
      cut_com = "NO".
    end.
    if docrnn_value_changed then do:
      docrnn = docrnn:screen-value.
      juridical_person = is_it_jur_person_rnn(docrnn).
      if not juridical_person then do:
        find first rnn where rnn.trn = docrnn no-lock no-error.
        if avail rnn then do:
          if newdoc and docrnn_value_changed and entry(1,comm.rnn.info[1],',') = 'ВОВ' then do:
            v_vov_name = comm.rnn.info[1].
            v_vov_name = substr(v_vov_name, length(vov_str + ' '), length(v_vov_name)) no-error.
            doccomcode = "24".
            cut_com = "YES".
            run init_doccomsum_totsum(yes).
          end.
          rid_rnn = rowid(rnn).
        end.
      end.
      fio = caps(getfioadr1(docrnn)).
      tValidRnn  = not (fio = '').
      if not tValidRnn and chk_rnn() then
        if yes-no("", "РНН не найден в справочнике.~nХотите пополнить справочник?") then
          apply "enter-menubar" to docrnn in frame sf.
        else
          apply "return" to docrnn in frame sf.
        docresid = true.
    end.
    display fio docresid with frame sf.
    run init_doccomsum_totsum(yes).
  end.

  on value-changed of docrnnnk in frame sf do:
    docrnnnk = docrnnnk:screen-value.
    find first taxnk where taxnk.rnn = docrnnnk no-lock no-error.
    if avail  taxnk then do:
      if taxnk.visible = true then do:
        nkname =  taxnk.name.
        find first btaxnk where rowid(btaxnk) = rowid(taxnk) no-lock no-error.
        if avail btaxnk then
        do:
          find first bankl where bankl.bank = string(btaxnk.bik,"999999999") no-lock no-error.
            if avail bankl then
              kazna = trim(bankl.name).
        end.
        else do:
          kazna = ''.
          message "Не настроена таблица taxnk, поле taxnk.bank" view-as alert-box.
        end.
      end. else do:
        nkname = "".
        kazna = ''.
        docrnnnk = ''.
        message "Этот НК заблокирован в пункте 5-3-4. Обратитесь в ДРР." view-as alert-box.
        displ docrnnnk with frame sf.
      end.
    end. else do:
      nkname = "".
      kazna = ''.
    end.
    displ nkname kazna btaxnk.iik btaxnk.bik with frame sf.
  end.

    /* F3 */
  on "enter-menubar" of docrnn in frame sf do:
    /*
    if ourcode = 0 then
      message "Редактировать РНН может только старший менеджер~nв специальном пункте меню!" view-as alert-box title ''.
    else do:
    */
      if yes-no("", "Редактировать РНН " + docrnn + " ?") then
      do:
        run taxrnnin (docrnn).
        docrnn = ''.
        apply "value-changed" to docrnn in frame sf.
      end.
    /*end.*/
  end.

  /*enter*/
  on return of docrnn in frame sf do:
    if result_rnn and not tValidRnn then do:
      disable all with frame sf.
      run rnnzero.
      enable all
      except totsum doccomsum cdate nkname kbchar fio docnum tire0 tire1 tire2 tire3 with frame sf.
      if return-value = ' ' then do:
        docrnn = ''.
        displ docrnn with frame sf.
      end.
      fio = return-value.
    end.
    display fio with frame sf.
  end.

  on help of docrnn in frame sf do:
    disable all with frame sf.
    run taxfind.
    enable all
    except totsum doccomsum cdate nkname kbchar fio docnum tire0 tire1 tire2 tire3 with frame sf.
    if return-value <> "" then
    do:
      docrnn = return-value.
      display docrnn WITH side-labels FRAME sf.
      docrnn = ''.
    end.
    apply "value-changed" to self.
  end.


  on help of docrnnnk in frame sf  do:
    disable all with frame sf.
    run taxnkall.
    enable all
    except totsum doccomsum cdate nkname kbchar fio docnum tire0 tire1 tire2 tire3 with frame sf.
    if (not candel) and (not newdoc) then
      disable docrnn cursum1 cursum2 cursum3 cursum4 cursum5 oldsum fine1 fine2 with frame sf.
    if return-value <> "" then
    do:
      docrnnnk = return-value.
      display docrnnnk WITH side-labels FRAME sf.
    end.
    apply "value-changed" to self.
  end.

  on help of cursum1 in frame sf do:
    run on_help_of_cursum(1).
  end.

  on help of cursum2 in frame sf do:
    run on_help_of_cursum(2).
  end.

  on help of cursum3 in frame sf do:
    run on_help_of_cursum(3).
  end.

  on help of cursum4 in frame sf do:
    run on_help_of_cursum(4).
  end.

  on help of cursum5 in frame sf do:
    run on_help_of_cursum(5).
  end.



  on value-changed of knp in frame sf do:
    knp[1] = integer(knp[1]:screen-value).
    knp[2] = integer(knp[2]:screen-value).
    knp[3] = integer(knp[3]:screen-value).
    knp[4] = integer(knp[4]:screen-value).
    knp[5] = integer(knp[5]:screen-value).
 end.





  /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
  /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
  /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
  /*Main logic --------------------------------------------------------------*/



  find first btaxnk where btaxnk.bank = ourbank no-lock no-error.
  if avail btaxnk then
  do:
    find first bankl where bankl.bank = string(btaxnk.bik,"999999999") no-lock no-error.
    if avail bankl then
      kazna = trim(bankl.name).
    docrnnnk = btaxnk.rnn.
  end.
  else
    message "Не настроена таблица taxnk, поле taxnk.bank" .

  do /*while choice2*/:
    do:
      /*choice2 = false.*/
      if newdoc then do:
        run newdoc1.
      end. else do:
        run not_newdoc1.
      end.

      run display_all.

      if (newdoc or (doccomdoc = ? and docsenddoc = ? and doctaxdoc = ?)) then
      do:
        do while true:
          if newdoc or candel then
            update
            docrnnnk
            docrnn
            docresid
            doccolord
            kbud[1] oldsum[1] cursum1 fine1[1] fine2[1] knp[1]
            kbud[2] oldsum[2] cursum2 fine1[2] fine2[2] knp[2]
            kbud[3] oldsum[3] cursum3 fine1[3] fine2[3] knp[3]
            kbud[4] oldsum[4] cursum4 fine1[4] fine2[4] knp[4]
            kbud[5] oldsum[5] cursum5 fine1[5] fine2[5] knp[5]
            lcom
            docinfo
            WITH FRAME sf editing:
              do i = 1 to 5:
                if wastns[i] then
                do:
                  case i:
                    when 1 then
                      disable cursum1 with frame sf.
                    when 2 then
                      disable cursum2 with frame sf.
                    when 3 then
                      disable cursum3 with frame sf.
                    when 4 then
                      disable cursum4 with frame sf.
                    when 5 then
                      disable cursum5 with frame sf.
                  end case.
              end.
            end.
            readkey.
            apply lastkey.
            if frame-field = "docrnnnk" then
              apply "value-changed" to docrnnnk in frame sf.
            if frame-field = "kbud" then
              apply "value-changed" to kbud in frame sf.
            if frame-field = "oldsum" then
              apply "value-changed" to oldsum in frame sf.
            if frame-field = "cursum1" then
              apply "value-changed" to cursum1 in frame sf.
            if frame-field = "cursum2" then
              apply "value-changed" to cursum2 in frame sf.
            if frame-field = "cursum3" then
              apply "value-changed" to cursum3 in frame sf.
            if frame-field = "cursum4" then
              apply "value-changed" to cursum4 in frame sf.
            if frame-field = "cursum5" then
              apply "value-changed" to cursum5 in frame sf.
            if frame-field = "fine1" then
              apply "value-changed" to fine1 in frame sf.
            if frame-field = "fine2" then
              apply "value-changed" to fine2 in frame sf.
            if frame-field = "knp" then
              apply "value-changed" to knp in frame sf.
            if frame-field = "docrnn" then
              apply "value-changed" to docrnn in frame sf.
            if frame-field = "doccolord" then
              apply "value-changed" to doccolord in frame sf.
          end. else do:
            run update_candel.
          end.
          run save_to_tax.
          if return-value = 'ok' then leave.
        end.
      end.
    end.
    if (newdoc = no) and (alldoc = yes) and doccomdoc = ? and docsenddoc = ? and doctaxdoc <> ? then
    do:
      update_mode = 1.
      do i = 1 to 5:
        if kbud[i] = 0 then
          ukbn[i] = yes. else
          ukbn[i] = no.
      end.
      do while true:
        if newdoc or candel then
          update
          docrnnnk docrnn
          docresid
          kbud[1] kbud[2] kbud[3] kbud[4] kbud[5]
          knp[1]  knp[2]  knp[3]  knp[4]  knp[5]
          WITH FRAME sf editing:
            readkey.
            apply lastkey.
            if frame-field = "docrnnnk" then
              apply "value-changed" to docrnnnk in frame sf.
            if frame-field = "kbud" then
              apply "value-changed" to kbud in frame sf.
            if frame-field = "docrnn" then
              apply "value-changed" to docrnn in frame sf.
            if frame-field = "knp" then
              apply "value-changed" to knp in frame sf.
          end.
        else do:
          /* update candel */
          run update_candel.
        end. /* update candel */
        run save_to_tax.
        if return-value = 'ok' then leave.
      end.
    end.

    /*
    if newdoc then do:
    MESSAGE "Создать еще один?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "" UPDATE choice2.
    end.
    */

    /*choice2 = false.*/

  end.
  /*while*/


  hide frame sf.

  if rids <> "" then
  do:

    if canprn then
    do:
      case only_yes_or_no("", "Распечатать Извещение/Квитанцию?"):
        when true then
          run taxkvit (rids).
      end case.

    end.
    /*
    else do:  run taxkvit (rids).
    end.
    */

    case only_yes_or_no("", "Распечатать ордер?"):
      when true then
        run taxprn (rids).
    end case.
    if doctns > 0 then
    do:
      case only_yes_or_no("", "Распечатать справку по транспортному налогу?"):
        when true then
          run taxprtns(rids).
      end case.
    end.
  end.

  return rids.

  /*----------------------------------------------------------------------------*/
  procedure init_doccomsum_totsum:
    def input parameter update_ as logical.
    if not newdoc then
      return.
    doccomsum = 0.
    totsum = 0.
    do v-icount = 1 to 5:
      v-temp-tot[v-icount] = 0.
    end.
    v-temp-tot[1] = cursum1 + oldsum[1] + fine1[1] + fine2[1].
    v-temp-tot[2] = cursum2 + oldsum[2] + fine1[2] + fine2[2].
    v-temp-tot[3] = cursum3 + oldsum[3] + fine1[3] + fine2[3].
    v-temp-tot[4] = cursum4 + oldsum[4] + fine1[4] + fine2[4].
    v-temp-tot[5] = cursum5 + oldsum[5] + fine1[5] + fine2[5].
    alldoccomcodes = ''.
    do v-icount = 1 to 5:
      if lookup(doccomcode,'24,42') = 0 then
      do:
        case seltxb:
          WHEN 0 then
          do:
            /*Алматы*/
            if lookup(string(kbud[v-icount]),v-omp-kb) > 0 and
            lookup(string(kbud[v-icount]),v-custom-kb) = 0 and
            lookup(string(kbud[v-icount]),v-reg-kb) = 0 then
            do:
              if string(kbud[v-icount]) ne '204105' then
                doccomcode = '21'.
              if string(kbud[v-icount]) = '204105' then
              do:
                doccomcode = '14#15'.
              end.
            end.
            if lookup(string(kbud[v-icount]),v-custom-kb) > 0 and
            lookup(string(kbud[v-icount]),v-omp-kb) = 0 and
            lookup(string(kbud[v-icount]),v-reg-kb) = 0 then
            do:
              doccomcode = '13#29'.
            end.
            if lookup(string(kbud[v-icount]),v-reg-kb) > 0 and
            lookup(string(kbud[v-icount]),v-omp-kb) = 0 and
            lookup(string(kbud[v-icount]),v-custom-kb) = 0 then
            do:
              doccomcode = '03#04#05'.
            end.
            if lookup(string(kbud[v-icount]),v-custom-kb) = 0 and
            lookup(string(kbud[v-icount]),v-omp-kb) = 0 and
            lookup(string(kbud[v-icount]),v-reg-kb) = 0 then
            do:
              doccomcode = '18#19#16#20#28'.
            end.
          end.
          WHEN 1 then
          do:
            /*Астана*/
            doccomcode = '43#44#45#46'.
          end.
          WHEN 2 then
          do:
            /*Уральск*/
            doccomcode = '43#44#45#46'.
            if string(kbud[v-icount]) = '204105' then
              doccomcode = '14#47#48'.
          end.
          WHEN 3 then
          do:
            /*Атырау*/
            doccomcode = '43#44#45#46'.
          end.
          WHEN 4 then
          do:
            /*Актобе*/
            doccomcode = '43#44#45#46'.
          end.
          WHEN 5 then
          do:
            /*Караганда*/
            doccomcode = '43#44#45#46'.
          end.
          WHEN 6 then
          do:
            /*Талдыкорган*/
            doccomcode = '43#44#45#46'.
          end.
        end case.
      end.
      else
        cut_com = "YES". /*комиссия льготная */
      doccomsum = doccomsum + COMM-COM-1(v-temp-tot[v-icount], doccomcode, "7", comchar) * doccolord.
      alldoccomcodes = alldoccomcodes + doccomcode + ','.
      totsum = totsum + v-temp-tot[v-icount].
    end.
    totsum = totsum + doccomsum.
    if update_ then
    do:
      displ
      doccomsum
      with frame sf.
      run changed_totsum.
    end.
    return.
  end.


/*---------------------------------------------------------------------------*/
  procedure changed_totsum:
    /* если изменилась общая сумма, то выводит словестную формулировку*/
    run Sm-vrd(totsum, output sumchartmp) no-error.
    sumchartmp = sumchartmp + ' тенге '.
    run frac (input totsum, output sumdec).
    if sumdec = 0.0 then
      sumchartmp = sumchartmp + "00 тиын".
    else
      sumchartmp = sumchartmp + string(sumdec * 100) + " тиын".
    if length(sumchartmp) > 50 then
    do:
      mark = R-INDEX(sumchartmp, " ", 50).
      sumchar1 = SUBSTR(sumchartmp,1, mark).
      sumchar2 = SUBSTR(sumchartmp, mark + 1).
    end.
    else
    do:
      sumchar1 = sumchartmp.
      sumchar2 = "".
    end.
    displ
    totsum
    sumchar1
    sumchar2
    with frame sf.
  end.


/*---------------------------------------------------------------------------*/
  procedure newdoc1:
        /*
        docnum = 0.
        cursum1 = 0. cursum2 = 0. cursum3 = 0. cursum4 = 0. cursum5 = 0.
        fine1 = 0.   fine2 = 0.
        oldsum = 0.  totsum = 0.  doccomsum = 0.
        doccolord = 1.
        docinfo = "".
        doccomdoc = ?.

        docsenddoc = ?.
        doctns = 0.
        numtns = 0.
        olddocnum = 0.
        docrnn2 = "".
        */
        doctaxdoc = ?.
        docuid = userid('bank').

        find last btax where btax.txb = ourcode
                         and btax.date = g-today
                         and btax.uid = docuid
                         use-index datenum
                       no-lock no-error.
        if avail btax then do:
          if btax.resid = true then do:
            docrnn = btax.rnn.
            fio = btax.chval[1].
            tValidRnn = btax.valid.
            docresid = btax.resid.
          end. else do:
            docrnn = ''.
            fio = ''.
            tValidRnn = false.
            docresid = true.
          end.
          docrnnnk = btax.rnn_nk.
        end. else do:
          docrnn = ''.
          fio = ''.
          tValidRnn = false.
          docresid = true.
          docrnnnk = ''.
        end.
  end.


/*-------------------------------------------*/
  procedure not_newdoc1:
  find  tax where rowid( tax) = rid exclusive-lock no-error.
        find first btax where btax.txb = tax.txb and btax.date = tax.date and btax.dnum = tax.dnum and
        btax.rnn = tax.rnn and btax.uid = tax.uid and btax.created = tax.created and btax.duid = ?
        no-lock no-error.
        if avail btax then
        do:
          ctime = btax.created.
          docuid = btax.uid.
          olddocnum = btax.dnum.
          docrnn2 = btax.rnn.
          docnum = btax.dnum.
          doccolord = btax.colord.
          docinfo = docinfo + trim (btax.info).
          docrnn = btax.rnn.
          docrnnnk = btax.rnn_nk.
          doctns = btax.tns.
          doccomsum = doccomsum + btax.comsum.
          doccomcode = btax.comcode.
          kbud[1] = btax.kb.
          oldsum[1] = btax.decval[1].
          cursum1 = btax.decval[2].
          fine1[1] = btax.decval[3].
          fine2[1] = btax.decval[4].
          /*doccomsum = btax.comsum.*/
          totsum = btax.sum.
          tValidRnn = btax.valid.
          docresid = btax.resid.
          doccomdoc = btax.comdoc.
          doctaxdoc = btax.taxdoc.
          docsenddoc = btax.senddoc.
          /*s_full_name = btax.chval[1].*/
          fio = btax.chval[1].
          v_vov_name = btax.chval[2].
          alldoccomcodes = btax.comcode.
          knp[1] = btax.intval[1].
          /*fio = s_full_name.*/
          displ fio with frame sf.

          if doctns <> 0 then
            wastns[1] = yes.
        end.

        do i = 2 to 5:
          find next btax where btax.txb = tax.txb and btax.date = tax.date and btax.dnum = tax.dnum and
          btax.rnn = tax.rnn and btax.uid = tax.uid and btax.created = tax.created and btax.duid = ?
          no-lock no-error.
          if avail btax then
          do:
            docinfo = docinfo + trim (btax.info).
            doccomsum = doccomsum + btax.comsum.
            doccomcode = btax.comcode.
            kbud[i] = btax.kb.
            alldoccomcodes = alldoccomcodes + ',' + btax.comcode.
            /*kanat - добавил КНП*/
            knp[i] = btax.intval[1].

            oldsum[i] = btax.decval[1].
            case i:
              when 2 then
                cursum2 = btax.decval[2].
              when 3 then
                cursum3 = btax.decval[2].
              when 4 then
                cursum4 = btax.decval[2].
              when 5 then
                cursum5 = btax.decval[2].
            end case.
            fine1[i] = btax.decval[3].
            fine2[i] = btax.decval[4].
            /*
            doccomsum = btax.comsum.
            */
            totsum = totsum + btax.sum.
            if btax.tns > 0 then
            do:
              wastns[i] = yes.
              doctns = btax.tns.
            end.
          end.
          end.
  end.

/*-----------------------------------------------*/
  procedure display_all:
      display
      cdate
      docnum
      docrnn
      docrnnnk
      btaxnk.iik
      btaxnk.bik
      docresid
      kazna
      doctns
      totsum
      oldsum
      fine1
      fine2
      cursum1 cursum2 cursum3 cursum4 cursum5
      knp
      doccolord
      lcom
      doccomsum
      docinfo
      kbud
      tire0
      tire1
      tire2
      tire3
      WITH side-labels FRAME sf.
      apply "value-changed" to docrnnnk in frame sf.
      apply "value-changed" to kbud in frame sf.
      apply "value-changed" to oldsum in frame sf.
      apply "value-changed" to cursum1 in frame sf.
      apply "value-changed" to cursum2 in frame sf.
      apply "value-changed" to cursum3 in frame sf.
      apply "value-changed" to cursum4 in frame sf.
      apply "value-changed" to cursum5 in frame sf.
      apply "value-changed" to fine1  in frame sf.
      apply "value-changed" to fine2  in frame sf.
      apply "value-changed" to knp in frame sf.
      apply "value-changed" to doccolord in frame sf.
      apply "value-changed" to docrnn    in frame sf.
  end.


  /*-----------------------------------------------*/
  procedure save_to_tax:
    do:
      do i = 1 to 5:
        if kbud[i] = 0 then
        do:
          fine1[i] = 0.
          fine2[i] = 0.
          oldsum[i] = 0.
          case i:
            when 1 then cursum1 = 0.
            when 2 then cursum2 = 0.
            when 3 then cursum3 = 0.
            when 4 then cursum4 = 0.
            when 5 then cursum5 = 0.
          end case.
        end.
      end.
      run init_doccomsum_totsum(yes).
      run display_all.
      /*проверки*/
      if not newdoc and INDEX(docinfo,'<по акту изъятия>') <> 0 and doccomcode = '42' then do:
        message "Этот документ был загружен с дискеты~nналогового инспектора.~n~nЕго редактировать нельзя." view-as alert-box title "!!!".
        return 'ok'.
      end.
      if cut_com <> "YES" and doccomsum = 0 and newdoc then
      do:
        message "Неверная сумма комиссии" view-as alert-box title "".
        undo, retry.
      end.
      If newdoc then do:
        do i = 1 to 5:
          if kbud[i] <> 0 then do:
            find first budcodes where budcodes.code = kbud[i] no-lock no-error.
            if avail budcodes and budcodes.hand then do:
              update kbud[i] no-label docbud[i] label 'Для данного кода бюджета необходимо указать тип распределения' skip
              '"М" - местный, "Г" - государственный'
              with centered side-labels frame bf editing:
                disable kbud[i] with frame bf.
                readkey.
                apply lastkey.
              end.
              hide frame bf.
            end.
            if kbud[i] = 301103 then do:
              update
                fam3 nam3 otch3 Adr3 cost3
              with frame sf301103.
              hide frame sf301103.
              if trim(fam3) = "" OR trim(nam3) = "" OR  trim(Adr3) = "" OR trim(cost3) = "" then
              do:
                message "Поля со (*) - обязятельны для заполниния" view-as alert-box title "Внимание".
                undo, retry.
              end.
              docinfo = docinfo + ' для КБК 301103: покупатель - ' + fam3 + ' ' + nam3 + ' ' + otch3 + ', адрес  - ' + Adr3 + ', стоимость  - ' + cost3.
            end.
          end.
        end.
        if docresid = false then docinfo = fio_n + ' ' + pass_n + ' ' + docinfo.
      end.

      case yes-no-question("", "Сохранить?"):
        WHEN false then return 'ok'.
        WHEN ? then return.
      end case.

      /*
      if not yes-no("", "Сохранить?") then
        return 'ok'.
       */
      find last btax where btax.txb = ourcode and btax.date = g-today  no-lock no-error.
      if avail btax then
        docnum = btax.dnum + 1.
      else
        docnum = 1.
      /* удалить все записи из предыдущей платежки */
    end. /*tran*/
    m1:
    do transaction:
      if not newdoc then
      do:
        find first btax where btax.txb = ourcode
                          and btax.date = g-today
                          and btax.dnum = olddocnum
                          and btax.rnn = docrnn2
                          and btax.uid = docuid
                          and btax.created = ctime
                          and btax.duid = ?
                        exclusive-lock no-error.
        if avail btax then
          assign btax.deldate = today
            btax.duid = userid ("bank")
            btax.deldnum = docnum
            btax.delwhy = "Изменение реквизитов"
            btax.deltime = time.
        do i = 2 to 5 ON error UNDO m1:
          find next btax where btax.txb = ourcode
                          and btax.date = g-today
                          and btax.dnum = olddocnum
                          and btax.rnn = docrnn2
                          and btax.uid = docuid
                          and btax.created = ctime
                          and btax.duid = ?
                        exclusive-lock no-error.
          if avail btax then
            assign
            btax.deldate = today
            btax.duid = userid ("bank")
            btax.deldnum = docnum
            btax.delwhy = "Изменение реквизитов"
            btax.deltime = time.
          else
            leave.
        end.
      end.
      release btax.
      /*s-rnn = docrnn.*/
      ctime = time.
      /*s_full_name = fio.*/
      do i = 1 to 5 ON error UNDO m1:
        if kbud[i] <> 0 then do:
          CREATE tax no-error.
          case i:
            when 1 then tax.decval[2] = cursum1.
            when 2 then tax.decval[2] = cursum2.
            when 3 then tax.decval[2] = cursum3.
            when 4 then tax.decval[2] = cursum4.
            when 5 then tax.decval[2] = cursum5.
          end case.
          /*i1 = 0.*/
          assign
            tax.kb = kbud[i]/*. message string(i1) view-as alert-box title "". i1 = i1 + 1.*/
            tax.bud = docbud[i]
            tax.decval[1] = oldsum[i]
            tax.decval[3] = fine1[i]
            tax.decval[4] = fine2[i]
            tax.intval[1] = knp[i]
            /*tax.chval[1] = s_full_name*/
            tax.chval[1] = fio
            tax.colord = doccolord
            tax.tns = if wastns[i] then doctns else  0
            tax.txb = ourcode
            tax.date = g-today
            tax.dnum = docnum
            tax.cdate = today
            tax.created = ctime
            tax.uid = docuid
            tax.rnn_nk = docrnnnk
            tax.rnn = docrnn
            tax.resid = docresid
            tax.valid = tValidRnn
            tax.comu = doccomu
            tax.com = yes
            tax.sum = oldsum[i] + tax.decval[2] + fine1[i] + fine2[i]
            tax.comsum = if i = 1 then doccomsum else 0
            tax.info = if i = 1 then docinfo else ""
            tax.taxdoc = doctaxdoc
          /*no-error*/.
            alldoccomcodes = alldoccomcodes + ',,,,,,,,,,,'.
            tax.comcode = entry(i,alldoccomcodes,','). /*doccomcode*/
          if not newdoc then
            assign
              tax.edate = today
              tax.euid = userid ("bank")
              tax.etim = time.
          if i = 1 then
            rids = rids + string(rowid( tax)).
          /*else
          do:
            assign
              tax.sum = 0
            no-error.
          end.*/
          if cut_com = "YES" and lookup(doccomcode,'24,42') <> 0 and trim(v_vov_name) <> "" then
          do:
            tax.chval[2] = v_vov_name.
            run update_rnn_for_veteran.
          end.
        end.
      end.
      if riddolg <> "0x000000000" then
      do:
        /* Запись в TnsDolg*/
        find first  tnsdolg where rowid( tnsdolg) = to-rowid(riddolg) exclusive-lock no-error.
        if avail tnsdolg then
        do:
          riddolg = "0x000000000".
          tnsdolg.dtfk = g-today.
          tnsdolg.dnum = docnum.
          tnsdolg.uid = docuid.
          tnsdolg.codenk = substring(docrnnnk,1,4).
          release tnsdolg.
        end.
      end.
    end. /*tran*/
    return 'ok'.
  end.


  /*-----------------------------------------------*/
  procedure on_help_of_cursum:   /*on help of cursum*/
    def input PARAMETER  vi as int no-undo.
    DEFINE var cursum as decimal no-undo.

    case vi:
          when 1 then cursum = cursum1.
          when 2 then cursum = cursum2.
          when 3 then cursum = cursum3.
          when 4 then cursum = cursum4.
          when 5 then cursum = cursum5.
    end case.

    if can-find(first  taxtns  where  taxtns.kb   = kbud[vi] no-lock) and
    can-find(first  taxauto where  taxauto.rnn = docrnn no-lock)
    then
    do:
      /*docrnn   = docrnn:screen-value.
      docrnnnk = docrnnnk:screen-value.
      tsum     = decimal(cursum1:screen-value).*/
      tsum = cursum.
      run taxtns(g-today).
      docrnn:screen-value in frame sf = docrnn.
      docrnnnk:screen-value in frame sf = docrnnnk.
      doctns:screen-value in frame sf = string(numtns).
      /*apply "value-changed" to doctns in frame sf.*/
      apply "value-changed" to docrnn in frame sf.
      apply "value-changed" to docrnnnk in frame sf.
      case vi:
          when 1 then do:
              cursum1:screen-value = string(tsum).
              apply "value-changed" to cursum1 in frame sf.
              disable cursum1 with frame sf.
            end.
          when 2 then do:
              cursum2:screen-value = string(tsum).
              apply "value-changed" to cursum2 in frame sf.
              disable cursum2 with frame sf.
            end.
          when 3 then do:
              cursum3:screen-value = string(tsum).
              apply "value-changed" to cursum3 in frame sf.
              disable cursum3 with frame sf.
            end.
          when 4 then do:
              cursum4:screen-value = string(tsum).
              apply "value-changed" to cursum4 in frame sf.
              disable cursum4 with frame sf.
            end.
          when 5 then do:
              cursum5:screen-value = string(tsum).
              apply "value-changed" to cursum5 in frame sf.
              disable cursum5 with frame sf.
            end.
      end case.
      doctns = numtns.
      displ fio docrnn docrnnnk nkname with frame sf.
      wastns[vi] = yes.
    end.
    else
      MESSAGE "Записи в базе автомобилей для этого РНН не найдены." docrnn
      VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "".
  end.


  /*-----------------------------------------------*/
  procedure update_candel: /* update candel */
          update
          docrnnnk
          docresid
          WITH FRAME sf editing:
            readkey.
            apply lastkey.
            if frame-field = "docrnnnk" then
              apply "value-changed" to docrnnnk in frame sf.
            if frame-field = "doccolord" then
              apply "value-changed" to doccolord in frame sf.
          end.
          do i = 1 to 5:
            if kbud[i] <> 0 then
            do:
              update
              kbud[i]
              knp[i]
              with frame sf editing:
                readkey.
                apply lastkey.
                if frame-field = "kbud" then
                  apply "value-changed" to kbud in frame sf.
                if frame-field = "knp" then
                  apply "value-changed" to knp in frame sf.

              end.
            end.
          end.
          update docinfo help "Дополнительно (F2-выбор для 203111)"
          with frame sf.
  end.


  /*-----------------------------------------------*/
  procedure update_rnn_for_veteran:
    if v_vov_name<> '' then
    do:
      do transaction:
        find comm.rnn where rowid(rnn) = rid_rnn.
        if comm.rnn.trn = docrnn then do:
          assign
            comm.rnn.info[1] = vov_str + v_vov_name
          no-error.
        end.
      end. /* transaction */
    end.
  end.




  /*
  FUNCTION get_s_kod RETURNS char (INPUT kbk as char , kbk_list as char, money_range as char, kods_list as char, money as decimal).

  def var max_mony_limit as int init 0.
  def var min_mony_limit as int init 0.
  def var s_kod as char init "".
  def var i_entr_nmb as int init 0.

  if lookup(kbk,kbk_list) > 0 then do:
  i_entr_nmb = num-entries(s_payment,'|').

  find first tarif2 where num = "7" and kod = code and tarif2.stat = 'r' no-lock no-error.


  min_mony_limit = decimal(entry(1,money_range,'#')) no-error.
  money_range = substr(money_range, length(entry(1,money_range,'#')) + 2, length(money_range)) no-error.
  max_mony_limit = decimal(entry(1,money_range,'#')) no-error.

  s_kod = entry(1,kods_list,'#') no-error.
  kods_list = substr(kods_list, length(entry(1,kods_list,'#')) + 2, length(kods_list)) no-error.
  if min_mony_limit <= money and (money < max_mony_limit or max_mony_limit = 0) then do:
  return (s_kod)
  end.
  end.
  return (s_kod)
  END FUNCTION.

  */
