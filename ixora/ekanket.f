/* ekanket.f
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Анкета клиента - форма
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

form
    v-cifcod  label " Код клиента         " format "x(06)" validate(can-find(first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and trim(v-cifcod) <> "" no-lock), 'Неверный код клиента')
    s-ln label "                    Номер анкеты    " format ">>>9" skip
    v-iin     label " ИИН                 " format "x(12)" validate(can-find(first pcstaff0 where pcstaff0.iin = v-iin and pcstaff0.bank = v-bank no-lock), "Нет такого ИИН в базе Платежных карт вашего филиала! F2-помощь") skip
    v-sname   label " Фамилия             " format "x(25)" v-fname  label " Имя " format "x(20)" skip
    v-mname   label " Отчество            " format "x(30)" skip
    v-birth   label " Дата рождения       " format "99/99/9999"     v-bplace label "                Место рождения  " format "x(25)" skip
    v-nomdoc  label " Номер документа     " format "x(15)"          v-isswho label "           Орган выдачи    " format 'x(15)' skip
    v-issdt   label " Дата выдачи         " format "99/99/9999"     v-expdt  label "                Срок действия   " format '99/99/9999' skip
    v-addr[1] label " Адрес регистрации   " format "x(50)"  skip
    v-addr[2] label " Адрес проживания    " format "x(50)"  skip
    v-tel[1]  label " Телефон домашний    " format 'x(12)'          v-tel[3] label "              Телефон рабочий " format 'x(12)' skip
    v-tel[2]  label " Телефон мобильный   " format 'x(12)'          v-mail   label "              E-mail          " format "x(20)" skip
    v-educat  label " Образование         " format "x(30)" validate(can-find(first codfr where codfr.codfr = 'educat' and codfr.name[1] = v-educat no-lock), "Выберите значение из справочника!") skip
    v-work    label " Место работы        " format "x(25)"          v-posit  label " Должность       " format "x(20)" validate(v-posit <> '', "Необходимо заполнить поле!") skip
    v-stajpos label " Стаж на посл. месте "  validate (v-stajpos >= 6, 'Стаж на последнем месте работы должен быть не меньше 6 мес.') format ">>>9"
    v-stajob  label "                      Общий стаж      " validate (v-stajob >= 6, 'Общий стаж работы должен быть не меньше 6 мес.') format ">>>9" skip
    v-salary  label " Сумма з/платы нетто " validate (v-salary >= 70000, 'Сумма заработной платы должна быть не меньше 70 000') format ">>>,>>>,>>>,>>9.99" skip
    v-marsts  label " Семейное положение  " format "x(30)" validate(can-find(first codfr where codfr.codfr = 'maritsts' and codfr.name[1] = v-marsts no-lock), "Выберите значение из справочника!") skip
    v-spsname label " Фамилия супруга(и)  " format "x(25)" v-spfname label " Имя супруга(и)  " format "x(20)" skip
    v-spmname label " Отчество супруга(и) " format "x(30)" skip
    v-spwork  label " Супруг(а) работает  " format "да/нет" skip
    v-tel[4]  label " Телефон мобильный   " format 'x(12)' skip
    v-spwplc  label " Место работы супр.  " format "x(25)" v-spsal   label " Сумма з/п супр. " format ">>>,>>>,>>>,>>9.99" skip
    v-memnum  label " Кол-во членов семьи " format '>>>>9' validate(v-memnum <> 0, "Необходимо заполнить поле!") v-depend  label "    кол-во детей " format '>>>>9' v-depend1 label 'в том числе несовершеннолетних ' format '>>>>9' skip
    v-vidfin  label " Вид финансирования  " format 'x(30)' validate(can-find(first codfr where codfr.codfr = 'ekvidfin' and codfr.name[1] = v-vidfin no-lock), "Выберите значение из справочника!") skip
    v-sumtr   label " Запраш.сумма кредита" validate (v-sumtr >= 70000 and v-sumtr <= 1500000, 'Сумма кредита не должна быть меньше 70 000 и превышать 1 500 000') format '>>>,>>>,>>>,>>9.99'
    v-sroktr  label "        Запраш.срок кред.мес" validate (v-sroktr >= 3 and v-sroktr <= 48, 'Срок кредитования должен быть не менее 3 мес. и не более 48 мес.') format '>>>9' skip
    v-gstav   label " Годовая ставка возн." format '>>9.9' skip
    v-comorg  label " Комиссия за организ." format '>>9.9' skip
    v-metam   label " Метод погашения     " format 'x(26)' validate(can-find(first codfr where codfr.codfr = 'ekmetam' and codfr.name[1] = v-metam no-lock), "Выберите значение из справочника!") v-issue label " Выдача кредита на" format 'x(15)' validate(can-find(first codfr where codfr.codfr = 'ekissu' and codfr.name[1] = v-issue no-lock), "Выберите значение из справочника!") skip
    v-dattr   label " Желат.день погашения" validate (v-dattr >= 1 and v-dattr <= 31, 'Выберите день месяца') format ">9" skip
    with side-labels centered row 3 title ' Анкета ' width 100 frame frpc.

form
    v-quest1  label " Сохранить изменения?" format "Да/нет" skip
    with side-labels centered row 33 width 100 frame quest1.

form
    v-quest2  label " Произвести выдачу?  " format "Да/нет" skip
    with side-labels centered row 35 width 100 frame quest2.

form
    v-cbnomd  label " Номер договора      " format "x(20)"   v-cbbank  label "      Наименование Банка " format "x(20)" skip
    with side-labels centered row 33 width 100 frame info2.


form
    v-crbank  label " Банк (Кредитор) - источник информации " format 'x(30)' skip
    v-cdnom   label " Номер кредитного договора " format 'x(30)' skip
    v-bdat    label " Дата начала срока дейсвтия договора " format "99/99/9999" skip
    v-edat    label " Дата оконч. срока дейсвтия договора " format "99/99/9999" skip
    v-outam   label " Непогашенная сумма по кредиту " format '>>>,>>>,>>>,>>9.99' skip
    with side-labels centered row 3 title ' Параметры кредита ' width 100 frame fpar.

on "END-ERROR" of frame frpc do:
  hide frame frpc no-pause.
end.

on help of v-cifcod in frame frpc do:
    run h-pcr PERSISTENT SET phand.
    v-cifcod = frame-value.
    displ v-cifcod with frame frpc.
end.

on help of s-ln in frame frpc do:
    {itemlist.i
        &file    = "pkanketa"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 30 overlay "
        &where   = " pkanketa.bank = v-bank and pkanketa.credtype = '10' and pkanketa.cif = v-cifcod "
        &flddisp = " pkanketa.ln label ' Номер анкеты ' format '>>>>9' "
        &chkey   = "ln"
        &chtype  = "inte"
        &index   = "bankcred"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    s-ln = pkanketa.ln.
    displ s-ln with frame frpc.
end.

on help of v-educat in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 30 overlay "
        &where   = " codfr.codfr = 'educat' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Вид образования ' format 'x(25)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-educat = codfr.name[1].
    displ v-educat with frame frpc.
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
on help of v-marsts in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 20 down width 40 overlay "
        &where   = " codfr.codfr = 'maritsts' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Семейное положение ' format 'x(35)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-marsts = codfr.name[1].
    displ v-marsts with frame frpc.
end.
on help of v-vidfin in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 20 down width 40 overlay "
        &where   = " codfr.codfr = 'ekvidfin' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Вид финансирования ' format 'x(35)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-vidfin = codfr.name[1].
    displ v-vidfin with frame frpc.
end.
on help of v-metam in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 20 down width 40 overlay "
        &where   = " codfr.codfr = 'ekmetam' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Метод погашения ' format 'x(35)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-metam = codfr.name[1].
    displ v-metam with frame frpc.
end.
on help of v-issue in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 20 down width 40 overlay "
        &where   = " codfr.codfr = 'ekissu ' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Выдача на ' format 'x(35)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-issue = codfr.name[1].
    displ v-issue with frame frpc.
end.