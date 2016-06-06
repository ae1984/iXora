/* expspr.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Справочник условий по розничному кредитованию
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-3
 * AUTHOR
        25.07.2013 Lyubov - ТЗ 1833
 * BASES
        BANK COMM
 * CHANGES
        17.09.2013 Lyubov - ТЗ 2088, добавлен код ourbnk, убраны несколько видов комиссий
        23.09.2013 Lyubov - перекомпиляция
        08.10.2013 Lyubov - ТЗ 2132, поиск только по введенному коду
*/

{global.i}

def var i as inte.
def var v-select  as inte.
def var v-select1 as inte.
def var v-select2 as inte.
def var v-select3 as inte.
def var v-vid     as char.
def var v-vides   as char.
def var v-grp     as char.

def var v-minsum  as deci.
def var v-maxsum  as deci.
def var v-minsrok as inte.
def var v-maxsrok as inte.
def var v-bazst   as deci.
def var v-comann  as inte.
def var v-comdif  as inte.
def var v-pogas   as char extent 2.
def var v-vidpl   as char.
def var v-vidob   as char.
def var v-insur   as logi format 'Да/Нет'.
def var v-fine    as char extent 3.
def var v-kknom   as char.
def var v-kkdat   as date.
def var v-kknomc  as char.
def var v-kkdatc  as date.
def var v-save    as logi format 'Да/Нет'.
def var v-cont    as logi format 'Да/Нет'.

def var v-zag      as char.
def var v-str      as char.
def var v-maillist as char.

def var v-cif as char.
def var v-cifnam as char.
def var v-act as char.
def var v-dmo as logi init no.

def var v-stf as char extent 5.
DEFINE VARIABLE phand AS handle.

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'dmomail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
    trim(v-maillist,',').
end.
if can-do(codfr.name[1],g-ofc) then v-dmo = yes.

DEFINE QUERY q-spr FOR bookcod.

DEFINE BROWSE b-spr QUERY q-spr
       DISPLAY bookcod.code label " Код " format "x(1)" bookcod.name label "Описание" format "x(25)"
       WITH  15 DOWN.
DEFINE FRAME f-spr b-spr  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

form
    v-minsum  label " Минимальная сумма кредита       " format ">>>,>>9.99"   "тг." skip(1)
    v-maxsum  label " Максимальная сумма кредита      " format ">,>>>,>>9.99" "тг." skip(1)
    v-minsrok label " Минимальный срок кредитования   " format ">>9" "мес." skip(1)
    v-maxsrok label " Максимальный срок кредитования  " format ">>9" "мес." skip(1)
    v-bazst   label " Базовая ставка вознагрждения    " format ">>9.9" "%" skip(1)
    v-stf[1]  label " Комиссия за организацию кредита " skip
    v-comann  label " при аннуитетном методе погашен. " format ">>9.9" "%" skip(1)
    v-stf[2]  label " Комиссия за организацию кредита " skip
    v-comdif  label " при дифференц. методе погашен.  " format ">>9.9" "%" skip(1)
    v-pogas[1] label " Комиссия за полное/частичное    " format "x(60)" skip
    v-pogas[2] label " досрочное погашение             " format "x(60)" skip(1)
    v-vidpl   label " Вид платежа                     " format "x(60)" skip(1)
    v-vidob   label " Вид обеспечения                 " format "x(60)" skip(1)
    v-insur   label " Страхование                     " format "Да/Нет" skip(1)
    v-fine[1] label " Пени/штрафы на просроченную     " format "x(60)" skip
    v-fine[2] label " сумму задолженности за каждый   " format "x(60)" skip
    v-fine[3] label " день просрочки                  " format "x(60)" skip(1)
    v-kknom   label " № протокола КК                  " format "x(60)" skip
    v-kkdat   label " Дата протокола КК               " format "99.99.9999" skip(1)
    v-save    label " Сохранить?                      " format "Да/Нет" skip
    v-cont    label " Контролировать?                 " format "Да/Нет" skip
with side-labels centered row 3 title ' СПРАВОЧНИК ' width 100 frame fsprav.

repeat:
    run sel2("Выберите :", " 1. Условия кредитования | 2. Рефинансирование | 3. Рефин. в период акции | 4. Выход ", output v-select).
    case v-select:
        when 1 then do:
            run sel2 ("Условия кредитования :", " 1. Стандартные | 2. Индивидуальные | 3. Выход ", output v-select1).
            case v-select1:
                when 1 then v-vid = '1'.
                when 2 then do:
                    run sel2 ("Индивидуальные условия кредитования :", " 1. Комиссия 4 | 2. Комиссия 5 | 3. Комиссия 6 | 4. Выход ", output v-select2).
                    case v-select2:
                        when 1 then v-vid = '2'.
                        when 2 then v-vid = '3'.
                        when 3 then v-vid = '4'.
                        when 4 then return.
                    end.
                end.
                when 3 then return.
            end.
        end.
        when 2 then do:
            run sel2 ("Рефинансирование :", " 1. Реф.16,5% | 2. Реф.18% | 3. Выход ", output v-select1).
            case v-select1:
                when 1 then do:
                    run sel2 ("Условия рефинансирования :", " 1. Комиссия 4 | 2. Комиссия 5 | 3. Комиссия 6 | 5. Выход ", output v-select2).
                    case v-select2:
                        when 1 then v-vid = '5'.
                        when 2 then v-vid = '6'.
                        when 3 then v-vid = '7'.
                        when 4 then return.
                    end.
                end.
                when 2 then do:
                    run sel2 ("Условия рефинансирования :", " 1. Комиссия 6 | 2. Выход ", output v-select2).
                    case v-select2:
                        when 1 then v-vid = '8'.
                        when 2 then return.
                    end.
                end.
                when 3 then return.
            end.
        end.
        when 3 then v-vid = '9'.
        when 4 then return.
    end.

    case v-vid:
        when '1'  then v-vides = 'Стандартные условия кредитования'.
        when '2'  then v-vides = 'Индивидуальные условия кредитования - Комиссия 4'.
        when '3'  then v-vides = 'Индивидуальные условия кредитования - Комиссия 5'.
        when '4'  then v-vides = 'Индивидуальные условия кредитования - Комиссия 6'.
        when '5'  then v-vides = 'Рефинансирование 16,5% - Комиссия 4'.
        when '6'  then v-vides = 'Рефинансирование 16,5% - Комиссия 5'.
        when '7'  then v-vides = 'Рефинансирование 16,5% - Комиссия 6'.
        when '8'  then v-vides = 'Рефинансирование 18% - Комиссия 6'.
        when '9'  then v-vides = 'Рефин. в период акции'.
    end case.

    define button but1 label "Список условий".
    define button but2 label "Список компаний".
    define button but3 label "Выход".
    define frame f2
    but1
    but2
    but3 with width 50.

    enable all with frame f2.

    on choose of but1 in frame f2 do:

        if v-vid = '' then do:
            message 'Не выбран вид справочника' view-as alert-box.
            return.
        end.
        find first credhdbk where credhdbk.hdbkcod = v-vid no-lock no-error.
        if avail credhdbk then do:
            assign
            v-minsum  = credhdbk.minsum
            v-maxsum  = credhdbk.maxsum
            v-minsrok = credhdbk.minsrok
            v-maxsrok = credhdbk.maxsrok
            v-bazst   = credhdbk.bazst
            v-comann  = credhdbk.comann
            v-comdif  = credhdbk.comdif
            v-insur   = credhdbk.insur
            v-pogas[1] = substr(credhdbk.pogas,1,60)
            v-pogas[2] = substr(credhdbk.pogas,61,120)
            v-vidpl   = credhdbk.vidpl
            v-vidob   = credhdbk.vidob
            v-fine[1] = substr(credhdbk.fine,1,60)
            v-fine[2] = substr(credhdbk.fine,61,120)
            v-fine[3] = substr(credhdbk.fine,121,180)
            v-kknom   = credhdbk.kkprot
            v-kkdat   = credhdbk.kkdat.
        end.
        displ v-minsum v-maxsum v-minsrok v-maxsrok v-bazst v-comann v-comdif v-pogas[1] v-pogas[2] v-vidpl v-vidob v-insur v-fine[1] v-fine[2] v-fine[3] v-kknom v-kkdat with frame fsprav.

        pause 0.

        if not v-dmo then do:
            if avail credhdbk and credhdbk.con then do:
                message 'Необходимо снять отметку о контроле!' view-as alert-box.
                return.
            end.
            else if not credhdbk.con then do:
                update v-minsum v-maxsum v-minsrok v-maxsrok v-bazst v-comann v-comdif v-pogas[1] v-pogas[2] v-vidpl v-vidob v-insur v-fine[1] v-fine[2] v-fine[3] v-kknom v-kkdat v-save with frame fsprav.
                if v-save then do:
                    find current credhdbk exclusive-lock no-error.
                    if not avail credhdbk then do:
                        create credhdbk.
                        assign
                        credhdbk.hdbkcod = v-vid
                        credhdbk.hdbkdes = v-vides
                        credhdbk.who     = g-ofc
                        credhdbk.whn     = today
                        credhdbk.tim     = time.
                    end.
                    assign
                    credhdbk.minsum  = v-minsum
                    credhdbk.maxsum  = v-maxsum
                    credhdbk.minsrok = v-minsrok
                    credhdbk.maxsrok = v-maxsrok
                    credhdbk.bazst   = v-bazst
                    credhdbk.comann  = v-comann
                    credhdbk.comdif  = v-comdif
                    credhdbk.insur   = v-insur
                    credhdbk.pogas   = v-pogas[1] + ' ' + v-pogas[2]
                    credhdbk.vidpl   = v-vidpl
                    credhdbk.vidob   = v-vidob
                    credhdbk.fine    = v-fine[1] + ' ' + v-fine[2] + ' ' + v-fine[3]
                    credhdbk.kkprot  = v-kknom
                    credhdbk.kkdat   = v-kkdat.
                    find current credhdbk no-lock no-error.
                    release credhdbk.
                    v-zag = 'Контроль ДМО'.
                    v-str = "Здравствуйте! Вам назначена  задача в АБС iXora в п.м. 3.2.7.3. «Справочник условий» " + v-vides + " Список условий. Бизнес процесс: Экспресс кредит".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                end.
            end.
        end.
        else if v-dmo then update v-cont with frame fsprav.

        else message 'Ваш ID не найден в справочнике. Обратитеть в службу технической поддержки' view-as alert-box.

        if v-cont then do:
            if credhdbk.con then v-act = 'снять'.
            else v-act = 'установить'.
            message ' Вы уверены, что хотите' caps(v-act) 'отметку о контроле? ' view-as alert-box question buttons yes-no title "" update v-ans as logical.
            if v-ans then do:
                find current credhdbk exclusive-lock no-error.
                if credhdbk.con then credhdbk.con = no.
                else credhdbk.con = yes.
                find current credhdbk no-lock no-error.
            end.
            v-zag = 'Контроль ДМО'.
            v-str = "Здравствуйте! П.м. 3.2.7.3. «Справочник условий» " + v-vides + " Список условий успешно отконтролирован. Бизнес процесс: Экспресс кредит".
            if not credhdbk.con then run mail(credhdbk.who + '@fortebank.com',"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
        end.
        if lastkey = keycode("F4") then leave.
    end.

    on choose of but2 in frame f2 do:
        if v-vid = '' then return.
        hide all.
        define query q1 for hdbkcif scrolling.

        define browse b1 query q1
        display hdbkcif.cif     format 'x(6)'       label 'CIF-код'
                hdbkcif.compnam format 'x(25)'      label 'Наименов.'
                hdbkcif.kkprot  format "x(15)"      label '№ протокола'
                hdbkcif.kkdat   format "99.99.9999" label 'Дата проток.'
                hdbkcif.whn     format "99.99.9999" label 'Дата редакт.'
                hdbkcif.con     format 'есть/нет'   label 'Отм. о кон.'
        enable hdbkcif.cif help "Для перемещения используйте CTRL+G CTRL+U" with 10 down width 92
        no-row-markers.

        form v-cif    label " Cif-код компании      " format "x(6)" validate(can-find(first cif where cif.cif = v-cif no-lock) or v-cif = 'OURBNK', 'Неверный код компании!')  help " Допустим поиск компании по нажатию F2 " skip
             v-cifnam label " Наименование компании " format "x(30)" skip
             v-kknomc label " № протокола КК        " format "x(30)" skip
             v-kkdatc label " Дата протокола КК     " format "99.99.9999" skip
        with side-labels centered row 3 title ' Добавление ' width 100 frame fadd.

        define button bt1 label "Добавить запись".
        define button bt2 label "Удалить запись".
        define button bt5 label "Сохранить".
        define button bt3 label "Контроль".
        define button bt4 label "Выход".
        define frame f1
        b1 skip
        bt1
        bt2
        bt5
        bt3
        bt4 with width 95.

        on choose of bt1 do:
            if not v-dmo then do:
                update v-cif v-kknomc v-kkdatc with frame fadd.
                find first cif where cif.cif = v-cif no-lock no-error.
                if avail cif and cif.type <> 'B' then message ' Не является юр.лицом! ' view-as alert-box.
                else if avail cif then v-cifnam = cif.prefix + ' ' + cif.name.
                else v-cifnam = 'АО ForteBank'.

                if can-do('1,2,3,4',v-vid) then v-grp = '1,2,3,4'.
                else v-grp = '5,6,7,8,9'.

                find first hdbkcif where hdbkcif.cif = v-cif and not hdbkcif.del and can-do(v-grp,hdbkcif.hdbkcod) no-lock no-error.
                if avail hdbkcif and v-grp = '1,2,3,4' then
                message 'Компания уже привязана к условиям кредитования' view-as alert-box.

                else if avail hdbkcif and v-grp = '5,6,7,8,9' then
                message 'Компания уже привязана к условиям рефинансирования' view-as alert-box.

                else if not avail hdbkcif then do:
                    create hdbkcif.
                    hdbkcif.cif = v-cif.
                    hdbkcif.hdbkcod = v-vid.
                    hdbkcif.who = g-ofc.
                    hdbkcif.whn = today.
                    hdbkcif.tim = time.
                    hdbkcif.compnam = v-cifnam.
                    hdbkcif.kkprot = v-kknomc.
                    hdbkcif.kkdat  = v-kkdatc.
                end.
                else if hdbkcif.hdbkcod = v-vid then message ' Компания уже привязана к этим условиям! ' view-as alert-box.
                displ v-cifnam with frame fadd.
                open query q1 for each hdbkcif where not hdbkcif.del and hdbkcif.hdbkcod = v-vid.
                b1:refresh().
            end.
            v-zag = 'Контроль ДМО'.
            v-str = "Здравствуйте! Вам назначена  задача в АБС iXora в п.м. 3.2.7.3. «Справочник условий» " + v-vides + " Список компаний. Бизнес процесс: Экспресс кредит".
            find first credhdbk where credhdbk.hdbkcod = v-vid no-lock no-error.
            run mail(credhdbk.who + '@fortebank.com',"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
        end.

        on choose of bt2 do:
            if not v-dmo then do:
                if hdbkcif.con = false then do:
                    find current hdbkcif exclusive-lock no-error.
                    hdbkcif.del = yes.
                    hdbkcif.who = g-ofc.
                    hdbkcif.whn = today.
                    open query q1 for each hdbkcif where not hdbkcif.del and hdbkcif.hdbkcod = v-vid.
                    b1:refresh().
                end.
                else message 'Необходимо снять отметку о контроле!' view-as alert-box.
            end.
        end.

        on choose of bt3 do:
            if v-dmo then do:
                if hdbkcif.con then v-act = 'снять'.
                else v-act = 'установить'.
                message ' Вы уверены, что хотите' caps(v-act) 'отметку о контроле? ' view-as alert-box question buttons yes-no title "" update v-ans as logical.
                if v-ans then do:
                    find current hdbkcif exclusive-lock no-error.
                        if hdbkcif.con then hdbkcif.con = no.
                        else hdbkcif.con = yes.
                    find current hdbkcif no-lock no-error.
                end.
            end.
        end.

        on choose of bt5 do:
            if not v-dmo then do:
                v-zag = 'Контроль ДМО'.
                v-str = "Здравствуйте! Вам назначена  задача в АБС iXora в п.м. 3.2.7.3. «Справочник условий» " + v-vides + " Список компаний. Бизнес процесс: Экспресс кредит".
                run mail(v-maillist + '@fortebank.com',"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
            end.
        end.

        open query q1 for each hdbkcif where not hdbkcif.del and hdbkcif.hdbkcod = v-vid.

        enable all with frame f1.
        on choose of bt4 do:
            hide frame f1.
            enable all with frame f2.
        end.
        wait-for choose of bt4 or window-close of current-window.
    end.
    enable all with frame f2.
    wait-for choose of but3 or window-close of current-window.

end.