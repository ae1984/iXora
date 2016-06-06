/* stchk0.i
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

/* stchk0.i Create Stml for splits in Active ORG-s 
            Start 27/11/1998: Last Mo: 
            Include for stmlist.i 
            Only for Zero Period of Time  */

if periods eq 0 then do:
  /*  tmp_date = a_start.  */
  tmp_date = first_date.

  for each stgenhi where stgenhi.cif eq in_cif and
                         stgenhi.account eq in_account and
                         stgenhi.sts eq "ORG" and 
                         stgenhi.active no-lock break by stgenhi.d_from.

    if stgenhi.d_from > tmp_date  then do:
          
          OMIT-LOOP:
          do while tmp_date < stgenhi.d_from - 1:
          find first a_hi where a_hi.cif eq in_cif and
                                a_hi.account eq in_account and
                                a_hi.sts eq "ORG" and
                                not a_hi.active and
                                a_hi.d_from eq tmp_date and
                                a_hi.d_to lt stgenhi.d_from - 1
                                no-lock no-error.
              if available a_hi then do:
              create stml.
              stml.seq = a_hi.seq.
              stml.aaa = in_account.
              stml.d_from = tmp_date.
              stml.d_to = a_hi.d_to.
              stml.sts = "ORG".
              tmp_date = a_hi.d_to + 1. 
              end.
              else leave OMIT-LOOP.
          end.     /* OMIT-LOOP */

    create stml.
    stml.seq = iseq.
    stml.aaa = in_account.
    stml.d_from = tmp_date.
    stml.d_to = stgenhi.d_from - 1.
    stml.sts = "ORG".
    iseq = iseq + 1.
   
    end.  /* stgenhi.d_from > tmp_date */ 
  tmp_date = stgenhi.d_to + 1.
  end.  /* for each stgenhi */
 end.  /* if periods eq 0 */

/* Test stml for absence of intersections with another active originals */

for each stml where stml.sts eq "ORG" break by stml.d_from:
find first stgenhi where stgenhi.cif eq in_cif  
                     and stgenhi.account eq in_account   
                     and stgenhi.d_from le stml.d_from 
                     and stgenhi.d_to ge stml.d_from
                     and stgenhi.sts eq "ORG" and stgenhi.active
                     no-lock no-error. 
  if available stgenhi then delete stml.
  else do:
  find first stgenhi where stgenhi.cif eq in_cif
                       and stgenhi.account eq in_account
                       and stgenhi.d_from le stml.d_to 
                       and stgenhi.d_to ge stml.d_to
                       and stgenhi.sts eq "ORG" and stgenhi.active
                       no-lock no-error. 
  if available stgenhi then delete stml.
  end.

find last stgenhi where stgenhi.cif eq in_cif
                    and stgenhi.account eq in_account
                    and stgenhi.d_from eq stml.d_from
                    and stgenhi.d_to eq stml.d_to 
                    and stgenhi.sts eq "ORG" 
                    and not stgenhi.active no-lock no-error.
    if available stgenhi then do: 
    stml.seq = stgenhi.seq.
    stml.who = "(" + stgenhi.who + ")". 
    end.
end.  /* for each stml */

/* Test stml for non-dublicating */

for each stml:
isolda = no.
 for each m-stml where m-stml.aaa eq stml.aaa
                   and m-stml.d_from eq stml.d_from
                   and m-stml.d_to eq stml.d_to 
                   and RECID(m-stml) ne RECID(stml):
 if m-stml.sts ne "ORG" then delete m-stml. else isolda = yes.   
 end.  /* each m-stml  */
if isolda then delete stml.
end.  /* each stml   */


