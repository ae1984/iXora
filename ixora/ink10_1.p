/* ink10_1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Полное приостановление операций за исключением пенсионных платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.6.2.1
 * AUTHOR
        07/10/2004 dpuchkov
 * BASES
      BANK COMM
 * CHANGES
     20/10/2009 galina - забросила из старой библиотеки с добавлением приостановлений за исключением СО
     03.11.2009 galina - изменила on help для поля aas.bnf
     05.02.2010 galina - расширение поля счета до 20 знаков
     08/02/2010 galina - поправила статус для поиска в истории
     06/01/2011 marinav - наименование НК берется из taxnk
     18.05.2011 ruslan - добавил функцию on help of
     20/06/2011 evseev - из-за перехода на ИИН/БИН, ink10 переименован в ink10_1
     21/06/2011 evseev - перекомпиляция
     22/06/2011 evseev - удалил и добавил в src
     20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
     15.08.2011 ruslan - изменил основание
     28/04/2012 evseev - логирование значения aaa.hbal
     18.06.2012 evseev - отструктурировал код. вынес save_data в aas2his.i и переименовал в aas2his. добавил mn
 */
{yes-no.i}
{mainhead.i CFSIENT}
/*{comm-txb.i}*/

/* блок объявления переменных ->*/
    def temp-table t-aashist like aas_hist
           field ctc as char.
    def temp-table t-journal
           field num as integer
           field sts as char
           field name as char
           field dt as date
           field tm as char
           field docnum   like aas.docnum
           field docdat   like aas.docdat
           field dpname   like aas.dpname
           field bnf   like aas.bnf
           field docnum1  like aas.docnum1
           field docdat1  like aas.docdat1
           field docprim1 like aas.docprim1
           field chgoper like aas_hist.chgoper
           field payee like aas.payee
           field kbk like aas.kbk.
    def temp-table t-ln
        field rnn as char
        field name as char
        index main is primary rnn ASC.

    def var vsele as char form "x(35)" extent 1 initial [" Просмотр истории спец. инструкций "].
    def var op_kod AS CHAR format "x(1)".
    def var p-ln LIKE aas_hist.ln.
    def var p-aaa LIKE aas_hist.aaa.
    def var s-aaa LIKE aaa.aaa.
    def var v-dep as integer.
    def var s_FindAcc as char format "x(20)".
    def var s_FindCIF as char format "x(6)".
    def var s_FindLogin as char format "x(10)".
    def var dt_FindDateBegin as date .
    def var dt_FindDateEnd as date .
    def var i_indx as integer.
    def var v-specin     AS char      INIT ''.
    def var v-speckr     AS char      INIT ''.
    def var dt_1 as date .
    def var dt_2 as date .
    def var v-cod as char.
    def var ch_acc like aaa.aaa.
    def var v-sta as integer.
    def var v-sel as integer.
    def var phand AS handle.
    def var v-cif1 AS char.
    def var v-dp3 as integer init 0.
    def var v-mn as char.

    def buffer pl-ofc  for ofc.
    def buffer b-ofc   for ofc.
    def buffer buf-ofc for ofc.
    def buffer b-aash  for aas_hist.
    def buffer buf for aas.
    def buffer buf1 for t-aashist .
    def buffer bufl for t-journal.
    def buffer b-cif for cif.

    def button bt_AddNew label "ДОБАВИТЬ НОВОЕ".
    def button bt_Find   label "ПОИСК".
    def button bdet      LABEL "Детали"  .
    def button bdel      LABEL "Удалить" .
    def button bext      LABEL "Выход"   .
    def button bprint    LABEL "Печать"  .
    def button bRedakt   LABEL "Изменить".
    def button bexit     LABEL "Выход"   .
    def button bdetail   LABEL "Свойства".
    def button brem      LABEL "Удалить" .
    def button bhistory  LABEL "История" .
    def button bdethis   LABEL "История операций".


    def query q-help FOR aaa, lgr.
    def query q1 FOR aas.
    def query q4 FOR  t-aashist .
    def query q5 FOR t-journal.

    def browse b-help query q-help
           DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
           aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
           WITH  15 DOWN.
    def browse b1 query q1 displ
        aas.cif format "x(6)" label "CIF-код"
        aas.aaa format "x(20)" label "Счет"
        aas.regdt format "99.99.99" label "Дата рег.  "
        aas.payee  format "x(40)" label "Примечание"
        with 20 down title "Приостановление операций за искл. плат в бюджет(действующие)" overlay.
    def browse b4 query q4 displ
          t-aashist.ln     format "99"  label 'N'
          t-aashist.cif  label 'CIF-код'
          t-aashist.aaa  format "x(20)" label 'Счет'
          t-aashist.regdt  label 'Дата рег'
          t-aashist.payee  format "x(29)" label 'Основание'
          t-aashist.ctc  format "x(12)" label 'Статус'
          with 20 down title "История спец. инструкций (текущие и удаленые)" overlay.
    def browse b5 query q5 displ
         t-journal.num format "99"  label 'N'
         t-journal.name format "x(50)" label 'Статус '
         with 20 down title "История операций"  overlay.

    def frame getlist1
       aas.aaa format "x(20)" label     "Номер счета      " skip
       aas.regdt label                   "Дата регистрации " skip
       aas.docnum label                "Номер документа  " help "Номер документа на основании которого накладывается ограничение" skip
       aas.docdat label                "Дата документа   " help "Дата документа на основании которого накладывается ограничение" skip
       aas.bnf format "x(40)" label                   "Орган огранич(F2)" help "Наименование органа выставившего ограничение" skip
       aas.dpname  format "x(16)"     label           "РНН              " skip
       aas.payee  label "Примечание       " skip
       with side-labels centered row 9.
    def frame getlist2
       aas.docnum1  label "Номер документа" help "Номер документа на основании которого снимается ограничение" skip
       aas.docdat1  label "Дата документа " help "Дата документа на основании которого снимается ограничение" skip
       aas.docprim1 label "Примечание     "  skip
       with side-labels centered row 8.
    def frame getlist3
      aas.who    label                "Логин менеджера блокирующего счет" skip
      aas.docnum label                "Номер документа блокирующего счет" skip
      aas.docdat label                "Дата документа блокирующего счет " skip
      aas.bnf format "x(35)" label "Организация, выставившая огранич." skip
      aas.dpname format "x(35)" label "РНН                              "
      with side-labels centered row 8.
    def frame getlock
      t-journal.docnum label                "Номер документа блокирующего счет   " skip
      t-journal.docdat label                "Дата документа блокирующего счет    " skip
      t-journal.bnf format "x(30)" label "Организация, выставившая ограничение" skip
      t-journal.payee  format "x(30)" label "Примечание                          " skip
      with side-labels centered row 8.
    def frame getunlock
      t-journal.docnum1 label                 "Номер документа разблокирующего счет" skip
      t-journal.docdat1 label                 "Дата документа разблокирующего счет " skip
      t-journal.docprim1 format "x(30)" label "Примечание                          " skip
      with side-labels centered row 8.
    def frame getlist5
      aas.who  label "Установил     " skip
      aas.regdt  label "Дата создания." skip
      aas.dpname format "x(25)" label "Орган огранич. " help "Наименование органа выставившего ограничение" skip
      aas.payee label "Примечание" help "Примечание"
      with side-labels centered row 8.
    def frame aacc
       ch_acc label "Счет" validate(ch_acc <> "", "Введите номер счета ")
       with side-labels centered row 8.
    def frame a2 bt_AddNew bt_Find with side-labels row 3 no-box.
    def frame f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
    def frame fr1 b1 skip bRedakt bprint bdetail brem bhistory bexit  with centered overlay row 3 top-only width 90.
    def frame fr4 b4 skip bexit bdethis with centered overlay row 3 top-only width 100.
    def frame fr5 b5 skip bdet bexit  with centered overlay row 3 top-only.
    def frame t_frame1 s_FindAcc label "Поиск по номеру счета" format "x(21)" with side-labels centered row 7.
    def frame t_frame2 s_FindCIF label "Поиск по CIF коду клиента" format "x(7)" with side-labels centered row 7.
    def frame t_frame3 s_FindLogin label "Введите логин менеджера" format "x(8)" with side-labels centered row 7.
/* <-блок объявления переменных*/

/* функции и процедуры ->*/
    PROCEDURE specindo.
        def var pack  as char init ''.
        def var i     as inte init 0.
        def var boole as logi init false.
        def var cha   as char init ''.

        find sysc where sysc.sysc = 'pkcon' no-lock no-error.
        if avail sysc then do:
           /* 11.11.2004 saltanat - Проставление признака Платежных карт с учетом прав доступа !!! на пакеты !!! */
           boole = false.
           find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
           if avail pl-ofc then do:
              if pl-ofc.expr[1] <> '' then do:
                 do i = 1 to num-entries(pl-ofc.expr[1]):
                    cha = entry(i,pl-ofc.expr[1]).
                    if lookup(cha,sysc.chval) > 0 then do:
                       boole = true.
                       leave.
                    end.
                 end.
              end.
           end.
           if lookup(g-ofc,sysc.chval) > 0 or boole then do:
              find current aas exclusive-lock.
              if aas.delaas = '' then do:
                 aas.delaas = 'd'.
                 v-specin   = '*'.
                 aas.specin = '*'.
              end. else do:
                 if aas.delaas = 'd' then do:
                    aas.delaas = ''.
                    v-specin   = ''.
                    aas.specin = ''.
                 end. else do:
                    message 'Стоит признак удаления Департамента Кредитного Администрирования!' view-as alert-box warning buttons ok.
                 end.
              end.
           end. else message 'У Вас нет прав работы с признаком удаления спец.инструкции Платежных карт! ' view-as alert-box warning buttons ok.
        end. else message 'Нет возможности работы с признаком удаления спец.инструкции Платежных карт! 'view-as alert-box warning buttons ok.
        find current aas no-lock.
    end PROCEDURE.
    PROCEDURE speckrdo.
        def var pack  as char init ''.
        def var i     as inte init 0.
        def var boole as logi init false.
        def var cha   as char init ''.

        find sysc where sysc.sysc = 'dkpriz' no-lock no-error.
        if avail sysc then do:
           boole = false.
           find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
           if avail pl-ofc then do:
              if pl-ofc.expr[1] <> '' then do:
                 do i = 1 to num-entries(pl-ofc.expr[1]):
                    cha = entry(i,pl-ofc.expr[1]).
                    if lookup(cha,sysc.chval) > 0 then do:
                       boole = true.
                       leave.
                    end.
                 end.
               end.
           end.
           if lookup(g-ofc,sysc.chval) > 0 or boole then do:
              find current aas exclusive-lock.
              if aas.delaas = '' then do:
                 aas.delaas = 'k'.
                 v-speckr   = '*'.
                 aas.speckr = '*'.
              end. else do:
                 if aas.delaas = 'k' then do:
                    aas.delaas = ''.
                    v-speckr   = ''.
                    aas.speckr = ''.
                 end. else do:
                    message 'Стоит признак удаления Департамента Платежных карт!' view-as alert-box warning buttons ok.
                 end.
              end.
           end. else message 'У Вас нет прав работы с признаком удаления спец.инструкции Кредитного Администрирования! ' view-as alert-box warning buttons ok.
        end. else message 'Нет возможности работы с признаком удаления спец.инструкции Кредитного Администрирования! 'view-as alert-box warning buttons ok.
        find current aas no-lock.
    end PROCEDURE.
/* <-функции и процедуры*/
{aas2his.i &db = "bank"}

find ofc where ofc.ofc = g-ofc no-lock no-error.

on help of aas.bnf in frame getlist1 do:
      empty temp-table t-ln.
      for each taxnk  no-lock use-index rnn1:
        create t-ln.
        assign t-ln.rnn = taxnk.rnn
               t-ln.name = taxnk.name.
      end.
      find first t-ln no-error.
      if not avail t-ln then do:
        message skip " Справочника нет !" skip(1) view-as alert-box button ok title "".
        return.
      end.
      {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 20 down overlay title 'Выберите налоговый комитет' "
       &where = " true "
       &flddisp = " t-ln.rnn label 'РНН' format 'x(12)'
                    t-ln.name label 'Наименование' format 'x(50)'"
       &chkey = "rnn"
       &chtype = "string"
       &index  = "main"
      }
      v-cod = frame-value.
      find first taxnk where taxnk.rnn = v-cod use-index rnn1 no-lock no-error.
      if avail taxnk then
         assign
           aas.dpname = taxnk.rnn
           aas.bnf = taxnk.name.
      display aas.dpname aas.bnf with frame getlist1.
end.
on help of ch_acc in frame aacc do:
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock no-error.
        if available aaa then do:
            OPEN query  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock, each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH frame f-help.
            wait-for return of frame f-help
            FOCUS b-help IN frame f-help.
            ch_acc = aaa.aaa.
            hide frame f-help.
        end. else do:
            ch_acc = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        end.
        displ  ch_acc with frame aacc.
    end.
    DELETE PROCEDURE phand.
end.

/*Новое*/
on choose of bt_AddNew in frame a2 do:
   v-mn = "6".
   repeat on endkey undo, return:
         v-sel = 0.
         run sel2(" Параметры ", " 1. Обязательные пенсионные отчисления| 2. Обязательные социальные отчисления | ВЫХОД ", output v-sel).
         if v-sel < 1 or v-sel >= 3 then return.
         if v-sel = 1 then do:
            v-sta = 16.
            v-mn = "61000".
            leave.
         end.
         if v-sel = 2 then do:
            v-sta = 17.
            v-mn = "62000".
            leave.
         end.
   end.
   repeat:
      update ch_acc with frame aacc.
      hide frame aacc.
      find last aaa where aaa.aaa = ch_acc no-lock no-error.
      if not available aaa then do:
         message "Счет не найден".
         pause 3.
      end. else do:
         if aaa.sta = 'C' then do:
            message skip "Счет " + aaa.aaa + " закрыт !" skip "Добавление спец. инструкций невозможно !" skip(1) view-as alert-box button Ok title "Внимание!".
            return.
         end.
         leave.
      end.
   end.
   hide frame aacc.
   if avail aaa then do:
      find last cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then do:
         message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".
      end.
      create aas.
      find last b-aash where b-aash.aaa = aaa.aaa and b-aash.ln <> 7777777  use-index aaaln no-lock no-error.
      if available b-aash then aas.ln = b-aash.ln + 1. else aas.ln = 1.
      find last cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then aas.cif = cif.cif.
      aas.aaa = aaa.aaa.
      if v-sta = 16 then  aas.payee = "РПРО агента пенс.отчислений".
      if v-sta = 17 then  aas.payee = "РПРО плательщика соц.отчислений".
      displ aas.aaa with frame getlist1.
      aas.whn = g-today.
      update aas.regdt aas.docnum aas.docdat aas.bnf aas.dpname aas.payee with frame getlist1.
      aas.sta = v-sta.
      aas.mn = v-mn.
      aas.chkamt = 100000000000.
      aas.activ = True.
      aas.contr = False.
      aas.tim = time.
      aas.who = g-ofc.
      find last cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then aas.cif = cif.cif.
      aas.sic = 'HB'.
      s-aaa = aaa.aaa.

      find first aaa where aaa.aaa = s-aaa exclusive-lock.
      run savelog("aaahbal", "ink10_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
      aaa.hbal = aaa.hbal + aas.chkamt.

      hide frame getlist1.
      FIND FIRST b-ofc WHERE b-ofc.ofc = g-ofc NO-LOCK.
      aas.point = b-ofc.regno / 1000 - 0.5.
      aas.depart = b-ofc.regno MODULO 1000.
      op_kod = 'A'.
      RUN aas2his.
   end.
end.

/*Поиск*/
on choose of bt_Find in frame a2 do:
   ON "GO" of b1 IN frame fr1 DO:
      RUN specindo.
      browse b1:refresh().
   end.
   ON "GET" of b1 IN frame fr1 DO:
      RUN speckrdo.
      browse b1:refresh().
   end.
   ON CHOOSE OF bhistory IN frame fr1 do:
      ON CHOOSE OF bexit IN frame fr4 do:
         message "". pause 0.
         hide frame fr4.
         APPLY "WINDOW-CLOSE" TO browse b4.
      end.
      ON CHOOSE OF bdethis IN frame fr4 do: /*История операций*/
         message "". pause 0.
         find buf1 where rowid (buf1) = rowid (t-aashist) exclusive-lock.
         if not avail buf1 then return.
         ON CHOOSE OF bexit IN frame fr5 do:
            message "". pause 0.
            hide frame fr5.
            APPLY "WINDOW-CLOSE" TO browse b5.
         end.
         ON CHOOSE OF bdet IN frame fr5 do: /*Детали*/
            find bufl where rowid (t-journal) = rowid (bufl) exclusive-lock.
            if avail bufl then do:
               if bufl.chgoper = "A" or  bufl.chgoper = "E" then do:
                  displ t-journal.docnum t-journal.docdat t-journal.bnf t-journal.payee  with frame getlock.
                  hide frame getlock.
               end.
               if t-journal.chgoper = "D" then do:
                  displ t-journal.docnum1 t-journal.docdat1 t-journal.docprim1 with frame getunlock.
                  hide frame getunlock.
               end.
            end.
         end.
         for each t-journal :
             delete t-journal.
         end.
         for each aas_hist where aas_hist.aaa = t-aashist.aaa  and aas_hist.ln = t-aashist.ln exclusive-lock use-index aasprep:
             find first ofc where ofc.ofc = aas_hist.who no-lock.
             create t-journal.
             t-journal.num = aas_hist.ln.
             if      aas_hist.chgoper = 'A' then t-journal.name = "Введена  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
             else if aas_hist.chgoper = 'E' then t-journal.name = "Изменена [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
             else if aas_hist.chgoper = 'D' then t-journal.name = "Удалена  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
             else t-journal.name =  "                    ***" .
             t-journal.docnum   = aas_hist.docnum  .
             t-journal.docdat   = aas_hist.docdat  .
             t-journal.dpname   = aas_hist.dpname  .
             t-journal.docnum1  = aas_hist.docnum1 .
             t-journal.docdat1  = aas_hist.docdat1 .
             t-journal.docprim1 = aas_hist.docprim1.
             t-journal.chgoper  = aas_hist.chgoper .
             t-journal.payee = aas_hist.payee      .
             find first taxnk where taxnk.rnn = aas_hist.dpname no-lock no-error.
             if  avail taxnk then aas_hist.bnf = taxnk.name.
             t-journal.kbk = aas_hist.kbk.
             t-journal.bnf = aas_hist.bnf.
         end.
         open query q5 for each t-journal no-lock.
         b5:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
         ENABLE all with frame fr5 centered overlay top-only.
         apply "value-changed" to b5 in frame fr5.
         WAIT-FOR WINDOW-CLOSE of frame fr5.
      end.
      for each t-aashist.
          delete t-aashist.
      end.
      p-aaa = ''.
      p-ln = 0.
      for each aas_hist where aas_hist.aaa = aas.aaa and aas_hist.sta = v-sta NO-LOCK USE-INDEX aasprep:
          if aas_hist.ln <> p-ln then do transaction:
             p-aaa = aas_hist.aaa.
             p-ln = aas_hist.ln.
             create t-aashist.
             t-aashist.aaa = aas_hist.aaa.
             t-aashist.ln  = aas_hist.ln.
             t-aashist.sic = aas_hist.sic.
             t-aashist.chkdt = aas_hist.chkdt.
             t-aashist.chkno = aas_hist.chkno.
             t-aashist.chkamt = aas_hist.chkamt.
             t-aashist.payee = aas_hist.payee.
             t-aashist.chgoper = aas_hist.chgoper.
             t-aashist.who = aas_hist.who.
             t-aashist.tim = aas_hist.tim.
             t-aashist.cif = aas_hist.cif.
             if aas_hist.chgoper = "D" then t-aashist.ctc = " [Удалена]". else t-aashist.ctc = " [Действует]".
          end.
      end.
      message "Ждите идет поиск" .
      open query q4 for each t-aashist where t-aashist.aaa = aas.aaa no-lock.
      message " " . pause 0.
      b4:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
      ENABLE all with frame fr4 centered overlay top-only.
      apply "value-changed" to b4 in frame fr4.
      WAIT-FOR WINDOW-CLOSE of frame fr4.
   end.
   ON CHOOSE OF bRedakt IN frame fr1 do:
      find buf where rowid (aas) = rowid (buf) exclusive-lock no-error.
      find first aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
      if avail buf and avail aaa then do:
         display aas.who aas.regdt aas.dpname aas.payee with frame getlist5.
         update aas.dpname  aas.payee with frame getlist5.
         s-aaa = aas.aaa.
         op_kod = 'E'.
         aas.mn = substr(aas.mn,1,3) + "68".
         RUN aas2his.
         if (aas.dpname entered) or (aas.payee entered) then op_kod= 'E'.
         hide frame getlist5.
      end.
   end.
   ON CHOOSE OF bprint IN frame fr1 do:
      output to value("file.txt").
      put unformatted " " skip.
      put unformatted "--------------------------------------------------------------------------------------------------------" skip.
      if v-sta = 16 then put unformatted "          ПРИОСТАНОВЛЕНИЕ ОПЕРАЦИЙ ЗА ИСКЛ ОБЯЗАТЕЛЬНЫХ ПЕНСИОННЫХ ОТЧИСЛЕНИЙ                           " skip.
      if v-sta = 17 then put unformatted "          ПРИОСТАНОВЛЕНИЕ ОПЕРАЦИЙ ЗАОБЯЗАТЕЛЬНЫХ СОЦИАЛЬНЫХ ОТЧИСЛЕНИЙ                                 " skip.
      put unformatted "--------------------------------------------------------------------------------------------------------" skip.
      put unformatted "  CIF    НАИМЕНОВАНИЕ        ДАТА РЕГ  СЧЕТ      N ДОК    ДАТА ДОК.  ОРГАН_ОГР         ПРИМЕЧАНИЕ       " skip.
      put unformatted "--------------------------------------------------------------------------------------------------------" skip.
      if v-dep = 1 then do:
          for each aas where aas.sta = v-sta and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln:
              find last b-cif where b-cif.cif = aas.cif no-lock no-error.
              put unformatted "  " aas.cif " " b-cif.sname format 'x(20)' string(aas.regdt,"99/99/99") "  " aas.aaa format "x(20)" " " aas.docnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "   " aas.dpname format 'x(15)'  "   " aas.payee  skip.
          end.
      end.
      if v-dep = 2 then do:
         for each aas where aas.sta = v-sta and aas.cif = s_FindCIF and aas.ln <> 7777777 use-index aaaln:
             find last b-cif where b-cif.cif = aas.cif no-lock no-error.
             put unformatted "  " aas.cif " " b-cif.sname format 'x(20)' string(aas.regdt,"99/99/99") "  " aas.aaa format "x(20)" " " aas.docnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "   " aas.dpname format 'x(15)'  "   " aas.payee  skip.
         end.
      end.
      if v-dep = 3 then do:
         for each aas where aas.sta = v-sta and aas.who = s_FindLogin and aas.ln <> 7777777 use-index aaaln:
             find last b-cif where b-cif.cif = aas.cif no-lock no-error.
             put unformatted "  " aas.cif " " b-cif.sname format 'x(20)' string(aas.regdt,"99/99/99") "  " aas.aaa format "x(20)" " " aas.docnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "   " aas.dpname format 'x(15)'  "   " aas.payee  skip.
         end.
      end.
      if v-dep = 4 then do:
         for each aas where aas.sta = v-sta and aas.regdt >= dt_FindDateBegin and aas.regdt <= dt_FindDateEnd and aas.ln <> 7777777 use-index aaaln:
             find last b-cif where b-cif.cif = aas.cif no-lock no-error.
             put unformatted "  " aas.cif " " b-cif.sname format 'x(20)' string(aas.regdt,"99/99/99") "  " aas.aaa format "x(20)" " " aas.docnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "   " aas.dpname format 'x(15)'  "   " aas.payee  skip.
         end.
      end.
      output close.
      run menu-prt('file.txt').
   end.
   ON CHOOSE OF bexit IN frame fr1 do:
      message "". pause 0.
      hide frame fr1.
      APPLY "WINDOW-CLOSE" TO browse b1.
      view frame a2.
      message "".  message "".
   end.
   ON CHOOSE OF bdetail IN frame fr1 do:
      find buf where rowid (aas) = rowid (buf) exclusive-lock.
      if avail buf then do:
         find first taxnk where taxnk.rnn = aas.dpname no-lock no-error.
         if  avail taxnk then aas.bnf = taxnk.name.
         display aas.who aas.docnum aas.docdat aas.bnf  aas.dpname  with frame getlist3.
         hide frame getlist3.
      end.
   end.
   /* Снять ограничение */
   ON CHOOSE OF brem IN frame fr1 do:
      find buf where rowid (buf) = rowid (aas) exclusive-lock no-error.
      if avail buf then do:
         if yes-no ("Внимание!", "Вы действительно хотите снять ограничение?") then do:
            find buf where rowid (buf) = rowid (aas) no-lock.
            if not aas.contr then do:
               update aas.docnum1 aas.docdat1 aas.docprim1 with frame getlist2 .
               aas.activ = False.
               aas.whn1 = g-today.
               aas.who1 = g-ofc.
               hide frame getlist2.
               MESSAGE "Необходим контроль Директором/ЗамОД в 1.3.1.6" VIEW-AS ALERT-BOX QUESTION buttonS OK.
            end. else do:
               find buf where rowid (buf) = rowid (aas) exclusive-lock.
               find first aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
               if avail aaa then do:
                  run savelog("aaahbal", "ink10_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
                  aaa.hbal = aaa.hbal - aas.chkamt.
               end.
               op_kod= 'D'.
               aas.who = g-ofc. aas.whn = g-today. aas.tim = time.
               s-aaa = aaa.aaa.
               aas.mn = substr(aas.mn,1,3) + "69".
               RUN aas2his.
               delete buf.
               browse b1:refresh().
            end.
         end.
      end.
   end.
   repeat on endkey undo, return:
      v-sel = 0.
      run sel2(" Параметры ", " 1. Обязательные пенсионные отчисления| 2. Обязательные социальные отчисления | ВЫХОД ", output v-sel).
      if v-sel < 1 or v-sel >= 3 then return.
      if v-sel = 1 then do:
         v-sta = 16.
         leave.
      end.
      if v-sel = 2 then do:
         v-sta = 17.
         leave.
      end.
   end.
   repeat:
      run sel2 (" Параметры поиска", " 1. По номеру счета | 2. По CIF коду | 3. По менеджеру | 4. За период | ВЫХОД", output v-dep).
      if v-dep = 0 then return.
      on help of s_FindAcc in frame t_frame1 do:
         v-cif1 = "".
         run h-cif PERSISTENT SET phand.
         v-cif1 = frame-value.
         if trim(v-cif1) <> "" then do:
            find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock no-error.
            if available aaa then do:
               OPEN query  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock, each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
               ENABLE ALL WITH frame f-help.
               wait-for return of frame f-help
               FOCUS b-help IN frame f-help.
               s_FindAcc = aaa.aaa.
               hide frame f-help.
            end. else do:
               s_FindAcc = "".
               MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            end.
            displ  s_FindAcc with frame t_frame1.
         end.
         DELETE PROCEDURE phand.
      end.
      on help of s_FindCIF in frame t_frame2 do:
         v-cif1 = "".
         run h-cif PERSISTENT SET phand.
         v-cif1 = frame-value.
         if trim(v-cif1) <> "" then do:
            find first cif where cif.cif = v-cif1 no-lock no-error.
            if available cif then do:
               s_FindCIF = cif.cif.
            end. else do:
               s_FindCIF = "".
               MESSAGE "CIF код КЛИЕНТА НЕ НАЙДЕН.".
            end.
            displ  s_FindCIF with frame t_frame2.
         end.
         DELETE PROCEDURE phand.
      end.
      on help of s_FindLogin in frame t_frame3 do:
         v-cif1 = "".
         run h-ofc PERSISTENT SET phand.
         v-cif1 = frame-value.
         if trim(v-cif1) <> "" then do:
            find first ofc where ofc.ofc = v-cif1 no-lock no-error.
            if available ofc then do:
               s_FindLogin = ofc.ofc.
            end. else do:
               s_FindLogin = "".
               MESSAGE "Менеджер не найден.".
            end.
            displ  s_FindLogin with frame t_frame3.
         end.
         DELETE PROCEDURE phand.
      end.
      case v-dep:
          when 1 then do: /*По номеру счета*/
               hide frame a2.
               repeat:
                    update s_FindAcc with frame t_frame1.
                    find aaa where aaa.aaa = s_FindAcc no-error.
                    if not available aaa then do:
                       message "Счет не найден". pause 3.
                    end. else do:
                       if aaa.sta = 'C' then do:
                          message skip "Счет " + aaa.aaa + " закрыт !" skip "Добавление спец.инструкций невозможно !" skip(1) view-as alert-box button Ok title "Внимание!".
                          return.
                       end.
                       leave.
                    end.
               end.
               hide frame t_frame1.
               i_indx = 0.
               for each aas where aas.sta = v-sta and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln.
                   i_indx = i_indx + 1.
               end.
               if i_indx <> 0 then do:
                  open query q1 for each aas where aas.sta = v-sta and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln.
                  b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                  ENABLE all with frame fr1 centered overlay top-only.
                  apply "value-changed" to b1 in frame fr1.
                  WAIT-FOR WINDOW-CLOSE of frame fr1.
               end. else do:
                  display "По счету " + s_FindAcc + " нет инструкций по приост операций за искл платежей в бюджет !" format "x(78)" with center row 7 frame bridin.
                  form vsele with 1 column centered row 10 no-label frame nnn.
                  view frame nnn.
                  display vsele with frame nnn.
                  choose field vsele auto-return with frame nnn.
                  hide frame bridin.
                  hide frame nnn.
                  if frame-index = 1 then do:
                     ON CHOOSE OF bexit IN frame fr4 do:
                        message "". pause 0.
                        hide frame fr4.
                        APPLY "WINDOW-CLOSE" TO browse b4.
                     end.
                     ON CHOOSE OF bdethis IN frame fr4 do: /* История операций */
                        message "". pause 0.
                        find buf1 where rowid (buf1) = rowid (t-aashist) exclusive-lock no-error.
                        if not avail buf1 then return.

                        ON CHOOSE OF bexit IN frame fr5 do:
                           message "". pause 0.
                           hide frame fr5.
                           APPLY "WINDOW-CLOSE" TO browse b5.
                        end.
                        ON CHOOSE OF bdet IN frame fr5 do: /*Детали*/
                           find bufl where rowid (t-journal) = rowid (bufl) exclusive-lock.
                           if avail bufl then do:
                              if bufl.chgoper = "A" or  bufl.chgoper = "E" then do:
                                 displ t-journal.docnum t-journal.docdat t-journal.bnf t-journal.payee with frame getlock.
                                 hide frame getlock.
                              end.
                              if t-journal.chgoper = "D" then do:
                                 displ t-journal.docnum1 t-journal.docdat1 t-journal.docprim1 with frame getunlock.
                                 hide frame getunlock.
                              end.
                           end.      /*777777777777*/
                        end.
                        for each t-journal :
                            delete t-journal.
                        end.
                        for each aas_hist where aas_hist.aaa = t-aashist.aaa  and aas_hist.ln = t-aashist.ln no-lock use-index aasprep:
                            find first ofc where ofc.ofc = aas_hist.who no-lock.
                            create t-journal.
                            t-journal.num = aas_hist.ln.
                            if aas_hist.chgoper = 'A' then t-journal.name = "Введена  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                            else if aas_hist.chgoper = 'E' then t-journal.name = "Изменена [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                            else if aas_hist.chgoper = 'D' then t-journal.name = "Удалена  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                            else t-journal.name =  "                    ***" .
                            t-journal.docnum   = aas_hist.docnum  .
                            t-journal.docdat   = aas_hist.docdat  .
                            t-journal.dpname   = aas_hist.dpname  .
                            t-journal.docnum1  = aas_hist.docnum1 .
                            t-journal.docdat1  = aas_hist.docdat1 .
                            t-journal.docprim1 = aas_hist.docprim1.
                            t-journal.chgoper  = aas_hist.chgoper .
                            t-journal.payee = aas_hist.payee      .
                            t-journal.bnf = aas_hist.bnf      .
                        end.
                        open query q5 for each t-journal no-lock.
                        b5:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                        ENABLE all with frame fr5 centered overlay top-only.
                        apply "value-changed" to b5 in frame fr5.
                        WAIT-FOR WINDOW-CLOSE of frame fr5.
                     end.
                     for each t-aashist.
                        delete t-aashist.
                     end.
                     p-aaa = ''.
                     p-ln = 0.
                     for each aas_hist where aas_hist.aaa = aaa.aaa and aas_hist.sta = v-sta NO-LOCK USE-INDEX aasprep:
                        if aas_hist.ln <> p-ln then do transaction:
                           p-aaa = aas_hist.aaa.
                           p-ln = aas_hist.ln.
                           create t-aashist.
                           t-aashist.aaa = aas_hist.aaa.
                           t-aashist.ln  = aas_hist.ln.
                           t-aashist.sic = aas_hist.sic.
                           t-aashist.chkdt = aas_hist.chkdt.
                           t-aashist.chkno = aas_hist.chkno.
                           t-aashist.chkamt = aas_hist.chkamt.
                           t-aashist.payee = aas_hist.payee.
                           t-aashist.chgoper = aas_hist.chgoper.
                           t-aashist.who = aas_hist.who.
                           t-aashist.tim = aas_hist.tim.
                           t-aashist.cif = aas_hist.cif.
                           if aas_hist.chgoper = "D" then t-aashist.ctc = " [Удалена]". else t-aashist.ctc = " [Действует]".
                        end.
                     end.
                     open query q4 for each t-aashist where t-aashist.aaa = aaa.aaa no-lock .
                     b4:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                     ENABLE all with frame fr4 centered overlay top-only.
                     apply "value-changed" to b4 in frame fr4.
                     WAIT-FOR WINDOW-CLOSE of frame fr4.
                  end.
               end.
          end.
          when 2 then do: /*По CIF коду    */
               hide frame a2.
               update s_FindCIF with frame t_frame2.
               open query q1 for each aas where aas.sta = v-sta and  aas.cif = s_FindCIF and aas.ln <> 7777777 use-index aaaln.
               b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
               ENABLE all with frame fr1 centered overlay top-only.
               apply "value-changed" to b1 in frame fr1.
               WAIT-FOR WINDOW-CLOSE of frame fr1.
          end.
          when 3 then do: /* По менеджеру */
               hide frame a2.
               update s_FindLogin with frame t_frame3.

               v-dp3 = 0.
               run sel2 (" Параметры поиска", " ПОКАЗАТЬ ВСЕ | ЗАДАТЬ ПЕРИОД", output v-dp3).
               if v-dp3 = 0  then return.
               if v-dp3 = 1 then do:
                  open query q1 for each aas where aas.sta = v-sta and aas.who = s_FindLogin and aas.ln <> 7777777 use-index aaaln.
               end.
               if v-dp3 = 2 then do:
                  update dt_1 label "Дата начала   "  validate(dt_1 <> ?, "Введите дату для поиска") skip
                         dt_2 label "Дата окончания" validate(dt_2 <> ?, "Введите дату для поиска") with centered row 7 side-label frame t_frame3_1.
                  open query q1 for each aas where aas.sta = v-sta and aas.who = s_FindLogin and aas.regdt >= dt_1 and aas.regdt <= dt_2 and aas.ln <> 7777777 use-index aaaln.
               end.
               b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
               ENABLE all with frame fr1 centered overlay top-only.
               apply "value-changed" to b1 in frame fr1.
               WAIT-FOR WINDOW-CLOSE of frame fr1.
          end.
          when 4 then  do: /*За период      */
               hide frame a2.
               update dt_FindDateBegin label  "Дата начала" with centered row 7 side-label frame t_frame4.
               update dt_FindDateEnd label "Дата окончания" with centered row 7 side-label frame t_frame4.
               open query q1 for each aas where aas.sta = v-sta and aas.regdt >= dt_FindDateBegin and aas.regdt <= dt_FindDateEnd and aas.ln <> 7777777 use-index aaaln.
               b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
               ENABLE all with frame fr1 centered overlay top-only.
               apply "value-changed" to b1 in frame fr1.
               WAIT-FOR WINDOW-CLOSE of frame fr1.
          end.
          when 5 then do: view frame a2. return. end.
      end.
   end.
end.

enable all with frame a2.
view frame a2.
wait-for window-close of current-window.






