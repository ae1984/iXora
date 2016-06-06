/* ivcfimp.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Обработка файлов DBF из ИВЦ, Алсеко
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
     3.2.10.2
 * AUTHOR
     25.01.02 pragma
 * CHANGES
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
     31.07.03 kanat добавил новый параметр при вызове процедуры commpl для совместимости с обработкой таможенных платежей
     29.09.03 sasco добавил проверку остатка на АРП карточке
     14/09/04 kanat добавил обработку и отправку полей rnn_abon и fio - для налоговых платежей ИВЦ
     12/10/04 kanat добавил запись референса после отправки платежей и убрал очистку реестра перед отправкой
     14/10/04 kanat добавил условие для повторных загрузок
     19/05/2005 kanat - добавил формирование реестра в формате XLS для сверки перед отправкой платежей
     24/05/2005 kanat - убрал вывод лишних сообщений в ведомости распределения
     25/05/2005 kanat - добавил возможность автоматического зачисления на внутренние счета банка в общем цикле зачислений
                        по ведомости распределения.
     27/05/2005 kanat - если счет внутренний, то делается проводка по банку
     07/06/2005 kanat - убрал вопросы относительно - делать проводки или не делать - все они будут делаться сразу ...
     24/05/2006 marinav  - добавлен параметр даты факт приема платежа
      4/10/2006 u00568 Evgeniy - добавил дополнительный контроль прогрузки. + оптимизация + нормальные отступы + реальная проверка на прогрузку.
      9/10/2006 u00568 Evgeniy - исправил свой баг
     22/11/2006 u00568 Evgeniy - возникла ситуация, когда надо отправлять деньги на счита клиентов в других банках, тогда как такие же точно номера счетов были в нашем банке, поэтому программа переделана и обезбажена
*/

  {comm-arp.i}

  def var s-arp  as char.
  def var s-date as date.    /* Date vedomosti  */
  def var s-ved as char. /* Nomer vedomosti */
  def var s-num as integer initial 1.
  def var fname as char initial 'a:\\'.
  def new shared var s-jh like jh.jh.

  define variable choice as log.
  define variable choice0 as log.

  define variable choicex as log init false.

  define variable v-count as integer.
  define variable v-whole as decimal.

  update fname format "x(30)" label "Введите имя файла " with side-labels
  centered frame ff.
  hide frame ff.

  message "спсибо" view-as alert-box title "".

  for each ivcimp exclusive-lock where ivcimp.ref = ?:
    delete ivcimp.
  end.
  /*
  for each ivcimp exclusive-lock where trim(ivcimp.ref) = '':
    delete ivcimp.
  end.
  */

  fname = replace(fname, '\\', '\\\\').

  unix silent echo -n \\# > getfile.sh.
  unix silent echo '/bin/sh' >> getfile.sh.
  unix silent echo -n "rcp " ' ' >> getfile.sh.
  unix silent echo -n '\\' >> getfile.sh.
  unix silent value("askhost | awk '\{  printf " + '"%s"' + " , $0 }'
  >> getfile.sh").
  unix silent echo -n ':' >> getfile.sh.
  unix silent echo -n value('"' + "'" + '"') >> getfile.sh.
  unix silent echo -n value(fname) >> getfile.sh.
  unix silent echo -n value('"' + "'" + '"') >> getfile.sh.
  unix silent echo -n '\\' >> getfile.sh.
  unix silent echo -n './' >> getfile.sh.
  unix silent echo -n  >> getfile.sh.
  unix silent chmod +x getfile.sh.
  unix silent getfile.sh.
  unix silent echo y | rm getfile.sh.

  fname = substring(fname, r-index(fname, "\\") + 1).

  if search("./" + fname) = ? then
  do:
    MESSAGE "Невозможно обработать файл: " + fname + "."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE " Проблема: ".
    return.
  end.

  UNIX SILENT dbfcnv.pl value(fname) base.txt.
  unix silent cat base.txt | alt2koi > base.d

  /*select * from ivcimp.*/ /* u00568 убрал*/

  message "IMPORT начинается" view-as alert-box title "Внимание".

  INPUT FROM base.d.

  m1:
  do transaction:
    REPEAT on error undo m1, return:
      CREATE ivcimp.
      IMPORT DELIMITER "|" ivcimp.
      ivcimp.kbe = trim(ivcimp.fl) + trim(ivcimp.kbe).
      ivcimp.fl = string(s-num).
      s-num = s-num + 1.
      ivcimp.ref = ?.
    end.
  end.
  INPUT CLOSE.

  message "IMPORT прошел" view-as alert-box title "Внимание".

  for each ivcimp no-lock where ivcimp.ref = ? :
      find first bankl where bankl.bank = trim(ivcimp.kodbn) no-lock no-error.
      if not avail bankl then
      do:
        message "Неверный банк бенефициара!" view-as alert-box title "Внимание".
        return.
      end.

      /*
      if can-find( first aaa where aaa.aaa = ivcimp.numrs no-lock) and
         can-find( bankl where bankl.bank = ivcimp.kodbn and bankl.bank = "190501914" no-lock) then
      do:
        message "Неверный aaa или bankl ~n проверьте банк бенефициара!~n для " + ivcimp.name-pol
        view-as alert-box title "Внимание".
      end.
      */

      if length(trim(ivcimp.rnn)) <> 12 then
      do:
        message "Неверный РНН!" view-as alert-box title "Внимание".
        return.
      end.

      if length(trim(ivcimp.kbe)) <> 2 then
      do:
        message "Неверный КБе!" view-as alert-box title "Внимание".
        return.
      end.

      if length(trim(ivcimp.knp)) <> 3 then
      do:
        message "Неверный КНП!" view-as alert-box title "Внимание".
        return.
      end.

      if trim(ivcimp.numrs) matches "*080900*" and length(trim(ivcimp.kodd)) <> 6 then
      do:
        message "Неверный КБК!" view-as alert-box title "Внимание".
        return.
      end.
  end.



  find first ivcimp where ivcimp.ref = ? and ivcimp.rnn = '600400110092' no-lock no-error.
  if avail ivcimp then
  do:
    s-arp = "000904883".
  end.

  find first ivcimp where ivcimp.ref = ? and ivcimp.rnn = '600700163157' no-lock no-error.
  if avail ivcimp then
  do:
    s-arp = "000904786".
  end.

  s-num = 1.
  unix silent echo y | rm  value(fname).
  unix silent value("rm -f base.* ").

  /* Получение даты ведомость из наименования файла  2330mmdd.dbf  */
  s-date = date(SUBSTR(fname,7,2) + '/' + SUBSTR(fname,5,2) + '/' + substr(string(Year(TODAY)),3,2)).

  update s-arp  format '999999999' label 'Введите номер карточки ARP'
  s-date format '99/99/99'  label 'Дата ведомости' at 1
  with centered side-labels frame farp.

  if s-arp = "000904883" then
    s-ved = 'ТОО "ИВЦ"'.
  if s-arp = "000904786" then
    s-ved = 'ЗАО "Алсеко"'.
  /*
  for each ivcimp exclusive-lock where trim(ivcimp.ref) = '' :
    ivcimp.ref = ?.
  end.
  */
  run make_xls.

  MESSAGE "Продолжить ?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
  TITLE " Отправка платежей " update choicex.

  /* 16/05/2005 kanat - добавил формирование реестра в формате XLS для сверки перед отправкой платежей  */

  if not choicex then
    return.

  for each ivcimp exclusive-lock where ivcimp.ref = ? by integer(fl):

    choice = yes.
    choice0 = yes.

    /*     27/05/2005 kanat - если счет внутренний, то делается проводка по банку*/

    find first aaa where aaa.aaa = ivcimp.numrs no-lock no-error.
    if avail aaa and ivcimp.kodbn = "190501914" then
    do:
      /*
      find bankl where bankl.bank = ivcimp.kodbn and bankl.bank = "190501914" no-lock no-error.
      if avail bankl then
      */
      do:

        /*
        MESSAGE "Сформировать документ на сумму: " ivcimp.sump  "?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE " Документ : " update choice0.
        if choice0 then do:
        */
        if not comm-arp(s-arp, ivcimp.sump) then do:
          choice0 = false.
          MESSAGE "Не хватает средств на счете " + s-arp + "!"
          VIEW-AS ALERT-BOX /*QUESTION BUTTONS YES-NO*/
          TITLE "Проверка остатка".
        end.
        /*
        end.
        */

        case choice0:
          when true then
          do:

            run trx (
            6,
            ivcimp.sump,
            1,
            '',
            s-arp,
            '',
            ivcimp.numrs,
            ivcimp.nazn-pl + ' Ведомость от ' + STRING(s-date,"99.99.99") + ' г.',
            '14',
            '14',
            '856').

            if return-value = '' then
              undo, return.

            s-jh = int(return-value).

            run jou.

            if return-value <> ? and trim(return-value) <> '' then
              ivcimp.ref = return-value.
            else
            do:
              message "Ошибка формирование платежного документа" view-as alert-box title "Внимание".
              return.
            end.

          end.
          /* when choice = true then ... */
          when false then.
            otherwise return.
        end case.
        /* case choice ... */

        s-num = s-num + 1.
      end.
    end.
    /*     27/05/2005 kanat - если счет внутренний, то делается проводка по банку*/
    else
    do:

      /*
      MESSAGE "Сформировать п/п на сумму: " ivcimp.sump  "?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE " Платежное поручение: " update choice.
      if choice then do:
      */
      if not comm-arp(s-arp, ivcimp.sump) then do:
        choice = false.
        MESSAGE "Не хватает средств на счете " + s-arp + "!"
        VIEW-AS ALERT-BOX /*QUESTION BUTTONS YES-NO*/
        TITLE "Проверка остатка".
      end.
      /*
      end.
      */

      case choice:
        when true then
        do:

          run commpl (s-num,
                      ivcimp.sump,
                      s-arp,
                      ivcimp.kodbn,
                      ivcimp.numrs,
                      integer(ivcimp.kodd),
                      yes,
                      ivcimp.name-pol,
                      ivcimp.rnn,
                      ivcimp.knp,
                      '14',
                      ivcimp.kbe,
                      ivcimp.nazn-pl + ' Ведомость ' + s-ved + ' от ' + STRING(s-date,"99.99.99") + ' г.',
                      'SG',
                      0,
                      1,
                      ivcimp.rnn_abon,
                      ivcimp.fio,
                      s-date).

          if return-value <> ? and trim(return-value) <> '' then
            ivcimp.ref = return-value.
          else
          do:
            message "Ошибка формирование платежного документа" view-as alert-box title "Внимание".
            return.
          end.

        end.
        /* when choice = true then ... */
        when false then.
          otherwise return.
      end case.
      /* case choice ... */
      s-num = s-num + 1.

    end.

  end.
  /* for each ivcimp .... */


  if can-find(first ivcimp no-lock where ivcimp.ref = ?) then do:
    run make_xls.
  end.


  procedure make_xls:
    output to ivcfimp.xls.
    {html-start.i " "}
    put unformatted
    "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
    "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
    "Реестр платежей " s-ved "<BR><BR>" skip
    "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
    "<TR bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip.

    put unformatted
    "<TD><FONT size=""2""><B>Дата</B></FONT></TD>"     skip
    "<TD><FONT size=""2""><B>БИК</B></FONT></TD>"      skip
    "<TD><FONT size=""2""><B>Счет получателя</B></TD>" skip
    "<TD><FONT size=""2""><B>РНН</B></FONT></TD>"      skip
    "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>"    skip
    "<TD><FONT size=""2""><B>Получатель</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Назначение</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Кбе</B></FONT></TD>"      skip
    "<TD><FONT size=""2""><B>КНП</B></FONT></TD>"      skip
    "</FONT></TR>".

    for each ivcimp where ivcimp.ref = ? no-lock by integer(fl):
      put unformatted "<TR align = ""right""><TD>"  string(ivcimp.dat) "</TD>" skip
      "<TD>"  ivcimp.kodbn "</TD>" skip
      "<TD>"  ivcimp.numrs "</TD>" skip
      "<TD>["  ivcimp.rnn "]</TD>" skip
      "<TD>"  replace(string(ivcimp.sump), ".", ",") "</TD>" skip
      "<TD>"  ivcimp.name-pol "</TD>" skip
      "<TD>"  ivcimp.nazn-pl "</TD>" skip
      "<TD>"  ivcimp.kbe "</TD>" skip
      "<TD>"  ivcimp.knp "</TD>" skip
      "</TR>" skip.
      v-count = v-count + 1.
      v-whole = v-whole + ivcimp.sump.
    end.
    put unformatted "<TR bgcolor=""#C0C0C0"" align = ""center""><TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD><B>" string(v-count) "</B></TD>" skip
    "<TD><B>" replace(string(v-whole),".", ",") "</B></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</TR>" skip.

    {html-end.i " "}
    output close.

    unix silent cptwin ivcfimp.xls excel.
    pause 0.
  end.
