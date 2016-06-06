/* sw-mt200p.f
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

/* sw-mt200.f */

form
       remtrz.remtrz
          label "M:20:  /transaction reference number" skip
       remtrz.valdt2
          label "M:32: a/value date,crc and amount   " space(1)
       crc.code
          no-label                                     space(1)
       remtrz.payment
          no-label                                     skip

       F53-L
          format "!" label "O:53"
          help " B - Branch, N if none"  space(0)
       remtrz.sndcor[1]
          format "x(35)" label "/sender's correspondent      "        skip
       remtrz.sndcor[2]
          format "x(35)" no-label at 39                               skip

       F56-L
          format "!" label "O:56"
          help " A - BIC, D - ADDRESS, N if none" space(0)
       remtrz.intmedact
          format "x(34)" label "/intermediary                "        skip
       remtrz.intmed
          format "x(35)" no-label at 39                               skip

       F57-L
          format "!" label "M:57"
          help " A - BIC, D - ADDRESS" space(0)
       remtrz.bb[1]
          format "x(35)" label "/account with institution    "        skip
       remtrz.bb[2]
          format "x(35)" no-label  at 39                              skip

       F72-1val[1]
          format "x(35)" label "O:72:  /sender to receiver inform.  " skip
       F72-1val[2]
          format "x(35)" no-label at 39                               skip
       F72-1val[3]
          format "x(35)" no-label at 39                               skip
       F72-1val[4]
          format "x(35)" no-label at 39                               skip
       F72-1val[5]
          format "x(35)" no-label at 39                               skip
       F72-1val[6]
          format "x(35)" no-label at 39                               skip

       with frame mt200
          side-labels
          row 1
          centered
          overlay
          width 76
          title " SWIFT MT200 MESSAGE. " + "DESTINATION: " + realbic + " ".
