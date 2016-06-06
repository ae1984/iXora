/* cif-cll.p
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

/* cif-cll.p
*/

{global.i}
def var amt as dec format "zzz,zzz,zzz.99-" label "ДОСТУП.СУММА".
{linel.i
&var = "  "
&start = "form
          clt.regdt clt.des  clt.addr
          clt.purdt clt.puramt
          clt.appname
          clt.appdt clt.appamt
          clt.pname clt.pamt
          clt.clsdt
          clt.cltamt
          clt.mort
          clt.fcom clt.fino clt.fin clt.finamt clt.finfdt clt.finsdt
          with frame clt centered row 5 2 col overlay top-only.

          form
          clt.regdt clt.des  clt.qty
          clt.purdt clt.puramt
          clt.pname clt.pamt
          clt.appdt clt.appamt
          clt.clsdt clt.cltamt
     /*   clt.fcom clt.fino clt.finsdt clt.fin  */
          with frame clts centered row 5 1 col overlay top-only.

          form
          clt.regdt clt.des clt.com clt.ref
          clt.idt clt.duedt clt.amt
          clt.pname clt.pamt
          clt.clsdt clt.cltamt  clt.rem
          with frame cltk centered row 5 1 col overlay top-only."
&head = "cif"
&line = "clt"
&index = "cifln"
&form = "clt.ln clt.grp clt.des  clt.appamt clt.cltamt"
&frame = "row 3 centered scroll 1 10 down overlay title
          "" Осн.ср-ва/Залог "" "
&newline = "  "
&predisp = "  "
&flddisp = "clt.ln clt.grp clt.des  clt.appamt clt.cltamt"
&newpreupdt = " "
&fldupdt = " clt.regdt clt.des clt.addr
            clt.purdt clt.puramt
            clt.appname
            clt.appdt clt.appamt
            clt.pname clt.pamt
            clt.clsdt
            clt.cltamt clt.mort
          clt.fcom clt.fino clt.fin clt.finamt clt.finfdt clt.finsdt"
&fldupdt1 = " clt.regdt clt.des clt.qty
            clt.purdt clt.puramt
            clt.pname clt.pamt
            clt.appdt clt.appamt clt.clsdt clt.cltamt
      /*  clt.fcom clt.fino clt.finsdt clt.fin */ "
&fldupdt2  =  " clt.regdt clt.des clt.com clt.ref
                clt.idt clt.duedt clt.amt
                clt.pname clt.pamt clt.clsdt
                clt.cltamt  clt.rem"
&postplus = " "
&postminus = " "
&end = " "
}
