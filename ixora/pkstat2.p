/* pkstat2.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Статистика "Портрет заемщика" (БД)
 * RUN
        
 * CALLER
        pkstat.p
 * SCRIPT
        
 * INHERIT

 * MENU
        4-13-13
 * AUTHOR
        23.09.2004 sasco
 * CHANGES
        27.09.2004 sasco Добавил поле tmpcln.accs
        30.09.2004 sasco исправил порядок счетов ak31,32,33,34 (депозит - карточка - счет - карточка)
        01.10.2004 sasco Исправил обработку финансовых обязательств
        28.12.2004 saltanat Добавила формирование и вывод сводной таблицы
        17.08.2006 Natalya D. - оптимизация: добавлена проверка на существование записей по таблице pkkrit.
*/


{pk0.i}
{msg-box.i}
{pkstat.i " "}

define input parameter v-bank as character.

/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

cnt_zaj = 0.
cnt_otk = 0.
cnt_zaj_all  = 0.
cnt_otk_all  = 0.

if not rep_con then do:
cnt_conz     = 0.
cnt_conz_all = 0.
cnt_cono     = 0.
cnt_cono_all = 0.
tot_ank_cnt  = 0.

for each tmp:
    delete tmp.
end.

for each tmpcln:
    delete tmpcln.
end.

for each tmpcnt:
    delete tmpcnt.
end.
end.

create tmpcnt.
tmpcnt.bank = v-bank.
tmpcnt.loaned = yes.
tmpcnt.cnt = 0.

create tmpcnt.
tmpcnt.bank = v-bank.
tmpcnt.loaned = no.
tmpcnt.cnt = 0.

find first tmpcnt where tmpcnt.bank = "CONS" no-error.
if not avail tmpcnt then do:
   create tmpcnt.
   tmpcnt.bank = "CONS".
   tmpcnt.loaned = yes.
   tmpcnt.cnt = 0.
   create tmpcnt.
   tmpcnt.bank = "CONS".
   tmpcnt.loaned = no.
   tmpcnt.cnt = 0.
end.
Message vd1 " " vd2 view-as alert-box.
do vdt = vd1 to vd2:
for each pkanketa where pkanketa.rdt = vdt and pkanketa.bank = v-bank and pkanketa.credtype = s-credtype no-lock use-index rdt:

    tot_ank_cnt = tot_ank_cnt + 1.

    if pkanketa.lon <> '' and pkanketa.lon <> ? then v-loan = true.
                                                else v-loan = false.

    create tmpcln.
    tmpcln.bank = v-bank.
    tmpcln.loaned = v-loan.
    tmpcln.ln = tot_ank_cnt.
    tmpcln.cln = no.
    tmpcln.accs = no.
    tmpcln.finobrem = ?.

    create tmpcln.
    tmpcln.bank = "CONS".
    tmpcln.loaned = v-loan.
    tmpcln.ln = tot_ank_cnt.
    tmpcln.cln = no.
    tmpcln.accs = no.
    tmpcln.finobrem = ?.

    find tmpcnt where tmpcnt.bank = v-bank and tmpcnt.loaned = v-loan no-error.
    tmpcnt.cnt = tmpcnt.cnt + 1.

    find tmpcnt where tmpcnt.bank = "CONS" and tmpcnt.loaned = v-loan no-error.
    tmpcnt.cnt = tmpcnt.cnt + 1.

    if rep_con and rep_zaj and v-loan then cnt_conz_all = cnt_conz_all + 1.
    if rep_con and rep_otk and not v-loan then cnt_cono_all = cnt_cono_all + 1.

    if rep_zaj and v-loan then cnt_zaj_all = cnt_zaj_all + 1.
    if rep_otk and not v-loan then cnt_otk_all = cnt_otk_all + 1.

    run SHOW-MSG-BOX (v-bank + " " + string (pkanketa.rdt) + " " + string (pkanketa.ln) + 
                      (if rep_zaj then " З:" + string (cnt_zaj_all) else " ") + 
                      (if rep_otk then " О:" + string (cnt_otk_all) else " ") ).

    pkh:
    for each pkanketh where pkanketh.bank = pkanketa.bank and 
                            pkanketh.credtype = pkanketa.credtype and 
                            pkanketh.ln = pkanketa.ln no-lock:

        if pkanketh.value1 = '' and lookup (pkanketh.kritcod, "acc1,acc2,nedvstreet,") = 0 then next pkh.

        /* пропустим обработку РНН для филиалов */
        if pkanketh.kritcod = "rnn" and v-bank <> "TXB00" then next.

        /* пропустим ненужные по списку */
        do si = 1 to num-entries (skips): 
           if pkanketh.kritcod matches entry(si, skips) then next pkh. 
        end.

        /* данные по филиалу */
        run Copy_tmp_value (v-bank, 1).
        
        /* консолидированные данные */
        run Copy_tmp_value ("CONS", 1).

    end. /* pkanketh */

end. /* pkanketa */
end. /* vdt */


/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


procedure Copy_tmp_value.

    define input parameter valueBank as character.
    define input parameter valueCnt  as integer.

    define variable v-s as character.
    define variable v-d as date.
    define variable s-valcod as character.
    define variable s-valdes as character.
    define variable s-kritcod as character.
    define variable s-kritname as character.

    s-kritcod = pkanketh.kritcod. /* код критерия */
    s-kritname = "".              /* описание критерия */
    s-valcod = pkanketh.value1.   /* код значения */
    s-valdes = "".                /* описание значения */

    v-s = trim(pkanketh.value1). 

    case pkanketh.kritcod:
    when "bdt" then do:
                       if pkanketh.value1 <> "" then do:
                          s-kritcod = "bdt".
                          s-kritname = "Возраст".
                          v-s = replace (v-s, ".", "").
                          v-s = replace (v-s, "-", "").
                          v-s = replace (v-s, "/", "").
                          v-s = replace (v-s, ",", "").       
                          v-d = date (substr(v-s,1,2) + "/" + substr(v-s,3,2) + "/" + substr(v-s,5)) no-error.
                          if not error-status:error then do:
                             if (pkanketa.rdt - v-d) / 365 < 21 then assign s-valcod = "bdt1" s-valdes = "до 21".
                             else
                             if (pkanketa.rdt - v-d) / 365 < 31 then assign s-valcod = "bdt2" s-valdes = "21 - 30".
                             else
                             if (pkanketa.rdt - v-d) / 365 < 41 then assign s-valcod = "bdt3" s-valdes = "31 - 40".
                             else
                             if (pkanketa.rdt - v-d) / 365 < 51 then assign s-valcod = "bdt4" s-valdes = "41 - 50".
                             else assign s-valcod = "bdt5" s-valdes = "свыше 50". 
                          end.
                       end.
                   end.
    when "rnn" then do:
                       find last rnn where rnn.trn = v-s no-lock no-error.
                       if avail rnn then do:
                          if rnn.raj1 <> "" then v-s = CAPS (rnn.raj1).
                          else if rnn.raj2 <> "" then v-s = CAPS (rnn.raj2).
                          else v-s = "(Район не известен)".
                       end.
                       else do:
                            find last rnnu where rnnu.trn = v-s no-lock no-error.
                            if avail rnnu then do:
                               if rnnu.raj1 <> "" then v-s = CAPS (rnnu.raj1).
                               else if rnnu.raj2 <> "" then v-s = CAPS (rnnu.raj2).
                               else v-s = "(Район не известен)".
                            end.
                            else v-s = "(Район не известен)".
                       end.
                       if trim(v-s) = "" then v-s = "(Район не известен)".
                       s-kritcod = "rajon".
                       s-kritname = "Район фактического проживания".
                       s-valcod = v-s.
                       s-valdes = v-s.
                   end.
    when "child" then do:
                      if v-s <> "" then do:
                          s-kritcod = "childhas".
                          s-kritname = "Наличие детей".
                          s-valcod = "1".
                          s-valdes = "Да".
                          find tmp where tmp.bank = valueBank and 
                                         tmp.kritcod = s-kritcod and 
                                         tmp.loaned = v-loan and
                                         tmp.valcod = s-valcod
                                         no-error.
                          if not avail tmp then do:                                                  
                             create tmp.
                             assign tmp.bank = valueBank
                                    tmp.kritcod = s-kritcod
                                    tmp.kritname = s-kritname
                                    tmp.valcod = s-valcod
                                    tmp.loaned = v-loan
                                    tmp.valdes = s-valdes
                                    .
                          end.
                          tmp.cnt = tmp.cnt + valueCnt.

                          s-kritcod = "childnum".
                          s-kritname = "Количество детей".

                          if v-s = "1" then assign s-valcod = "1" s-valdes = "1".
                          else
                          if v-s = "2" then assign s-valcod = "2" s-valdes = "2".
                          else assign s-valcod = "3" s-valdes = "3 и больше".

                      end.
                      else do:
                          s-kritcod = "childhas".
                          s-kritname = "Наличие детей".
                          s-valcod = "0".
                          s-valdes = "Нет".
                      end.
                   end.
    when "child16" then do:
                      if v-s <> "" then do:
                          s-kritcod = "childnum16".
                          s-kritname = "Несовершеннолетние дети".
                          if v-s = "1" then assign s-valcod = "1" s-valdes = "1".
                          else
                          if v-s = "2" then assign s-valcod = "2" s-valdes = "2".
                          else assign s-valcod = "3" s-valdes = "3 и больше".

                      end.
                   end.
    when "ak31" then do:
                      if v-s <> "" then do:
                          s-kritcod = "finacc".
                          s-kritname = "Финансовые активы (наличие счета)".
                          s-valcod = "ak31".
                          s-valdes = "Депозитный".
                          find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                          find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                      end.
                   end.
    when "ak32" or when "ak34" then do:
                      if v-s <> "" then do:
                          s-kritcod = "finacc".
                          s-kritname = "Финансовые активы (наличие счета)".
                          s-valcod = "ak32".
                          s-valdes = "Карточный".
                          find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                          find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                      end.
                   end.
    when "ak33" then do:
                      if v-s <> "" then do:
                          s-kritcod = "finacc".
                          s-kritname = "Финансовые активы (наличие счета)".
                          s-valcod = "ak33".
                          s-valdes = "Текущий".
                          find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                          find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                          tmpcln.accs = yes.
                      end.
                   end.
    when "nedvstreet" then do:
                      if pkanketh.value3 <> "" then do:
                          assign s-kritcod = "hasnedvizh"
                                 s-kritname = "Недвижимость в собственности"
                                 s-valcod = "1"
                                 s-valdes = "Да".
                      end.
                   end.
    when "auto" then do:
                      if pkanketh.value3 <> "" then do:
                          s-kritcod = "hasauto".
                          s-kritname = "Автомобиль в собственности".
                          s-valcod = "1".
                          s-valdes = "Да".
                      end.
                   end.
    when "ob1" or 
    when "ob2" or 
    when "ob3" or 
    when "ob4" or 
    when "ob4gar" or
    when "zalogodat" or 
    when "autoz" or 
    when "nedvz" then do:
                      
                      find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                      if tmpcln.finobrem = ? then tmpcln.finobrem = no.
                      find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                      if tmpcln.finobrem = ? then tmpcln.finobrem = no.

                      if pkanketh.rat < 0 then do:
                         find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                         tmpcln.finobrem = yes.
                         find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                         tmpcln.finobrem = yes.
                         s-kritcod = "".
                      end.
                 end.
    when "acc1" or 
    when "acc2" then do:
                    if pkanketh.value2 <> "" then do:
                       find tmpcln where tmpcln.bank = v-bank and tmpcln.ln = tot_ank_cnt no-error.
                       tmpcln.cln = yes.
                       find tmpcln where tmpcln.bank = "CONS" and tmpcln.ln = tot_ank_cnt no-error.
                       tmpcln.cln = yes.
                       s-kritcod = "".
                    end.
                end.
    otherwise do:
         find pkkrit where pkkrit.kritcod = pkanketh.kritcod and pkkrit.credtype = s-credtype no-lock no-error.
         if avail pkkrit then  
            s-kritname = trim(pkkrit.kritname).
         
         si = lookup (s-kritcod, valdefs).
         if si > 0 then do:
            find bookcod where bookcod.bookcod = entry (si, valspr) and bookcod.code = s-valcod no-lock no-error.
            if avail bookcod then s-valdes = bookcod.name.
                             else assign s-valcod = "99" 
                                         s-valdes = "Другое".
         end.
        end.

    end case.

    if s-kritcod <> "" then do:
 
       find tmp where tmp.bank = valueBank and 
                      tmp.kritcod = s-kritcod and 
                      tmp.loaned = v-loan and
                      tmp.valcod = s-valcod
                      no-error.
       
       if not avail tmp then do:                                                  
          create tmp.
          assign tmp.bank = valueBank
                 tmp.kritcod = s-kritcod
                 tmp.kritname = s-kritname
                 tmp.valcod = s-valcod
                 tmp.loaned = v-loan
                 tmp.valdes = s-valdes
                 .
       end.
       tmp.cnt = tmp.cnt + valueCnt.

    end. /* kritcod <> "" */

end procedure.
