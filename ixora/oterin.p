 /* oterin.p
 * MODULE
       Коммунальные (прочие) платежи
 * DESCRIPTION
       ИВЦ/Алсеко/Водоканал/АПК - ввод платежа
 * AUTHOR
       13/03/04 kanat
 * CHANGES
       14/03/04 kanat номера договоров теперь пишутся в commonpl.diskont и можно редактировать наименование получателя
       22/04/04 kanat Добавил возможность формирования и печати квитанции по просьбе ДРР
       29/06/04 kanat в связи с появлением нового справочника по КСК - добавлена возможность автоматического протавления реквизитов
                      получателей.
       04.08.04 saltanat - добавлено передача параметров в процедуру oterprn(rids, v-kods, v-kbes, v-knps)
       30.09.04 kanat - добавлено передача commonls.type в прочие квитанции
       08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
       16.02.2005 kanat - за Асибо платежи идут без комиссий
       07.04.2005 kanat - за ЭКО платежи идут без комиссий и убрал лишний вывод сообщений о неверный контрольных суммах по РНН
                          при вводе квитанций
      6/01/2005 u00568(Evgeniy) - Добавленf возможность выбора комиссии по F2 чтобы не брать комиссию с ВОВ
             и для филиалов в том числе по ТЗ 188 от 30/11/2005 от ДДР и по ТЗ 175 от 16/11/2005 от ДДР
             и теперь всем обязательно вностить номер удостоверения ВОВ, всем филиалам, и нельзя откосить от этого  кнопкой <Tab>
      03/03/06 u00568 Evgeniy - РНН! в справочник физ лиц РНН (rnn) в поле comm.rnn.info[1] = 'ВОВ, ветеран, номер уд. ' + v-vov-name
                       пишется номер удостоверения ВОВ, и при последующем платеже этого физика комиссия автоматом станет льготная.
      28/03/06 u00568 Evgeniy чтобы верно считало количество вкладчиков
      24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
      02/05/06 u00568 Evgeniy - для получателей КСК "ЭКО" и КСК "Ернар"  РНН '600800034120' и '600800039693' код комиссии "711".
      04/05/06 u00568 Evgeniy - по дополнению к ТЗ 175 всегда 710 код для всех филиалов.
      25/09/06 u00568 Evgeniy - 710 код для всех новых филиалах тоже..
      28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
*/


{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

{get-dep.i}
{yes-no.i}
{comm-com.i}
{comm-rnn.i}
{getfromrnn.i}


define shared variable g-ofc as character.

/*def var KOd_ as char no-undo.
def var KBe_ as char no-undo.
def var KNp_ as char no-undo.*/

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.

define buffer oldb for commonpl.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then
  if lookup (g-ofc, sysc.chval) > 0 then
    canprn = yes.

def var choice2 as logical init true  no-undo.
def var evnt as logical initial false  no-undo.
def var mark as int no-undo.
def var cret as char init "" no-undo.
def var rnnlg as logical no-undo.

def new shared var numtns as integer init 0.
/*def new shared var riddolg as char init "0x000000000".*/

def var result_rnn as logical init false.
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
def shared var doctgrp  as integer.
def shared var docarp   as char    format "x(10)".
def shared var docsum      as decimal format ">>>,>>>,>>>,>>9.99".
def shared var doccomsum   as decimal format ">>>,>>>,>>9.99".
def        var doccomcode  like commonpl.comcode init '##'.
/*def        var doccomcode1  like doccomcode init '##'.*/
def shared var docprc   as integer  format "9.9999". /* Процент с АРП */
def shared var bsdate   as date.
def shared var esdate   as date.
def shared var selgrp   as integer init 9. /* Прочие платежи организаций */
def shared var docnumber as char.
def shared var dockts  as char init "".
def shared var v-benef as char init "".

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
def var colord as int init 1 format "zzzzzz9" no-undo.
def var cdate as date init today no-undo.
/*def var tarif2_num like tarif2.num init '7'*/

def var s_rid as char no-undo.
def var s_payment as char no-undo.

def shared var v-kods as char.       /*chval[1]*/
def shared var v-kbes as char.       /*chval[2]*/
def shared var v-knps as char.       /*chval[3]*/
def shared var v-bentype as integer. /*chval[4]*/
define variable candel as log no-undo.
def var rid_rnn as rowid no-undo.
def var vov_str as char init 'ВОВ, ветеран, номер уд. ' no-undo.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then
  if lookup (userid("bank"), sysc.chval) = 0 then
    candel = no.

define buffer bcommpl for commonpl.

def var v-vov-name as char no-undo.
def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.

def frame sf
    g-today         view-as text                              no-label
    docnum          view-as text                              label "Квитанция"                    at 15 skip
    docrnn                       format "999999999999"        label "*РНН отправителя"   help "F2 - ПОИСК,  F3 - РЕДАКТИРОВАНИЕ" skip
    docfioadr                    format "x(55)"               label "ФИО"                          skip
    docrnnbn                     format 'x(12)'               label "*РНН получателя"              skip
    v-benef                      format "x(40)"               label "Наименование получателя"      help "F2 - ВЫБОР ПОЛУЧАТЕЛЯ (КСК)" skip
    dociik                       format "999999999"           label "*ИИК (Получатель)"
    docbik                       format "999999999"           label "*БИК (Получатель)"            at 30 skip
    docbank         view-as text format "x(40)"               label "Банк"                         skip
    docnumber                    format 'x(12)'               label "Лицевой счет/Номер договора"  skip
    docnpl                       format "x(40)"               label "*Назначение"                  skip
    docsum                       format ">>>,>>>,>>9.99"      label "*Сумма"                       skip
    v-bentype validate (v-bentype <= 3 and v-bentype > 0, "Не верный тип платежа!")   format "9"   label "Тип платежа"  help "F2 - ВЫБОР ТИПА ПЛАТЕЖА" skip
    v-kods                       format "x(2)"                label "*Код дебитора"                skip
    v-kbes                       format "x(2)"                label "*Код бенефициара"             skip
    v-knps                       format "x(3)"                label "*КНП"                         skip
    dockbk                       format "x(6)"                label "КБК"                          skip
    lcom                         format ":/:"                 label "Комиссия (y/n)"               skip
    comchar         view-as text format 'x(30)'               no-label
    doccomsum       view-as text format ">>>,>>9.99"          label "Сумма комиссии"               skip
    colord          validate (colord > 0, "Не верное количество плательщиков!") label "Количество чел."
    with side-labels row 1 column 2 centered.



    on value-changed of colord in frame sf do:
      if integer(colord:screen-value) >= 1 then do:
        doccomsum = doccomsum / colord no-error.
        colord = integer(colord:screen-value).
        doccomsum = doccomsum * colord no-error.
        displ doccomsum with frame sf.
      end.
    end.


    on value-changed of docsum in frame sf do:
        docsum = decimal(docsum:screen-value).
        run choose_doccomcode_calc_and_displ_sums.
        apply "value-changed" to self.
    end.


    on value-changed of docnumber in frame sf do:
        docnumber = docnumber:screen-value.
        apply "value-changed" to docnumber.
    end.

    on value-changed of docfioadr in frame sf do:
        docfioadr = docfioadr:screen-value.
        apply "value-changed" to docfioadr.
    end.

    on value-changed of dockbk in frame sf do:
        dockbk = dockbk:screen-value.
        apply "value-changed" to dockbk.
    end.

/*
    on value-changed of v-bentype in frame sf do:
        v-bentype = integer(v-bentype:screen-value).
    if integer(v-bentype:screen-value) = 1 then do:
        v-kods = "14".
        v-kbes = "17".
        v-knps = "890".
    end.
    if integer(v-bentype:screen-value) = 2 then do:
        v-kods = "14".
        v-kbes = "17".
        v-knps = "856".
    end.
    if integer(v-bentype:screen-value) = 3 then do:
        v-kods = "14".
        v-kbes = "11".
        v-knps = "911".
    end.
        update v-kods:screen-value = v-kods with frame sf.
        update v-kbes:screen-value = v-kbes with frame sf.
        update v-knps:screen-value = v-knps with frame sf.
    end.
*/

    on help of v-bentype in frame sf
    do:
        run otrtpsel.
        update v-bentype:screen-value = string(v-bentype) with frame sf.
        update v-kods:screen-value = v-kods with frame sf.
        update v-kbes:screen-value = v-kbes with frame sf.
        update v-knps:screen-value = v-knps with frame sf.
    end.

    on value-changed of v-kods in frame sf do:
        v-kods = v-kods:screen-value.
        apply "value-changed" to v-kods.
    end.

    on value-changed of v-kbes in frame sf do:
        v-kbes = v-kbes:screen-value.
        apply "value-changed" to v-kbes.
    end.

    on value-changed of v-knps in frame sf do:
        v-knps = v-knps:screen-value.
        apply "value-changed" to v-knps.
    end.

    on value-changed of docrnn in frame sf do:
        docrnn = docrnn:screen-value.
        if newdoc and doccomcode='24' then do:
          doccomcode = "##".
          v-vov-name = ''.
          run choose_doccomcode_calc_and_displ_sums.
        end.
        find first rnn where rnn.trn = docrnn USE-INDEX rnn
        no-lock no-error.
        if avail rnn then do:
            if newdoc and entry(1,comm.rnn.info[1],',') = 'ВОВ' then do:
              v-vov-name = comm.rnn.info[1].
              v-vov-name = substr(v-vov-name, length(vov_str + ' '), length(v-vov-name)) no-error.
              doccomcode = "24".
              run choose_doccomcode_calc_and_displ_sums.
            end.
            release rnnu.
            rid_rnn = rowid(rnn).
            rnnValid  = true.
            docFIO = caps(getfio()).
            docADR = caps(getadr()).
            docfioadr = trim(docfio).
        end.
        else do:
            find first rnnu where rnnu.trn = docrnn:screen-value USE-INDEX rnn no-lock no-error.
            if avail rnnu then do:
                rnnValid  = true.
                release rnn.
                docFIO = caps(getfio()).
                docADR = caps(getadr()).
                docfioadr = trim(docfio).
            end.
            else do:
                rnnValid = false.
            end.
        end.
        update docfioadr:screen-value = docfioadr with frame sf.
    end.

    on value-changed of docrnnbn in frame sf do:
        if docrnnbn:screen-value <> "" then do:
          find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.rnn = docrnnbn no-lock no-error.
          if not avail commonls then do:
            docrnnbn =  docrnnbn:screen-value.
              find first rnnu where rnnu.trn = docrnnbn:screen-value USE-INDEX rnn no-lock no-error.
                if avail rnnu then do:
                  v-benef = caps(trim( rnnu.busname )).
                end.
            update v-benef:screen-value = v-benef with frame sf.
          end.
        end.
    end.

/*
    on help of docrnn in frame sf do:
        disable all with frame sf.
        run taxfind.
        enable all
            except doccomsum docnum g-today
                with frame sf.
        if return-value <> "" then do:
            update docrnn:screen-value = return-value with frame sf.
            update docrnn = return-value with frame sf.
        end.
        apply "value-changed" to self.
    end.
*/


    on help of docrnnbn in frame sf do:
/*
        if docrnnbn:screen-value <> "" then do:
*/
        disable all with frame sf.
        run otrnnufd.
        enable all
            except doccomsum docnum g-today
                with frame sf.
        if return-value <> "" then do:
            update docrnnbn:screen-value = return-value with frame sf.
            update docrnnbn = return-value with frame sf.
        end.
        apply "value-changed" to self.
/*
        end.
*/
    end.


    on help of v-benef in frame sf do:
        disable all with frame sf.
        run ChooseType.
        enable all
            except doccomsum docnum g-today
                with frame sf.
    end.


    on "enter-menubar" of docrnn in frame sf do:
       if not comm-rnn (docrnn:screen-value) and length(docrnn:screen-value) = 12 then
       do:
       if yes-no ("", "Редактировать РНН " + docrnn:screen-value + " ?") then
       do:
          run taxrnnin (docrnn:screen-value).
          apply "value-changed" to docrnn in frame sf.
       end.
       end.
       else message "Не верный РНН!~nНельзя редактировать!" view-as alert-box title "".
    end.


    on "enter-menubar" of docrnnbn in frame sf do:
       if not comm-rnn (docrnnbn:screen-value) and length(docrnnbn:screen-value) = 12 then
       do:
       if yes-no ("", "Редактировать РНН " + docrnnbn:screen-value + " ?") then
       do:
          run taxrnnin (docrnnbn:screen-value).
          apply "value-changed" to docrnnbn in frame sf.
       end.
       end.
       else message "Не верный РНН!~nНельзя редактировать!" view-as alert-box title "".
    end.


    on return of docrnn in frame sf do:
        IF  (  can-find( first rnn where rnn.trn = docrnn no-lock) or
               can-find( first rnnu where rnnu.trn = docrnn no-lock)
            )  or
            (  length(docrnn) = 12 and yes-no("", "РНН не найден в справочнике.~nПродолжить с введенным РНН?")
               and
               not comm-rnn (docrnn)
            )
            then result_rnn = true.
            else result_rnn = false.
        IF result_rnn and LENGTH(docrnn:screen-value) = 12 and
        not can-find(first rnn where rnn.trn = docrnn:screen-value no-lock)
        and not can-find(first rnnu where rnnu.trn = docrnn:screen-value no-lock)
        then do:
             if yes-no ("", "Редактировать РНН " + docrnn:screen-value + " ?")
             then run taxrnnin(docrnn:screen-value).
             apply "value-changed" to docrnn in frame sf.

             IF (can-find( first rnn where rnn.trn = docrnn:screen-value no-lock) or
                 can-find( first rnnu where rnnu.trn = docrnn:screen-value no-lock) or
                 length(docrnn:screen-value) = 12)
                 and  (not comm-rnn (docrnn:screen-value))
                 then result_rnn = true.
                 else assign result_rnn = false.
            end.
    end.


    on return of docrnnbn in frame sf do:
        IF  (  can-find( first rnn where rnn.trn = docrnnbn no-lock) or
               can-find( first rnnu where rnnu.trn = docrnnbn no-lock)
            )  or
            (  length(docrnnbn) = 12 and yes-no("", "РНН не найден в справочнике.~nПродолжить с введенным РНН?")
               and
               not comm-rnn (docrnnbn)
            )
            then result_rnn = true.
            else result_rnn = false.
        IF result_rnn and LENGTH(docrnnbn:screen-value) = 12 and
        not can-find(first rnn where rnn.trn = docrnnbn:screen-value no-lock)
        and not can-find(first rnnu where rnnu.trn = docrnnbn:screen-value no-lock)
        then do:
             if yes-no ("", "Редактировать РНН " + docrnnbn:screen-value + " ?")
             then run taxrnnin(docrnnbn:screen-value).
             apply "value-changed" to docrnnbn in frame sf.

             IF (can-find( first rnn where rnn.trn = docrnnbn:screen-value no-lock) or
                 can-find( first rnnu where rnnu.trn = docrnnbn:screen-value no-lock) or
                 length(docrnnbn:screen-value) = 12)
                 and  (not comm-rnn (docrnnbn:screen-value))
                 then result_rnn = true.
                 else assign result_rnn = false.
            end.
    end.

    on value-changed of docbik in frame sf do:
        docbik = integer(docbik:screen-value).
        find first bankl where bankl.bank = string(docbik) USE-INDEX bank no-lock no-error.
        if avail bankl then update docbank = bankl.name.
        update docbank:screen-value = docbank with frame sf.
        apply "value-changed" to self.
    end.


    on help of lcom in frame sf do:
        case seltxb:
          WHEN 0 then run comtar("7","24,##").
          WHEN 1 then run comtar("7","24,##").
          WHEN 3 then run comtar("7","24,##").
          OTHERWISE run comm-coms.
        end.
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




/*Main logic ---------------------------------------------------------------> */


do while choice2:
  choice2 = false.
  run choose_doccomcode_calc_and_displ_sums.
  if newdoc then do:
    find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.visible = yes and type = 1 no-lock no-error.
    if avail commonls then do:
      assign
       seltxb     = commonls.txb
       doctype    = commonls.type
       docbn      = commonls.bn
       docarp     = commonls.arp
       docgrp     = commonls.grp
       doctgrp    = commonls.typegrp
       dociik = 0
       docbik = 0
       docfioadr = " "
       docnumber = " "
       docrnnbn = " "
       docnpl = " "
       docsum = 0
       v-benef = " "
       v-bentype = 1
       dockbk = ""
       docbank = ""
       docrnn = "".

       run choose_doccomcode_calc_and_displ_sums.
    end.
/*
    run ChooseType.
    if return-value = "" or return-value = ? then leave.
*/
    find last bcommpl where bcommpl.date = g-today and bcommpl.dnum > 0 and bcommpl.dnum < 10000 and bcommpl.txb = seltxb
                      and bcommpl.grp = selgrp use-index datenum no-lock no-error.
    if avail  bcommpl then do:
      docnum = bcommpl.dnum + 1.
    end. else
      docnum = 1.
  end. else do:
    find commonpl where rowid(commonpl) = rid.
    assign
      seltxb    = commonpl.txb
      docnum    = commonpl.dnum
      doctype   = commonpl.type
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
      doccomcode = commonpl.comcode
      colord   = commonpl.z
      docnumber = commonpl.diskont
      dociik = integer(commonpl.info[2])
      docbik = integer(commonpl.info[3])
      v-kods = commonpl.chval[1]
      v-kbes = commonpl.chval[2]
      v-knps = commonpl.chval[3]
      v-bentype = integer(commonpl.chval[4])
      dockbk = string(commonpl.kb)
      v-benef = commonpl.info[4]
    no-error.
    if trim(docfioadr) = "" then
      docfioadr = trim(docfio)  + ", " + trim(docadr).
    update docrnn:screen-value = docrnn with frame sf.
    apply "value-changed" to docrnn.
/*
    find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.type = doctype
         and commonls.visible = yes no-lock no-error.
    if avail   commonls then
       assign
        dockod = commonls.kod
        dockbe = commonls.kbe
        no-error.
*/
  end.

  find first tarif2 where tarif2.num = '7' and tarif2.kod = doccomcode
    and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then
    comchar = tarif2.pakalp.
  else
    comchar = "Сейчас нет такого тарифа.".

  displ
         g-today
         docrnn
         docfioadr
         docnum
         docrnnbn
         v-benef
         dociik
         docbik
         docbank
         docnumber
         docnpl
         docsum
         v-bentype
         v-kods
         v-kbes
         v-knps
         dockbk
         lcom
         comchar
         doccomsum
         colord
  WITH side-labels FRAME sf.

  if frame-field = "docrnn" then
      apply "value-changed" to docrnn in frame sf.
  if frame-field = "docrnnbn" then
      apply "value-changed" to docrnnbn in frame sf.
  if frame-field = "dociik" then
      apply "value-changed" to dociik in frame sf.
  if frame-field = "docbik" then
      apply "value-changed" to docbik in frame sf.
  if frame-field = "docnumber" then
      apply "value-changed" to docnumber in frame sf.
  if frame-field = "docnpl" then
      apply "value-changed" to docnpl in frame sf.
  if frame-field = "docsum" then
      apply "value-changed" to docsum in frame sf.
  if frame-field = "v-benef" then
      apply "value-changed" to v-benef in frame sf.
  if frame-field = "v-bentype" then
      apply "value-changed" to v-bentype in frame sf.
  if frame-field = "v-kods" then
      apply "value-changed" to v-kods in frame sf.
  if frame-field = "v-kbes" then
      apply "value-changed" to v-kbes in frame sf.
  if frame-field = "v-knps" then
      apply "value-changed" to v-knps in frame sf.

  if frame-field = "dockbk" then
      apply "value-changed" to dockbk in frame sf.
  if frame-field = "lcom" then
      apply "value-changed" to lcom in frame sf.
  if frame-field = "colord" then
      apply "value-changed" to colord in frame sf.

  run choose_doccomcode_calc_and_displ_sums.
  if newdoc or commonpl.rmzdoc = ? then do:
    if not newdoc then do:
       find last bcommpl where bcommpl.txb = seltxb and
                         bcommpl.date = commonpl.date and
                         bcommpl.grp = selgrp
                         and bcommpl.dnum > 0
                         and bcommpl.dnum < 10000
                         use-index datenum no-lock no-error.
       if avail bcommpl then
         docnum = bcommpl.dnum + 1.
       else
         docnum = 1.
       create oldb.
       buffer-copy commonpl to oldb.
       commonpl.chval[5] = "0".
       assign oldb.deldate = g-today
              oldb.deltime = time
              oldb.deluid = userid ("bank")
              oldb.delwhy = "Изменение реквизитов"
              oldb.deldnum = docnum.
    end.
    if newdoc or candel then do:
      update
        docrnn validate(
            (can-find( first rnn where
            rnn.trn = docrnn no-lock) or
            can-find( first rnnu where
            rnnu.trn = docrnn no-lock) or
            length(docrnn) = 12) and
            not comm-rnn (docrnn)
            ,"Не верный контрольный ключ РНН!")
        docfioadr
        docrnnbn
        v-benef
        dociik
        docbik
        docnumber
        docnpl
        docsum
        v-bentype
        v-kods
        v-kbes
        v-knps
        dockbk
        lcom
        colord
      WITH FRAME sf editing:
        readkey.
        apply lastkey.
        if frame-field = "docrnn" then
            apply "value-changed" to docrnn in frame sf.
        if frame-field = "docrnnbn" then
            apply "value-changed" to docrnnbn in frame sf.
        if frame-field = "dociik" then
            apply "value-changed" to dociik in frame sf.
        if frame-field = "docbik" then
            apply "value-changed" to docbik in frame sf.
        if frame-field = "docnumber" then
            apply "value-changed" to docnumber in frame sf.
        if frame-field = "docnpl" then
            apply "value-changed" to docnpl in frame sf.
        if frame-field = "docsum" then
            apply "value-changed" to docsum in frame sf.
        if frame-field = "v-benef" then
            apply "value-changed" to v-benef in frame sf.
        if frame-field = "v-bentype" then
            apply "value-changed" to v-bentype in frame sf.
        if frame-field = "v-kods" then
            apply "value-changed" to v-kods in frame sf.
        if frame-field = "v-kbes" then
            apply "value-changed" to v-kbes in frame sf.
        if frame-field = "v-knps" then
            apply "value-changed" to v-knps in frame sf.
        if frame-field = "dockbk" then
            apply "value-changed" to dockbk in frame sf.
        if frame-field = "lcom" then
            apply "value-changed" to lcom in frame sf.
        if frame-field = "colord" then
            apply "value-changed" to colord in frame sf.
      end.
    end. else
      update
        docrnn validate(
            (can-find( first rnn where
            rnn.trn = docrnn no-lock) or
            can-find( first rnnu where
            rnnu.trn = docrnn no-lock) or
            length(docrnn) = 12) and
            not comm-rnn (docrnn)
            ,"Не верный контрольный ключ РНН!")
        docfioadr
        docrnnbn
        v-benef
        dociik
        docbik
        docnumber
        docnpl
        v-bentype
        v-kods
        v-kbes
        v-knps
        dockbk
        WITH FRAME sf editing:
          readkey.
          apply lastkey.
          if frame-field = "docrnn" then
              apply "value-changed" to docrnn in frame sf.
          if frame-field = "docfioadr" then
              apply "value-changed" to docfioadr in frame sf.
          if frame-field = "docrnnbn" then
              apply "value-changed" to docrnnbn in frame sf.
          if frame-field = "dociik" then
              apply "value-changed" to dociik in frame sf.
          if frame-field = "docbik" then
              apply "value-changed" to docbik in frame sf.
          if frame-field = "docnumber" then
              apply "value-changed" to docnumber in frame sf.
          if frame-field = "docnpl" then
              apply "value-changed" to docnpl in frame sf.
          if frame-field = "v-benef" then
              apply "value-changed" to v-benef in frame sf.
          if frame-field = "v-bentype" then
              apply "value-changed" to v-bentype in frame sf.
          if frame-field = "v-kods" then
              apply "value-changed" to v-kods in frame sf.
          if frame-field = "v-kbes" then
              apply "value-changed" to v-kbes in frame sf.
          if frame-field = "v-knps" then
              apply "value-changed" to v-knps in frame sf.
          if frame-field = "dockbk" then
              apply "value-changed" to dockbk in frame sf.
        end.

    MESSAGE "Сохранить?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Прочие платежи" UPDATE choice as logical.
    if not choice then
      delete oldb no-error.
    if choice and (docrnnbn = "" or
                   docbik = 0 or
                   dociik = 0 or
                   docnpl = "" or
                   docrnn = "" or
                   docfioadr = "" or
                   docsum = 0 or
                   v-kods = "" or
                   v-kbes = "" or
                   v-knps = "") then
    do:
      message "Отсутствуют обязательные реквизиты: " view-as alert-box title "Внимание".
      return.
    end.

    case choice:
      when true then do:
        do /*transaction*/:
          if newdoc then
            CREATE commonpl no-error.

          if newdoc then do:
            if doccomcode = "24" and trim(v-vov-name) = "" then do:
              message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
              undo,retry.
            end. else do:
              commonpl.info[5] = v-vov-name.
              run update_rnn_for_veteran.
            end.
          end.
          if newdoc then do:
             commonpl.credate = today.
             commonpl.cretime = time.
             commonpl.dnum    = docnum.
             commonpl.rko     = get-dep(userid("bank"), g-today).
             commonpl.uid     = userid("bank").
          end. else do:
             commonpl.rko     = get-dep(commonpl.uid, g-today).
             commonpl.dnum    = docnum.
             commonpl.euid    = userid ("bank").
             commonpl.edate   = today.
             commonpl.etim    = time.
          end.

          assign
             commonpl.date    = g-today
             commonpl.diskont = trim(docnumber)
             commonpl.txb     = seltxb
             commonpl.type    = doctype
             commonpl.sum     = docsum
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
             commonpl.info[2] = string(dociik,"999999999")
             commonpl.info[3] = string(docbik,"999999999")
             commonpl.chval[1] = v-kods
             commonpl.chval[2] = v-kbes
             commonpl.chval[3] = v-knps
             commonpl.chval[4] = string(v-bentype)
             commonpl.kb = integer(dockbk)
             commonpl.info[4] = v-benef
          no-error.

          cret = string(rowid(commonpl)).
          rids = rids + cret.
        end. /* transaction */
      end.
      otherwise leave.
    end case.
  end.  /*if newdoc or commonpl.rmzdoc = ?*/

  choice2 = false.
  find current commonpl no-lock.
  s-rnn = docrnn.
END.  /* While */

hide frame sf.

if rids <> "" then do:
  run oterkvit(rids).
  MESSAGE "Распечатать ордер?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
  TITLE "Стан.Диаг." UPDATE choice4 as logical.
  case choice4:
    when true then
      run oterprn(rids, v-kods, v-kbes, v-knps).
  end case.
end.

return cret.

Procedure ChooseType.
 DEFINE QUERY q1 FOR commonls.
 def browse b1
    query q1 no-lock
    display
        fill(" ",12)  format "x(12)"
        commonls.type   format '>9'
        commonls.bn     label "Тип" format 'x(15)'
        fill(" ",12)  format "x(12)"
        with no-labels 15 down title "Получатель платежа".
 def frame fr1
    b1
    with centered overlay view-as dialog-box.

 on return of b1 in frame fr1
    do:
      rid = rowid(commonls).
      find first commonls where rowid(commonls) = rid no-lock no-error.
      if avail commonls then
       assign
        v-benef   = commonls.bn
        dociik    = commonls.iik
        docbik    = commonls.bik
        docnpl    = commonls.npl
        v-kods    = commonls.kod
        v-kbes    = commonls.kbe
        v-knps    = commonls.knp
        dockbk    = commonls.kbk
        docrnnbn  = commonls.rnn
        doctype   = commonls.type
        no-error.

        update v-benef :screen-value    = v-benef with frame sf.
        update dociik  :screen-value    = string(dociik) with frame sf.
        update docbik  :screen-value    = string(docbik) with frame sf.
        update docnpl  :screen-value    = docnpl with frame sf.
        update v-kods  :screen-value    = v-kods with frame sf.
        update v-kbes  :screen-value    = v-kbes with frame sf.
        update v-knps  :screen-value    = v-knps with frame sf.
        update dockbk  :screen-value    = dockbk with frame sf.
        update docrnnbn:screen-value    = docrnnbn with frame sf.

       apply "endkey" to frame fr1.
    end.

 open query q1 for each commonls where commonls.txb = seltxb and commonls.visible = yes and commonls.grp = selgrp and commonls.type <> 1
                                       use-index type no-lock.
   b1:SET-REPOSITIONED-ROW (7, "CONDITIONAL").
   ENABLE all with frame fr1.
   if (not candel) and (not newdoc) then disable docrnn docsum with frame sf.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR endkey of frame fr1.
 hide frame fr1.
 return "ok".
end.


procedure update_rnn_for_veteran:
  if v-vov-name <> '' then do:
    do transaction:
      find comm.rnn where rowid(rnn) = rid_rnn no-error.
      if avail comm.rnn then
         if comm.rnn.trn = docrnn then comm.rnn.info[1] = vov_str + v-vov-name.
    end. /* transaction */
  end.
end.


procedure choose_doccomcode_calc_and_displ_sums:
      if doccomcode <> "24" then do:
        doccomcode = get_tarifs_common(seltxb, selgrp, docrnnbn, false).
      end.
      /* calc_and_displ_sums считаем и выводим суммы */
      doccomsum = comm-com-1(docsum, doccomcode, '7', comchar) * colord.
      displ
        doccomsum
        comchar
      with frame sf.
end.
