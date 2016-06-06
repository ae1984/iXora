/* debost.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату
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
        06/01/04 sasco Остатки берутся по первому незакрытому приходу
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        16/03/05 sasco Переделал поиск последней проводки 
        17/03/05 sasco Исправил переделанный ранее поиск последней проводки 
        31/03/05 sasco Исправил поиск последнего остатка (вставил use-index dategl)
        01/06/06 u00600 формирование отчета по одному дебитору с разбивкой по группам
        15/08/06 u00600 оптимизация
*/
{debls.f}

def shared var g-today as date.

def var vlen as int  init 69.
def var slen as char init "69".
/* def var totost as decimal init 0.0. */
def var grpost as decimal init 0.0.
def var vdt as date.

def temp-table wrk
         field grp  like debls.grp          label "GRP"
         field ls   like debls.ls           label "NN"
         field ost  like debhis.ost         label "Остаток"
         field type like debhis.type        label "Тип"
         field date like debhis.date        label "Дата"
         field arp  like debgrp.arp
         /*index idx_wrk is primary grp ls date*/ .

def temp-table twrk
         field ctime like debhis.ctime
         field jh    like debhis.jh
         index itwrk is primary jh.

def new shared temp-table t-deb
    field grp  as integer format "z9"
    field ls   as integer  format "zzz9"
    field name as char format "x(37)".

def new shared var l_tr as logical. 
def new shared var l_int as int.
def var v-name like debls.name no-undo.
def new shared var ls like debls.ls.

hide all.

update v-grp with frame get-grp-all0.  
find debgrp where debgrp.grp = v-grp no-lock no-error.
if avail debgrp then displ debgrp.des @ v-grp-des with frame get-grp-all0.  
pause 0.

if v-grp <> 0 then do:
  update v-ls with frame get-grp-all0. 
  if l_tr then do: /*группа <> 0, дебитора вводили поиском*/
    find first t-deb no-lock no-error. 
    if avail t-deb then do: 
      v-ls = t-deb.ls. 
      find first debls where debls.grp = t-deb.grp and debls.ls = t-deb.ls no-lock no-error.
      if avail debls then disp debls.name @ v-ls-des with frame get-grp-all0.    
      pause 0.
    end.
  end.
  else do:
    for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock.
      create t-deb.
      assign t-deb.grp  = debls.grp
             t-deb.ls   = debls.ls
             t-deb.name = debls.name.
     l_tr = true.
    end. 
    find first t-deb no-lock no-error.
    if avail t-deb then displ t-deb.name @ v-ls-des with frame get-grp-all0.  
    pause 0.
  end.
end.
else do:  /*v-grp = 0*/
  update v-ls with frame get-grp-all0.
  if l_tr then do: 
    find first t-deb no-lock no-error. 
    if avail t-deb then do:
      v-ls = t-deb.ls. 
      find first debls where debls.grp = t-deb.grp and debls.ls = t-deb.ls no-lock no-error.
      if avail debls then do:
        if l_int = 1 or l_int = 3 then disp debls.name @ v-ls-des with frame get-grp-all0.  /*если выбор по наименованию, то выводим наименование*/
        if l_int = 2 then disp "Все дебиторы" @ v-ls-des with frame get-grp-all0. /*если по номеру, то выводим - все дебиторы*/    
        pause 0.
      end.
    end.
  end.
  else do: /*если группа 0, а дебиторов вводили не поиском*/
    for each debls where debls.ls = v-ls no-lock .
      create t-deb.
      assign t-deb.grp  = debls.grp
             t-deb.ls   = debls.ls
             t-deb.name = debls.name.
     l_tr = true.
    end. 
    displ "Все дебиторы" @ v-ls-des with frame get-grp-all0.  
    pause 0.
  end.
end. 

v-dat = g-today.

update v-dat with frame get-dat.
hide frame get-dat.
hide frame get-grp-all0.  

if v-grp = 0 then
  if v-ls = 0 then do:  /*13.04.2006 u00600*/
   for each debls where debls.grp > 0 and debls.ls > 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debls then do:
       create wrk.
       assign wrk.grp = debls.grp
              wrk.ls = debls.ls
              wrk.arp = debgrp.arp.
       end.
   end.
   end.
   if v-ls <> 0 then do:    /*13.04.2006 u00600*/
     for each t-deb no-lock.
       find first debgrp where debgrp.grp = t-deb.grp no-lock no-error.
       if avail debgrp then do:
       create wrk.
       assign wrk.grp = t-deb.grp
              wrk.ls = t-deb.ls
              wrk.arp = debgrp.arp.
       end.
     end.
   end.  

else

if v-ls = 0 then 
   for each debls where debls.grp = v-grp and debls.ls ne 0  no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
         create wrk.
         assign wrk.grp = debls.grp
                wrk.ls = debls.ls
                wrk.arp = debgrp.arp.
       end.
   end.
else
   for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
         create wrk.
         assign wrk.grp = debls.grp
                wrk.ls = debls.ls
                wrk.arp = debgrp.arp.
       end.
   end.

define variable v-dtost as date format "99/99/99".

for each wrk no-lock:

   find last debhis where debhis.date <= v-dat and
                          debhis.grp   = wrk.grp and
                          debhis.ls    = wrk.ls
                          no-lock use-index dategl no-error.
   if avail debhis then do:
      vdt = debhis.date.
      for each twrk: delete twrk. end.
      for each debhis where debhis.date = vdt and
                            debhis.grp  = wrk.grp and
                            debhis.ls   = wrk.ls 
                            no-lock use-index dategl:
          create twrk.
          twrk.jh = debhis.jh.
          twrk.ctime = debhis.ctime.
      end.

      find last twrk use-index itwrk.
      find last debhis where debhis.jh = twrk.jh and 
                             debhis.grp = wrk.grp and 
                             debhis.ls = wrk.ls 
                             no-lock use-index dategl no-error.
   end.

   if avail debhis then assign wrk.date = debhis.date
                               wrk.type = debhis.type
                               wrk.ost  = debhis.ost.
   /* вычислим дату попадания первого незакрытого прихода в остаток */
   find first debop where debop.grp = wrk.grp and
                          debop.ls = wrk.ls and
                          debop.type = 1 and
                          debop.closed = no and
                          debop.date <= v-dat 
                          no-lock use-index type no-error.
   if not available debop then v-dtost = g-today.
                          else v-dtost = debop.date.

   find first debop where debop.grp = wrk.grp and
                          debop.ls = wrk.ls and
                          debop.type = 1 and
                          debop.closed and
                          debop.cdt > v-dat and
                          debop.date <= v-dat 
                          no-lock use-index type no-error.

   if available debop then do:
      if debop.date < v-dtost then v-dtost = debop.date.
   end. 

   wrk.date = v-dtost.

end.

for each wrk: if wrk.ost = 0 then delete wrk. end.

if not can-find (first wrk) then do:
   message "За указанный период данных нет!" view-as alert-box.
   return.
end.

/*для вывода на экран/отчет наименований выборки*/
if l_tr  and l_int = 1 or l_int = 3 then do:
  find first wrk no-lock no-error.
  find first debls where debls.grp = wrk.grp and debls.ls = wrk.ls no-lock no-error.
    if avail debls then v-name = debls.name.
end.
if l_tr and l_int = 2 then v-name = "Все дебиторы".
if l_tr and l_int = 0 and v-grp = 0 and v-ls <> 0 then v-name = "Все дебиторы".
if l_tr and l_int = 0 and v-grp <> 0 and v-ls = 0 then v-name = "Все дебиторы".
if l_tr and v-grp <> 0 and v-ls <> 0 then v-name = get-ls-name (v-grp, v-ls).

output to debost.img.
put unformatted skip
                "        ОСТАТКИ ПО ДЕБИТОРАМ НА ДАТУ: " v-dat skip
                "        ГРУППА " string(v-grp) " : " get-grp-des (v-grp) skip
                "        ДЕБИТОР " if l_int = 1 then "0" else string(v-ls) " : " v-name skip(1).


for each wrk no-lock break by wrk.grp by wrk.ls:
    if first-of (wrk.grp) then do:
       put unformatted skip "ГРУППА  : " get-grp-des (wrk.grp) " (ARP: " wrk.arp ")" skip
                       fill ("-", vlen) format "x(" + slen + ")" skip
           " ДАТА   | ДЕБИТОР                              |            ОСТАТОК |" skip
                       fill ("- ", vlen) format "x(" + slen + ")" skip.
       grpost = 0.0.
    end.

    put unformatted wrk.date "| "
                    get-ls-name (wrk.grp, wrk.ls) format "x(36)" " | "
                    wrk.ost format ("->>,>>>,>>>,>>9.99") " | " 
                    skip.
    grpost = grpost + wrk.ost.

    if last-of (wrk.grp) then do:
       put unformatted fill ("-", vlen) format "x(" + slen + ")" skip
                       " ИТОГО ПО ГРУППЕ:"
                       " " format "x(32)" 
                       grpost format ("->>,>>>,>>>,>>9.99") " |"
                       skip
                       fill ("-", vlen) format "x(" + slen + ")" skip(1).
    end.

/*    totost = totost + wrk.ost. */

end.

/* put unformatted " ИТОГО :                                      " 
                totost format ("->,>>>,>>>,>>>,>>9.99") skip(1). */

output close.

run menu-prt ("debost.img").
