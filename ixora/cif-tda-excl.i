/* cif-tda-excl.i
 * MODULE
        Депозиты
 * DESCRIPTION
        Установка исключительной % ставки на депозиты ФЛ
 * RUN
        
 * CALLER
        cif-tda.p, cif-tdae.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.2 "ОткрСч"
 * AUTHOR
        20/05/2004 nadejda
 * CHANGES
        21.06.2004 nadejda - добавлена отсылка письма при установке/снятии ставки
        19.10.2004 dpuchkov- возможность менять дату окончания
*/

def var v-des as char.
def var v-adr as char.

function getmail returns char.
  find sysc where sysc.sysc = "excl%m" no-lock no-error.
  if not avail sysc or trim(sysc.chval) = "" then return "".

  v-adr = trim(sysc.chval).
  repeat:
    if index(v-adr, ",,") = 0 then leave.
    v-adr = replace(v-adr, ",,", ",").
  end.
  if substr(v-adr, length(v-adr)) = "," then v-adr = substr(v-adr, 1, length(v-adr) - 1).
  if substr(v-adr, 1) = "," then v-adr = substr(v-adr, 2).
  if v-adr = "" then return "".

  v-adr = replace(v-adr, ",", "@metrocombank.kz,").
  v-adr = v-adr + "@metrocombank.kz".
  return v-adr.
end.

if aaa.expdt <> d-prddate then do:
    update v-des no-label format "x(47)" validate (trim(v-des) <> "", "Введите сведения о распоряжении руководства!") with centered overlay row 15 title " СВЕДЕНИЯ О РАСПОРЯЖЕНИИ " frame f-des.
    hide frame f-des.
    v-des = trim(v-des).
    v-adr = getmail().
    if v-adr <> "" then do:
      find ofc where ofc.ofc = g-ofc no-lock no-error.
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.
      run mail(v-adr, g-ofc + "@metrocombank.kz <" + g-ofc + "@metrocombank.kz>", "Установлена новый срок депозитного вклада", 
         "По депозиту " + aaa.aaa + " " + lgr.des + " установлен новый срок окончания" + trim(string(aaa.expdt)) + 
         " вместо " + trim(string(d-prddate)) + ". Установил менеджер : (" + g-ofc + ") " + ofc.name + ". Сведения о распоряжении : " + v-des + ".", 
         "1", "", ""). 

    end.
end.


if v-excl then do:
  /* ставка на группе */
  run tdagetrate("", aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output v-rate).

  update aaa.rate with frame aaa.
  /* если что-то менялось - запишем */
  if aaa.payfre = 0 or aaa.rate entered then do:

    mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).
    disp mbal with frame aaa.
    pause 0.

    update v-des no-label format "x(47)" validate (trim(v-des) <> "", "Введите сведения о распоряжении руководства!") with centered overlay row 15 title " СВЕДЕНИЯ О РАСПОРЯЖЕНИИ " frame f-des.
    hide frame f-des.
    v-des = trim(v-des).
    if aaa.geo <> "" then aaa.geo = aaa.geo + "|".
    aaa.geo = aaa.geo + g-ofc + "^" + string(g-today) + "^" + string(aaa.rate) + "^" + string(v-excl) + "^" + v-des.

    /* послать письмо об установке исключения */
    v-adr = getmail().
    if v-adr <> "" then do:
      find ofc where ofc.ofc = g-ofc no-lock no-error.
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.

      run mail(v-adr, g-ofc + "@metrocombank.kz <" + g-ofc + "@metrocombank.kz>", "Установлена исключительная % ставка по депозиту", 
         "По депозиту " + aaa.aaa + " " + lgr.des + " установлена исключительная ставка " + trim(string(aaa.rate, ">>>>>>>>9.99")) + 
         "% вместо " + trim(string(v-rate, ">>>>>>>>9.99")) + "% по группе. Установил менеджер : (" + g-ofc + ") " + ofc.name + ". Сведения о распоряжении : " + v-des + ".", 
         "1", "", "").  
    end.
  end.
  aaa.payfre = 1.
end.
else do:
  /* если что-то менялось - запишем */
  if aaa.payfre = 1 then do:
    aaa.payfre = 0.
    v-rate = aaa.rate.

    /* счет теперь не исключение - поставим верную ставку и сумму */
    run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output aaa.rate).
    mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).

    if aaa.geo <> "" then aaa.geo = aaa.geo + "|".
    aaa.geo = aaa.geo + g-ofc + "^" + string(g-today) + "^" + string(aaa.rate) + "^" + string(v-excl) + "^".

    /* послать письмо об отмене исключения */
    v-adr = getmail().
    if v-adr <> "" then do:
      find ofc where ofc.ofc = g-ofc no-lock no-error.
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.

      run mail(v-adr, g-ofc + "@metrocombank.kz <" + g-ofc + "@metrocombank.kz>", "Отменена исключительная % ставка по депозиту", 
         "По депозиту " + aaa.aaa + " " + lgr.des + " установлена ставка по умолчанию " + trim(string(aaa.rate, ">>>>>>>>9.99")) + 
         "% вместо исключительной " + trim(string(v-rate, ">>>>>>>>9.99")) + "%. Отменил менеджер : (" + g-ofc + ") " + ofc.name + ".", 
         "1", "", ""). 
    end.

    disp aaa.rate mbal with frame aaa.
    pause 0.
  end.
  pause 10.
end.


