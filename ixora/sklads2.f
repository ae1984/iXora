/* sklads2.f
 * MODULE
        Склад
 * DESCRIPTION
        Для sklad.p
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
        12/10/04 sasco добавил вывод subamt, subcost в форме текущего склада и остатков на дату
        07.09.05 nataly замена skaldb -> item, sklada -> grp (скопировано с sklads.f)
*/


define new shared var v-sid like item.grp.
define new shared var v-pid like item.item.
define new shared var v-des as char init "".
define new shared var v-cost like skladc.cost.

define variable subamt as integer.
define variable subcost as decimal.

define var can-exit as logical.
define var v-param as char.
define var v-del as char init "^".
define var v-doc as char.
define var v-dpr like skladh.dpr.
define var v-amt like skladh.amt.
define new shared var s-jh like jh.jh.
define var rcode as integer.
define var rdes as char.
define var yesno as logical.
define var totamt as integer init 0.
define var totcost as decimal init 0.0.


define
       temp-table wsk
       field sid  like skladh.sid
       field pid  like skladh.pid 
       field sdes like grp.des 
       field pdes like item.des
       field type like skladh.type
       field tdes as char format "x(55)"
       field ddes like gl.des
       field cdes like gl.des
       field amt  like skladh.amt
       field cost like skladh.cost
       field rem  like skladh.rem extent 2
       field who  like skladh.who
       field whn  like skladh.whn
       field dgl  like jl.gl 
       field cgl  like jl.gl 
       field darp like arp.arp
       field carp like arp.arp.

define temp-table wcho
       field des like item.des label "DES" column-label "НАИМЕНОВАНИЕ"
       field amt like skladc.amt label "AMT" column-label "КОЛИЧЕСТВО"
       field cost like skladc.cost label "KZT" column-label "ЦЕНА"
       field dpr like skladc.dpr label "ДАТАПР" column-label "ДАТАПР"
       index iid dpr.


/*------------------------------------------------------------------------*/       
define temp-table wcur
       field pdes like item.des label "TOV" column-label "ТОВАР"
       field amt  like skladc.amt label "AMT" column-label "КОЛИЧЕСТВО"
                       format ">>>,>>>"
       field cost like skladc.cost label "KZT" column-label "ЦЕНА"
                       format ">>,>>>,>>9.9999"
       field sid  like item.grp column-label "SID"
       field pid  like item.item column-label "PID"
       field dpr  like skladc.dpr column-label "ДАТАПР"
       index iid pdes dpr.

define buffer bwcur for wcur.

define query qc for wcur.
define browse bc query qc
              displ
                 wcur.pdes format "x(26)"
                 wcur.amt format ">>>,>>>"
                 wcur.cost format ">>,>>>,>>9.9999"
                 wcur.cost * wcur.amt format ">>,>>>,>>9.99"
                 wcur.dpr
                 with centered no-label row 2 13 down no-box.
define frame fc bc help "Используйте стрелки для передвижения. F4 - Конец"
       skip (1) "По группе:"   totamt  format "zzzzzzzzzzzzzzzzz" view-as text
                "       По товару:" subamt  format "zzzzzzzzzzzzzzzzz" view-as text
       skip     "стоимость:"   totcost format "zz,zzz,zzz,zz9.99" view-as text
                "       стоимость:" subcost format "zz,zzz,zzz,zz9.99" view-as text
 with row 2 no-label title
" Наименование             Количество          Цена     Стоимость   ДатаПр ".


/*------------------------------------------------------------------------*/
define temp-table wcur2                           
       field sid like skladc.sid
       field pid like skladc.pid
       field pdes like item.des label "TOV" column-label "ТОВАР"
       field amt  like skladc.amt label "AMT" column-label "КОЛИЧЕСТВО"
       field cost like skladc.cost label "KZT" column-label "ЦЕНА"
       field who  like skladh.who label "WHO" column-label "ОФИЦЕР"
       field whn  like skladh.whn column-label "ДАТА"
       field dpr  like skladc.dpr column-label "ДАТАПР"
       field type like skladh.type column-label "T"
       field amtrest like sklado.amt column-label "КОЛ.ОСТ"
       field costrest like sklado.cost column-label "ЦЕНА.ОСТ"
       field gl like skladh.gl column-label "Г/К"
       index iid pdes dpr.

define buffer bwcur2 for wcur2.

define query qc2 for wcur2.
define browse bc2 query qc2
           displ
                 wcur2.whn
                 wcur2.pdes format "x(20)"
                 wcur2.type format "x(1)"
                 wcur2.amt format ">>>,>>>"
                 wcur2.cost format "z,zzz,zzz,zz9.9999"
                 wcur2.amt * wcur2.cost format "zzz,zzz,zz9.99"
                 with centered no-label row 2 13 down no-box.
define frame fc2 bc2 help "ENTER - подробности, F8 - удалить, F4 - конец"
       skip (1) "По группе:"   totamt  format "zzzzzzzzzzzzzzzzz" view-as text
                "       По товару:" subamt  format "zzzzzzzzzzzzzzzzz" view-as text
       skip     "стоимость:"   totcost format "zz,zzz,zzz,zz9.99" view-as text
                "       стоимость:" subcost format "zz,zzz,zzz,zz9.99" view-as text
 with row 2 no-label title
"Дата     Наименование       Тип   Колич.            Цена       Стоимость".  
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/


define button byes label "ПРОВОДКА".
define button byes2 label "Добавить товар".
define button bretry label "ИЗМЕНИТЬ".

define frame income1
       "Тип операции  :" wsk.tdes skip
       "Группа N" wsk.sid help "Введите номер группы. F2 - выбор"
       validate(can-find(grp where grp.grp = wsk.sid),
                "Такой группы не существует! Повторите ввод")
       " :" wsk.sdes skip
       "Товар  N" wsk.pid help "Введите номер товара. F2 - выбор"
       validate(can-find(item where item.grp = wsk.sid and
                item.item = wsk.pid),
                "Такой группы не существует! Повторите ввод")
       " :" wsk.pdes skip
       "Количество    :" wsk.amt
       validate(wsk.amt > 0, "Количество должно быть больше нуля!") skip
       "Цена за штуку :" wsk.cost 
       validate(wsk.cost > 0, "Цена должна быть больше нуля!") skip
       "Примечание    :" wsk.rem[1] skip
       "               " wsk.rem[2] skip
       "На счет ARP   :" wsk.darp wsk.ddes skip
       "Со счета ARP  :" wsk.carp wsk.cdes skip(1)
       "Офицер        :" wsk.who skip
       "Дата          :" wsk.whn skip
"________________________________________________________________________"
       skip(1)
       " F4 - выход   |" byes
       with no-labels title "ПРИХОД" row 4
       .
       
define var cost like skladh.cost.
define var gra1 as integer.
define var gra2 as integer.
define var grc1 as decimal.
define var grc2 as decimal.
define var grdx as decimal.
define var grd1 as decimal format ">>>>>>>9.9999".
define var grd2 as decimal.
define var grstr as char.

define frame income
       "Тип операции  :" wsk.tdes skip
       "Группа №" wsk.sid help "Введите номер группы. F2 - выбор"
       validate(can-find(grp where grp.grp = wsk.sid),
                "Такой группы не существует! Повторите ввод")
       " :" wsk.sdes skip
       "Товар  №" wsk.pid help "Введите номер товара. F2 - выбор"
       validate(can-find(item where item.grp = wsk.sid and
                item.item = wsk.pid),
                "Такой группы не существует! Повторите ввод")
       " :" wsk.pdes skip
       "Количество      :" wsk.amt
       validate(wsk.amt > 0, "Количество должно быть больше нуля!") skip
/*       "Цена за штуку :" wsk.cost
       validate(wsk.cost > 0, "Цена должна быть больше нуля!") skip */
       "Общая стоимость :" cost skip
       "Примечание    :" wsk.rem[1] skip
       "               " wsk.rem[2] skip
       "На счет ARP   :" wsk.darp wsk.ddes skip
       "Со счета ARP  :" wsk.carp wsk.cdes skip(1)
       "Офицер        :" wsk.who skip
       "Дата          :" wsk.whn skip
"________________________________________________________________________"
       skip(1)
/*       " F4 - выход   |" byes2*/
       with no-labels title "ПРИХОД" row 4  .

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

DEFINE FRAME getsid2 "Введите номер группы" v-sid 
       with no-label row 9 centered.


define temp-table tb
       field gl like gl.gl
       field amt like jl.dam
       field arp like arp.arp.


define temp-table wcur3
       field sdes like item.des column-label "ГРУППА"
       field sid  like item.grp column-label "SID"
       field pid  like item.item column-label "PID"
       field pdes like item.des column-label "ТОВАР"
       index iid sdes pdes.

define query qa for grp.
define query qa1 for grp.
define query qb for item.
define query qb1 for wcur3.
define query qt for skladt.
define query qp for skladp.

define buffer st_buf for skladt.
define buffer st_bufp for skladp.
define var st_amt as decimal format "z,zzz,zzz,zz9".
define var st_sum as decimal format "z,zzz,zzz,zz9.99".
define var st_amt1 as decimal format "z,zzz,zzz,zz9".
define var st_sum1 as decimal format "z,zzz,zzz,zz9.99".

define browse bt query qt
       display
               skladt.des  label "Наименование" format "x(14)"
               skladt.amt  label "Количество" format ">>>>>>"
               skladt.cost label "Цена"    format ">>>>>>9.9999"
               skladt.dpr  label "ДатаПр"
               skladt.gl   label "G/L"
               skladt.arp  label "ARP"     format "x(9)"
       with 9 down /* size 80 by 9 */ no-label title "Списание".

define browse bp query qp
       display
               skladp.des  label "Наименование" format "x(14)"
               skladp.amt  label "Количество" format ">>>>>>"
               skladp.cost label "Цена"       format ">>>>>>9.9999"
               skladp.dpr  label "ДатаПр"
               skladp.gl   label "G/L"
               skladp.arp  label "ARP"        format "x(9)"
       with 9 down /* size 80 by 9 */ no-label title "Приход".

define frame st
               st_amt  label "Итого по товару"
               st_sum  label "на сумму"
               st_amt1 label "Итого по наклад"
               st_sum1 label "на сумму"
               with row 15 centered side-labels.
          

define browse ba query qa
       display grp.grp label "ID"
               grp.des label "Группа"
              /* sklada.gl label "Счет ГК"*/
       with 15 down no-label title "Список групп товаров".

define browse ba1 query qa1
       display grp.grp label "ID"
               grp.des label "Группа"
               /*sklada.gl label "Счет ГК"*/
       with 15 down no-label title "Список групп товаров".

define browse bb query qb
       display item.item label "ID"
               item.des label "Наименование"
               item.code label "Код"
       with 12 down no-label.

define browse bb1 query qb1
       display wcur3.sdes format "x(23)" label "Группа"
               wcur3.pid label "ID"
               wcur3.pdes format "x(42)" label "Наименование"
       with 15 down no-label.

define frame ft bt
help " [ENTER] - добавление,  F8 - удаление , F4 - конец"
       with row 2 centered no-box. 

define frame ftp bp
help " [ENTER] - добавление,  F8 - удаление , F4 - конец"
       with row 2 centered no-box. 

define frame fa ba 
 help "[ENTER] - редак-ть,F4 - конец" /*[INS] - добавить, ,F8 - удалить*/
       with row 2 centered  no-box. 

define frame fb bb 
 help  "  [ENTER] - редак-ть,F4 - конец,F8 - удалить"  /*[INS] - добавить товар, /*F8 - удалить,*/*/
       with row 4 centered no-box.

define frame fa1 ba1 help " Используйте стрелки для передвижения,  F4 - Конец"
       with row 2 centered no-box.

define frame fb1 bb1 help " Используйте стрелки для передвижения,  F4 - Конец"
       with row 2 centered no-box.


form
            "ГРУППА ТОВАРОВ :" wsk.sid
             validate(can-find(grp where grp.grp eq wsk.sid), 
             "Введите верно код. <F2>- помощь") "НАИМЕНОВАНИЕ :" wsk.sdes skip
            "ТОВАР :" wsk.pid
             validate(can-find(grp where grp.grp eq wsk.sid),
            "Введите верно код. <F2>- помощь") "НАИМЕНОВАНИЕ :" wsk.pdes skip
             "ТИП ОПЕРАЦИИ :" wsk.type 
                  validate(wsk.type = "P" or wsk.type = "S",
                  "Введите верно код. <F2>- помощь ") "[" v-des "]" skip
            "КОЛИЧЕСТВО :" wsk.amt 
                validate(wsk.amt > 0, "Количество должно быть больше нуля")
            "   ЦЕНА ЗА ШТУКУ :" wsk.cost 
                validate(wsk.cost > 0, "Цена должна быть больше нуля") skip
            "ПРИМЕЧАНИЕ :" wsk.rem skip
            "ОПЕРАЦИЯ ПРОВЕДЕНА :" wsk.who "ДАТА :" wsk.whn
            with frame skladh row 2 centered no-label.

define frame rsklada
            grp.grp label "ID"
            grp.des label "Группа"
            with no-label 5 down row 3 centered.

define frame rskladb
            item.item label "ID"
            item.des label "Наименование"
            with no-label 10 down row 3 centered.

define frame getsid
            v-sid label "Выберите группу (F2 - помощь)" 
            with row 2 centered side-labels.

define frame getpid
            v-pid label "Выберите товар (F2 - помощь) "
            with row 2 centered side-labels.   

define frame getlist
            v-sid label "Выберите группу (F2 - помощь)" skip
            v-pid label "Выберите товар (F2 - помощь) " 
            skladt.cost label "Цена"
            skladt.amt label "Количество"
            skladt.dpr label "ДатаПр"
            skladt.gl label "Г/К" validate(skladt.gl = 0 or can-find(first gl where gl.gl = 
                     skladt.gl no-lock), "Счет главной книги не найден")
            skladt.arp label "АРП" validate(skladt.arp = '' or can-find(first arp where arp.arp = 
                     skladt.arp no-lock), "Счет АРП не найден")
            with row 2 centered side-labels.

define frame getlistp
            v-sid label "Выберите группу (F2 - помощь)" skip
            v-pid label "Выберите товар (F2 - помощь) " 
            skladp.cost label "Цена"
            skladp.amt label "Количество"
            skladp.dpr label "ДатаПр"

            skladp.gl label "Г/К" validate(skladp.gl = 0 or can-find(first gl where gl.gl = 
                     skladp.gl no-lock), "Счет главной книги не найден")
            skladp.arp label "АРП" validate(skladp.arp = '' or can-find(first arp where arp.arp = 
                     skladp.arp no-lock), "Счет АРП не найден")
            with row 2 centered side-labels.

form        
            "ГРУППА :" grp.grp skip
            "НАИМЕНОВАНИЕ :" grp.des
          /*  "СЧЕТ ГК :" sklada.gl validate (can-find(gl where gl.gl = sklada.gl  no-lock) or gl.gl = 0, "Счет ГК не найден! ")*/
            with frame sklada side-labels row 2 centered.
form
            "ID :" item.item
            "НАИМЕНОВАНИЕ :" item.des
            "КОД :" item.code
            with frame skladb side-labels row 2 centered.

form
            "ТОВАР :" wsk.pid
             validate(can-find(grp where grp.grp eq wsk.sid and
                      grp.grp = v-sid),
            "Введите верно код. <F2>- помощь") "НАИМЕНОВАНИЕ :" wsk.pdes
             with frame skladh 5 down row 5 centered no-label .

define var dfrom as date init today.
define var dto as date init today.

form 
             "Период: с" dfrom 
             validate (dfrom <= today, 
                       "Начало периода не может быть больше, чем сегодня!")
             " по" dto
             validate (dfrom <= dto, 
                      "Конец периода не может быть раньше его начала!")
             with no-label centered row 7 frame fdat.

