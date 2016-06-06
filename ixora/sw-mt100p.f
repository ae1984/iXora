/* sw-mt100p.f
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

/* sw-mt100.f */

form
       remtrz.remtrz
          label "M:20:  /transaction reference number" skip
       remtrz.valdt2
          label "M:32: a/value date,crc and amount   " space(1)
       crc.code
          no-label                                     space(1)
       remtrz.payment
          no-label                                                    skip
       remtrz.ord
          format "x(35)" label "M:50:  /ordering customer           " skip

       F52-L
          format "!" label "O:52"
          help " A - BIC, D - ADDRESS or N if none" space(0)
       remtrz.ordins[1]
          format "x(35)" label "/ordering institution        "        skip

       F53-L
          format "!" label "O:53"
          help " A - BIC, D - ADDRESS or N if none"  space(0)
       remtrz.sndcor[1]
          format "x(35)" label "/sender's correspondent      "        skip

       F54-L
          format "!" label "O:54"
          help " A - BIC, D - ADDRESS or N if none" space(0)
       remtrz.rcvcor[1]
          format "x(35)" label "/receiver's correspondent    "        skip

       F56-L
          format "!" label "O:56"
          help " A - BIC, D - name , N if none" space(0)
       remtrz.intmedact
          format "x(12)" label "/intermediary                "        skip

       F57-L
          format "!" label "O:57"
          help " A - BIC, D - ADDRESS or N if none" space(0)
       remtrz.bb[1] format "x(35)" label "/account with institution    "        skip
       remtrz.bb[2] format "x(35)" no-label                           skip

       /* Field M59 - beneficiary customer [/34x] / 4*35x */
       remtrz.ba
          format "x(34)" label "M:59:  /beneficiary customer        " skip
       remtrz.detpay[1]
          format "x(35)" label "O:70:  /details of payment          " skip
       remtrz.detpay[2]
          format "x(35)" no-label at 39                               skip
       remtrz.detpay[3]
          format "x(35)" no-label at 39                               skip
       remtrz.detpay[4]
          format "x(35)" no-label at 39                               skip

       remtrz.bi
          format "x(3)"  label "O:71: a/details of charges          " skip

       /* Field O72 - Sender to Receiver information  6*35x */
       F72-1val[1]
          format "x(35)" label "O:72:  /sender to receiver inform.  " skip

       with frame mt100
          side-labels
          row 1
          centered
          overlay
          width 76
          title f_title .
