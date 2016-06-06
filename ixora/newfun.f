/* newfun.f
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

/* newfun.f
*/

form        "     M®S-NOR#:" fun.fun  skip
            "   VAL®TA    :" fun.crc  "  B…Z.DIENA  :" at 41 fun.basedy skip
            "     G/G KONT:" fun.gl gl.sname "(" fun.grp format "zz9" ")" skip
            " KREDR/AIZNMS:" fun.bank
                             fun.cst skip
            "       SUMMA :" fun.amt skip
            " DILINGA-DAT.:" fun.ddt[5] skip
            "   IEGRM-DAT.:" fun.rdt
                "    DZЁ№ANAS-DAT.:" fun.duedt skip
            "         TERM:" fun.trm   "  DIEN" skip
            "     PRC-LIKM:" fun.intrate skip
            "     PROCENTS:" fun.interest format "z,zzz,zzz,zz9.99"
            "(" fun.itype ")" skip
            " M®S P/R BANK:" fun.dfb vdfbnm no-label skip
            "         A/C#:" vdfbacct skip
            "VIјU  P/R BNK:" fun.tbank fun.crbank no-label skip
            "         K/T#:" fun.acct format "x(40)" skip
            "      ATBILDG:" fun.who   "   KONTROL#" s-jh skip
            "       PIEZ§M:" fun.rem
            with frame fun row 3 centered no-label no-box.
/*
form            "      PIEZ§M:" fun.rem
                       with frame funnew overlay row 15 no-label no-box.
*/
