/* garan.p

 * MODULE
      Кредитный модуль
 * DESCRIPTION
      Форма для открытия новых гарантий  в соответсвии с тербованиями НБ РК
 * RUN

 * CALLER
      garan.p
 * SCRIPT

 * INHERIT

 * MENU
      2-15
 * AUTHOR
      15/08/03 nataly
 * CHANGES
      18/08/2003 nataly - была доработана форма просмотра и удаления проводки
      14/04/2010 madiyar - переделал форму; комиссия через кассу
      15/04/2010 madiyar - подправил справочник
*/

form
     v-cif     label "Код клиента               " format "x(6)" validate(can-find(cif where cif.cif = v-cif no-lock), " Клиент не найден! ") skip
     v-name    label "Наименование клиента      " format "x(60)" skip
     v-jh      label "N транзакции              " format ">>>,>>>,>>9" skip(1)
     vaaa2     label "Счет депозит-гарантия     " validate(can-find(aaa where aaa.aaa = vaaa2 and aaa.cif = v-cif no-lock), " Счет клиента не найден! ") skip(1)
     vsum      label "Сумма покрытия            " format ">>>,>>>,>>>,>>9.99" validate(vsum >= 0 , " Сумма должны быть >= 0 ") skip
     v-garan   label "N гарантии                " format "x(35)" validate(trim(v-garan) <> "", " Номер гарантии обязателен для заполнения! ") skip
     vaaa      label "Расчетный счет клиента    " validate(can-find(aaa where aaa.aaa = vaaa and aaa.cif = v-cif no-lock), " Счет клиента не найден! ") skip
     dfrom     label "Дата откр. гарантии       " skip
     dto       label "Дата оконч. гарантии      " validate(dto >= dfrom , " Дата окончания не может быть меньше даты открытия! ") skip(1)
     v-codfr   label "Обеспечение               " format "x(5)" validate(can-find(lonsec where lonsec.lonsec eq integer(trim(v-codfr))), " Такой вид залога в справочнике не найден! ") help "Выберите вид залога, F2-Помощь"
     vobes at 35 format "x(60)" no-label skip
     sumzalog  label "Сумма залога              " format ">>>,>>>,>>>,>>9.99" skip
     sumtreb   label "Сумма треб. по гарантии   " format ">>>,>>>,>>>,>>9.99" validate (sumtreb >= 0, " Сумма должны быть >= 0! ") skip
     vcrc      label "Валюта гарантии           " validate(can-find(crc where crc.crc = vcrc no-lock), " Такой вид валюты в справочнике не найден! ") skip(1)
     v-jh2     label "N транзакции комиссии     " format ">>>,>>>,>>9" skip
     vcrc3     label "Валюта комиссии           " validate(can-find(crc where crc.crc = vcrc no-lock), " Такой вид валюты в справочнике не найден! ") skip
     sumkom    label "Сумма комиссии            " format ">>>,>>>,>>>,>>9.99" validate(sumkom >= 0, " Сумма комиссии должна быть >= 0! ") skip
     /*
     v-eknp    label "КНП                       " format "x(40)" validate(can-find(codfr where codfr.codfr = 'spnpl' and codfr.code = v-eknp no-lock),  "Такой код КНП в справочнике не найден! ") help "Выберите код КНП, F2-Справ." skip
     */
     vaaa3     label "Р/счет для снятия комиссии" validate(can-find(aaa where aaa.aaa eq vaaa3 and aaa.cif = v-cif no-lock) or vaaa3 = '', "Счет не найден!") skip
     v-bankben label "Банк бенефециара          " format "x(60)" validate(trim(v-bankben) <> "", " Банк бенефециара обязателен для заполнения! ") skip
     v-naim    label "Наименование бенефециара  " format "x(60)" validate(trim(v-naim) <> "", " Наименование бенефециара обязательно для заполнения! ") skip
     v-address label "Адрес бенефециара         " format "x(60)" validate(trim(v-address) <> "", " Адрес бенефециара обязателен для заполнения! ") skip
with side-label row 4 centered title " Общая информация " overlay width 110 frame garan0.

on help of v-codfr in frame garan0 do:
    run h-lonsec.
    v-codfr:screen-value = return-value.
    v-codfr = v-codfr:screen-value.
end.

/*
on help of v-eknp in frame garan0 do:
    run uni_help1('spnpl','*').
    v-eknp = return-value.
end.
*/

on help of vaaa2 in frame garan0 do:
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' use-index aaa-idx1 no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' "
            &flddisp = " aaa.aaa label 'Счет' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        vaaa2 = aaa.aaa.
        displ vaaa2 with frame garan0.
    end.
end.

on help of vaaa in frame garan0 do:
    def buffer bbaaa for aaa.
    find first bbaaa where bbaaa.aaa = vaaa2 no-lock no-error.
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc use-index aaa-idx1 no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "1"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc "
            &flddisp = " aaa.aaa label 'Счет' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        vaaa = aaa.aaa.
        displ vaaa with frame garan0.
    end.
end.

on help of vaaa3 in frame garan0 do:
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = vcrc3 use-index aaa-idx1 no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "2"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = vcrc3 "
            &flddisp = " aaa.aaa label 'Счет' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        vaaa3 = aaa.aaa.
        displ vaaa3 with frame garan0.
    end.
end.

on help of vcrc in frame garan0 do:
    run h-crc.
    vcrc:screen-value = return-value.
    vcrc = integer(vcrc:screen-value).
end.

on help of vcrc3 in frame garan0 do:
    run h-crc.
    vcrc3:screen-value = return-value.
    vcrc3 = integer(vcrc3:screen-value).
end.


