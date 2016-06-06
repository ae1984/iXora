/* debhist.p
 * MODULE
        Дебиторы
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
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        16/03/05 sasco Перед сортировкой по времени сначала сортируется по номеру проводки
*/


{debls.f}

def shared var g-today as date.
def var vlen as int  init 116.
def var slen as char init "116".

/* def var totcam as decimal init 0.0.
def var totdam as decimal init 0.0. */

def var grpcam as decimal init 0.0.
def var grpdam as decimal init 0.0.

def temp-table wrk
         field grp   like debls.grp          label "GRP"
         field ls    like debls.ls           label "NN"
         field ost   like debhis.ost         label "Остаток"
         field cam   as   decimal
         field dam   as   decimal
         field type  like debhis.type        label "Тип"
         field date  like debhis.date        label "Дата"
         field rem   as   char               label "ПРИМЕЧАНИЕ"
         field ctime like debhis.ctime       label "Время"
         field arp   like debgrp.arp
         field jh    like debhis.jh          label "Проводка"
         field gl    as char format "x(6)"
         field ind   as int.

def temp-table wost
         field grp    like debhis.grp
         field ls     like debhis.ls
         field ost    like debhis.ost.

hide all.

def var oldjh like debhis.jh.
def var numlin as int.
def var jllin as int.
def var damcam as char.
def var i as int.
def var xx as int.

oldjh = 0.
numlin = 0.
xx = 0.


update v-grp with frame get-grp-all.
find debgrp where debgrp.grp = v-grp no-lock.
displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

if v-grp <> 0 then do:
update v-ls with frame get-grp-all.
find debls where debls.grp = v-grp and debls.ls = v-ls no-lock.
displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.
end.

v-d1 = g-today.
v-d2 = g-today.

update v-d1 v-d2 with frame get-dates.
hide frame get-dates.
hide frame get-grp-all.


for each debhis where debhis.date >= v-d1 and debhis.date <= v-d2 no-lock:

    xx = xx + 1.
    create wrk.
    find first debgrp where debgrp.grp = debhis.grp no-lock.
    assign wrk.grp = debhis.grp
           wrk.ls = debhis.ls
           wrk.ost = debhis.ost
           wrk.date = debhis.date
           wrk.ctime = debhis.ctime                                      
           wrk.rem = trim (debhis.rem[1]) + trim (debhis.rem[2]) + trim (debhis.rem[3])
           wrk.arp = debgrp.arp
           wrk.jh = debhis.jh
           wrk.gl = "      "
           wrk.ind = xx.

    if debhis.jh <> 0 and debhis.type >= 3 then do: /* списание или закрытие */

    /* найдем первое вхождение счета в проводку */
    find first jl where jl.jh = debhis.jh and jl.acc = debgrp.arp no-lock no-error.

    if oldjh <> debhis.jh then do: oldjh = debhis.jh. numlin = 0. end.
                          else numlin = numlin + 1.
                                
    /* найдем линию проводки : numlin = сколько есть еще линий кроме первой */
    do i = 1 to numlin:
       find next jl where jl.jh = debhis.jh and jl.acc = debgrp.arp no-lock no-error.
    end.

    if avail jl then
    do:

       if jl.dc = "D" then damcam = "C".
                      else damcam = "D".

       if jl.ln mod 2 = 1 then jllin = jl.ln + 1.
                          else jllin = jl.ln - 1.
/*       case jl.ln:
           when 1 or when 3 or when 5 or when 7 or when 9 or when 11 or when 13,15,17,19] then jllin = jl.ln + 1.
           otherwise: jllin = jl.ln - 1.
       end.
  */
       find jl where jl.jh = debhis.jh and jl.dc = damcam and jl.ln = jllin no-lock no-error.
       if avail jl then wrk.gl = string(jl.gl).

    end.

    end. /* списание */

    if debhis.type < 3 then do: wrk.dam = 0.          wrk.cam = debhis.amt. end.
                       else do: wrk.dam = debhis.amt. wrk.cam = 0.          end.

end.


if v-grp <> 0 then
for each wrk where wrk.grp <> v-grp:
    delete wrk.
end.

if v-ls <> 0 then
for each wrk where wrk.ls <> v-ls:
    delete wrk.
end.

for each wrk:
   if wrk.jh <> 0 and wrk.jh <> ? then wrk.rem = "(" + trim(string(wrk.jh)) + ") " + wrk.rem.
end.

if not can-find (first wrk) then do:
   message "За указанный период данных нет!" view-as alert-box.
   return.
end.


output to rpt.img.
put unformatted skip
                "        ИСТОРИЯ ДВИЖЕНИЙ ПО ДЕБИТОРАМ С " v-d1 " ПО " v-d2 skip
                "        ГРУППА  : " get-grp-des (v-grp) skip
                "        ДЕБИТОР : " get-ls-name (v-grp, v-ls) skip(1).


for each wrk no-lock break by wrk.grp by wrk.ls by wrk.date by wrk.jh by wrk.ctime by wrk.ind:

    find first wost where wost.grp = wrk.grp and wost.ls = wrk.ls no-error.
    if not avail wost then do:
        create wost.
        assign wost.grp = wrk.grp
               wost.ls = wrk.ls
               wost.ost = 0.0.
    end.

    if first-of (wrk.grp) then
    do:
       put unformatted
           skip "ГРУППА  : " get-grp-des (wrk.grp) " (ARP: " wrk.arp ")" skip
           fill ("-", vlen) format "x(" + slen + ")" skip
           " ДАТА   | ДЕБИТОР                              |         ПОПОЛНЕНИЕ |          СПИСАНИЕ |           ОСТАТОК |  Г/К |" skip
           fill ("- ", vlen) format "x(" + slen + ")" skip.
       grpcam = 0.0.
       grpdam = 0.0.
    end.

/*    totcam = totcam + wrk.cam. 
    totdam = totdam + wrk.dam.  */

    grpcam = grpcam + wrk.cam.
    grpdam = grpdam + wrk.dam.

    wost.ost = wrk.ost.


    put unformatted wrk.date "| "
                    get-ls-name (wrk.grp, wrk.ls) format "x(36)" " | "
                    wrk.cam format ("->>,>>>,>>>,>>9.99") " |" 
                    wrk.dam format ("->>,>>>,>>>,>>9.99") " |" 
                    wrk.ost format ("->>,>>>,>>>,>>9.99") " |" 
                    wrk.gl format "x(6)" "|"
                    skip.

    do while wrk.rem <> "":
       if length (wrk.rem) le 36 then do:
          put unformatted "        | " wrk.rem format "x(36)" " | "
                          " " format ("x(18)") " |" 
                          " " format ("x(18)") " |"
                          " " format ("x(18)") " |      |"
                          skip.
          wrk.rem = "".
       end.
       else do:
          put unformatted "        | " substring (wrk.rem, 1, 36) format "x(36)" " | "
                          " " format ("x(18)") " |"
                          " " format ("x(18)") " |"
                          " " format ("x(18)") " |      |"
                          skip.
          wrk.rem = trim (substring (wrk.rem, 37)).
       end.
    end.

    if last-of (wrk.grp) then do:
       put unformatted fill ("-", vlen) format "x(" + slen + ")" skip.
       put unformatted " ИТОГО ПО ГРУППЕ:"
                       " " format "x(29)" " | "
                       grpcam format ("->>,>>>,>>>,>>9.99") " |"
                       grpdam format ("->>,>>>,>>>,>>9.99") " |"
                       skip.
       put unformatted fill ("-", vlen) format "x(" + slen + ")" skip (1).
    end.
end.

/* put unformatted " ИТОГО:"
                " " format "x(42)" 
                totcam format ("->>,>>>,>>>,>>9.99") "  "
                totdam format ("->>,>>>,>>>,>>9.99")  
                skip(1). */

output close.

run menu-prt ("rpt.img").
 