/* cif-clt.p
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

/* cif-clt.p
*/

{global.i}
def var amt as dec format "zzz,zzz,zzz.99-" label "Дост.Ост.".
{line-clt.i
&var = "  "
&start = "form
          clt.regdt label 'Дата рег.'
          clt.des  label 'Описание'
          clt.addr label 'Адрес'
          clt.purdt label ''
          clt.puramt label ''
          clt.appname label ''
          clt.appdt label 'Дата'
          clt.appamt label 'Сумма'
          clt.pname label 'Наименование'
          clt.pamt  label 'Сумма'
          clt.clsdt label 'Дата закр.'
          clt.cltamt label 'Сумма залога'
          clt.mort   label 'Залог'
          clt.fcom   label ''
          clt.fino   label ''
          clt.fin    label ''
          clt.finamt label 'Сумма закр.'
          clt.finfdt label 'Дата'
          clt.finsdt label 'Дата'
          with frame clt centered row 5 2 col overlay top-only.

          form
          clt.regdt label 'Дата рег.'
          clt.des   label 'Описание'
          clt.qty   label 'Кол-во'
          clt.purdt label 'Дата'
          clt.puramt label 'Сумма'
          clt.pname  label 'Наименование'
          clt.pamt   label 'Сумма'
          clt.appdt  label 'Дата'
          clt.appamt label 'Сумма'
          clt.clsdt  label 'Дата закр.'
          clt.cltamt label 'Сумма залога'
     /*   clt.fcom clt.fino clt.finsdt clt.fin  */
          with frame clts centered row 5 1 col overlay top-only.

          form
          clt.regdt label 'Дата рег.'
          clt.des   label 'Описание'
          clt.com   label ''
          clt.ref   label 'Ссылка'
          clt.idt   label 'Дата проц.'
          clt.duedt label 'Дата закр.'
          clt.amt   label 'Сумма'
          clt.pname label 'Наименование'
          clt.pamt  label 'Сумма'
          clt.clsdt label 'Дата закр.'
          clt.cltamt label 'Сумма залога' 
          clt.rem    label 'Примечание'
          with frame cltk centered row 5 1 col overlay top-only."
&head = "cif"
&line = "clt"
&index = "cifln"
&form = "clt.ln label 'Номер' 
         clt.grp label 'Группа' 
         clt.des label 'Наименование группы'
         clt.appamt label 'Сумма'
         clt.cltamt label 'Стоимость залога' "
&frame = "row 3 centered scroll 1 10 down overlay title
          "" Залоги/Обеспечение "" "
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
