/* pccreds.f
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Форма для редактирования кредитной анкеты по ПК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        17.09.2013 Lyubov - ТЗ 2081, убрала ограничение на сумму з.п. 40000
        16.10.2013 Lyubov - ТЗ 2082, проверяем стаж, должен быть не менее 6 месяцев
*/


form
    v-aaa      label " Тек.счет по плат.карте  " format "x(20)" skip
    v-cifcod   label " Код клиента             " format "x(06)" validate(can-find(first pcstaff0 where pcstaff0.cif = v-cifcod no-lock), 'Неверный код клиента')        v-iin       label "                             ИИН " format "x(12)" validate(can-find(first pcstaff0 where pcstaff0.iin = v-iin and pcstaff0.bank = v-bank no-lock), "Нет такого ИИН в базе Платежных карт вашего филиала! F2-помощь") skip
    v-sname    label " Фамилия                 " format "x(30)" skip
    v-fname    label " Имя                     " format "x(20)" skip
    v-mname    label " Отчество                " format "x(50)" skip
    v-namelat1 label " Фамилия (лат.)          " format "x(26)"         v-namelat2  label "  Имя (лат.) " format "x(15)" skip
    v-birth    label " Дата рождения           " format "99/99/9999"    v-cword     label "               Кодовое слово " format 'x(15)' skip(1)
    v-mail     label " E-mail                  " format "x(50)" skip
    v-work     label " Место работы            " format "x(30)" skip
    v-tel[1]   label " Телефон домашний        " format 'x(12)'         v-tel[2]    label "              Телефон моб. " format 'x(12)' skip
    v-addr[1]  label " Адрес регистрации       " format "x(50)"  skip
    v-addr[2]  label " Адрес проживания        " format "x(50)"  skip(1)
    v-nomdoc   label " Документ,удост.личность " format "x(15)"         v-isswho    label "              Кем выдан " format 'x(15)' skip
    v-issdt    label " Когда выдан             " format "99/99/9999"    v-expdt     label "               Срок действия " format '99/99/9999' skip(1)
    v-crcname  label " Вид валюты              " format "x(03)"         v-pctype    label "                          Вид карты " format "x(10)" validate(can-find(first codfr where codfr.codfr = 'pctype' and codfr.name[1] = v-pctype no-lock), "Нет такого вида платежных карт! F2-помощь") skip
    v-rez      label " Резидент да/нет         " format "Да/нет"        v-country   label "                             Страна " format "x(03)" validate(can-find(first codfr where codfr.codfr = 'iso3166' and codfr.name[2] = v-country no-lock), "Нет такой страны в справочнике кодов стран! F2-помощь") skip(1)
    v-migrn    label " Миграционная карта №    " format "x(10)" skip
    v-migrdt1  label " Срок пребывания с       " format '99/99/9999'    v-migrdt2   label "                          по " format '99/99/9999'skip
    v-publicf  label " Публич.должн.лицо да/нет" format "Да/нет" skip
    v-position label " Должность               " format "x(30)" skip
    v-offsh    label " Счета в оффшорных зонах " format "Да/нет" skip
    v-offshd   label " Доп.информация по счетам" format "x(30)" skip
    v-sms      label " Sms-информирование      " format "Да/нет"  v-bplace label "                     Место рождения " format "x(25)" skip
    v-hdt      label " Дата приема на работу   " validate ((g-today - v-hdt) / 30 >= 6 and v-hdt < today, 'Минимальный стаж работы клиента не соответствует требованиям продукта!')format "99/99/9999" skip
    v-salary   label " Сумма заработной платы нетто " validate (v-salary > 0, 'Неверно указана сумма заработной платы') format ">>>,>>>,>>>,>>9.99" skip
    v-quest2   label " Сохранить изменения?    " format "Да/нет" skip
    v-quest1   label " Заполнить доп. анкету?  " format "Да/нет" skip
    with side-labels centered row 3 title ' Анкета ' width 100 frame frpc.

form
    v-relative label " Близкий родственник          " format "x(50)" skip
    v-relfio   label " Ф.И.О. (полностью)           " format "x(50)" skip
    v-reladr   label " Адрес проживания             " format "x(50)" skip
    v-reltel   label " Контактные данные            " format "x(50)" skip(1)

    v-spouse   label " Супруг/супруга               " format "x(50)" skip
    v-spofio   label " Ф.И.О. (полностью)           " format "x(50)" skip
    v-spotel   label " Контактные данные            " format "x(50)" skip(1)

    v-active   label " Активы                       " format "x(50)" skip
    v-estate   label " Недвижимое имущество (адрес) " format "x(50)" skip
    v-car      label " Автотранспорт                " format "x(50)" skip(1)

    v-quest3   label " Сохранить изменения?         " format "Да/нет" skip
    with side-labels centered row 3 title ' Ввод дополнительных данных : ' width 100 frame dopinfo.

on "END-ERROR" of frame frpc do:
  hide frame frpc no-pause.
end.

on help of v-cifcod in frame frpc do:
    run h-pcr PERSISTENT SET phand.
    v-cifcod = frame-value.
    displ v-cifcod with frame frpc.
end.

on help of v-iin in frame frpc do:
    {itemlist.i
         &file    = "pcstaff0"
         &set     = "1a"
         &frame   = "row 2 centered scroll 1 10 down width 55 overlay "
         &where   = " pcstaff0.bank = v-bank "
         &flddisp = " pcstaff0.iin label 'ИНН' format 'x(12)' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО клиента' format 'x(40)' "
         &chkey   = "iin"
         &index   = "iin"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
    v-iin = pcstaff0.iin.
    displ v-iin with frame frpc.
end.

on help of v-country in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 50 overlay "
        &where   = " codfr.codfr = 'iso3166' and codfr.name[2] ne '' "
        &flddisp = " codfr.code label ' Код1 ' codfr.name[2] label ' Код2 ' format 'x(03)' codfr.name[1] label ' Название страны ' format 'x(25)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-country = codfr.name[2].
    displ v-country with frame frpc.
end.
on help of v-bplace in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 20 down width 40 overlay "
        &where   = " codfr.codfr = 'regionkz' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Название региона ' format 'x(35)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-bplace = codfr.name[1].
    displ v-bplace with frame frpc.
end.