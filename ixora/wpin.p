/* wpin.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       ИВЦ/Алсеко/Водоканал/АПК - ввод платежа
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
     23.09.03 sasco изменять платеж может только менеджер из sysc."COMDEL".chval
     23.12.03 sasco добавил обнуление счетчика распечатанных квитанций при изменении платежа
     12.04.04 kanat поменял комиссии при приеме платежей
     16.04.04 kanat добавил возможность выбора вида комиссии по получателям платежей
     25/05/04 dpuchkov добавил возможность контроля платежей от юр лиц в пользу юр лиц.
     09/06/04 kanat добавил вывод суммы с комиссией при приеме платежей
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     27/02/2006 u00568 Evgeniy - Автоматизация тарифов по тз 175, проставил no-undo
     06/03/2006 u00568 Evgeniy - убрал no-undo где оно не надо, теперь сохраняется код комиссии.
     31/10/2006 u00568 Evgeniy - как везде - переделал всё чтобы оптимизить транзакцию
      1/11/2006 u00568 Evgeniy - для атырау водоканала ТЗ 231
     28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{comm-com.i}
{yes-no.i}
{rekv_pl.i}

define variable candel as log no-undo.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

def input parameter g-today as date.
def input parameter newdoc as logical .
def input parameter rid as rowid.
def input parameter selgrp as integer.

define buffer oldb for commonpl.
define buffer cmpb for commonpl.

def var rids as char initial "" no-undo.

/*def var commtel like commonpl.comsum no-undo.*/
def var cret as char init "" no-undo.
def var temp as char init "" no-undo.

define frame sf with side-labels centered view-as dialog-box.

def var whole_sum as decimal.
def var vov_name as char init "" no-undo.
def var comchar  as char.
def var lcom as logical init false no-undo.
def var doccomsum  as decimal.
def var doccomcode as char .
def var commonpl_sum like commonpl.sum .
def var commonpl_accnt like commonpl.accnt.
def var commonpl_date like commonpl.date.
def var commonpl_dnum like commonpl.dnum.


def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     vov_name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.

def var grpname as char format "x(10)" no-undo.
grpname =  selname(selgrp).


def frame sf
     "Платеж " grpname view-as text no-label                                                 skip
     "----------------------------------------"                                              skip
     commonpl_date     view-as text                         label "Дата"                     skip
     commonpl_accnt                 format "9999999"        label "Счет"                     skip
     commonpl_sum                   format ">>>,>>9.99"     label "Сумма"                    skip
     lcom                           format ":/:"            label "Тип комиссии"
     comchar           view-as text format 'x(30)'          no-label                         skip
     doccomsum         view-as text format ">>>,>>9.99"     label "Сумма комиссии"           skip
     whole_sum                    format ">>>,>>>,>>9.99" label "Общая сумма с комиссией" skip
     with side-labels centered.


    /*-----------------------------*/
    on value-changed of commonpl_sum in frame sf do:
        commonpl_sum = decimal(commonpl_sum:screen-value).
        if doccomcode <> "24" then do:
          doccomcode = get_tarifs_common(seltxb, selgrp, '', false).
        end.
        doccomsum = comm-com-1(commonpl_sum, doccomcode, "7", comchar).
        whole_sum = commonpl_sum + doccomsum.
        displ
          doccomsum
          comchar
          whole_sum
        with frame sf.
    end.

    /*-----------------------------*/
    on help of lcom in frame sf do:
      def var temp1 like doccomcode.
      run comtar("7","24,##").
      if return-value <> "" then do:
        temp1 = return-value.
      end.
      if temp1 = "24" then do:
        update
          vov_name
        with frame sfx.
        hide frame sfx.
        if trim(vov_name) = "" then do:
          message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
          undo,retry.
        end.
      end.
      doccomcode = temp1.
      apply "value-changed" to commonpl_sum in frame sf.
    end.



/* Main ---------------------------------------------------------------------*/

  find first commonls where commonls.txb = seltxb
                        and commonls.grp = selgrp
                        and commonls.visible = yes
                      no-lock no-error.
  if not avail commonls then do:
    message "Не могу найти такой платеж (commonls)" view-as alert-box title "Внимание".
    return.
  end.

  if newdoc then do:
    run rekvin(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod).
    if not l-ind then return.
    doccomcode = get_tarifs_common(seltxb, selgrp, '', false).
    commonpl_accnt = 0.
    commonpl_sum = 0.
    commonpl_date = g-today.
    doccomsum = comm-com-1(commonpl_sum, doccomcode, "7", comchar).
  end. else do:
    find commonpl no-lock where rowid(commonpl) = rid.
    doccomsum = commonpl.comsum.
    commonpl_accnt = commonpl.accnt.
    commonpl_sum = commonpl.sum.
    commonpl_date = commonpl.date.
    comchar = 'код комиссии 7' + string(commonpl.comcode).
  end.
  whole_sum = commonpl_sum + doccomsum.



  DISPLAY
          grpname
          commonpl_date
          doccomsum
          whole_sum
          commonpl_sum
          comchar
  WITH side-labels FRAME sf.

  if candel or newdoc then
    UPDATE
      commonpl_accnt
      commonpl_sum
      lcom
      doccomsum
    WITH FRAME sf.
  else
    UPDATE
      commonpl_accnt
    WITH FRAME sf.

  if ( not newdoc )
       and  (commonpl.joudoc <> ?
          or commonpl.comdoc <> ?
          or commonpl.prcdoc <> ?
          or commonpl.rmzdoc <> ?) then
  do:
    message "Редактировать нельзя, потому что ~n" +
    "joudoc или comdoc или prcdoc или" +
    "rmzdoc ~n заполнено." view-as alert-box title "".
    pause.
    return.
  end.

  if newdoc and doccomcode = "24" then do:
    if trim(vov_name) = "" then do:
      message "Не введен номер и дату выдачи удостоверения ВОВ" view-as alert-box title "Внимание".
      return.
    end.
  end.

  commonpl_dnum = next-value(w_p_seq).

  if can-find( first cmpb where cmpb.txb = seltxb
                    and cmpb.grp = selgrp
                    and cmpb.date = g-today
                    and cmpb.type = commonls.type
                    and cmpb.rnnbn = commonls.rnnbn
                    /*and cmpb.fioadr = commonpl.fioadr
                    and cmpb.counter = commonpl.counter*/
                    and cmpb.accnt = commonpl_accnt
                    and cmpb.sum = commonpl_sum
                    and cmpb.dnum <> commonpl_dnum
                    and cmpb.deluid = ?
                  no-lock ) then do:
     message "Повторный платеж за дату валютирования!" view-as alert-box title ''.
     return.
  end.

  /* для атырау водоканала */
  if seltxb = 3 and selgrp = 7 then do:
    do while true :
       find first vodokanal-ls no-lock where vodokanal-ls.num = commonpl_accnt and vodokanal-ls.deluid = ? no-error.
       if avail vodokanal-ls then do:
         case yes-no-question("", ("Это действительно ~n" + vodokanal-ls.fio + "~n проживающий по адресу~n" + vodokanal-ls.adr)):
           WHEN false then
             run vod_atr.
           WHEN true then
             leave.
           WHEN ? then
             return.
         end case.
       end. else
         run vod_atr.
    end.
  end.



  temp =  trim(commonls.npl) + ", лицевой счет " + string(commonpl_accnt,"9999999").

  if YES-NO("", "Сохранить платеж?") then do transaction:
      if newdoc then
        CREATE commonpl.
      else do:
        find current commonpl exclusive-lock.
        /*if ( not newdoc )
        and commonpl.joudoc = ?
        and commonpl.comdoc = ?
        and commonpl.prcdoc = ?
        and commonpl.rmzdoc = ? then
        do:*/
        create oldb.
        buffer-copy commonpl to oldb.
        commonpl.chval[5] = "0".
        assign
          oldb.deldate = today
          oldb.deltime = time
          oldb.deluid  = userid ("bank")
          oldb.delwhy  = "Изменение реквизитов"
          oldb.deldnum = commonpl_dnum.
        assign
          commonpl.edate = today
          commonpl.dnum  = oldb.deldnum
          commonpl.euid  = userid("bank")
          commonpl.etim  = time.
         find current oldb no-lock.
      end.

      commonpl.uid = userid("bank").
      UPDATE
        commonpl.rko    = get-dep(commonpl.uid, g-today)
        commonpl.dnum   = commonpl_dnum
        commonpl.txb    = seltxb
        commonpl.grp    = selgrp
        commonpl.arp    = commonls.arp
        commonpl.type   = commonls.type
        commonpl.rnnbn  = commonls.rnnbn
        commonpl.valid  = false /* РНН плательщика неизвестно */
        commonpl.npl    = temp
        commonpl.comsum = doccomsum
        commonpl.sum    = commonpl_sum
        commonpl.accnt  = commonpl_accnt
        commonpl.date   = commonpl_date
        commonpl.credate = today
        commonpl.cretime = time
        commonpl.comcode = doccomcode.
      if newdoc and doccomcode = "24" then do:
          commonpl.info[3] = vov_name.
      end.

  END.
  cret = string(rowid(commonpl)).
  rids = rids + cret.
  release commonpl.
  release oldb.



  hide frame sf.

  /*
  if rids <> "" then do:
      MESSAGE "Распечатать ордер?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Внимание" UPDATE choice4 as logical.
      case choice4:
          when true then
              run wpprn(rids).
      end case.
  end.
  */
  return cret.


/*---------------------------------------------------------------------------*/


  procedure vod_atr:
    def var vodokanal_ls_fio like vodokanal-ls.fio.
    def var vodokanal_ls_num like vodokanal-ls.num.
    def var vodokanal_ls_adr like vodokanal-ls.adr.

    def frame f_vod
     "Номер " vodokanal_ls_num view-as text no-label      skip
     "----------------------------------------"           skip
     vodokanal_ls_fio     format 'x(35)'   label "ФИО   " skip
     vodokanal_ls_adr     format 'x(35)'   label "Адрес " skip
     with side-labels centered.



    if avail vodokanal-ls then do:
      assign
       vodokanal_ls_num = vodokanal-ls.num
       vodokanal_ls_fio = vodokanal-ls.fio
       vodokanal_ls_adr = vodokanal-ls.adr.
    end. else do:
      assign
       vodokanal_ls_num = commonpl_accnt
       vodokanal_ls_fio = ''
       vodokanal_ls_adr = ''.
    end.

    DISPLAY
      vodokanal_ls_num
      vodokanal_ls_fio
      vodokanal_ls_adr
    WITH side-labels FRAME f_vod.
    UPDATE
      vodokanal_ls_fio
      vodokanal_ls_adr
    WITH FRAME f_vod.

    if YES-NO("", "Сохранить изменения в справочнике водоканала?") then do transaction:
      if avail vodokanal-ls then do:
       find current vodokanal-ls exclusive-lock.
        assign
         vodokanal-ls.deldate = today
         vodokanal-ls.deltime = time
         vodokanal-ls.deluid = userid ("bank").
      end.
      create vodokanal-ls.
      assign
        vodokanal-ls.credate = today
        vodokanal-ls.uid = userid("bank")
        vodokanal-ls.cretime = time
        vodokanal-ls.num = vodokanal_ls_num
        vodokanal-ls.fio = vodokanal_ls_fio
        vodokanal-ls.adr = vodokanal_ls_adr.
      find current vodokanal-ls no-lock.
    end.

  end procedure.
