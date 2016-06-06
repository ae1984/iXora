/* taxlbr.f
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

{global.i}
{yes-no.i}

define var yesno as logical.
define var i as integer.
def var stavka as char format "x(3)".
def var dt  as date.
def var rcol as integer.
/*define input parameter v-dt as date.*/

define temp-table wcur
       field regdt   like taxrate.regdt   label "RDT" column-label "РЕГДАТ"
       field taxrate as logical format "ЛИБОР/РЕФИН" 
                    label "TAX" column-label "СТАВКА"
       field prd     as integer     label "PRD" column-label "ПЕРИОД"
       field val     as decimal     label "VAL" column-label "СУММА"
       index iid taxrate.

define query qc for wcur.
define browse bc query qc
              displ
                 wcur.regdt
                 wcur.prd
                 wcur.taxrate
                 wcur.val
                 with centered no-label row 2 13 down no-box.
define frame fc bc help "F4 - Конец, ENTER - редакт., F1 - Либор, F2 - Рефин"
       with row 2 centered title "  РЕГДАТ   ПЕРИОД   СТАВКА СУММА    ".

define frame uptax
             wcur.regdt label "РЕГДАТ" help "ДАТА РЕГИСТРАЦИИ" skip
             wcur.prd label "ПЕРИОД" help "ПЕРИОД СТАВКИ"  skip
             wcur.taxrate label "СТАВКА" help "ЛИБОР / РЕФИН"  skip
             wcur.val label "СУММА" help "ВЕЛИЧИНА СТАВКИ" 
       with centered side-labels row 8 title "Задайте ставку".

define frame uptax2
             wcur.regdt label "РЕГДАТ" help "ДАТА РЕГИСТРАЦИИ" skip
             wcur.taxrate label "СТАВКА" help "ЛИБОР / РЕФИН"  skip
             wcur.val label "СУММА" help "ВЕЛИЧИНА СТАВКИ" 
       with centered side-labels row 8 title "Задайте ставку".


DEFINE MENU mbar MENUBAR
      MENU-ITEM mmedt LABEL "Ставки"
      MENU-ITEM mmhis LABEL "История"
      MENU-ITEM mmext LABEL "Выход".

ON CHOOSE OF MENU-ITEM mmhis
    do:
      /*------- покажем данные  за предыдущие даты */
    find last cls no-lock no-error. 
    dt = cls.cls.
    update dt label 'Введите дату ' 
    validate (dt < g-today, "Дата должна быть меньше " + string(g-today)) 
     skip with side-label row 5 centered frame dat.
     hide  frame dat.
    /*!!!!!!!!!!!!!!!!!!!!!!!!!!*/
    /*------- запомним текущие значения taxrate -> wcur-- */
      for each wcur: delete wcur. end.
      rcol = 0.
      /*  run find-taxrate(input g-today). */
      for each taxrate where taxrate.regdt = dt  
        and (taxrate.taxrate = 'lbr' or taxrate.taxrate = 'rfn')  no-lock:
    if taxrate.taxrate = 'lbr' 
         then  do: 
           do i = 1 to 12:
           create wcur.
           wcur.regdt = taxrate.regdt.
           wcur.taxrate = yes.   
           wcur.prd = i /*string(i)*/ . 
           wcur.val = taxrate.val[i].
          end. 
         end. 
         else do: 
          create wcur.
          wcur.regdt = taxrate.regdt.
          wcur.taxrate = no.
          wcur.prd = 000 . 
          wcur.val = taxrate.val[12].
          rcol = rcol + 1.
         end.
      end.


      run stavki.
      /* --------  upload всех изменений ------------------ */
      for each wcur:
        if wcur.taxrate then stavka = 'lbr'.
                        else stavka = 'rfn'.
        find last taxrate where taxrate.regdt = wcur.regdt and
                               /* taxrate.prd = wcur.prd and */
                                taxrate.taxrate = stavka
                                no-error.
        if avail taxrate  then do:
         if stavka = 'lbr' then taxrate.val[wcur.prd] = wcur.val.
         else taxrate.val[12] = wcur.val.
         end.              
        else do:
                create taxrate.
                taxrate.regdt = wcur.regdt.
             /*   taxrate.prd = wcur.prd.*/
                taxrate.taxrate = stavka.
        if stavka = 'lbr' then taxrate.val[wcur.prd] = wcur.val.
        else taxrate.val[12] = wcur.val.
        end.
        delete wcur.
      end.
      release taxrate.

    /*!!!!!!!!!!!!!!!!!*/
  end. /*mmhis*/
                             
ON CHOOSE OF MENU-ITEM mmedt
    do:
      /*------- запомним текущие значения taxrate -> wcur-- */
      for each wcur: delete wcur. end.
      rcol = 0.
      /*  run find-taxrate(input g-today). */
      for each taxrate where taxrate.regdt = g-today 
      and (taxrate.taxrate = 'lbr' or taxrate.taxrate = 'rfn') no-lock:
        if taxrate.taxrate = 'lbr' 
         then  do: 
           do i = 1 to 12:
           create wcur.
           wcur.regdt = taxrate.regdt.
           wcur.taxrate = yes.   
           wcur.prd = i /*string(i)*/ . 
           wcur.val = taxrate.val[i].
          end. 
         end. 
         else do: 
          create wcur.
          wcur.regdt = taxrate.regdt.
          wcur.taxrate = no.
          wcur.prd = 000 . 
          wcur.val = taxrate.val[12].
          rcol = rcol + 1.
         end.
      end.


      run stavki.
      /* --------  upload всех изменений ------------------ */
      for each wcur:
        if wcur.taxrate then stavka = 'lbr'.
                        else stavka = 'rfn'.
        find last taxrate where taxrate.regdt = wcur.regdt and
                               /* taxrate.prd = wcur.prd and */
                                taxrate.taxrate = stavka
                                no-error.
        if avail taxrate  then do:
         if stavka = 'lbr' then taxrate.val[wcur.prd] = wcur.val.
         else taxrate.val[12] = wcur.val.
         end.              
        else do:
                create taxrate.
                taxrate.regdt = wcur.regdt.
             /*   taxrate.prd = wcur.prd.*/
                taxrate.taxrate = stavka.
        if stavka = 'lbr' then taxrate.val[wcur.prd] = wcur.val.
        else taxrate.val[12] = wcur.val.
        end.
        delete wcur.
      end.
      release taxrate.

    end. /*medt*/


