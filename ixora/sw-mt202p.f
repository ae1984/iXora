/* sw-mt202p.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
*/

/* sw-mt202.f */

form
       remrem202
          label "M:20:  /transaction reference number" skip
       remtrz.remtrz
          label "M:21:  /related reference           " skip
       remtrz.valdt2
          label "M:32: a/value date,crc and amount   " space(1)
       crc.code
          no-label                                     space(1)
       remtrz.payment
          no-label                                                    skip

       F52-L
          format "!" label "O:52"
          help " A - BIC, D - ADDRESS or N if none" space(0)
       remtrz.ordins[1]
          format "x(35)" label "/ordering institution        "        skip

       F53-2L
          format "!" label "O:53"
          help " A - BIC, D - ADDRESS, B - BRANCH,  N if none" space(0)
       F53-2val[1]
          format "x(35)" label "/sender's correspondent      "        skip
       F53-2val[2]
          format "x(35)" no-label  at 39                              skip
       F53-2val[3]
          format "x(35)" no-label  at 39                              skip
       F53-2val[4]
          format "x(35)" no-label  at 39                              skip

       F56-2L
          format "!" label "O:56"
          help " A - BIC, D - ADDRESS, N if none" space(0)
       F56-2val[1]
          format "x(35)" label "/intermediary                "        skip
       F56-2val[2]
          format "x(35)" no-label  at 39                              skip
       F56-2val[3]
          format "x(35)" no-label  at 39                              skip
       F56-2val[4]
          format "x(35)" no-label  at 39                              skip

       F57-2L
          format "!" label "O:57"
          help " A - BIC, D - ADDRESS, B - BRANCH or N if none" space(0)
       F57-2val[1]
          format "x(34)" label "/Account with institution    "        skip
       F57-2val[2]
          format "x(35)" no-label  at 39                              skip
       F57-2val[3]
          format "x(35)" no-label  at 39                              skip
       F57-2val[4]
          format "x(35)" no-label  at 39                              skip
       F57-2val[5]
          format "x(35)" no-label  at 39                              skip

       /* Field M58 - beneficiary institution [/34x] / 4*35x */
       F58-2L
          format "!" label "M:58"
          help " A - BIC, D - ADDRESS " space(0)
       F58-2aval[1]
          format "x(34)" label "/beneficiary institutution   "        skip

       /* Field O72 - Sender to Receiver information  6*35x */
       F72-2val[1]
          format "x(35)" label "O:72:  /sender to receiver inform.  " skip

       with frame mt202
          side-labels
          row 1
          centered
          overlay
          width 76
          title " SWIFT MT202 (2) MESSAGE. " + "DESTINATION: " + realbic + " ".
