/* garan_new.f
 * MODULE
        Операции
 * DESCRIPTION
        Форма для открытия новых гарантий с информацией по кредитору
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19/05/2010 galina
 * BASES
        BANK
 * CHANGES
        29/06/2010 k.gitalov - добавил поле "Тип гарантии"
        09/09/2010 galina - добавила учет и списание обеспечения
        23/02/2011 evseev - изменил N гарантии на N договора
        30/06/2011 id00810 - добавила поле N гарантии
        14/12/2011 id00810 - добавила поле "Дата оплаты комиссии", переставила некоторые поля
        15.06.2012 Lyubov  - закомментировала функцию проверки суммы покрытия. т.к. проверка осуществляется в осн. программе
        07/03/2013 sayat(id01143) - ТЗ 1707 от 07/02/2013 добавлено поле "Страна бенефициара"
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013 добавлены поля "N доп.согл.к договору" и "Дата доп.соглашения"
        02/09/2013 galina - ТЗ 1918

*/
/*function  chksum returns char (input p-sum as deci).
    def var mess as char.
    mess = ''.
    find first aaa where aaa.aaa = vaaa2 no-lock no-error.
    if (aaa.gl = 224011 or aaa.gl = 224021) and p-sum = 0 then mess = 'Гаратия обеспечена деньгами. Введите сумму покрытия!'.
    if (aaa.gl = 224013 or aaa.gl = 224023) and p-sum > 0 then mess = 'Гарантия необеспеченная. Сумма покрытия должна быть = 0!'.
    return mess.
end function.*/

function  chksumzal returns char (input p-sum as deci).
    def var mess as char.
    mess = ''.
    find first aaa where aaa.aaa = vaaa2 no-lock no-error.
    if (aaa.gl = 224011 or aaa.gl = 224021) and p-sum > 0 then mess = 'Гаратия обеспечена деньгами. Сумма залога должна быть = 0!'.
    if (aaa.gl = 224013 or aaa.gl = 224023) and p-sum > 0 then mess = 'Гарантия необеспеченная. Сумма залога должна быть = 0!'.
    return mess.
end function.


form
     v-cif       label "Код клиента               " format "x(6)" validate(can-find(cif where cif.cif = v-cif no-lock), " Клиент не найден! ") help "F2 - помощь" ' ' v-name   no-label format "x(60)" skip
     /*v-name    label "Наименование клиента      " format "x(60)" skip*/
     v-jh        label "N транзакции              " format ">>>,>>>,>>9" skip(1)
     vaaa2       label "Счет депозит-гарантия     " validate(can-find(aaa where aaa.aaa = vaaa2 and aaa.cif = v-cif no-lock), " Счет клиента не найден! ") help "F2 - помощь" ' ' vcrc label "Валюта гарантии" ' ' v-crcname no-label format 'x(3)' skip(1)
     vsum        label "Сумма покрытия            " format ">>>,>>>,>>>,>>9.99" /*validate(chksum(vsum) = '', chksum(vsum))*/ skip
     v-garan     label "N договора                " format "x(20)" validate(trim(v-garan) <> "", " Номер договора обязателен для заполнения! ")
     v-gardop    at 53 label "N доп.согл.к договору " format "x(20)" skip
     v-nomgar    label "N гарантии                " format "x(35)" validate(trim(v-nomgar) <> "", " Номер гарантии обязателен для заполнения! ") skip
     ListType    label "Тип гарантии              " skip
     vaaa        label "Расчетный счет клиента    " validate(can-find(aaa where aaa.aaa = vaaa and aaa.cif = v-cif no-lock), " Счет клиента не найден! ") help "F2 - помощь" skip
     dfrom       label "Дата откр. гарантии       "
     dtdop at 53 label "Дата доп.соглашения " skip
     dto         label "Дата оконч. гарантии      " /*validate(dto >= dfrom , " Дата окончания не может быть меньше даты открытия! ")*/ skip(1)
     v-codfr     label "Обеспечение               " format "x(5)" validate(can-find(lonsec where lonsec.lonsec eq integer(trim(v-codfr))), " Такой вид залога в справочнике не найден! ") help "F2-помощь"
     vobes at 35 format "x(60)" no-label skip
     sumzalog    label "Сумма залога (кроме денег)" format ">>>,>>>,>>>,>>9.99" validate(chksumzal(sumzalog) = '', chksumzal(sumzalog)) '    '
     v-crczal    label "Валюта залога" validate(can-find(crc where crc.crc = v-crczal no-lock), " Такой вид валюты в справочнике не найден! ") help "F2 - помощь" v-crczname no-label skip
     sumtreb     label "Сумма треб. по гарантии   " format ">>>,>>>,>>>,>>9.99" validate (sumtreb >= 0, " Сумма должны быть >= 0! ") skip(1)
     /*vcrc      label "Валюта гарантии           " validate(can-find(crc where crc.crc = vcrc no-lock), " Такой вид валюты в справочнике не найден! ") help "F2 - помощь" skip(1)*/
     v-jh2       label "N транзакции комиссии     " format ">>>,>>>,>>9" skip
     /*vcrc3     label "Валюта комиссии           " validate(can-find(crc where crc.crc = vcrc3 no-lock), " Такой вид валюты в справочнике не найден! ") help "F2 - помощь" skip*/
     v-grcom     label "Комиссия по графику?      " format "да/нет"
     v-mcom%     at 53 label "% по комиссии" format ">9.99" skip
     v-mcomsum   label "Ежемес. платж по комиссии " format ">>>,>>>,>>>,>>9.99" validate((v-grcom and v-mcomsum > 0) or not v-grcom, 'Введите значение больше нуля')
     v-mlstdate  at 53 label "Оплата в последний день месяца?" skip
     /*v-mdate     label "Дата первого платежа      " format "99/99/9999" validate((v-grcom and v-mdate > g-today) or not v-grcom, 'Неверное значение даты первого платежа') skip*/
     sumkom      label "Сумма комиссии            " format ">>>,>>>,>>>,>>9.99" validate(sumkom >= 0, " Сумма комиссии должна быть >= 0! ") '    '
     vcrc3       label "Валюта комиссии" validate(can-find(crc where crc.crc = vcrc3 no-lock), " Такой вид валюты в справочнике не найден! ") help "F2 - помощь" ' ' v-crc3name no-label skip
     dcom        label "Дата оплаты комиссии      "  validate(dcom >= g-today, 'Дата оплаты комиссии не может быть меньше текущего операционного дня') skip
     vaaa3       label "Р/счет для снятия комиссии" validate(can-find(aaa where aaa.aaa eq vaaa3 and aaa.cif = v-cif no-lock) or vaaa3 = '', "Счет не найден!") help "F2 - помощь" skip(1)
     v-bankben   label "Банк бенефециара          " format "x(60)" validate(trim(v-bankben) <> "", " Банк бенефециара обязателен для заполнения! ") skip
     v-benres    label "Резидентство бенефециара  " format "9" validate(v-benres = 1 or v-benres = 2, 'Резиденство бенефециара обязательно для заполнения')  help "F2 - помощь" v-benrdes no-label format "x(12)"
     v-bencount  at 53 label "Страна бенефициара" format "x(4)" validate(v-bencount <> "" and can-find(codfr where codfr.codfr = "countnum" and codfr.code = v-bencount),"Страна бенефициара обязательна для заполнения!") help "F2 - помощь" v-bencountr no-label format "x(30)" skip
     v-bentype   label "Тип бенефециара           " format "9" validate(v-bentype > 0 and v-bentype < 4, 'Тип бенефециара обязателен для заполнения!') help "F2 - помощь" v-bentdes no-label format "x(32)"skip
     v-naim      label "Наименование бенефециара  " format "x(60)" validate(trim(v-naim) <> "", " Наименование бенефециара обязательно для заполнения! ") skip
     v-fname     label "Фамилия бенефециара       " format "x(60)" validate(trim(v-fname) <> "", " Фамилия бенефециара обязательно для заполнения! ") skip
     v-lname     label "Имя бенефециара           " format "x(60)" validate(trim(v-lname) <> "", " Имя бенефециара обязательно для заполнения! ") skip
     v-mname     label "Отчество бенефециара      " format "x(60)"  skip
     v-address   label "Адрес бенефециара         " format "x(60)" validate(trim(v-address) <> "", " Адрес бенефециара обязателен для заполнения! ") skip
with side-label row 6 centered title " Общая информация " overlay width 110 frame garan0.

on help of v-codfr in frame garan0 do:
    run h-lonsec.
    v-codfr:screen-value = return-value.
    v-codfr = v-codfr:screen-value.
end.


on help of vaaa2 in frame garan0 do:
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and substr(string(aaa.gl),1,4) = '2240' /*use-index aaa-idx1*/ no-lock no-error.

    if avail aaa then do:
        {itemlist.i
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and substr(string(aaa.gl),1,4) = '2240' "
            &findadd = " v-crcname = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crcname = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crcname label 'Валюта' "
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
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 /*use-index aaa-idx1*/ no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "1"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 "
            &findadd = " v-crcname = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crcname = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crcname label 'Валюта' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        vaaa = aaa.aaa.
        displ vaaa with frame garan0.
    end.
end.

on help of vaaa3 in frame garan0 do:
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = vcrc3 and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 /*use-index aaa-idx1*/ no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "2"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = vcrc3 and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0"
            &findadd = " v-crc3name = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crc3name = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crc3name label 'Валюта' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        vaaa3 = aaa.aaa.
        displ vaaa3 with frame garan0.
    end.
end.

/*on help of vcrc in frame garan0 do:
    run h-crc.
    vcrc:screen-value = return-value.
    vcrc = integer(vcrc:screen-value).
end.*/

on help of vcrc3 in frame garan0 do:
    run h-crc.
    vcrc3:screen-value = return-value.
    vcrc3 = integer(vcrc3:screen-value).
end.

on help of v-benres in frame garan0 do:
   run sel2 (' РЕЗИДЕНСТВО ', '1 - резидент |2 - нерезидент ', output v-benres).
   if v-benres = 1 then v-benrdes = 'резидент'.
   if v-benres = 2 then v-benrdes = 'нерезидент'.
   display v-benres v-benrdes with frame garan0.
end.

on help of v-bentype in frame garan0 do:
   run sel2 (' ТИП БЕНЕФЕЦИАРА ', '1 - Юридическое лицо |2 - Физическое лицо |3 - Индивидуальный предприниматель ', output v-bentype).
   if v-bentype = 1 then v-bentdes = 'Юридическое лицо'.
   if v-bentype = 2 then v-bentdes = 'Физическое лицо'.
   if v-bentype = 2 then v-bentdes = 'Индивидуальный предприниматель'.
   display v-bentype v-bentdes with frame garan0.
end.

on help of v-bencount in frame garan0 do:
    {itemlist.i
        &file = "codfr"
        &form = " codfr.code label ""Код"" format ""x(5)"" codfr.name[1] label ""Наименование"" format ""x(60)"" "
        &frame = " 28 down row 6 width 70 overlay "
        &where = " codfr.codfr = ""countnum"" "
        &flddisp = " codfr.code codfr.name[1] "
        &chkey = "code"
        &chtype = "string"
        &index = "cdco_idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    if avail codfr then do:
        v-bencount = codfr.code.
        v-bencountr = codfr.name[1].
    end.
    display v-bencount v-bencountr with frame garan0.
end.
